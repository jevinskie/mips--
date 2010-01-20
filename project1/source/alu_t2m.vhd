-- a wrapper for the alu course component

use work.common.all;
use work.alu_pkg.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity alu_r is
   port (
      d : in  alu_in_type;
      q : out alu_out_type
   );
end;      

architecture wrapper of alu_r is

   component alu
      port (
         OPCODE: in std_logic_vector(2 downto 0);
         A, B: in std_logic_vector(31 downto 0);
         OUTPUT: out std_logic_vector(31 downto 0);
         NEGATIVE, OVERFLOW, ZERO: out std_logic
      );
   end component;

   signal r : word_slv;

begin

   alu_b : alu port map (
      OPCODE => to_slv(d.op), A => std_logic_vector(d.a), B => std_logic_vector(d.b),
      OUTPUT => r,
      NEGATIVE => q.n, OVERFLOW => q.v, ZERO => q.z
   );

   q.r <= unsigned(r);

end;

