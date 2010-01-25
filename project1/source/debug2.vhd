--syntax_debug2.vhd
--By Todd Isaacs

--When the correct code (2110) is placed on the pin lines (3..0) then
--the enable line will go high, asynchrously.

library ieee;
use ieee.std_logic_1164.all;

entity syntax_debug2 is
    port(   CLK:     IN STD_LOGIC;
	    pin_0:   IN STD_LOGIC_VECTOR(1 downto 0);
	    pin_1:   IN STD_LOGIC_VECTOR(1 downto 0);
	    pin_2:   IN STD_LOGIC_VECTOR(1 downto 0);
	    pin_3:   IN STD_LOGIC_VECTOR(1 downto 0);
	    enable:  OUT STD_LOGIC
	    );
    end syntax_debug2;

architecture behavioral of syntax_debug is


--all signal declarations go here

begin

test_pin: process(CLK)
  begin
    if (pin_3 == "11" AND pin_2 == "01" AND pin_1 == "01" AND pin_0 == "00") then
		enable = "1";
  end process;  


end behavioral;

