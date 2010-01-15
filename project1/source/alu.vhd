-- this is the alu for the cpu


use work.common.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- component declaration package
package alu_comp is
   
   type alu_in_type is record
      a  : word;
      b  : word;
      op : alu_op_type;
   end record;

   type alu_out_type is record
      r : word;
      n : std_logic;
      v : std_logic;
      z : std_logic;
   end record;

   component alu
      port (
         d : in  alu_in_type;
         q : out alu_out_type
      );
   end component;

end package;


use work.common.all;
use work.alu_comp.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity alu is
   port (
      d : in  alu_in_type;
      q : out alu_out_type
   );
end;      

architecture twoproc of alu is
begin

   -- combinatiorial process
   comb : process(d)
   begin
      -- drive module outputs
      case d.op is
         when sll_alu_op =>
            q.r <= d.a sll to_integer(d.b);
         when srl_alu_op =>
            q.r <= d.a srl to_integer(d.b);
         when add_alu_op =>
            q.r <= d.a + d.b;
         when sub_alu_op =>
            q.r <= d.a - d.b;
         when and_alu_op =>
            q.r <= d.a and d.b;
         when nor_alu_op =>
            q.r <= d.a nor d.b;
         when or_alu_op =>
            q.r <= d.a or d.b;
         when xor_alu_op =>
            q.r <= d.a xor d.b;
         when others =>
            assert false;
      end case;
   end process;

end;

