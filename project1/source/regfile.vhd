-- this is the register file for the cpu


use work.common.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- component declaration package
package regfile_comp is
   
   type regfile_in_type is record
      wen   : std_logic;
      wsel  : reg_index;
      wdat  : word;
      rsel1 : reg_index;
      rsel2 : reg_index;
   end record;

   type regfile_out_type is record
      rdat1 : word;
      rdat2 : word;
   end record;

   component regfile
      port (
         clk   : in  std_logic;
         nrst  : in  std_logic;
         d     : in  regfile_in_type;
         q     : out regfile_out_type
      );
   end component;

end package;


use work.common.all;
use work.regfile_comp.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity regfile is
   port (
      clk   : in  std_logic;
      nrst  : in  std_logic;
      d     : in  regfile_in_type;
      q     : out regfile_out_type
   );
end;      

architecture twoproc of regfile is

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

      for i in en_mask'range loop
         if en_mask(i) = '1' then
            v.registers(i) := d.wdat;
         end if;
      end loop;

      -- drive the register inputs
      rin <= v;

      -- drive module outputs
      if d.rsel1 = 0 then
         q.rdat1 <= (others => '0');
      else
         q.rdat1 <= r.registers(d.rsel1);
      end if;

      if d.rsel2 = 0 then
         q.rdat2 <= (others => '0');
      else
         q.rdat2 <= r.registers(d.rsel2);
      end if;
   end process;


   regs : process(clk, nrst)
   begin
      if nrst = '0' then
         for i in r.registers'range loop
            r.registers(i) <= (others => '0');
         end loop;
      elsif rising_edge(clk) then
         r <= rin;
      end if;
   end process;

end;

