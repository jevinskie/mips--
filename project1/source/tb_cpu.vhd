library ieee;
use std.textio.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use ieee.std_logic_arith.all;

entity tb_cpu is
	generic (Period : Time := 10 ns);
end tb_cpu;

architecture tb_arch of tb_cpu is

	-- cpu
	component cpu
		port(
			-- begin ports needed for synthesis testing
			altera_reserved_tms	:		in	std_logic;
			altera_reserved_tck	:		in	std_logic;
			altera_reserved_tdi	:		in	std_logic;
			-- end ports needed for synthesis testing
			-- clock signal
    	CLK									:		in	std_logic;
			-- reset for processor
    	nReset							:		in	std_logic;
			-- halt for processor
    	halt								:		out	std_logic;
			-- instruction memory address
			imemAddr						:		out	std_logic_vector(31 downto 0);
			-- instruction data read from memory
    	imemData						:		out	std_logic_vector(31 downto 0);
			-- data memory address
			dmemAddr						:		out	std_logic_vector(31 downto 0);
			-- data read from memory
    	dmemDataRead				:		out	std_logic_vector(31 downto 0);
			-- data written to memory
    	dmemDataWrite				:		out	std_logic_vector(31 downto 0);
			-- memory address to dump
    	dumpAddr						:		in	std_logic_vector(15 downto 0)
		);
	end component; 

-- function convert std_logic_vector to integer
function vec2int (slv: std_logic_vector) return integer is
  variable retval		: integer := 0;
  alias vec					: std_logic_vector(slv'length-1 downto 0) is slv;
 begin
  for i in vec'high downto 1 loop
   if (vec(i) = '1') then
    retval := (retval + 1) * 2;
   else
		retval := retval * 2;
   end if;
  end loop;
  if (vec(0)='1') then 
   retval := retval + 1;
  end if;
  return retval;
 end vec2int; 


	-- signals here
  signal clk, nReset, halt												: std_logic;
	signal memout, imemData, dmemDataWrite					:	std_logic_vector(31 downto 0);
	signal imemAddr, dmemAddr												:	std_logic_vector(31 downto 0);
	-- supply address that we want to dump
	signal address																	:	std_logic_vector(15 downto 0);

begin

  DUT: cpu port map(
			-- begin ports needed for synthesis testing
			altera_reserved_tms	=>	'0',
			altera_reserved_tck	=>	'0',
			altera_reserved_tdi	=>	'0',
			-- end ports needed for synthesis testing
    	CLK									=> clk,
    	nReset							=> nReset,
    	halt								=> halt,
			imemAddr						=> imemAddr,
    	imemData						=> imemData,
			dmemAddr						=> dmemAddr,
    	dmemDataRead				=> memout,
    	dmemDataWrite				=> dmemDataWrite,
    	dumpAddr						=> address); 


	-- generate clock signal
  clkgen: process
    variable clk_tmp : std_logic := '0';
  begin
    clk_tmp := not clk_tmp;
    clk <= clk_tmp;
    wait for Period/2;
  end process;

	-- start computer
  testingprocess : process
  begin
    nReset <= '0';
    wait for 2 ns;
    nReset <= '1';
    wait on halt;
    wait on halt;  
  end process;

	-- print cycles for execution
  printprocess : process
    variable cycles : integer := 0;
    variable lout : line;
  begin
    cycles := cycles + 1;
    if (halt = '1') then
      write(lout, string'("Halted, cycles="));
      write(lout, integer'(cycles));
      writeline(output, lout);
			wait on halt;
    end if;
    wait for Period;
  end process;
  
	-- dumps memory to file
	-- change memout and address to reflect component and portmap
	-- also change filename for output if necessary
	dump_mem: process 
		file my_output : text;
		variable my_line : line;
		variable my_output_line : line;
		variable i : integer := 0;
		variable j : integer := 0;
		variable field1 : integer := 0;
		variable field2 : integer := 0;
		variable field3 : integer := 0;
		variable field4 : integer := 0;
		variable field5 : integer := 0;
		variable field6 : integer := 0;
		variable field7 : integer := 0;
		variable field8 : integer := 0;
		variable checksum : integer := 0;
		variable tmp : std_logic_vector(63 downto 0);
		
		begin
			address <= x"0000";
			wait on halt;
			if (halt = '1') then
				-- open file for writing you may change filename
				file_open(my_output, "memout.hex", write_mode);
				-- set address
				address <= conv_std_logic_vector(0, 16);
				-- give address time to output
				wait for Period;
				-- pipeline change this value to 8191
				-- single cycle change this value to 4095
				-- for each spot in memory loop
				for i in 0 to 4095 loop
					-- fix address translation
					j := i*4;
					-- assign address
					address <= conv_std_logic_vector(j, 16);
					-- wait for output
					wait for Period*2;
					-- check if output has value
					if (memout /= x"00000000") then
						-- temp string so we can add 2 digit hex values for checksum
						tmp := x"04" & conv_std_logic_vector(i, 16) & x"00" & memout;
						-- fields of 2 digit hex values
						field1 := vec2int(tmp(63 downto 56));
						field2 := vec2int(tmp(55 downto 48));
						field3 :=	vec2int(tmp(47 downto 40));
						field4 := vec2int(tmp(39 downto 32));
						field5 := vec2int(tmp(31 downto 24));
						field6 := vec2int(tmp(23 downto 16));
						field7 := vec2int(tmp(15 downto 8));
						field8 := vec2int(tmp(7 downto 0));
						-- compute checksum add fields
						checksum := field1 + field2 + field3 + field4 + field5 + field6 + field7 + field8;
						-- subtract from 0x100
						checksum := 16#100# - checksum;
						-- start outputing intel hex fields
						-- start character
						write(my_line, ':');
						-- size of data
						hwrite(my_line, conv_std_logic_vector(4, 8));
						-- address
						hwrite(my_line, conv_std_logic_vector(i, 16));
						-- type of data
						hwrite(my_line, conv_std_logic_vector(0, 8));
						-- data at address
						hwrite(my_line, memout);
						-- checksum
						hwrite(my_line, conv_std_logic_vector(checksum,8));
						-- write to file
						writeline(my_output, my_line);
					end if;
					-- wait rest of clock cycle
					wait for Period;
				end loop;
				-- write last line of hex file
				write(my_line, ':');
				hwrite(my_line, conv_std_logic_vector(0,8));
				hwrite(my_line, conv_std_logic_vector(0,16));
				hwrite(my_line, conv_std_logic_vector(1,8));
				hwrite(my_line, conv_std_logic_vector(255,8));
				writeline(my_output, my_line);
				-- close file
				file_close(my_output);
				-- so we don't keep looping
      	write(my_line, string'("dumped memory"));
      	writeline(OUTPUT, my_line);
				wait;
			end if; -- end if halt
		end process;

end tb_arch;
