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
   type arb_state_type is (idle_arb_state, busy_arb_state);

   type reg_type is record
      last_serviced  : consumer_type;
      cur_service    : consumer_type;
      mem_done       : std_logic;
      rdat           : word;
      state          : arb_state_type;
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
      
      if r.state = idle_arb_state then
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
      else
         winner := r.cur_service;
      end if;


      -- next state logic
      case r.state is
         when idle_arb_state =>
            if (d.cc.ren or d.cc.wen or d.icache0.ren or d.icache1.ren) = '1' then
               v.state := busy_arb_state;
               v.cur_service := winner;
            end if;

         when busy_arb_state =>
            if r.mem_done = '1' then
               v.mem_done := '0';

               case winner is
                  when cc_consumer =>
                     v.last_serviced   := cc_consumer;
                     v.state           := idle_arb_state;

                  when icache0_consumer =>
                     v.last_serviced   := icache0_consumer;
                     v.state           := idle_arb_state;

                  when icache1_consumer =>
                     v.last_serviced   := icache1_consumer;
                     v.state           := idle_arb_state;

                  when others =>
                     -- not possible

               end case;
            end if;

         when others =>
            -- not possible

      end case;

      -- we have to update the last consumer register
      if d.mem.state = ready_mem_state then
         v.mem_done  := '1';
         v.rdat      := d.mem.rdat;
      end if;

      
      -- drive the register inputs
      rin <= v;

      -- drive module outputs

      -- default outputs
      q.icache0.done <= '0';
      q.icache1.done <= '0';
      q.cc.done      <= '0';
      
      q.icache0.rdat <= r.rdat;
      q.icache1.rdat <= r.rdat;
      q.cc.rdat      <= r.rdat;
      
      q.mem.ren      <= '0';
      q.mem.wen      <= '0';

      q.mem.addr     <= x"FEEDB00B";
      q.mem.wdat     <= to_word(0);

      -- route the signals

      case r.state is
         when idle_arb_state =>
            -- defaults are fine

         when busy_arb_state =>
            case winner is
               when icache0_consumer =>
                  q.mem.addr     <= d.icache0.addr;
                  q.icache0.done <= r.mem_done;

               when icache1_consumer =>
                  q.mem.addr     <= d.icache1.addr;
                  q.icache1.done <= r.mem_done;

               when cc_consumer =>
                  q.mem.addr     <= d.cc.addr;
                  q.cc.done      <= r.mem_done;

               when others =>
                  -- not possible

            end case;

            if r.mem_done = '0' then
               case winner is
                  when icache0_consumer =>
                     q.mem.ren <= d.icache0.ren;

                  when icache1_consumer =>
                     q.mem.ren <= d.icache1.ren;

                  when cc_consumer =>
                     q.mem.ren <= d.cc.ren;
                     q.mem.wen <= d.cc.wen;

                  when others =>
                     -- not possible

               end case;
            end if;

         when others =>
            -- not possible

      end case;

   end process;

   -- the register process
   regs : process(clk, nrst)
   begin
      if nrst = '0' then
         r.last_serviced <= icache1_consumer;
         r.mem_done <= '0';
         r.rdat <= to_word(0);
      elsif rising_edge(clk) then
         r <= rin;
      end if;
   end process;

end;

