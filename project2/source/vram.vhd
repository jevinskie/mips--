library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_arith.all; 
use IEEE.std_logic_unsigned.all; 

entity vram is
	port
	(
		nReset		: in std_logic ;		
		clock		: in std_logic ;
		address		: in std_logic_vector (15 DOWNTO 0);
		data		: in std_logic_vector (31 DOWNTO 0);
		wren		: in std_logic ;
		rden		: in std_logic ;
		halt		: in std_logic ; 
		q		: out std_logic_vector (31 DOWNTO 0);
		memstate	: out std_logic_vector (1 DOWNTO 0)
	);

end vram;

architecture vram_arch of vram is

 	component ram
    	PORT
	(
		address		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		clock		: IN STD_LOGIC ;
		data		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		wren		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
  	end component;

	-- you can change this for testing purpose to make sure your pipeline can handle flexible latency.
	-- when latency is 5, the counter counts 1 to 5 then hits ready state, ready/access state itself takes one cycle,
	-- therefore, the memory operation will actually take LATENCY + 1 cycle to complete before next operation starts. 
	-- if LATENCY is set to 0, then there will be no busy state and counter will not count, 
	-- it will go straight to ready state and takes only one cycle to access the memory like lab4. 
	-- also keep in mind that LATENCY conunter is 4 bits, do not change to some number beyond, like a million. :)
	constant LATENCY	: std_logic_vector		:= x"02";
	
	-- when memory is in free or busy or error or reset state, this are the temperay outputs and also dummy outputs.
	-- only when memory hits ready state, then your read or write will be completed. you can change this as well. 
	constant BAD1BAD1	: std_logic_vector		:= x"BAD1BAD1";
	constant BAD1		: std_logic_vector		:= x"BAD1";		

	-- MEMFREE : when read enable (rden) or write enable (wren) are both '0', then memory is free to use
	-- MEMBUSY : when either read enable (rden) or write enable (wren) is '1', then memory enters busy state, 
	--		input address and data are also taken at the memont read or write flag is on. 
	--		when memory is in busy state, it will ignore the control signals (wren and rden)
	--		and data signals (address and data) for next LATENCY cycles. only reset signal can interrupt.
	-- MEMREADY: memory hits ready state when counter reaches LATENCY, then your read or write opreation are completed, 
	--		ready state will only last for one cycle, your read result will be on the 'q' signal in this state
	--		and your write will only be completed in ready state.
	-- MEMERROR: when read enable (rden) or write enable (wren) are both '1', then memory encounters error until flags changes.
	-- 		state changes are happening on falling edge of clock just like ram.vhd and your memories in lab4.
	constant MEMFREE	: std_logic_vector		:= "00";
	constant MEMBUSY	: std_logic_vector		:= "01";
	constant MEMREADY	: std_logic_vector		:= "10";
	constant MEMERROR	: std_logic_vector		:= "11";

	-- for internal read or write control state.
	constant READ		: std_logic			:= '0';
	constant WRITE		: std_logic			:= '1';

	-- internal write enable, temperay q, temperay data, and temperay address. used as wrapper signals to ram.vhd
	signal write_en		: std_logic;
	signal data_out		: std_logic_vector (31 downto 0);
	signal tempdata 	: std_logic_vector (31 downto 0);
	signal tempaddr	 	: std_logic_vector (15 downto 0);

	-- internal state signal connecting to output memstate signal, flag to MEMFREE, MEMBUSY, MEMREADY, and MEMERROR.
	-- internal memory operation control signal, flag to READ or WRITE base on wren and rden inputs at the begining of busy state.
	-- internal count signal in latency counter. 4 bits counter.
	signal state		: std_logic_vector (1 DOWNTO 0);
	signal memop		: std_logic;
	signal count		: std_logic_vector (3 downto 0);

begin
 	SYNRAM : ram
	port map ( tempaddr, clock, tempdata, write_en, data_out );

	memory: process(clock, nReset, wren, rden, state, count, halt, address, data, data_out)
	begin
		if nReset = '0' then
			state <= MEMFREE;
			memop <= READ;
			write_en <= '0';
			tempaddr <= BAD1;
			tempdata <= BAD1BAD1;
			q <= BAD1BAD1;
			count <= x"0";
		elsif(LATENCY = x"0" or halt = '1') then
                        if(wren = '1' and rden = '1') then
                                state <= MEMERROR;
                                memop <= READ;
                                write_en <= '0';
                                tempaddr <= BAD1;
                                tempdata <= BAD1BAD1;
                                q <= BAD1BAD1;
                                count <= x"0";
			elsif(wren = '1' and rden = '0') then
				state <= MEMREADY;
				memop <= WRITE;
				write_en <= '1';
				tempaddr <= address;
				tempdata <= data;
				count <= x"0";	
			elsif(wren = '0' and rden = '1') then
				state <= MEMREADY;
				memop <= READ;
				write_en <= '0';
				tempaddr <= address;
				q <= data_out;
				count <= x"0";
			elsif (wren = '0' and rden = '0') then
                                state <= MEMFREE;
                                memop <= READ;
                                write_en <= '0';
                                tempaddr <= BAD1;
                                tempdata <= BAD1BAD1;
                                q <= BAD1BAD1;
                                count <= x"0";
			end if;		
		elsif (falling_edge(clock)) then
			if(state = MEMBUSY) then	
				if (count = LATENCY) then
					if (memop = WRITE) then
						write_en <= '1';
					elsif (memop = READ) then								 
						q <= data_out;
						write_en <= '0';
					end if;	
					state <= MEMREADY;
					count <= x"0";
				else
					count <= count + 1;
				end if;
			else
				if (wren = '1' and rden = '1') then
					state <= MEMERROR;
					memop <= READ;
					write_en <= '0';	
					tempaddr <= BAD1;
					tempdata <= BAD1BAD1;
					q <= BAD1BAD1;
					count <= x"0";
				elsif (wren = '1' and rden = '0') then
					state <= MEMBUSY;
					memop <= WRITE;
					write_en <= '0';	
					tempaddr <= address;
					tempdata <= data;
					count <= count + 1;	
				elsif (wren = '0' and rden = '1') then
					state <= MEMBUSY;
					memop <= READ;
					write_en <= '0';	
					tempaddr <= address;
					tempdata <= data;
					count <= count + 1;
				elsif (wren = '0' and rden = '0') then
					state <= MEMFREE;
					memop <= READ;
					write_en <= '0';	
					tempaddr <= BAD1;
					tempdata <= BAD1BAD1;
					q <= BAD1BAD1;
					count <= x"0";
				end if;
			end if; 
		end if;
	end process;
			
	memstate <= state;	
end vram_arch;
