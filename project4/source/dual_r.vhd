-- dual core cpu implementation

use work.common.all;
use work.dual_pkg.all;
use work.cpu_pkg.all;
use work.arb_pkg.all;
use work.cc_pkg.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity dual_r is
   port (
      clk   : in std_logic;
      nrst  : in std_logic;
      d     : in  dual_in_type;
      q     : out dual_out_type
   );
end;


architecture structural of dual_r is

   -- memory signals
   signal mem_addr      : address;
   signal mem_wdat      : word;
   signal mem_wen       : std_logic;
   signal mem_ren       : std_logic;
   signal mem_halt      : std_logic;
   signal mem_rdat_slv  : word_slv;
   signal mem_rdat      : word;
   signal mem_state_slv : std_logic_vector(1 downto 0);
   signal mem_state     : mem_state_type;

   -- arbiter signals
   signal arb_in     : arb_in_type;
   signal arb_out    : arb_out_type;

   -- coherency controller signals
   signal cc_in      : cc_in_type;
   signal cc_out     : cc_out_type;

   -- core0 signals
   signal core0_in   : cpu_in_type;
   signal core0_out  : cpu_out_type;

   -- core1 signals
   signal core1_in   : cpu_in_type;
   signal core1_out  : cpu_out_type;

   -- master halt signal
   signal halt       : std_logic;
begin

   ---------------------------------------
   ---------------------------------------
   ---------      SYS MEMORY     ---------
   ---------------------------------------
   ---------------------------------------

   mem_b : entity work.vram port map (
      nReset => nrst, clock => clk,
      address => std_logic_vector(mem_addr(15 downto 0)),
      data => std_logic_vector(mem_wdat),
      wren => mem_wen, rden => mem_ren,
      halt => mem_halt, q => mem_rdat_slv,
      memstate => mem_state_slv
   );

   mem_addr    <= arb_out.mem.addr when halt = '0' else resize(d.dump_addr, address'length);
   mem_rdat    <= unsigned(mem_rdat_slv);
   mem_wdat    <= arb_out.mem.wdat;
   mem_ren     <= arb_out.mem.ren when halt = '0' else '1';
   mem_wen     <= arb_out.mem.wen when halt = '0' else '0';
   mem_state   <= to_mem_state(mem_state_slv);
   mem_halt    <= halt;

   -- arbiter
   arb_b : arb_r port map (
      clk => clk, nrst => nrst, d => arb_in, q => arb_out
   );

   arb_in.icache0.addr  <= core0_out.icache.addr;
   arb_in.icache0.ren   <= core0_out.icache.ren;
   arb_in.icache1.addr  <= core1_out.icache.addr;
   arb_in.icache1.ren   <= core1_out.icache.ren;
   arb_in.cc.addr       <= cc_out.mem.addr;
   arb_in.cc.wdat       <= cc_out.mem.wdat;
   arb_in.cc.ren        <= cc_out.mem.ren;
   arb_in.cc.wen        <= cc_out.mem.wen;
   arb_in.mem.rdat      <= mem_rdat;
   arb_in.mem.state     <= mem_state;

   core0_in.icache.rdat <= arb_out.icache0.rdat;
   core0_in.icache.done <= arb_out.icache0.done;
   core1_in.icache.rdat <= arb_out.icache1.rdat;
   core1_in.icache.done <= arb_out.icache1.done;
   cc_in.mem.rdat       <= arb_out.cc.rdat;
   cc_in.mem.done       <= arb_out.cc.done;


   -- coherency controller
   cc_b : cc_r port map (
      clk => clk, nrst => nrst, d => cc_in, q => cc_out
   );

   cc_in.dcache0.addr         <= core0_out.dcache.addr;
   cc_in.dcache0.wdat         <= core0_out.dcache.wdat;
   cc_in.dcache0.ren          <= core0_out.dcache.ren;
   cc_in.dcache0.rxen         <= core0_out.dcache.rxen;
   cc_in.dcache0.wen          <= core0_out.dcache.wen;
   cc_in.dcache0.flush        <= core0_out.dcache.flush;


   cc_in.dcache1.addr         <= core1_out.dcache.addr;
   cc_in.dcache1.wdat         <= core1_out.dcache.wdat;
   cc_in.dcache1.ren          <= core1_out.dcache.ren;
   cc_in.dcache1.rxen         <= core1_out.dcache.rxen;
   cc_in.dcache1.wen          <= core1_out.dcache.wen;
   cc_in.dcache1.flush        <= core1_out.dcache.flush;

   core0_in.dcache.rdat       <= cc_out.dcache0.rdat;
   core0_in.dcache.done       <= cc_out.dcache0.done;
   core0_in.dcache.snp_addr   <= cc_out.dcache0.snp_addr;
   core0_in.dcache.snp_ren    <= cc_out.dcache0.snp_ren;
   core0_in.dcache.snp_rxen   <= cc_out.dcache0.snp_rxen;
   core0_in.dcache.snp_wen    <= cc_out.dcache0.snp_wen;

   core1_in.dcache.rdat       <= cc_out.dcache1.rdat;
   core1_in.dcache.done       <= cc_out.dcache1.done;
   core1_in.dcache.snp_addr   <= cc_out.dcache1.snp_addr;
   core1_in.dcache.snp_ren    <= cc_out.dcache1.snp_ren;
   core1_in.dcache.snp_rxen   <= cc_out.dcache1.snp_rxen;
   core1_in.dcache.snp_wen    <= cc_out.dcache1.snp_wen;

   -- core0
   core0_b : cpu_r generic map (
      reset_vector => x"00000000"
   ) port map (
      clk => clk, nrst => nrst, d => core0_in, q => core0_out
   );

   -- core1
   core1_b : cpu_r generic map (
      reset_vector => x"00000200"
   ) port map (
      clk => clk, nrst => nrst, d => core1_in, q => core1_out
   );


   -- overall output signals
   halt <= core0_out.halt and core1_out.halt;
   q.halt <= halt;
   q.imem_addr <= mem_addr;
   q.dmem_addr <= mem_addr;
   q.imem_dat <= mem_rdat;
   q.dmem_rdat <= mem_rdat;
   q.dmem_wdat <= mem_wdat;


end;

