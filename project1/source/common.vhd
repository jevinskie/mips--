-- this holds common type and record declarations


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


package common is

   constant num_regs : integer := 32;


   subtype nibble is unsigned(3 downto 0);
   subtype byte   is unsigned(7 downto 0);
   subtype hword  is unsigned(15 downto 0);
   subtype word   is unsigned(31 downto 0);
   subtype dword  is unsigned(63 downto 0);

   subtype nibble_slv   is std_logic_vector(3 downto 0);
   subtype byte_slv     is std_logic_vector(7 downto 0);
   subtype hword_slv    is std_logic_vector(15 downto 0);
   subtype word_slv     is std_logic_vector(31 downto 0);
   subtype dword_slv    is std_logic_vector(63 downto 0);

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

   function to_slv (
      i_type : reg_index
   ) return std_logic_vector;


   type alu_op_type is (sll_alu_op, srl_alu_op, add_alu_op, sub_alu_op,
                        and_alu_op, nor_alu_op, or_alu_op, xor_alu_op);

   type alu_op_enc_lut_array is array(alu_op_type) of std_logic_vector(2 downto 0);

   constant alu_op_enc_lut : alu_op_enc_lut_array := (
      sll_alu_op => "000",
      srl_alu_op => "001",
      add_alu_op => "010",
      sub_alu_op => "011",
      and_alu_op => "100",
      nor_alu_op => "101",
      or_alu_op  => "110",
      xor_alu_op => "111"
   );

   function to_slv (
      op_type : alu_op_type
   ) return std_logic_vector;

   function to_alu_op (
      op_slv : std_logic_vector
   ) return alu_op_type;

end;

package body common is


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


   function to_reg_index(
      i_slv : std_logic_vector
   ) return reg_index is
      variable i : integer;
   begin
      i := to_integer(unsigned(i_slv));
      if i >= reg_index'low and i <= reg_index'high then
         return i;
      else
         --assert false;
         return 0;
      end if;
   end;

   function to_slv(
      i_type : reg_index
   ) return std_logic_vector is
   begin
      return std_logic_vector(to_unsigned(i_type, 5));
   end;


   function to_slv (
      op_type : alu_op_type
   ) return std_logic_vector is
   begin
      return alu_op_enc_lut(op_type);
   end;

   function to_alu_op (
      op_slv : std_logic_vector
   ) return alu_op_type is
   begin
      for op in alu_op_type loop
         if op_slv = alu_op_enc_lut(op) then
            return op;
         end if;
      end loop;

      --assert false;
      return sll_alu_op;
   end;


end;

