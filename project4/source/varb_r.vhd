-- this is the virtual arbiter

use work.common.all;
use work.varb_pkg.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity varb_r is
   port (
      clk   : in  std_logic;
      nrst  : in  std_logic;
      d     : in  varb_in_type;
      q     : out varb_out_type
   );
end;      

architecture twoproc of varb_r is

   type mem_type is array (2**8-1 downto 0) of word;
   
   type varb_state_type is (varb_idle, varb_read, varb_write);

   type reg_type is record
      state    : varb_state_type;
      counter  : integer;
      mem      : mem_type;
   end record;

   signal r, rin : reg_type;


begin

   -- combinatiorial process
   comb : process(d, r)
      variable v           : reg_type;
   begin
      -- default assignment
      v := r;

      -- module algorithm
      -- state machine next state logic
      case r.state is
         when varb_idle =>
            if d.ren = '1' then
               v.state := varb_read;
            elsif d.wen = '1' then
               v.state := varb_write;
            end if;
         when varb_read =>
            v.counter := r.counter + 1;
            if r.counter = 3 then
               v.state := varb_idle;
               v.counter := 0;
            end if;
         when varb_write =>
            v.counter := r.counter + 1;
            if r.counter = 0 then
               v.mem(to_integer(d.addr / 4) mod r.mem'length) := d.wdat;
            elsif r.counter = 3 then
               v.state := varb_idle;
               v.counter := 0;
            end if;
         when others =>
      end case;

      -- drive the register inputs
      rin <= v;

      -- drive module outputs
      if r.counter = 3 and r.state = varb_read then
         q.rdat <= r.mem(to_integer(d.addr / 4) mod r.mem'length);
      else
         q.rdat <= x"DEADBEEF";
      end if;

      -- state machine output logic
      case r.state is
         when varb_idle =>
            q.done <= '0';
         when varb_read | varb_write =>
            if r.counter /= 3 then
               q.done <= '0';
            else
               q.done <= '1';
            end if;
         when others =>
      end case;

   end process;


   -- the register process
   regs : process(clk, nrst)
   begin
      if nrst = '0' then
         r.state <= varb_idle;
         r.counter <= 0;
         for i in r.mem'range loop
            r.mem(i) <= to_word(i*4);
         end loop;
      elsif rising_edge(clk) then
         r <= rin;
      end if;
   end process;

end;

