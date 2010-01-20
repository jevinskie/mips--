-- barrel shifter block (record style) for the alu

use work.common.all;
use work.shifter_pkg.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity shifter_r is
   generic (
      to_the_left : boolean := true
   );
   port (
      d : in  shifter_in_type;
      q : out shifter_out_type
   );
end;


architecture dataflow of shifter_r is

   type staged_sig_type is array (5 downto 0) of word;

   signal staged : staged_sig_type;

   function zero_fill_left (
      i : unsigned;
      n : positive
   ) return unsigned is
      variable r : unsigned(n-1 downto 0);
   begin
      r := (others => '0');
      r(i'length-1 downto 0) := i;
      
      return r;
   end;

   function zero_fill_right (
      i : unsigned;
      n : positive
   ) return unsigned is
      variable r : unsigned(n-1 downto 0);
   begin
      r := (others => '0');
      r(n-1 downto n-i'length) := i;
      
      return r;
   end;

begin

   staged(0) <= d.a;

   single_shift :
   for i in 1 to 4 generate
      staged(i) <= staged(i-1) when d.b(i-1) = '0' else
                   zero_fill_right(staged(i-1)(word'length-1-binpow(i-1) downto 0), word'length) when to_the_left else
                   zero_fill_left(staged(i-1)(word'length-1 downto binpow(i-1)), word'length);
   end generate single_shift;

   q.r <= staged(4);

   --q.r <= zero_fill_right(d.a(3 downto 0), 32);

end;

