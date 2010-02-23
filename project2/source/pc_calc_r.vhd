-- program counter calculation (record style)

use work.common.all;
use work.pc_calc_pkg.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity pc_calc_r is
   port (
      d     : in  pc_calc_in_type;
      q     : out pc_calc_out_type
   );
end;


architecture twoproc of pc_calc_r is
begin


   -- combinatiorial process
   comb : process(d)
   begin
         if d.op = j_op or d.op = jal_op then
            q.pc(27 downto 0) <= d.j_addr & "00";
            q.branch <= '1';
         elsif d.op = special_op and d.func = jr_s_func then
            q.pc <= d.rs;
            q.branch <= '1';
         elsif (d.op = beq_op and d.rs = d.rt) or (d.op = bne_op and d.rs /= d.rt) then
            q.pc <= unsigned(signed(d.pc_inc) + signed(d.imm & "00"));
            q.branch <= '1';
         else
            q.pc <= d.pc_inc;
            q.branch <= '0';
         end if;
   end process;


end;

