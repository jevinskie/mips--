use work.dual_pkg.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- do not change this entity
-- yes the signal lengths are correct
entity cpu is
   port (
      -- clock signal
      CLK            : in std_logic;
      -- reset for processor
      nReset         : in std_logic;
      -- halt for processor
      halt           : out std_logic;
      -- instruction memory address
      imemAddr       : out std_logic_vector(31 downto 0);
      -- instruction data to the cpu
      imemData       : out std_logic_vector(31 downto 0);
      -- data memory address
      dmemAddr       : out std_logic_vector(31 downto 0);
      -- data read from memory
      dmemDataRead   : out std_logic_vector(31 downto 0);
      -- data written to memory
      dmemDataWrite  : out std_logic_vector(31 downto 0);
      -- start mmio addins
      -- dip switch in
      dipIn          : in std_logic_vector(15 downto 0);
      -- hexout
      hexOut         : out std_logic_vector(31 downto 0);
      -- end mmio addins
      -- address to dump
      dumpAddr       : in std_logic_vector(15 downto 0)
   );
end cpu;

architecture behavioral of cpu is

   signal dual_in  : dual_in_type;
   signal dual_out : dual_out_type;

begin

	dual_b : dual_r port map (
      clk => CLK, nrst => nReset,
      d => dual_in, q => dual_out
   );

   dual_in.dump_addr <= unsigned(dumpAddr);

   imemAddr <= std_logic_vector(dual_out.imem_addr);
   imemData <= std_logic_vector(dual_out.imem_dat);
   dmemAddr <= std_logic_vector(dual_out.dmem_addr);
   dmemDataRead <= std_logic_vector(dual_out.dmem_rdat);
   dmemDataWrite <= std_logic_vector(dual_out.dmem_wdat);
   halt <= dual_out.halt;

   hexOut <= (others => '0');

end;

