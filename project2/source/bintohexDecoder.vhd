-- decoder for the 7 segment displays
-- converts binary to hex
-- by Eric Villasenor

-- libraries
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

-- entity
entity bintohexDecoder is
	port
	(
		-- input binary digits 4
		input 		: in	std_logic_vector (3 downto 0);
		-- output control signals for 7seg display
		output		:	out	std_logic_vector (6 downto 0)
	);
end bintohexDecoder;

architecture BinToHex of bintohexDecoder is
begin 
-- decode binary to output control signals
--			______0______
--			|						|
--		5	|						|1
--			|						|
--			------6-----
--			|						|
--		4	|						|2
--			|						|
--			------3-----
--
-- yey ascii art
-- 1 is off 0 is on
with input select
	output <= "1000000" when x"0",
						"1111001" when x"1",
						"0100100" when x"2",
						"0110000" when x"3",
						"0011001" when x"4",
						"0010010" when x"5",
						"0000010" when x"6",
						"1111000" when x"7",
						"0000000" when x"8",
						"0010000" when x"9",
						"0001000" when x"a",
						"0000011" when x"b",
						"0100111" when x"c",
						"0100001" when x"d",
						"0000110" when x"e",
						"0001110" when x"f",
						"0001011" when others;
end BinToHex;
