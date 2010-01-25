-- By: Jason Horihan

library ieee;  use ieee. std_logic_1164.all;

entity debug5 is
  port (
         clk           : in  std_logic;
         nReset        : in  std_logic;
         output0       : out std_logic;
         output1       : out std_logic;
         output2       : out std_logic
       );
end ;

architecture debugtest of debug5 is

  type state_type is (zero, one, two, three, four, five, six, seven);
  signal   state, nextState : state_type;

begin

  define_outputs : process (state)
  begin

    case state is
      when zero =>
        output0 <= '0';
        output1 <= '0';
        output2 <= '0';
        nextState <= one;
      when one =>
        output0 <= '1';
        nextState <= two;
      when two =>
        output0 <= '0';
        output1 <= '1';
        nextState <= three;
      when three =>
        output0 <= '1';
        nextState <= four;
      when four =>
        output0 <= '0';
        output1 <= '0';
        output2 <= '1';
        nextState <= five;
      when five =>
        output0 <= '1';
        nextState <= six;
      when six => 
        output0 <= '0';
        output1 <= '1';
        nextState <= seven;
      when seven => 
        output0 <= '1';
        nextState <= zero;
      when others =>
        nextState <= zero;
    end case;

  end process;  

  clk_process : process (clk, nReset) 
  begin

    if (nReset = '0') then
      state <= zero;
    elsif (clk = '1' AND clk'event) then
      state <= nextState;
    end if; 

  end process;

end debugtest;

