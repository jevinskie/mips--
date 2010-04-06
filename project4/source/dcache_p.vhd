-- this is the data cache package for the cpu


use work.common.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- component declaration package
package dcache_pkg is
   
   type dcache_cc_in_type is record
      rdat  : word;
      done  : std_logic;
   end record;

   type dcache_cpu_in_type is record
      addr  : address;
      wdat  : word;
      ren   : std_logic;
      wen   : std_logic;
      halt  : std_logic;
   end record;

   type dcache_in_type is record
      cc    : dcache_cc_in_type;
      cpu   : dcache_cpu_in_type;
   end record;

   type dcache_cc_out_type is record
      addr  : address;
      wdat  : word;
      ren   : std_logic;
      wen   : std_logic;
   end record;

   type dcache_cpu_out_type is record
      rdat  : word;
      hit   : std_logic;
      halt  : std_logic;
   end record;

   type dcache_out_type is record
      cc    : dcache_cc_out_type;
      cpu   : dcache_cpu_out_type;
   end record;

   component dcache_r
      port (
         clk   : in  std_logic;
         nrst  : in  std_logic;
         d     : in  dcache_in_type;
         q     : out dcache_out_type
      );
   end component;

end package;

