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

   subtype nibble_slv   is std_logic_vector(nibble'range);
   subtype byte_slv     is std_logic_vector(byte'range);
   subtype hword_slv    is std_logic_vector(hword'range);
   subtype word_slv     is std_logic_vector(word'range);
   subtype dword_slv    is std_logic_vector(dword'range);

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


   function binlog (
      i : positive
   ) return natural;

   function binpow (
      i : natural
   ) return natural;


  function zero_fill_left (
      i           : unsigned;
      bit_width   : positive
   ) return unsigned;
   
   function zero_fill_right (
      i           : unsigned;
      bit_width   : positive
   ) return unsigned;


   function calc_overflow (
      a     : unsigned;
      b     : unsigned;
      r     : unsigned;
      sub   : std_logic
   ) return std_logic;

end;

package body common is


   function to_word (
      i_int : integer
   ) return word is
   begin
      if i_int < 0 then
         return unsigned(to_signed(i_int, word'length));
      else
         return to_unsigned(i_int, word'length);
      end if;
   end;

   function to_dword (
      i_int : integer
   ) return dword is
   begin
      if i_int < 0 then
         return unsigned(to_signed(i_int, dword'length));
      else
         return to_unsigned(i_int, dword'length);
      end if;
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


   function binlog (
      i : positive
   ) return natural is
      variable tmp : natural := i;
      variable log : natural := 0;
   begin
      while (tmp > 0) loop
         tmp := tmp / 2;
         log := log + 1;
      end loop;

      return log;
   end;


   function binpow (
      i : natural
   ) return natural is
      variable tmp : natural := i;
      variable pow : natural := 1;
   begin
      while (tmp > 0) loop
         tmp := tmp - 1;
         pow := pow * 2;
      end loop;

      return pow;
   end;


   -- this function zero fills (to the left)
   -- the passed number to the specified bit width
   function zero_fill_left (
      i           : unsigned;
      bit_width   : positive
   ) return unsigned is
      variable r : unsigned(bit_width-1 downto 0);
   begin
      r := (others => '0');
      r(i'length-1 downto 0) := i;
      
      return r;
   end;

   -- this function zero fills (to the right)
   -- the passed number to the specified bit width
   function zero_fill_right (
      i           : unsigned;
      bit_width   : positive
   ) return unsigned is
      variable r : unsigned(bit_width-1 downto 0);
   begin
      r := (others => '0');
      r(bit_width-1 downto bit_width-i'length) := i;
      
      return r;
   end;


   function calc_overflow (
      a     : unsigned;
      b     : unsigned;
      r     : unsigned;
      sub   : std_logic
   ) return std_logic is
      variable v : std_logic;
   begin
      assert (a'length = b'length) and (a'length = r'length);


      -- the overflow logic
      
      if sub = '0' then
         -- addition
         -- same sign in and opposite sign result -> overflow
         if (a(a'high) = b(b'high)) and (a(a'high) /= r(r'high)) then
            v := '1';
         else
            v := '0';
         end if;
      else
         -- subtraction
         -- if the operands have differing signs and the result is
         -- the opposite sign of the subtrahend, overflow occured
         if (a(a'high) /= b(b'high)) and (b(b'high) = r(r'high)) then
            v := '1';
         else
            v := '0';
         end if;
      end if;

      return v;
   end;

end;

