-- dual core cpu package


use work.common.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- component declaration package
package dual_pkg is

   type dual_in_type is record
      dump_addr   : dump_address;
   end record;

   -- please note that these are poorly named now
   type dual_out_type is record
      halt        : std_logic;
      imem_addr   : address;
      imem_dat    : word;
      dmem_addr   : address;
      dmem_rdat   : word;
      dmem_wdat   : word;
   end record;

   component dual_r
      port (
         clk   : in std_logic;
         nrst  : in std_logic;
         d     : in  dual_in_type;
         q     : out dual_out_type
      );
   end component;

end package;

