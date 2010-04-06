-- this is the instruction cache package for the cpu


use work.common.all;
use work.dual_pkg.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- component declaration package
package icache_pkg is
   
   type icache_mem_in_type is record
      rdat   : word;
      done  : std_logic;
   end record;

   type icache_cpu_in_type is record
      addr  : address;
      ren   : std_logic;
   end record;

   type icache_in_type is record
      mem : icache_mem_in_type;
      cpu : icache_cpu_in_type;
   end record;

   type icache_mem_out_type is record
      addr : address;
      ren  : std_logic;
   end record;

   type icache_cpu_out_type is record
      rdat : word;
      hit : std_logic;
   end record;

   type icache_out_type is record
      mem : icache_mem_out_type;
      cpu : icache_cpu_out_type;
   end record;

   component icache_r
      port (
         clk   : in  std_logic;
         nrst  : in  std_logic;
         d     : in  icache_in_type;
         q     : out icache_out_type
      );
   end component;

end package;

