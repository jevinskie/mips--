-- this is the memory arbiter package for the system


use work.common.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- component declaration package
package arb_pkg is
   
   type arb_mem_in_type is record
      rdat  : word;
      state : mem_state_type;
   end record;

   type arb_cc_in_type is record
      addr  : address;
      wdat  : word;
      wen   : std_logic;
      ren   : std_logic;
   end record;

   type arb_icache_in_type is record
      addr  : address;
      ren   : std_logic;
   end record;

   type arb_in_type is record
      mem      : arb_mem_in_type;
      cc       : arb_cc_in_type;
      icache0  : arb_icache_in_type;
      icache1  : arb_icache_in_type;
   end record;

   type arb_mem_out_type is record
      addr  : address;
      wdat  : word;
      ren   : std_logic;
      wen   : std_logic;
   end record;

   type arb_cc_out_type is record
      rdat  : word;
      done  : std_logic;
   end record;

   alias arb_icache_out_type is arb_cc_out_type;

   type arb_out_type is record
      mem      : arb_mem_out_type;
      cc       : arb_cc_out_type;
      icache0  : arb_icache_out_type;
      icache1  : arb_icache_out_type;
   end record;

   component arb_r
      port (
         clk   : in  std_logic;
         nrst  : in  std_logic;
         d     : in  arb_in_type;
         q     : out arb_out_type
      );
   end component;

end package;

