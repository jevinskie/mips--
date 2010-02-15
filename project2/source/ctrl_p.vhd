-- control package


use work.common.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- component declaration package
package ctrl_pkg is
   
   type ctrl_in_type is record
      j_ins : j_type;
      r_ins : r_type;
      i_ins : i_type;
   end record;

   type ctrl_out_type is record
      reg_dst     : std_logic;
      mem_read    : std_logic;
      reg_src     : reg_src_type;
      mem_write   : std_logic;
      alu_src     : alu_src_type;
      reg_write   : std_logic;
      alu_op      : alu_op_type;
   end record;

   component ctrl_r
      port (
         d : in  ctrl_in_type;
         q : out ctrl_out_type
      );
   end component;

end package;

