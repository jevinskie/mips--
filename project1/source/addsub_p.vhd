-- adder/subtractor block package for the alu


use work.common.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- component declaration package
package addsub_pkg is
   
   type addsub_in_type is record
      a     : word;
      b     : word;
      sub   : std_logic;
   end record;

   type addsub_out_type is record
      r : word;
      v : std_logic;
   end record;

   component addsub_r
      port (
         d : in  addsub_in_type;
         q : out addsub_out_type
      );
   end component;

end package;

