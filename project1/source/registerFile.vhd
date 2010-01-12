-- 32 bit version register file
-- evillase

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity registerFile is
	port
	(
		-- Write data input port
		wdat		:	in	std_logic_vector (31 downto 0);
		-- Select which register to write
		wsel		:	in	std_logic_vector (4 downto 0);
		-- Write Enable for entire register file
		wen			:	in	std_logic;
		-- clock, positive edge triggered
		clk			:	in	std_logic;
		-- REMEMBER: nReset-> '0' = RESET, '1' = RUN
		nReset	:	in	std_logic;
		-- Select which register to read on rdat1 
		rsel1		:	in	std_logic_vector (4 downto 0);
		-- Select which register to read on rdat2
		rsel2		:	in	std_logic_vector (4 downto 0);
		-- read port 1
		rdat1		:	out	std_logic_vector (31 downto 0);
		-- read port 2
		rdat2		:	out	std_logic_vector (31 downto 0)
		);
end registerFile;

architecture regfile_arch of registerFile is

	constant BAD1	:	std_logic_vector		:= x"BAD1BAD1";

	type REGISTER32 is array (1 to 31) of std_logic_vector(31 downto 0);
	signal reg	:	REGISTER32;				-- registers as an array
   signal next_reg : REGISTER32;

  -- enable lines... use en(x) to select
  -- individual lines for each register
	signal en		:	std_logic_vector(31 downto 0);

begin

	-- registers process
	registers : process (clk, nReset, en)
  begin
    -- one register if statement
		if (nReset = '0') then
			for i in reg'range loop
            reg(i) <= (others => '0');
         end loop;
    elsif (rising_edge(clk)) then
       reg <= next_reg;
    end if;
  end process;

   nsl : process(wsel, wen, wdat, reg)
   begin
      next_reg <= reg;
      if (wen = '1') then
         if (wsel /= "00000") then
            next_reg(to_integer(unsigned(wsel))) <= wdat;
         end if;
      end if;
   end process;

   output : process(rsel1, rsel2, reg)
      variable vsel1, vsel2 : integer;
   begin
      vsel1 := to_integer(unsigned(rsel1));
      if (vsel1 /= 0) then
         rdat1 <= reg(vsel1);
      else
         rdat1 <= (others => '0');
      end if;

      vsel2 := to_integer(unsigned(rsel2));
      if (vsel2 /= 0) then
         rdat2 <= reg(vsel2);
      else
         rdat2 <= (others => '0');
      end if;
   end process;

end regfile_arch;
