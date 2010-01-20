-- a wrapper for the registerFile course component to export a regfile_r component

use work.common.all;
use work.regfile_pkg.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity regfile_r is
   port (
      clk   : in  std_logic;
      nrst  : in  std_logic;
      d     : in  regfile_in_type;
      q     : out regfile_out_type
   );
end;      

architecture wrapper of regfile_r is

   component registerFile
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
   end component;

   signal wsel, rsel1, rsel2 : std_logic_vector(4 downto 0);
   signal wdat, rdat1, rdat2 : word_slv;

begin

   regfile_b : registerFile port map (
      clk => clk, nReset => nrst,
      wdat => wdat, wsel => wsel, wen => d.wen,
      rdat1 => rdat1, rdat2 => rdat2, rsel1 => rsel1, rsel2 => rsel2
   );

   wsel <= to_slv(d.wsel);
   wdat <= std_logic_vector(d.wdat);
   rsel1 <= to_slv(d.rsel1);
   rsel2 <= to_slv(d.rsel2);

   q.rdat1 <= unsigned(rdat1);
   q.rdat2 <= unsigned(rdat2);

end;

