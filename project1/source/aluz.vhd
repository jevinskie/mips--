-- this is the alu for the cpu


use work.common.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- component declaration package
package aluz_comp is
   
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

   component aluz
      port (
         d : in  alu_in_type;
         q : out alu_out_type
      );
   end component;

end package;


use work.common.all;
use work.aluz_comp.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity aluz is
   port (
      d : in  alu_in_type;
      q : out alu_out_type
   );
end;      

architecture twoproc of aluz is
begin

   -- combinatiorial process
   comb : process(d)
      variable res : word;
      variable big_res : unsigned(res'high+1 downto 0);
   begin

      -- clear out the extended result
      big_res := (others => '0');

      -- module algorithm
      case d.op is
         when sll_alu_op =>
            res := d.a sll to_integer(resize(d.b, 5));
         when srl_alu_op =>
            res := d.a srl to_integer(resize(d.b, 5));
         when add_alu_op =>
            -- sign extend and then perform the op
            big_res := (d.a(d.a'high) & d.a) + d.b;
            -- tear out the 32 LSBs
            res := big_res(res'high downto 0);
         when sub_alu_op =>
            -- same as with the add op
            big_res := (d.a(d.a'high) & d.a) - d.b;
            res := big_res(res'high downto 0);
         when and_alu_op =>
            res := d.a and d.b;
         when nor_alu_op =>
            res := d.a nor d.b;
         when or_alu_op =>
            res := d.a or d.b;
         when xor_alu_op =>
            res := d.a xor d.b;
         when others =>
            assert false;
      end case;

      -- drive module outputs

      -- drive the result output
      q.r <= res;

      --drive the flags
      
      -- zero
      if res = (res'range => '0') then
         q.z <= '1';
      else
         q.z <= '0';
      end if;

      -- negative
      q.n <= res(res'high);

      -- overflow
      if big_res(big_res'high) /= big_res(big_res'high-1) then
         q.v <= '1';
      else
         q.v <= '0';
      end if;
   end process;

end;

