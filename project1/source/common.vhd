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

   function to_nibble (
      i_int : integer
   ) return nibble;

   function to_byte (
      i_int : integer
   ) return byte;
   
   function to_hword (
      i_int : integer
   ) return hword;

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


   subtype j_address is unsigned(25 downto 0);
   subtype address is word;
   subtype immediate is hword;
   subtype shift_amount is integer range 0 to 31;

   function to_j_address (
      i_int : integer
   ) return j_address;


   type alu_op_type is (
      sll_alu_op, srl_alu_op, add_alu_op, sub_alu_op,
      and_alu_op, nor_alu_op, or_alu_op, xor_alu_op,
      slt_alu_op, sltu_alu_op
   );


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

   
   type op_type is (
      special_op, regimm_op, j_op, jal_op,
      beq_op, bne_op, blez_op, bgtz_op,
      addi_op, addiu_op, slti_op, sltiu_op,
      andi_op, ori_op, xori_op, lui_op,
      cop0_op, cop1_op, cop2_op, cop1x_op,
      beql_op, bnel_op, blezl_op, bgtzl_op,
      special2_op, jalx_op, special3_op,
      lb_op, lh_op, lwl_op, lw_op, lbu_op,
      lhu_op, lwr_op, sb_op, sh_op, swl_op,
      sw_op, swr_op, cache_op, ll_op, lwc1_op,
      lwc2_op, pref_op, ldc1_op, ldc2_op,
      sc_op, swc1_op, swc2_op, sdc1_op, sdc2_op,
      halt_op, unimp_op
   );

   type op_enc_lut_array is array(op_type) of std_logic_vector(5 downto 0);

   constant op_enc_lut : op_enc_lut_array := (
      special_op  => "000000",
      regimm_op   => "000001",
      j_op        => "000010",
      jal_op      => "000011",
      beq_op      => "000100",
      bne_op      => "000101",
      blez_op     => "000110",
      bgtz_op     => "000111",
      addi_op     => "001000",
      addiu_op    => "001001",
      slti_op     => "001010",
      sltiu_op    => "001011",
      andi_op     => "001100",
      ori_op      => "001101",
      xori_op     => "001110",
      lui_op      => "001111",
      cop0_op     => "010000",
      cop1_op     => "010001",
      cop2_op     => "010010",
      cop1x_op    => "010011",
      beql_op     => "010100",
      bnel_op     => "010101",
      blezl_op    => "010110",
      bgtzl_op    => "010111",
      special2_op => "011100",
      jalx_op     => "011101",
      special3_op => "011111",
      lb_op       => "100000",
      lh_op       => "100001",
      lwl_op      => "100010",
      lw_op       => "100011",
      lbu_op      => "100100",
      lhu_op      => "100101",
      lwr_op      => "100110",
      sb_op       => "101000",
      sh_op       => "101001",
      swl_op      => "101010",
      sw_op       => "101011",
      swr_op      => "101110",
      cache_op    => "101111",
      ll_op       => "110000",
      lwc1_op     => "110001",
      lwc2_op     => "110010",
      pref_op     => "110011",
      ldc1_op     => "110101",
      ldc2_op     => "110110",
      sc_op       => "111000",
      swc1_op     => "111001",
      swc2_op     => "111010",
      sdc1_op     => "111101",
      sdc2_op     => "111110",
      halt_op     => "111111",
      unimp_op    => "UUUUUU"
   );

   function to_slv (
      op : op_type
   ) return std_logic_vector;

   function to_op (
      op_slv : std_logic_vector
   ) return op_type;


   type s_func_type is (
      sll_s_func, movci_s_func, srl_s_func, sra_s_func,
      sllv_s_func, srlv_s_func, srav_s_func, jr_s_func,
      jalr_s_func, movz_s_func, movn_s_func, syscall_s_func,
      break_s_func, sync_s_func, mfhi_s_func, mthi_s_func,
      mflo_s_func, mtlo_s_func, mult_s_func, multu_s_func,
      div_s_func, divu_s_func, add_s_func, addu_s_func,
      sub_s_func, subu_s_func, and_s_func, or_s_func,
      xor_s_func, nor_s_func, slt_s_func, sltu_s_func,
      tge_s_func, tgeu_s_func, tlt_s_func, tltu_s_func,
      teq_s_func, tne_s_func, unimp_s_func
   );

   type special_func_enc_lut_array is array(s_func_type) of std_logic_vector(5 downto 0);

   constant special_func_enc_lut : special_func_enc_lut_array := (
      sll_s_func       => "000000",
      movci_s_func     => "000001",
      srl_s_func       => "000010",
      sra_s_func       => "000011",
      sllv_s_func      => "000100",
      srlv_s_func      => "000110",
      srav_s_func      => "000111",
      jr_s_func        => "001000",
      jalr_s_func      => "001001",
      movz_s_func      => "001010",
      movn_s_func      => "001011",
      syscall_s_func   => "001100",
      break_s_func     => "001101",
      sync_s_func      => "001111",
      mfhi_s_func      => "010000",
      mthi_s_func      => "010001",
      mflo_s_func      => "010010",
      mtlo_s_func      => "010011",
      mult_s_func      => "011000",
      multu_s_func     => "011001",
      div_s_func       => "011010",
      divu_s_func      => "011011",
      add_s_func       => "100000",
      addu_s_func      => "100001",
      sub_s_func       => "100010",
      subu_s_func      => "100011",
      and_s_func       => "100100",
      or_s_func        => "100101",
      xor_s_func       => "100110",
      nor_s_func       => "100111",
      slt_s_func       => "110010",
      sltu_s_func      => "101011",
      tge_s_func       => "110000",
      tgeu_s_func      => "110001",
      tlt_s_func       => "110010",
      tltu_s_func      => "110011",
      teq_s_func       => "110100",
      tne_s_func       => "110110",
      unimp_s_func     => "UUUUUU"
   );

   function to_slv (
      func : s_func_type
   ) return std_logic_vector;

   function to_s_func (
      func_slv : std_logic_vector
   ) return s_func_type;

   type r_type is record
      op    : op_type;
      rs    : reg_index;
      rt    : reg_index;
      rd    : reg_index;
      sa    : shift_amount;
      func  : s_func_type;
   end record;

   type i_type is record
      op    : op_type;
      rs    : reg_index;
      rt    : reg_index;
      imm   : immediate;
   end record;

   type j_type is record
      op       : op_type;
      j_addr   : j_address;
   end record;

   function to_r_type (
      slv : std_logic_vector
   ) return r_type;

   function to_slv (
      ins : r_type
   ) return std_logic_vector;

   function to_i_type (
      slv : std_logic_vector
   ) return i_type;

   function to_slv (
      ins : i_type
   ) return std_logic_vector;

   function to_j_type (
      slv : std_logic_vector
   ) return j_type;

   function to_slv (
      ins : j_type
   ) return std_logic_vector;


   subtype dump_address is unsigned(15 downto 0);


   type alu_src_type is (
      reg_alu_src, imm_alu_src, sa_alu_src,
      immu_alu_src, lui_alu_src
   );

   type reg_src_type is (
      mem_reg_src, pc_reg_src, alu_reg_src
   );

end;

package body common is
   
   
   function to_nibble (
      i_int : integer
   ) return nibble is
   begin
      if i_int < 0 then
         return unsigned(to_signed(i_int, nibble'length));
      else
         return to_unsigned(i_int, nibble'length);
      end if;
   end;

   function to_byte (
      i_int : integer
   ) return byte is
   begin
      if i_int < 0 then
         return unsigned(to_signed(i_int, byte'length));
      else
         return to_unsigned(i_int, byte'length);
      end if;
   end;

   function to_hword (
      i_int : integer
   ) return hword is
   begin
      if i_int < 0 then
         return unsigned(to_signed(i_int, hword'length));
      else
         return to_unsigned(i_int, hword'length);
      end if;
   end;

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


   function to_j_address (
      i_int : integer
   ) return j_address is
   begin
      if i_int < 0 then
         return unsigned(to_signed(i_int, j_address'length));
      else
         return to_unsigned(i_int, j_address'length);
      end if;
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


   function to_slv (
      op : op_type
   ) return std_logic_vector is
   begin
      return op_enc_lut(op);
   end;

   function to_op (
      op_slv : std_logic_vector
   ) return op_type is
   begin
      for op in op_type loop
         if op_slv = op_enc_lut(op) then
            return op;
         end if;
      end loop;

      return unimp_op;
   end;


   function to_slv (
      func : s_func_type
   ) return std_logic_vector is
   begin
      return special_func_enc_lut(func);
   end;

   function to_s_func (
      func_slv : std_logic_vector
   ) return s_func_type is
   begin
      for func in s_func_type loop
         if func_slv = special_func_enc_lut(func) then
            return func;
         end if;
      end loop;

      return unimp_s_func;
   end;


   function to_r_type (
      slv : std_logic_vector
   ) return r_type is
      variable ins : r_type;
   begin
      ins.op   := to_op(slv(31 downto 26));
      ins.rs   := to_reg_index(slv(25 downto 21));
      ins.rt   := to_reg_index(slv(20 downto 16));
      ins.rd   := to_reg_index(slv(15 downto 11));
      ins.sa   := to_integer(unsigned(slv(10 downto 6)));
      ins.func := to_s_func(slv(5 downto 0));
   
      return ins;
   end;

   function to_slv (
      ins : r_type
   ) return std_logic_vector is
      variable slv : word_slv;
   begin
      slv(31 downto 26) := to_slv(ins.op);
      slv(25 downto 21) := to_slv(ins.rs);
      slv(20 downto 16) := to_slv(ins.rt);
      slv(15 downto 11) := to_slv(ins.rd);
      slv(10 downto 6)  := to_slv(ins.sa);
      slv(5 downto 0)   := to_slv(ins.func);

      return slv;
   end;

   function to_i_type (
      slv : std_logic_vector
   ) return i_type is
      variable ins : i_type;
   begin
      ins.op   := to_op(slv(31 downto 26));
      ins.rs   := to_reg_index(slv(25 downto 21));
      ins.rt   := to_reg_index(slv(20 downto 16));
      ins.imm  := unsigned(slv(15 downto 0));

      return ins;
   end;

   function to_slv (
      ins : i_type
   ) return std_logic_vector is
      variable slv : word_slv;
   begin
      slv(31 downto 26) := to_slv(ins.op);
      slv(25 downto 21) := to_slv(ins.rs);
      slv(20 downto 16) := to_slv(ins.rt);
      slv(15 downto 0)  := std_logic_vector(ins.imm);

      return slv;
   end;

   function to_j_type (
      slv : std_logic_vector
   ) return j_type is
      variable ins : j_type;
   begin
      ins.op      := to_op(slv(31 downto 26));
      ins.j_addr  := unsigned(slv(25 downto 0));

      return ins;
   end;

   function to_slv (
      ins : j_type
   ) return std_logic_vector is
      variable slv : word_slv;
   begin
      slv(31 downto 26) := to_slv(ins.op);
      slv(25 downto 0)  := std_logic_vector(ins.j_addr);

      return slv;
   end;

end;

