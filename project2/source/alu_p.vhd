-- this is the alu package for the cpu


use work.common.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- component declaration package
package alu_pkg is
   
   type alu_in_type is record
      a  : word;
      b  : word;
      op : alu_op_type;
   end record;

   type alu_out_type is record
      r : word;
      n : std_logic;
      v : std_logic;
      z : std_logic;
   end record;

   component alu_r
      port (
         d : in  alu_in_type;
         q : out alu_out_type
      );
   end component;

end package;

