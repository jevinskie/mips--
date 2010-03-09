-- this holds common type and record declarations used only in testbench code


use work.common.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


package common_tb is

   constant clk_per : time := 37 ns;

   type prng_state is record
      x : dword;
   end record;

   procedure tick (
      signal clk  : in std_logic;
      constant n  : in integer
   );

   procedure prng_init (
      variable state : out prng_state;
      constant seed  : in dword
   );

   procedure prng_gen (
      variable state : inout prng_state;
      variable rand  : out word
   );

end;

package body common_tb is

   procedure tick (
      signal clk  : in std_logic;
      constant n  : in integer
   ) is
   begin
      wait for clk_per*(n-1) + clk_per/2;
      wait until falling_edge(clk);
   end;

   procedure prng_init (
      variable state : out prng_state;
      constant seed  : in dword
   ) is
   begin
      state.x := seed;
   end;

   procedure prng_gen (
      variable state : inout prng_state;
      variable rand  : out word
   ) is
   begin
      state.x := state.x xor (state.x sll 21);
      state.x := state.x xor (state.x srl 35);
      state.x := state.x xor (state.x sll 4);

      rand := state.x(63 downto 32) xor state.x(31 downto 0);
   end;

end;

