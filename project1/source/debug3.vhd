-- Purpose: Debug problems arising from assigning signals.
-- Created 01/17/03
-- Mohammed Abu Al Soud


library ieee;
use ieee.std_logic_1164.all;


entity debug3 is
  port ( 
         A:  	out STD_LOGIC_VECTOR(15 downto 0);
         B:  	out STD_LOGIC_VECTOR(15 downto 0);
         C:  	out STD_LOGIC_VECTOR(15 downto 0);
         D:  	out STD_LOGIC_VECTOR(15 downto 0);
         E:  	out STD_LOGIC_VECTOR(15 downto 0)     
       );
end debug3;

architecture behavioral of debug3 is

constant DEAD:        STD_LOGIC_VECTOR := "1101111010101101";  -- DEAD
constant BEEF:        STD_LOGIC_VECTOR := "1011111011101111";  -- BEEF
constant CAB1:        STD_LOGIC_VECTOR := "1100101010110001";  -- CAB1
constant CAB2:        STD_LOGIC_VECTOR := "1100101010110010";  -- CAB2
constant FEED:        STD_LOGIC_VECTOR := "1111111011101101";  -- FEED
constant DEAF:        STD_LOGIC_VECTOR := "1101111010101111";  -- DEAF


  
signal sel, sel2: STD_LOGIC;
 begin
 update1 : process
  begin
	  A<=DEAD;
	  B<=DEAD;
	  C<=CAB1;
	  D<=CAB1;
	  sel<='0';
	  wait;
  end process; 
  
  update2 : process 
  begin
	B<=BEEF;
	wait;
  end process;
  
  update3 : process (sel2)
  begin
	if (sel2='0') then
	  E<=FEED;
	elsif (sel2='1') then
	  E<=DEAF;
	end if;	  
  end process;

  C<=CAB2 when sel='1' else CAB1;
  D<=CAB2 when sel='0' else CAB1;
    
end behavioral;

