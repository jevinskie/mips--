-- program counter (record style)

use work.common.all;
use work.pc_pkg.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity pc_r is
   port (
      clk   : in std_logic;
      nrst  : in std_logic;
      d     : in  pc_in_type;
      q     : out pc_out_type
   );
end;


architecture twoproc of pc_r is

   type reg_type is record
      pc : address;
   end record;

   signal r, rin : reg_type;

begin
   
   
   -- combinatiorial process
   comb : process(d, r)
      variable v : reg_type;
   begin
      -- default assignment
      v := r;


      -- module algorithm
      
      if d.we = '1' then
         v.pc := v.pc + 4;
         
         -- pc is always incremented before the other addressing operations are performed

         if d.op = j_op or d.op = jal_op then
            v.pc(27 downto 0) := d.j_addr & "00";
         elsif d.op = special_op and d.func = jr_s_func then
            v.pc := d.r_addr;
         elsif (d.op = beq_op and d.z = '1') or (d.op = bne_op and d.z = '0') then
            v.pc := unsigned(signed(v.pc) + signed(d.imm & "00"));
         else
            -- invalid but might be due to 'X's and 'U's so don't assert
         end if;
      else
         -- do nothing, PC is halted
      end if;

      -- drive the register inputs
      rin <= v;

      -- drive module outputs
      q.pc <= r.pc;

   end process;

   -- register process
   regs : process(clk, nrst)
   begin
      if nrst = '0' then
         r.pc <= (others => '0');
      elsif rising_edge(clk) then
         r <= rin;
      end if;
   end process;

end;

