-- cpu package


use work.common.all;
use work.icache_pkg.all;
use work.dcache_pkg.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- component declaration package
package cpu_pkg is

   type cpu_in_type is record
      icache   : icache_mem_in_type;
      dcache   : dcache_cc_in_type;
   end record;

   type cpu_out_type is record
      icache   : icache_mem_out_type;
      dcache   : dcache_cc_out_type;
      halt     : std_logic;
   end record;

   component cpu_r
      generic (
         reset_vector : address := (others => '0')
      );
      port (
         clk   : in std_logic;
         nrst  : in std_logic;
         d     : in  cpu_in_type;
         q     : out cpu_out_type
      );
   end component;

end package;

