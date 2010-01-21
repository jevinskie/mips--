-- this is the alu (records style) for the cpu

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


architecture twoproc of alu_r is
begin

   -- combinatiorial process
   comb : process(d)
      variable res : word;
   begin

      -- module algorithm
      case d.op is
         when sll_alu_op =>
            res := d.a sll to_integer(resize(d.b, 5));
         when srl_alu_op =>
            res := d.a srl to_integer(resize(d.b, 5));
         when add_alu_op =>
            res := d.a + d.b;
         when sub_alu_op =>
            res := d.a - d.b;
         when and_alu_op =>
            res := d.a and d.b;
         when nor_alu_op =>
            res := d.a nor d.b;
         when or_alu_op =>
            res := d.a or d.b;
         when xor_alu_op =>
            res := d.a xor d.b;
         when others =>
            res := (others => '0');
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
      if d.op = add_alu_op or d.op = sub_alu_op then
         if (d.a(d.a'high) = d.b(d.b'high)) and res(res'high) /= d.a(d.a'high) then
            q.v <= '1';
         else
            q.v <= '0';
         end if;
      else
         q.v <= '0';
      end if;
   end process;

end;


use work.addsub_pkg.all;
use work.shifter_pkg.all;

architecture add_shift of alu_r is

   signal sl_in, sr_in     : shifter_in_type;
   signal sl_out, sr_out   : shifter_out_type;

   signal addsub_in        : addsub_in_type;
   signal addsub_out       : addsub_out_type;
   signal sub              : std_logic;

begin

   -- left shifter
   sl_b : shifter_r generic map (
      to_the_left => true
   ) port map (
      d => sl_in, q => sl_out
   );

   sl_in.a <= d.a;
   sl_in.b <= d.b(4 downto 0);


   -- right shifter
   sr_b : shifter_r generic map (
      to_the_left => false
   ) port map (
      d => sr_in, q => sr_out
   );

   sr_in.a <= d.a;
   sr_in.b <= d.b(4 downto 0);
  

   -- adder/subtractor
   addsub_b : addsub_r port map (
      d => addsub_in, q => addsub_out
   );

   addsub_in.a <= d.a;
   addsub_in.b <= d.b;
   addsub_in.sub <= '1' when d.op = sub_alu_op else '0';


   -- combinatiorial process
   comb : process(d, sl_out, sr_out, addsub_out)
      variable res : word;
   begin

      -- module algorithm
      case d.op is
         when sll_alu_op =>
            res := sl_out.r;
         when srl_alu_op =>
            res := sr_out.r;
         when add_alu_op =>
            res := addsub_out.r;
         when sub_alu_op =>
            res := addsub_out.r;
         when and_alu_op =>
            res := d.a and d.b;
         when nor_alu_op =>
            res := d.a nor d.b;
         when or_alu_op =>
            res := d.a or d.b;
         when xor_alu_op =>
            res := d.a xor d.b;
         when others =>
            res := (others => '0');
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
      if d.op = add_alu_op or d.op = sub_alu_op then
         q.v <= addsub_out.v;
      else
         q.v <= '0';
      end if;
   end process;

end;

