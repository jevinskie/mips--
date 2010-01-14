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

   signal reg_in  : regfile_in_type;
   signal reg_out : regfile_out_type;

begin

   regfile_b : regfile port map (
      clk => clk, nrst => nReset, d => reg_in, q => reg_out
   );

   reg_in.wen <= wen;
   reg_in.wsel <= to_reg_index(wsel);
   reg_in.wdat <= unsigned(wdat);
   reg_in.rsel1 <= to_reg_index(rsel1);
   reg_in.rsel2 <= to_reg_index(rsel2);

   rdat1 <= std_logic_vector(reg_out.rdat1);
   rdat2 <= std_logic_vector(reg_out.rdat2);

end;

