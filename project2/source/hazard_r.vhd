-- hazard detection block (record style)

use work.common.all;
use work.hazard_pkg.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity hazard_r is
   port (
      d     : in  hazard_in_type;
      q     : out hazard_out_type
   );
end;


architecture twoproc of hazard_r is
begin
   
   
   -- combinatiorial process
   comb : process(d)
      variable t : reg_index;
   begin
      -- module algorithm

      q.stall <= '0';

      case d.r_ins.op is
         when special_op =>
            t := d.r_ins.rt;
            if t /= 0 then
               if t = d.ex_dst or t = d.mem_dst or t = d.wb_dst then
                  q.stall <= '1';
               end if;
            end if;
            t := d.r_ins.rs;
            if t /= 0 then
               if t = d.ex_dst or t = d.mem_dst or t = d.wb_dst then
                  q.stall <= '1';
               end if;
            end if;
         when others =>
            t := d.r_ins.rs;
            if t /= 0 then
               if t = d.ex_dst or t = d.mem_dst or t = d.wb_dst then
                  q.stall <= '1';
               end if;
            end if;
      end case;

   end process;

end;

