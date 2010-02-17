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
			-- start mmio addins
			-- dip switch in
			dipIn						:		in	std_logic_vector(15 downto 0);
			-- hexout
			hexOut					:		out	std_logic_vector(31 downto 0);
			-- end mmio addins
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
	signal dipin					:	std_logic_vector (15 downto 0);
	signal hexout					:	std_logic_vector (31 downto 0);

begin

	cpu_comp : cpu port map (
		CLK       		=> CLOCK_27,
		nReset    		=> KEY (3),
		halt      		=> LEDG (8),
		imemAddr			=> imemAddr,
		imemData			=> imemData,
		dmemAddr			=> dmemAddr,
		dmemDataRead	=> dmemDataRead,
		dmemDataWrite	=> dmemDataWrite,
		dipIn					=> dipin,
		hexOut				=> hexout,
		dumpAddr			=> dpaddr);

	--port map decoders to show address:
	--BTH0: bintohexDecoder port map (dmemDataRead (3 downto 0), HEX0);
	--BTH1: bintohexDecoder port map (dmemDataRead (7 downto 4), HEX1);	
	--BTH2: bintohexDecoder port map (dmemDataRead (11 downto 8), HEX2);
	--BTH3: bintohexDecoder port map (dmemDataRead (15 downto 12), HEX3);
	--BTH4: bintohexDecoder port map (dmemDataRead (19 downto 16), HEX4);
	--BTH5: bintohexDecoder port map (dmemDataRead (23 downto 20), HEX5);
	--BTH6: bintohexDecoder port map (dmemDataRead (27 downto 24), HEX6);
	--BTH7: bintohexDecoder port map (dmemDataRead (31 downto 28), HEX7);

	-- mmio output
	BTH0: bintohexDecoder port map (hexout(3 downto 0), HEX0);
	BTH1: bintohexDecoder port map (hexout(7 downto 4), HEX1);	
	BTH2: bintohexDecoder port map (hexout(11 downto 8), HEX2);
	BTH3: bintohexDecoder port map (hexout(15 downto 12), HEX3);
	BTH4: bintohexDecoder port map (hexout(19 downto 16), HEX4);
	BTH5: bintohexDecoder port map (hexout(23 downto 20), HEX5);
	BTH6: bintohexDecoder port map (hexout(27 downto 24), HEX6);
	BTH7: bintohexDecoder port map (hexout(31 downto 28), HEX7);

	-- address to dump
	--dpaddr <= SW (15 downto 0);
	dpaddr <= (others => '0');
	-- mmio dip switches
	dipin <= SW (15 downto 0);
end behavioral;
