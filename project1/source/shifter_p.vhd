-- barrel shifter block package for the alu


use work.common.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- component declaration package
package shifter_pkg is
   
   type shifter_in_type is record
      a     : word;
      b     : unsigned(4 downto 0);
   end record;

   type shifter_out_type is record
      r : word;
   end record;

   component shifter_r
      generic (
         to_the_left : boolean := true
      );
      port (
         d : in  shifter_in_type;
         q : out shifter_out_type
      );
   end component;

end package;

