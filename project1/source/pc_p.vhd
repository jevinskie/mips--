-- program counter package


use work.common.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- component declaration package
package pc_pkg is
   
   type pc_in_type is record
      imm      : immediate;
      j_addr   : j_address;
      z        : std_logic;
      op       : op_type;
      halt     : std_logic;
   end record;

   type pc_out_type is record
      pc : address;
   end record;

   component pc_r
      port (
         clk   : in std_logic;
         nrst  : in std_logic;
         d     : in  pc_in_type;
         q     : out pc_out_type
      );
   end component;

end package;

