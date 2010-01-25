--debug1.vhd
--By Todd Isaacs

--given a 3-bit number, this program should output an 8-bit representation
--of this number, on rising clk edge. 

--The value of the 3-bit number causes a '1' be be asserted at the 
--corresponding bit position. (ex. 111 ==> 10000000; 110 ==> 01000000 ...)

library ieee;
use ieee.std_logic_1164.all;

entity syntax_debug1 is
    port(   CLK:     IN STD_LOGIC;
	    input:   IN STD_LOGIC_VECTOR(2 downto 0);
	    output:  OUT STD_LOGIC_VECTOR(7 downto 0);
	    );
    end syntax_debug1;

architecture behavioral of syntax_debug1 is

	constant zero :    STD_LOGIC_VECTOR := "0000000000000000";  -- zero

--all signal declarations go here

begin

decode: process(CLK)
  begin
    if (CLK'Event AND CLK = '1') then
	case input is
	    when "000" =>
		output <= "00000001"
	    when "001" =>
		output <= "00000010"
	    when "010" =>
		output <= "00000100"
	    when "011" =>
		output <= "00001000"
	    when "100" =>
		output <= "00010000"
	    when "101" =>
		output <= "00100000"
	    when "110" =>
		output <= "01000000"
	    when "111" =>
		output <= "10000000"
	    when others =>
		output <= zero
	end case;
    end if;	
  end process;  


end behavioral;

