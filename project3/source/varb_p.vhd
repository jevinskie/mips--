-- this is the virtual arbiter package


use work.common.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- component declaration package
package varb_pkg is
   
   type varb_out_type is record
      rdat  : word;
      done  : std_logic;
      -- need mem state?
   end record;

   type varb_in_type is record
      addr  : address;
      wdat  : word;
      ren   : std_logic;
      wen   : std_logic;
   end record;

   component varb_r
      port (
         clk   : in  std_logic;
         nrst  : in  std_logic;
         d     : in  varb_in_type;
         q     : out varb_out_type
      );
   end component;

end package;

