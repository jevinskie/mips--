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
   begin
      -- module algorithm

      if d.id_dst /= 0 then
         if d.id_dst = d.ex_dst or d.id_dst = d.mem_dst or d.id_dst = d.wb_dst then
            q.stall <= '1';
         else
            q.stall <= '0';
         end if;
      end if;

   end process;

end;

