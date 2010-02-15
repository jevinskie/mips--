-- cpu package


use work.common.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- component declaration package
package cpu_pkg is

   type cpu_in_type is record
      dump_addr   : dump_address;
   end record;

   type cpu_out_type is record
      halt        : std_logic;
      imem_addr   : address;
      imem_dat    : word;
      dmem_addr   : address;
      dmem_rdat   : word;
      dmem_wdat   : word;
   end record;

   component cpu_r
      port (
         clk   : in std_logic;
         nrst  : in std_logic;
         d     : in  cpu_in_type;
         q     : out cpu_out_type
      );
   end component;

end package;

