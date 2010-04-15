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
   type cc_state_type is (idle_cc_state, busy_cc_state);

   type reg_type is record
      last_serviced  : consumer_type;
      cur_service    : consumer_type;
      state          : cc_state_type; 
   end record;

   signal r, rin : reg_type;

begin

   -- combinatiorial process
   comb : process(d, r)
      variable v        : reg_type;
      variable winner   : consumer_type;
   begin
      -- default assignment
      v := r;

      -- module algorithm


      if r.state = idle_cc_state then
         -- this is the prioritization of the memory accesses
         if (d.dcache0.flush or d.dcache1.flush) = '1' then
            if d.dcache0.flush = '1' then
               winner := dcache0_consumer;
            else
               winner := dcache1_consumer;
            end if;
         elsif ((d.dcache0.ren or d.dcache0.wen) and (d.dcache1.ren or d.dcache1.wen)) = '1' then
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
      else
        winner := r.cur_service;
      end if;


      -- next state logic
      case r.state is
         when idle_cc_state =>
            if (d.dcache0.ren or d.dcache0.wen or d.dcache1.ren or d.dcache1.wen) = '1' then
               v.state := busy_cc_state;
               v.cur_service := winner;
            end if;

         when busy_cc_state =>
            -- we have to update the last consumer register
            if winner = dcache0_consumer then
               if (d.dcache0.ren or d.dcache0.rxen or d.dcache0.wen) = '0' then
                  if d.dcache0.flush = '0' then
                     v.last_serviced := winner;
                  end if;
                  v.state := idle_cc_state;
               end if;
            else
               if (d.dcache1.ren or d.dcache1.rxen or d.dcache1.wen) = '0' then
                  if d.dcache1.flush = '0' then
                     v.last_serviced := winner;
                  end if;
                  v.state := idle_cc_state;
               end if;
            end if;

         when others =>
            -- not possible

      end case;


      -- drive the register inputs
      rin <= v;

      -- drive module outputs

      -- default outputs
      
      q.dcache0.rdat <= d.mem.rdat;
      q.dcache1.rdat <= d.mem.rdat;
      
      q.dcache0.done <= '0';
      q.dcache1.done <= '0';

      q.mem.addr     <= x"B00B700B";
      q.mem.wdat     <= to_word(0);
      q.mem.ren      <= '0';
      q.mem.wen      <= '0';

      if winner = dcache0_consumer then
         q.dcache0_win <= '1';
      else
         q.dcache0_win <= '0';
      end if;

      -- snooping
      q.dcache0.snp_addr   <= d.dcache1.addr;
      q.dcache0.snp_ren    <= d.dcache1.ren;
      q.dcache0.snp_rxen   <= d.dcache1.rxen;
      q.dcache0.snp_wen    <= d.dcache1.wen;

      q.dcache1.snp_addr   <= d.dcache0.addr;
      q.dcache1.snp_ren    <= d.dcache0.ren;
      q.dcache1.snp_rxen   <= d.dcache0.rxen;
      q.dcache1.snp_wen    <= d.dcache0.wen;
      

      -- route the signals
      case r.state is
         when idle_cc_state =>
            -- default outputs are fine

         when busy_cc_state =>
            if winner = dcache0_consumer then
               q.mem.addr     <= d.dcache0.addr;
               q.mem.wdat     <= d.dcache0.wdat;
               q.mem.ren      <= d.dcache0.ren;
               q.mem.wen      <= d.dcache0.wen;
               q.dcache0.done <= d.mem.done;
            else
               q.mem.addr     <= d.dcache1.addr;
               q.mem.wdat     <= d.dcache1.wdat;
               q.mem.ren      <= d.dcache1.ren;
               q.mem.wen      <= d.dcache1.wen;
               q.dcache1.done <= d.mem.done;
            end if;

         when others =>
            -- not possible
      end case;

   end process;

   -- the register process
   regs : process(clk, nrst)
   begin
      if nrst = '0' then
         r.last_serviced <= dcache1_consumer;
         r.state <= idle_cc_state;
      elsif rising_edge(clk) then
         r <= rin;
      end if;
   end process;

end;

