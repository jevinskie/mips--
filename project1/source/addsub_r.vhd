-- adder/subtractor block (record style) for the alu

use work.common.all;
use work.addsub_pkg.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity addsub_r is
   port (
      d : in  addsub_in_type;
      q : out addsub_out_type
   );
end;


architecture ripple of addsub_r is
   signal c    : std_logic_vector(word'length downto 0);
   signal bn   : word;
   signal r    : word;
begin

   bn <= not d.b when d.sub = '1' else d.b;

   c(0) <= '1' when d.sub = '1' else '0';

   full_adders :
   for i in word'range generate
      r(i) <= (d.a(i) xor bn(i)) xor c(i);
      c(i+1) <= (d.a(i) and bn(i)) or (c(i) and (d.a(i) xor bn(i)));
   end generate;

   q.r <= r;

   q.v <= '1' when (d.a(d.a'high) = d.b(d.b'high)) and (r(r'high) /= d.a(d.a'high)) else '0';

end;

