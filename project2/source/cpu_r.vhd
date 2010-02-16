-- cpu (record style)

use work.common.all;
use work.common_pipe.all;
use work.cpu_pkg.all;
use work.alu_pkg.all;
use work.regfile_pkg.all;
use work.ctrl_pkg.all;
use work.hazard_pkg.all;

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

   -- hazard signals
   signal hazard_in  : hazard_in_type;
   signal hazard_out : hazard_out_type;

begin


   ---------------------------------------
   ---------------------------------------
   ---------      IF STAGE       ---------
   ---------------------------------------
   ---------------------------------------


   -- pc register process
   pc_reg_proc : process(nrst, clk)
   begin
      if nrst = '0' then
         pc <= (others => '0');
      elsif rising_edge(clk) then
         if pc_wen = '1' then
            pc <= pc_in;
         end if;
      end if;
   end process;

   pc_in <= pc + 4;

   process(mem_state, r_ins.op)
   begin
      if r_ins.op /= halt_op then
         if mem_state = free_mem_state or mem_state = ready_mem_state then
            pc_wen <= '1';
         else
            pc_wen <= '0';
         end if;
      else
         pc_wen <= '0';
      end if;
   end process;

   
   -- instruction memory (from vmem)
   imem_addr <= pc;
   imem_dat <= mem_rdat;


   -- feed the IF/ID pipeline registers
   if_id_reg_in.ins     <= imem_dat;
   if_id_reg_in.pc_next <= pc + 4;




   ---------------------------------------
   ---------------------------------------
   ---------      ID STAGE       ---------
   ---------------------------------------
   ---------------------------------------


   -- decode instructions to all types
   r_ins <= to_r_type(std_logic_vector(if_id_reg.ins));
   j_ins <= to_j_type(std_logic_vector(if_id_reg.ins));
   i_ins <= to_i_type(std_logic_vector(if_id_reg.ins));


   -- control block
   ctrl_b : ctrl_r port map (
      d => ctrl_in, q => ctrl_out
   );

   ctrl_in.r_ins <= r_ins;
   ctrl_in.i_ins <= i_ins;
   ctrl_in.j_ins <= j_ins;


   regfile_b : regfile_r port map (
      clk => clk, nrst => nrst,
      d => reg_in, q => reg_out
   );

   reg_in.rsel1   <= r_ins.rs;
   reg_in.rsel2   <= r_ins.rt;
   reg_in.wen     <= mem_wb_reg.wb_ctrl.reg_write;
   -- JAL not supported!
   reg_in.wsel    <= mem_wb_reg.reg_dst;

   -- this process selects the register index for the regfile write
   reg_write_sel : process(ctrl_out.reg_dst)
      variable i : reg_index;
   begin
      if ctrl_out.reg_dst = '1' then
         i := r_ins.rd;
      else
         i := r_ins.rt;
      end if;

      id_ex_reg_in.reg_dst <= i;
   end process;


   -- this process selects which value is written to the regfile
   -- warning, no longer supports JAL instructions
   reg_write_mux : process(mem_wb_reg)
      variable r : word;
   begin
      case mem_wb_reg.wb_ctrl.reg_src is
         when mem_reg_src  => r := mem_wb_reg.lw_res;
         when alu_reg_src  => r := mem_wb_reg.alu_res;
         -- JAL not supported!
         when pc_reg_src   => null;
      end case;

      reg_in.wdat <= r;
   end process;


   -- feed the ID/EX pipeline register inputs
   id_ex_reg_in.rdat1      <= reg_out.rdat1;
   id_ex_reg_in.rdat2      <= reg_out.rdat2;
   -- id_ex_reg_in.reg_dst assigned in reg_write_sel process!
   id_ex_reg_in.sa         <= r_ins.sa;
   id_ex_reg_in.imm        <= i_ins.imm;

   id_ex_reg_in.ex_ctrl    <= ctrl_out.ex_ctrl;
   id_ex_reg_in.mem_ctrl   <= ctrl_out.mem_ctrl;
   id_ex_reg_in.wb_ctrl    <= ctrl_out.wb_ctrl;
   id_ex_reg_in.halt       <= '1' when r_ins.op = halt_op else '0';




   ---------------------------------------
   ---------------------------------------
   ---------      EX STAGE       ---------
   ---------------------------------------
   ---------------------------------------


   alu_b : alu_r port map (
      d => alu_in, q => alu_out
   );

   alu_in.a <= id_ex_reg.rdat1;
   alu_in.op <= id_ex_reg.ex_ctrl.alu_op;
   
   alu_mux : process (id_ex_reg)
      variable r : word;
   begin
      case id_ex_reg.ex_ctrl.alu_src is
         when reg_alu_src  => r := id_ex_reg.rdat2;
         when imm_alu_src  => r := unsigned(resize(signed(id_ex_reg.imm), r'length));
         when immu_alu_src => r := resize(id_ex_reg.imm, r'length);
         when sa_alu_src   => r := to_unsigned(id_ex_reg.sa, r'length);
         when lui_alu_src  => r := zero_fill_right(id_ex_reg.imm, r'length);
      end case;

      alu_in.b <= r;
   end process;


   -- feed the EX/MEM pipeline register inputs
   ex_mem_reg_in.alu_res   <= alu_out.r;
   ex_mem_reg_in.rdat2     <= id_ex_reg.rdat2;
   ex_mem_reg_in.reg_dst   <= id_ex_reg.reg_dst;
   
   ex_mem_reg_in.mem_ctrl  <= id_ex_reg.mem_ctrl;
   ex_mem_reg_in.wb_ctrl   <= id_ex_reg.wb_ctrl;
   ex_mem_reg_in.halt      <= id_ex_reg.halt;




   ---------------------------------------
   ---------------------------------------
   ---------      MEM STAGE      ---------
   ---------------------------------------
   ---------------------------------------


   -- data memory (from vmem)
   dmem_addr <= ex_mem_reg.alu_res;
   dmem_rdat <= mem_rdat;
   dmem_wdat <= ex_mem_reg.rdat2;
   dmem_wen  <= ex_mem_reg.mem_ctrl.mem_write;

   -- feed the MEM/WB pipeline register inputs
   mem_wb_reg_in.alu_res   <= ex_mem_reg.alu_res;
   mem_wb_reg_in.lw_res    <= dmem_rdat;
   mem_wb_reg_in.reg_dst   <= ex_mem_reg.reg_dst;

   mem_wb_reg_in.wb_ctrl   <= ex_mem_reg.wb_ctrl;
   mem_wb_reg_in.halt      <= ex_mem_reg.halt;




   ---------------------------------------
   ---------------------------------------
   ---------      PIPE REGS      ---------
   ---------------------------------------
   ---------------------------------------


   pipe_reg_proc : process(nrst, clk, ex_mem_reg.mem_ctrl, r_ins.op)
   begin
      if nrst = '0' then
         id_ex_reg.mem_ctrl.mem_read <= '0';
         id_ex_reg.mem_ctrl.mem_write <= '0';
         id_ex_reg.wb_ctrl.reg_write <= '0';
         id_ex_reg.halt <= '0';
         ex_mem_reg.mem_ctrl.mem_read <= '0';
         ex_mem_reg.mem_ctrl.mem_write <= '0';
         ex_mem_reg.wb_ctrl.reg_write <= '0';
         ex_mem_reg.halt <= '0';
         mem_wb_reg.wb_ctrl.reg_write <= '0';
         mem_wb_reg.halt <= '0';
      elsif rising_edge(clk) then
         if ex_mem_reg.mem_ctrl.mem_read = '0' and ex_mem_reg.mem_ctrl.mem_write = '0' and r_ins.op /= halt_op then
            if_id_reg <= if_id_reg_in;
         end if;
         id_ex_reg <= id_ex_reg_in;
         ex_mem_reg <= ex_mem_reg_in;
         mem_wb_reg <= mem_wb_reg_in;
      end if;
   end process;




   ---------------------------------------
   ---------------------------------------
   ---------    HAZARD DETECT    ---------
   ---------------------------------------
   ---------------------------------------


   hazard_b : hazard_r port map (
      d => hazard_in, q => hazard_out
   );

   hazard_in.id_dst <= r_ins.rd;
   hazard_in.ex_dst <= id_ex_reg.reg_dst;
   hazard_in.mem_dst <= ex_mem_reg.reg_dst;
   hazard_in.wb_dst <= mem_wb_reg.reg_dst;


   ---------------------------------------
   ---------------------------------------
   ---------      SYS MEMORY     ---------
   ---------------------------------------
   ---------------------------------------

   -- main memory
   mem_b : entity work.vram port map (
      nReset => nrst, clock => clk,
      address => std_logic_vector(mem_addr(15 downto 0)),
      data => std_logic_vector(mem_wdat),
      wren => mem_wen, rden => mem_ren,
      halt => mem_halt, q => mem_rdat_slv,
      memstate => mem_state_slv
   );

   mem_rdat <= unsigned(mem_rdat_slv);
   mem_wdat <= ex_mem_reg.rdat2;
   mem_state <= to_mem_state(mem_state_slv);
   mem_halt <= '0';

   process(pc, ex_mem_reg, d.dump_addr, mem_wb_reg.halt)
   begin
      if mem_wb_reg.halt = '0' then
         if ex_mem_reg.mem_ctrl.mem_read = '0' and ex_mem_reg.mem_ctrl.mem_write = '0' then
            mem_addr <= pc;
         else
            mem_addr <= ex_mem_reg.alu_res;
         end if;
      else
         mem_addr <= resize(d.dump_addr, address'length);
      end if;
   end process;

   mem_ren <= '1' when mem_wb_reg.halt = '1' else not ex_mem_reg.mem_ctrl.mem_write;
   mem_wen <= ex_mem_reg.mem_ctrl.mem_write;




   ---------------------------------------
   ---------------------------------------
   ---------      CPU OUTPUTS    ---------
   ---------------------------------------
   ---------------------------------------

   q.halt <= mem_wb_reg.halt;
   q.dmem_rdat <= mem_rdat;
   q.dmem_wdat <= mem_wdat;
   q.imem_dat <= mem_rdat;
   q.dmem_addr <= mem_addr;
   q.imem_addr <= mem_addr;


end;

