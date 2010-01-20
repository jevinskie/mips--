-- this is the register file (records style) for the cpu

use work.common.all;
use work.regfile_pkg.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity regfile_r is
   port (
      clk   : in  std_logic;
      nrst  : in  std_logic;
      d     : in  regfile_in_type;
      q     : out regfile_out_type
   );
end;      

architecture twoproc of regfile_r is

   type registers_type is array (reg_index'high downto 1) of word;

   type reg_type is record
      registers : registers_type;
   end record;

   signal r, rin : reg_type;

begin

   -- combinatiorial process
   comb : process(d, r)
      variable v        : reg_type;
      variable en_mask  : std_logic_vector(reg_index'high downto 1);
   begin
      -- default assignment
      v := r;


      -- module algorithm
      
      -- generate the enable mask
      en_mask := (others => '0');
      if d.wen = '1' and d.wsel /= 0 then
         en_mask(d.wsel) := '1';
      end if;

      -- write out the registers according to the enable mask
      for i in en_mask'range loop
         if en_mask(i) = '1' then
            v.registers(i) := d.wdat;
         end if;
      end loop;

      -- drive the register inputs
      rin <= v;

      -- drive module outputs

      -- output rdat1
      if d.rsel1 = 0 then
         q.rdat1 <= (others => '0');
      else
         q.rdat1 <= r.registers(d.rsel1);
      end if;

      -- output rdat2
      if d.rsel2 = 0 then
         q.rdat2 <= (others => '0');
      else
         q.rdat2 <= r.registers(d.rsel2);
      end if;

   end process;


   -- the register process
   regs : process(clk, nrst)
   begin
      if nrst = '0' then
         -- reset registers to zero
         for i in r.registers'range loop
            r.registers(i) <= (others => '0');
         end loop;
      elsif rising_edge(clk) then
         r <= rin;
      end if;
   end process;

end;

