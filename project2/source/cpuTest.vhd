library ieee;
use ieee.std_logic_1164.all;

entity cpuTest is
	port (
		-- clock
		CLOCK_27            : in    std_logic;
		-- switches
		SW      						: in    std_logic_vector(17 downto 0);
		-- the push keys
		KEY      						: in    std_logic_vector(3 downto 0);
		-- the 7seg display
		HEX0								:	out		std_logic_vector(6 downto 0);
		HEX1								:	out		std_logic_vector(6 downto 0);
		HEX2								:	out		std_logic_vector(6 downto 0);
		HEX3								:	out		std_logic_vector(6 downto 0);
		HEX4								:	out		std_logic_vector(6 downto 0);
		HEX5								:	out		std_logic_vector(6 downto 0);
		HEX6								:	out		std_logic_vector(6 downto 0);
		HEX7								:	out		std_logic_vector(6 downto 0);
		-- general perpose io (both have 36 pins but logic analyzer only supports 64)
		GPIO_0							: out		std_logic_vector(31 downto 0);
		GPIO_1							: out		std_logic_vector(31 downto 0);
		-- the leds
		LEDG             		: out   std_logic_vector(8 downto 0)
	);
end cpuTest;

architecture behavioral of cpuTest is

	component cpu
		port (
			-- clock signal
			CLK					:		in	std_logic;
			-- reset for processor
			nReset			:		in	std_logic;
			-- halt for processor
			halt				:		out	std_logic;
			-- instruction memory address
			imemAddr		:		out	std_logic_vector(31 downto 0);
			-- instruction data to the cpu
			imemData		:	out		std_logic_vector(31 downto 0);
			-- data memory address
			dmemAddr		:	out		std_logic_vector(31 downto 0);
			-- data read from memory
			dmemDataRead		:	out		std_logic_vector(31 downto 0);
			-- data written to memory
			dmemDataWrite		:	out		std_logic_vector(31 downto 0);
			-- address to dump
			dumpAddr : in std_logic_vector(15 downto 0)
		);
	end component;

	-- 7segment display decoder
	component bintohexDecoder
		port (
			input		:		in	std_logic_vector(3 downto 0);
			output	:		out	std_logic_vector(6 downto 0));
	end component;

	-- signals here
	signal imemAddr				:	std_logic_vector (31 downto 0);
	signal imemData				:	std_logic_vector (31 downto 0);
	signal dmemAddr				:	std_logic_vector (31 downto 0);
	signal dmemDataRead		:	std_logic_vector (31 downto 0);
	signal dmemDataWrite	:	std_logic_vector (31 downto 0);
	signal dpaddr					:	std_logic_vector (15 downto 0);
	signal halt						:	std_logic;

begin

	cpu_comp : cpu port map (
		CLK       		=> CLOCK_27,
		nReset    		=> KEY (3),
		halt      		=> halt, --LEDG (8),
		imemAddr			=> imemAddr,
		imemData			=> imemData,
		dmemAddr			=> dmemAddr,
		dmemDataRead	=> dmemDataRead,
		dmemDataWrite	=> dmemDataWrite,
		dumpAddr			=> dpaddr);

	--port map decoders:
	BTH0: bintohexDecoder port map (dmemDataRead (3 downto 0), HEX0);
	BTH1: bintohexDecoder port map (dmemDataRead (7 downto 4), HEX1);	
	BTH2: bintohexDecoder port map (dmemDataRead (11 downto 8), HEX2);
	BTH3: bintohexDecoder port map (dmemDataRead (15 downto 12), HEX3);
	BTH4: bintohexDecoder port map (dmemDataRead (19 downto 16), HEX4);
	BTH5: bintohexDecoder port map (dmemDataRead (23 downto 20), HEX5);
	BTH6: bintohexDecoder port map (dmemDataRead (27 downto 24), HEX6);
	BTH7: bintohexDecoder port map (dmemDataRead (31 downto 28), HEX7);

	-- address to dump i cut off the last 2 bits
	-- which are always 0 for 4 byte aligned memory spaces
	dpaddr(15 downto 2) <= SW (13 downto 0);
	dpaddr(1 downto 0) <= "00";
	-- halt signal
	LEDG(8) <= halt;

	-- logic analyzer mux use switches 17 downto 14
	-- signals we need to always have:
	-- clock
	GPIO_0(31) <= CLOCK_27;
	-- nreset
	GPIO_0(30) <= KEY(3);
	-- halt
	GPIO_0(29) <= halt;
	-- user definable pins 29 of them
	-- can use 17 downto 16 for GPIO_0(28 downto 0)
	GPIO_0(28 downto 0) <= "00000000000000000000000000000";
	
	-- databus/addr toggle between instr and data
	with SW(15 downto 14) select
		GPIO_1 <= imemData when "01",
							dmemDataRead when "10",
							dmemDataWrite when "11",
							imemAddr(15 downto 0) & dmemAddr(15 downto 0) when others;

end behavioral;
