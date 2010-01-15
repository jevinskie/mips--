-- this holds common type and record declarations


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


package common is

   constant num_regs : integer := 32;

   subtype byte is unsigned(7 downto 0);
   subtype hword is unsigned(15 downto 0);
   subtype word is unsigned(31 downto 0);
   subtype dword is unsigned(63 downto 0);

   function to_word (
      i_int : integer
   ) return word;
   
   function to_dword (
      i_int : integer
   ) return dword;


   subtype reg_index is integer range 0 to num_regs-1;

   function to_reg_index (
      i_slv : std_logic_vector
   ) return reg_index;


   type alu_op_type is (sll_alu_op, srl_alu_op, add_alu_op, sub_alu_op,
                        and_alu_op, nor_alu_op, or_alu_op, xor_alu_op);

end;

package body common is

   function to_reg_index(
      i_slv : std_logic_vector
   ) return reg_index is
      variable i : integer;
   begin
      i := to_integer(unsigned(i_slv));
      if i >= reg_index'low and i <= reg_index'high then
         return i;
      else
         assert false;
         return 0;
      end if;
   end;

   function to_word (
      i_int : integer
   ) return word is
   begin
      return to_unsigned(i_int, word'length);
   end;

   function to_dword (
      i_int : integer
   ) return dword is
   begin
      return to_unsigned(i_int, dword'length);
   end;

end;

