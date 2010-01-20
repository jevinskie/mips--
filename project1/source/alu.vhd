-- a wrapper for the alu course component

use work.common.all;
use work.alu_pkg.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
    port( OPCODE: in std_logic_vector(2 downto 0);
          A, B: in std_logic_vector(31 downto 0);
          OUTPUT: out std_logic_vector(31 downto 0);
          NEGATIVE, OVERFLOW, ZERO: out std_logic );
end;

architecture wrapper of alu is

   signal alu_in  : alu_in_type;
   signal alu_out : alu_out_type;

begin

   alu_b : alu_r port map (
      d => alu_in, q => alu_out
   );

   alu_in.a <= unsigned(A);
   alu_in.b <= unsigned(B);
   alu_in.op <= to_alu_op(OPCODE);

   OUTPUT   <= std_logic_vector(alu_out.r);
   NEGATIVE <= alu_out.n;
   OVERFLOW <= alu_out.v;
   ZERO     <= alu_out.z;

end;

