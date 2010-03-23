-- this is the data cache for the cpu

use work.common.all;
use work.dcache_pkg.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity dcache_r is
   port (
      clk   : in  std_logic;
      nrst  : in  std_logic;
      d     : in  dcache_in_type;
      q     : out dcache_out_type
   );
end;      

architecture twoproc of dcache_r is

   type block_type is record
      v     : std_logic;
      tag   : unsigned(31 downto 6);
      data  : word;
   end record;

   type block_array_type is array (15 downto 0) of block_type;

   signal r, rin : block_array_type;

begin

   -- combinatiorial process
   comb : process(d, r)
      variable v           : block_array_type;
      variable index       : integer;
      variable wanted_tag  : unsigned(31 downto 6);
      variable hit         : std_logic;
   begin
      -- default assignment
      v := r;

      -- module algorithm
      index := to_integer(unsigned(d.cpu.addr(5 downto 2)));
      wanted_tag := d.cpu.addr(31 downto 6);

      if wanted_tag = v(index).tag and v(index).v = '1' then
         hit := '1';
      else
         hit := '0';
      end if;


      if d.cpu.ren = '1' and hit = '0' then
         v(index).v := '1';
         v(index).tag := wanted_tag;
         v(index).data := d.mem.dat;
      end if;
      
      -- drive the register inputs
      rin <= v;

      -- drive module outputs
      q.cpu.hit <= hit;
      q.cpu.dat <= v(index).data;
   end process;

   q.mem.addr <= d.cpu.addr;

   -- the register process
   regs : process(clk, nrst)
   begin
      if nrst = '0' then
         for i in r'range loop
            r(i).v <= '0';
            r(i).tag <= (others => '0');
            r(i).data <= (others => '0');
         end loop;
      elsif rising_edge(clk) then
         r <= rin;
      end if;
   end process;

end;

