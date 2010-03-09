-- this is the register file package for the cpu


use work.common.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- component declaration package
package regfile_pkg is
   
   type regfile_in_type is record
      wen   : std_logic;
      wsel  : reg_index;
      wdat  : word;
      rsel1 : reg_index;
      rsel2 : reg_index;
   end record;

   type regfile_out_type is record
      rdat1 : word;
      rdat2 : word;
   end record;

   component regfile_r
      port (
         clk   : in  std_logic;
         nrst  : in  std_logic;
         d     : in  regfile_in_type;
         q     : out regfile_out_type
      );
   end component;

end package;

