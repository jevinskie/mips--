-- memwait controller (record style)

use work.common.all;
use work.memwait_pkg.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity memwait_r is
   port (
      clk   : in std_logic;
      nrst  : in std_logic;
      d     : in  memwait_in_type;
      q     : out memwait_out_type
   );
end;


architecture twoproc of memwait_r is

   type state_type is (not_waiting, waiting_sawmem, not_waiting_sawmem);

   type reg_type is record
      state : state_type;
   end record;

   signal r, rin : reg_type;
   signal s, ns : std_logic;

begin
   
   
   -- combinatiorial process
--   comb : process(d, r)
--     variable v : reg_type;
--   begin
--      -- default assignment
--      v := r;

      -- module algorithm
--      case v.state is
--         when not_waiting =>
--            if d.op = lw_op then
--               v.state := waiting_sawmem;
--            end if;
--         when waiting_sawmem =>
--            v.state := not_waiting_sawmem;
--         when not_waiting_sawmem =>
--           if d.op = lw_op then
--               v.state := waiting_sawmem;
--            else
--              v.state := not_waiting;
--            end if;
--      end case;

      -- drive the register inputs
--      rin <= v;

      -- drive module outputs
--      if r.state = waiting_sawmem then
--         q.memwait <= '1';
--      else
--         q.memwait <= '0';
--     end if;

--   end process;

   -- register process
--   regs : process(clk, nrst)
--   begin
--      if nrst = '0' then
--         r.state <= not_waiting;
--      elsif rising_edge(clk) then
--         r <= rin;
--      end if;
--   end process;

   process(clk, nrst)
   begin
      if nrst = '0' then
         s <= '0';
      elsif rising_edge(clk) then
         s <= ns;
      end if;
   end process;

   process(s, d.op)
   begin
      q.memwait <= '0';
      ns <= '0';
      if d.op = lw_op then
         if s = '0' then
            ns <= '1';
            q.memwait <= '1';
         end if;
      end if;
   end process;

end;

