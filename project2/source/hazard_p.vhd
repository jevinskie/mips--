-- hazard detection package


use work.common.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- component declaration package
package hazard_pkg is
   
   type hazard_in_type is record
      id_dst   : reg_index;
      ex_dst   : reg_index;
      mem_dst  : reg_index;
      wb_dst   : reg_index;
   end record;

   type hazard_out_type is record
      stall : std_logic;
   end record;

   component hazard_r
      port (
         d     : in  hazard_in_type;
         q     : out hazard_out_type
      );
   end component;

end package;

