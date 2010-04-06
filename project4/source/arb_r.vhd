-- this is the memory arbiter implementation for the system

use work.common.all;
use work.arb_pkg.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity arb_r is
   port (
      clk   : in  std_logic;
      nrst  : in  std_logic;
      d     : in  arb_in_type;
      q     : out arb_out_type
   );
end;      

architecture twoproc of arb_r is

   type consumer_type is (icache0_consumer, icache1_consumer, cc_consumer);

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
      if (d.icache0.ren or d.icache1.ren) = '1' then
         -- there is a pending icache read, service these first

         if (d.icache0.ren and d.icache1.ren) = '1' then
         -- both icaches want to read, alternate priority between them
            if r.last_serviced = icache0_consumer then
               winner := icache1_consumer;
            else
               winner := icache0_consumer;
            end if;
         elsif d.icache0.ren = '1' then
            -- just icache0 wants to read, give it access
            winner := icache0_consumer;
         else
            -- just icache1 wants to read, give it access
            winner := icache1_consumer;
         end if;
      else
         -- icaches have been given priority, now let the coherency controller have its turn
         -- we do this even if the CC doesn't want to read or write
         winner := cc_consumer;
      end if;

      -- we have to update the last consumer register
      if d.mem.state = ready_mem_state then
         v.last_serviced := winner;
         mem_done := '1';
      else
         mem_done := '0';
      end if;

      -- drive the register inputs
      rin <= v;

      -- drive module outputs

      -- default outputs
      q.icache0.done <= '0';
      q.icache1.done <= '0';
      q.cc.done      <= '0';
      
      q.icache0.rdat <= d.mem.rdat;
      q.icache1.rdat <= d.mem.rdat;
      q.cc.rdat      <= d.mem.rdat;
      
      q.mem.ren      <= '0';
      q.mem.wen      <= '0';

      q.mem.wdat     <= d.cc.wdat;

      -- route the signals
      if winner = icache0_consumer then
         q.mem.ren      <= '1';
         q.mem.addr     <= d.icache0.addr;
         q.icache0.done <= mem_done;
      elsif winner = icache1_consumer then
         q.mem.ren      <= '1';
         q.mem.addr     <= d.icache0.addr;
         q.icache1.done <= mem_done;
      else
         -- coherency controller is the winner
         q.mem.ren      <= d.cc.ren;
         q.mem.wen      <= d.cc.wen;
         q.cc.done      <= mem_done;
      end if;



   end process;

   -- the register process
   regs : process(clk, nrst)
   begin
      if nrst = '0' then
         r.last_serviced <= icache1_consumer;
      elsif rising_edge(clk) then
         r <= rin;
      end if;
   end process;

end;

