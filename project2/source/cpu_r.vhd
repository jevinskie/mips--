-- cpu (record style)

use work.common.all;
use work.common_pipe.all;
use work.cpu_pkg.all;
use work.alu_pkg.all;
use work.regfile_pkg.all;
use work.ctrl_pkg.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity cpu_r is
   port (
      clk   : in std_logic;
      nrst  : in std_logic;
      d     : in  cpu_in_type;
      q     : out cpu_out_type
   );
end;


architecture structural of cpu_r is


   signal alu_in  : alu_in_type;
   signal alu_out : alu_out_type;

   signal reg_in  : regfile_in_type;
   signal reg_out : regfile_out_type;

   signal ctrl_in    : ctrl_in_type;
   signal ctrl_out   : ctrl_out_type;

   signal imem_addr     : address;
   signal imem_dat      : word;

   signal dmem_addr     : address;
   signal dmem_rdat     : word;
   signal dmem_wdat     : word;
   signal dmem_wen      : std_logic;

   signal r_ins : r_type;
   signal j_ins : j_type;
   signal i_ins : i_type;

   signal z : std_logic;

   signal dump_addr : dump_address;

   -- pipeline register signals
   signal if_id_reg, if_id_reg_in   : if_id_reg_type;
   signal id_ex_reg, id_ex_reg_in   : id_ex_reg_type;
   signal ex_mem_reg, ex_mem_reg_in : ex_mem_reg_type;
   signal mem_wb_reg, mem_wb_reg_in : mem_wb_reg_type;

   -- vmem signals
   signal mem_addr      : address;
   signal mem_wdat      : word;
   signal mem_wen       : std_logic;
   signal mem_ren       : std_logic;
   signal mem_halt      : std_logic;
   signal mem_rdat_slv  : word_slv;
   signal mem_rdat      : word;
   signal mem_state_slv : std_logic_vector(1 downto 0);
   signal mem_state     : mem_state_type;


   -- pc signals
   signal pc, pc_in  : address;
   signal pc_wen     : std_logic;


begin


   regfile_b : regfile_r port map (
      clk => clk, nrst => nrst,
      d => reg_in, q => reg_out
   );

   reg_in.rsel1 <= r_ins.rs;
   reg_in.rsel2 <= r_ins.rt;
   reg_in.wen <= ctrl_out.reg_write and not memwait and not halt;

   reg_write_sel : process(ctrl_out.reg_dst, r_ins.rt, r_ins.rd, r_ins.op)
      variable i : reg_index;
   begin
      if r_ins.op = jal_op then
         i := 31;
      elsif ctrl_out.reg_dst = '1' then
         i := r_ins.rd;
      else
         i := r_ins.rt;
      end if;

      reg_in.wsel <= i;
   end process;

   reg_write_mux : process(ctrl_out.reg_src, pc_out.pc, dmem_rdat, alu_out.r)
      variable r : word;
      case ctrl_out.reg_src is
         when mem_reg_src  => r := dmem_rdat;
         when pc_reg_src   => r := pc_out.pc + 4;
         when alu_reg_src  => r := alu_out.r;
      end case;

      reg_in.wdat <= r;
   end process;


   alu_b : alu_r port map (
      d => alu_in, q => alu_out
   );

   z <= alu_out.z;
   alu_in.a <= reg_out.rdat1;
   alu_in.op <= ctrl_out.alu_op;
   
   alu_mux : process (ctrl_out.alu_src, reg_out.rdat2, i_ins.imm, r_ins.sa)
      variable r : word;
   begin
      case ctrl_out.alu_src is
         when reg_alu_src  => r := reg_out.rdat2;
         when imm_alu_src  => r := unsigned(resize(signed(i_ins.imm), r'length));
         when immu_alu_src => r := resize(i_ins.imm, r'length);
         when sa_alu_src   => r := to_unsigned(r_ins.sa, r'length);
         when lui_alu_src  => r := zero_fill_right(i_ins.imm, r'length);
      end case;

      alu_in.b <= r;
   end process;


   ctrl_b : ctrl_r port map (
      d => ctrl_in, q => ctrl_out
   );

   ctrl_in.r_ins <= r_ins;
   ctrl_in.i_ins <= i_ins;
   ctrl_in.j_ins <= j_ins;

   
   r_ins <= to_r_type(std_logic_vector(imem_dat));
   j_ins <= to_j_type(std_logic_vector(imem_dat));
   i_ins <= to_i_type(std_logic_vector(imem_dat));


   -- pc register process
   pc_reg_proc : process(nrst, clk)
   begin
      if nrst = '0' then
         pc => (others => '0');
      elsif rising_edge(clk) then
         if pc_wen = '1' then
            pc <= pc_in;
         end if;
      end if;
   end process;

   -- pc_wen logic
   pc_wen_proc : process
   begin
      if ex_mem_reg.mem_ctrl.mem_read = '1' then
         pc_wen <= '0';
      end if;
   end process;


   dmem_addr <= alu_out.r when halt = '0' else resize(d.dump_addr, address'length);
   dmem_rdat <= unsigned(dmem_rdat_slv);
   dmem_wdat <= reg_out.rdat2;
   dmem_wen  <= ctrl_out.mem_write;




   -- pipeline registers
   all_pipe_reg_proc : process(nrst, clk)
   begin
      if nrst = '0' then
         
      elsif rising_edge(clk) then
         if_id_reg   <= if_id_reg_in;
         id_ex_reg   <= id_ex_reg_in;
         ex_mem_reg  <= ex_mem_reg_in;
         mem_wb_reg  <= mem_wb_reg_in;
      end if;
   end process;


   -- main memory
   mem_b : entity work.vram port map (
      nReset => nrst, clock => clk,
      address => std_logic_vector(mem_addr),
      data => std_logic_vector(mem_wdat),
      wren => mem_wen, rden => mem_ren,
      halt => mem_halt, q => mem_rdat_slv,
      memstate => mem_state_slv;
   );

   mem_rdat <= unsigned(mem_rdat_slv);
   mem_state <= to_mem_state(mem_state_slv);


   q.halt <= mem_wb_reg.halt;


   -- cpu mappings
   q.imem_addr <= imem_addr;
   q.imem_dat <= imem_dat;
   q.dmem_addr <= dmem_addr;
   q.dmem_rdat <= dmem_rdat;
   q.dmem_wdat <= dmem_wdat;


end;

