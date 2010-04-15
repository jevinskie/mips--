-- this is the coherency controller package for the system


use work.common.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- component declaration package
package cc_pkg is
   
   type cc_mem_in_type is record
      rdat     : word;
      done     : std_logic;
   end record;

   type cc_dcache_in_type is record
      addr     : address;
      wdat     : word;
      ren      : std_logic;
      rxen     : std_logic;
      wen      : std_logic;
      flush    : std_logic;
   end record;

   type cc_in_type is record
      mem      : cc_mem_in_type;
      dcache0  : cc_dcache_in_type;
      dcache1  : cc_dcache_in_type;
   end record;

   type cc_mem_out_type is record
      addr     : address;
      wdat     : word;
      ren      : std_logic;
      wen      : std_logic;
   end record;

   type cc_dcache_out_type is record
      rdat     : word;
      done     : std_logic;
      snp_addr : address;
      snp_ren  : std_logic;
      snp_rxen : std_logic;
      snp_wen  : std_logic;
   end record;

   type cc_out_type is record
      mem      : cc_mem_out_type;
      dcache0  : cc_dcache_out_type;
      dcache1  : cc_dcache_out_type;
      new_req  : std_logic;
   end record;

   component cc_r
      port (
         clk   : in  std_logic;
         nrst  : in  std_logic;
         d     : in  cc_in_type;
         q     : out cc_out_type
      );
   end component;

end package;

