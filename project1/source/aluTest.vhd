-- libraries
library ieee;
use ieee.std_logic_1164.all;

-- entity
entity aluTest is
				-- clock
  port( CLOCK_27 : in std_logic;
				-- switches
        SW : in std_logic_vector(17 downto 0);
				-- push buttons
        KEY : in std_logic_vector(3 downto 0);
				-- green leds
        LEDG : out std_logic_vector(8 downto 0);
				-- red leds
        LEDR : out std_logic_vector(17 downto 0);
				-- 7seg right most
				HEX0	: out std_logic_vector(6 downto 0);
				-- 7seg 
				HEX1	: out std_logic_vector(6 downto 0);
				-- 7seg 
				HEX2	: out std_logic_vector(6 downto 0);
				-- 7seg 
				HEX3	: out std_logic_vector(6 downto 0);
				-- 7seg 
				HEX4	: out std_logic_vector(6 downto 0);
				-- 7seg 
				HEX5	: out std_logic_vector(6 downto 0);
				-- 7seg 
				HEX6	: out std_logic_vector(6 downto 0);
				-- 7seg 
				HEX7	: out std_logic_vector(6 downto 0)
      );
end aluTest;

architecture behav of aluTest is
	-- alu 
  component alu
    port( OPCODE: in std_logic_vector(2 downto 0);
          A, B: in std_logic_vector(31 downto 0);
          OUTPUT: out std_logic_vector(31 downto 0);
          NEGATIVE, OVERFLOW, ZERO: out std_logic );
  end component;

	-- decoders
	component bintohexDecoder
		port (input: in std_logic_vector(3 downto 0);
					output: out std_logic_vector(6 downto 0));
	end component;

	-- internal signals
  signal Op : std_logic_vector(2 downto 0);
  signal storedA : std_logic_vector(31 downto 0);
	signal modB : std_logic_vector(31 downto 0);
	signal res : std_logic_vector(31 downto 0);
  signal negative, overflow, zero : std_logic;
  signal workaround : std_logic;
begin

	-- create alu
  ALU0 : alu port
    map( Op, storedA, modB, res, negative, overflow, zero );

	-- create decoders
	BTH0 : bintohexDecoder port
		map(res(3 downto 0), HEX0);

	BTH1 : bintohexDecoder port
		map(res(7 downto 4), HEX1);

	BTH2 : bintohexDecoder port
		map(res(11 downto 8), HEX2);

	BTH3 : bintohexDecoder port
		map(res(15 downto 12), HEX3);

	BTH4 : bintohexDecoder port
		map(res(19 downto 16), HEX4);

	BTH5 : bintohexDecoder port
		map(res(23 downto 20), HEX5);

	BTH6 : bintohexDecoder port
		map(res(27 downto 24), HEX6);

	BTH7 : bintohexDecoder port
		map(res(31 downto 28), HEX7);

	-- setup input
  Op <= not KEY(2 downto 0); -- 0 when not pressed
  workaround <= KEY(3); -- 1 when not pressed

	-- setup output
	LEDG(8) <= overflow;
	LEDR(17) <= zero;
	LEDR(16) <= negative;
	LEDR(15 downto 0) <= (others => '0');
	LEDG(7 downto 0) <= (others => '0');

	-- set B
	modB <= SW(17 downto 4) & SW(17 downto 0);
	-- set A
  process( CLOCK_27, workaround )
  begin
		-- stores A in temp storage
    if( workaround = '0' ) then
      if( CLOCK_27'event and CLOCK_27 = '1' ) then
        storedA <= "00000000000000" & SW(17 downto 0);
      end if;
    end if;
  end process;

end behav;


