-- this is the coherency controller implementation for the system

use work.common.all;
use work.cc_pkg.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity cc_r is
   port (
      clk   : in  std_logic;
      nrst  : in  std_logic;
      d     : in  cc_in_type;
      q     : out cc_out_type
   );
end;      

architecture twoproc of cc_r is

   type consumer_type is (dcache0_consumer, dcache1_consumer);

   type reg_type is record
      last_serviced  : consumer_type;
   end record;

   signal r, rin : reg_type;

begin

   -- combinatiorial process
   comb : process(d, r)
      variable v        : reg_type;
      variable winner   : consumer_type;
      variable mem_done : std_logic;
   begin
      -- default assignment
      v := r;

      -- module algorithm
      
      -- this is the prioritization of the memory accesses
      if ((d.dcache0.ren or d.dcache0.wen) and (d.dcache1.ren or d.dcache1.wen)) = '1' then
         -- both caches want memory access

         if r.last_serviced = dcache0_consumer then
            winner := dcache1_consumer;
         else
            winner := dcache0_consumer;
         end if;
      elsif (d.dcache0.ren or d.dcache0.wen) = '1' then
         -- nobody else wants access, give it to cache 0
         winner := dcache0_consumer;
      else
         -- nobody else wants access, give it to cache 1
         winner := dcache1_consumer;
      end if;

      -- we have to update the last consumer register
      if d.mem.done = '1' then
         v.last_serviced := winner;
         mem_done := '1';
      else
         mem_done := '0';
      end if;

      -- drive the register inputs
      rin <= v;

      -- drive module outputs

      -- default outputs
      q.dcache0.done <= '0';
      q.dcache1.done <= '0';
      
      q.dcache0.rdat <= d.mem.rdat;
      q.dcache1.rdat <= d.mem.rdat;
      
      q.mem.ren      <= '0';
      q.mem.wen      <= '0';

      -- route the signals
      if winner = dcache0_consumer then
         q.mem.addr     <= d.dcache0.addr;
         q.mem.wdat     <= d.dcache0.wdat;
         q.mem.ren      <= d.dcache0.ren;
         q.mem.wen      <= d.dcache0.wen;
         q.dcache0.done <= mem_done;
      else
         q.mem.addr     <= d.dcache1.addr;
         q.mem.wdat     <= d.dcache1.wdat;
         q.mem.ren      <= d.dcache1.ren;
         q.mem.wen      <= d.dcache1.wen;
         q.dcache1.done <= mem_done;
      end if;

   end process;

   -- the register process
   regs : process(clk, nrst)
   begin
      if nrst = '0' then
         r.last_serviced <= dcache1_consumer;
      elsif rising_edge(clk) then
         r <= rin;
      end if;
   end process;

end;

