-- control block

use work.common.all;
use work.ctrl_pkg.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity ctrl_r is
   port (
      d : in  ctrl_in_type;
      q : out ctrl_out_type
   );
end;


architecture twoproc of ctrl_r is

begin
   
   
   -- combinatiorial process
   comb : process(d)
   begin
      -- module algorithm

      q.reg_dst      <= '0';
      q.jump         <= '0';
      q.branch       <= '0';
      q.mem_read     <= '0';
      q.mem_to_reg   <= '0';
      q.mem_write    <= '0';
      q.alu_src      <= '0';
      q.reg_write    <= '0';

      case d.op is
         when special_op =>
            q.reg_write <= '1';
         when 


   end process;

end;

