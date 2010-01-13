-- a wrapper for the registerFile course component

use work.common.all;
use work.regfile_comp.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity registerFile is
   port (
      wdat     : in  std_logic_vector (31 downto 0);
      wsel     : in  std_logic_vector (4 downto 0);
      wen      : in  std_logic;
      clk      : in  std_logic;
      nReset   : in  std_logic;
      rsel1    : in  std_logic_vector (4 downto 0);
      rsel2    : in  std_logic_vector (4 downto 0);
      rdat1    : out std_logic_vector (31 downto 0);
      rdat2    : out std_logic_vector (31 downto 0)
   );
end registerFile;

architecture wrapper of registerFile is

   signal d : regfile_in_type;
   signal q : regfile_out_type;

begin

   regfile_b : regfile port map (
      clk => clk, nrst => nReset, d => d, q => q
   );

   d.wen <= wen;
   d.wsel <= to_reg_index(wsel);
   d.wdat <= unsigned(wdat);
   d.rsel1 <= to_reg_index(rsel1);
   d.rsel2 <= to_reg_index(rsel2);

   rdat1 <= std_logic_vector(q.rdat1);
   rdat2 <= std_logic_vector(q.rdat2);

end;

