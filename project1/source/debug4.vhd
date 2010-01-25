-- Purpose: show Iteration Limit Reached; Zero Delay Oscillation Error.
-- Created 01/17/03
-- Mohammed Abu Al Soud


library ieee;
use ieee.std_logic_1164.all;


entity debug4 is
  port ( 
	reset:	in STD_LOGIC     
       );
end debug4;

architecture behavioral of debug4 is

  
signal sel, output: STD_LOGIC;
 begin

init : process (reset)
  begin
	  if (reset='1') then
	  	sel<='0';
	  end if;
  end process; 
  

 update1 : process (sel)
  begin
	  if (sel='0') then
	  	output<='0';
	  else
	  	output<='1';
	  end if;
  end process; 
  
  update2 : process (output)
  begin
	if (output='0') then
		sel<='1';
	else
		sel<='0';
	end if;
  end process;
end behavioral;

