library ieee;
use ieee.std_logic_1164.all;

entity regTest is
  port( CLOCK_27		: in std_logic;
        KEY	: in std_logic_vector(3 downto 0);
        SW	: in std_logic_vector(17 downto 0);
        LEDR		: out std_logic_vector(17 downto 0)
  );
end regTest;

architecture behav of regTest is
  component registerFile
   port (wdat: in STD_Logic_vector(31 downto 0);
         wsel: in STD_Logic_vector(4 downto 0);
         wen : in STD_LOGIC;
         clk: in STD_LOGIC;
         nReset : in STD_LOGIC;
         rsel1: in STD_Logic_vector(4 downto 0);
         rsel2: in STD_Logic_vector(4 downto 0);
         rdat1: out STD_LOGIC_VECTOR(31 downto 0);
         rdat2: out STD_LOGIC_VECTOR(31 downto 0)
         );
  end component;

  signal wen : std_logic;
  signal nReset : std_logic;
  signal wsel : std_logic_vector(4 downto 0);
  signal rsel1, rsel2 : std_logic_vector(4 downto 0);
  signal wdat : std_logic_vector(31 downto 0);
  signal rdat1, rdat2 : std_logic_vector(31 downto 0);
begin
  RegFile0 : registerFile port
    map( wdat, wsel, wen, CLOCK_27, nReset, rsel1, rsel2, rdat1, rdat2 );
	-- WSel
  wsel <= SW(4 downto 0);
	-- Rdat1
  rsel1 <= SW(9 downto 5);
	-- Rdat2
  rsel2 <= SW(14 downto 10);
	-- Wen
  wen <= not KEY(3);  --  0 when not pressed
	-- nReset
  nReset <= KEY(2);   --  1 when not pressed

	-- Wdat
  wdat(2 downto 0) <= SW(17 downto 15);
	-- rest of wdat
  wdat(31 downto 3) <= "00000000000000000000000000000";
	-- Display register values on red leds over switches
  LEDR(8 downto 5) <=  rdat1(3 downto 0);
  LEDR(13 downto 10) <=  rdat2(3 downto 0);

end behav;

