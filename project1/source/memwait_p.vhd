-- memory wait state package


use work.common.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- component declaration package
package memwait_pkg is
   
   type memwait_in_type is record
      op : op_type;
   end record;

   type memwait_out_type is record
      memwait : std_logic;
   end record;

   component memwait_r
      port (
         clk   : in std_logic;
         nrst  : in std_logic;
         d     : in  memwait_in_type;
         q     : out memwait_out_type
      );
   end component;

end package;

