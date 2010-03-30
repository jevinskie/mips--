-- program counter calculation package


use work.common.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- component declaration package
package pc_calc_pkg is
   
   type pc_calc_in_type is record
      imm      : immediate;
      j_addr   : j_address;
      op       : op_type;
      rs       : word;
      rt       : word;
      func     : s_func_type; 
      pc_inc   : address;
   end record;

   type pc_calc_out_type is record
      pc       : address;
      branch   : std_logic;
   end record;

   component pc_calc_r
      port (
         d     : in  pc_calc_in_type;
         q     : out pc_calc_out_type
      );
   end component;

end package;

