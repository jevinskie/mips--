library ieee;
use IEEE.STD_LOGIC_TEXTIO.all;
use STD.TEXTIO.all;
use ieee.std_logic_1164.all;


entity registerFile_tb is
end registerFile_tb;

architecture testbench_arch of registerFile_tb is
  component registerFile
    port (
      wdat   : in  std_logic_vector (31 downto 0);
      wsel   : in  std_logic_vector (4 downto 0);
      wen    : in  std_logic;
      clk    : in  std_logic;
      nReset : in  std_logic;
      rsel1  : in  std_logic_vector (4 downto 0);
      rsel2  : in  std_logic_vector (4 downto 0);
      rdat1  : out std_logic_vector (31 downto 0);
      rdat2  : out std_logic_vector (31 downto 0) );
  end component;

  signal wdat             : std_logic_vector (31 downto 0);
  signal wsel             : std_logic_vector (4 downto 0);
  signal wen, clk, nReset : std_logic;
  signal rsel2, rsel1     : std_logic_vector (4 downto 0);
  signal rdat2, rdat1     : std_logic_vector (31 downto 0);

  constant zero : std_logic_vector := "00000000000000000000000000000000";
  constant v1   : std_logic_vector := "00000000000000000000000000000001";
  constant v2   : std_logic_vector := "00000000000000000001001001110001";
  constant v3   : std_logic_vector := "00000000000000000110001000011111";

  procedure println( output_string : in string ) is
    variable lout                  :    line;
  begin
    WRITE(lout, output_string);
    WRITELINE(OUTPUT, lout);
  end println;

  procedure printlv( output_bv : in std_logic_vector ) is
    variable lout              :    line;
  begin
    WRITE(lout, output_bv);
    WRITELINE(OUTPUT, lout);
  end printlv;


begin
  DUT : registerFile
    port map (
      wdat   => wdat,
      wsel   => wsel,
      wen    => wen,
      nReset => nReset,
      rsel2  => rsel2,
      rdat2  => rdat2,
      rdat1  => rdat1,
      rsel1  => rsel1,
      clk    => clk
      );


  process

  begin

    println("");
    println("Starting Test");

    -- reset                            --------------
    nReset <= '0';
    wait for 50 ns;
    nReset <= '1';
    wdat   <= v1;
    wsel   <= "00111";
    wen    <= '1';
    rsel1  <= "00000";
    rsel2  <= "00111";
    -- --------------------
    wait for 50 ns;
    clk    <= '0';

    -- check to make sure nothing has been written yet 
    -- and that the reset is working
    if (rdat2 = zero) then
      println("PASSED   : no values passed through before clock edge");
    else
      println("FAILED   : value at wdat passed to rdat2 before clock edge");
      println("expected : ");
      printlv(zero);
      println("received : ");
      printlv(rdat2);
    end if;
    -- --------------------
    wait for 50 ns;
    clk <= '1';
    -- --------------------
    wait for 50 ns;
    clk <= '0';

    -- check written value to "00111";
    if (rdat2 = v1) then
      println("PASSED   : written value to register 00111 is ok");
    else
      println("FAILED   : written value is not the same");
      println("expected : ");
      printlv(v1);
      println("received : ");
      printlv(rdat2);
    end if;

    wdat <= v2;
    wen  <= '0';

    -- --------------------
    wait for 50 ns;
    clk <= '1';
    -- --------------------
    wait for 50 ns;
    clk <= '0';

    -- check to make sure wen stops writes

    if (rdat2 = v1) then
      println("PASSED   : wen controls writes");
    else
      println("FAILED   : register overwrote data");
      println("expected : ");
      printlv(v1);
      println("received : ");
      printlv(rdat2);

    end if;

    wdat  <= v3;
    wen   <= '1';
    wsel  <= "00000";
    rsel1 <= "00000";

    -- --------------------
    wait for 50 ns;
    clk <= '1';
    -- --------------------
    wait for 50 ns;
    clk <= '0';

    -- check to make sure writes to r0 do not modify zero


    if (rdat1 = zero) then
      println("PASSED   : r0 stays zero");
    else
      println("FAILED   : register r0 is not zero");
      println("expected : ");
      printlv(zero);
      println("received : ");
      printlv(rdat1);
    end if;

    -- --------------------
    wait for 50 ns;
    clk <= '1';
    -- --------------------
    wait for 50 ns;
    clk <= '0';

    -- check for reset again

    rsel1 <= "00111";

    nReset <= '0';
    wait for 5 ns;
    nReset <= '1';

    if (rdat1 = zero) then
      println("PASSED   : nReset works correctly");
    else
      println("FAILED   : nReset did not clear register 7");
      println("expected : ");
      printlv(zero);
      println("received : ");
      printlv(rdat1);
    end if;

    -- --------------------
    wait for 50 ns;
    clk <= '1';
    -- --------------------
    wait for 50 ns;
    clk <= '0';

    -- write a few values to various registers

    wsel <= "00010";
    wdat <= v1;

    -- --------------------
    wait for 50 ns;
    clk <= '1';
    -- --------------------
    wait for 50 ns;
    clk <= '0';

    wsel <= "00100";
    wdat <= v2;

    -- --------------------
    wait for 50 ns;
    clk <= '1';
    -- --------------------
    wait for 50 ns;
    clk <= '0';

    wsel <= "01000";
    wdat <= v3;

    -- --------------------
    wait for 50 ns;
    clk <= '1';
    -- --------------------
    wait for 50 ns;
    clk <= '0';

    wen   <= '0';
    rsel1 <= "00000";
    rsel2 <= "00000";

    -- let chug for a few cycles, shouldn't do anything

    -- --------------------
    wait for 50 ns;
    clk <= '1';
    -- --------------------
    wait for 50 ns;
    clk <= '0';
    -- --------------------
    wait for 50 ns;
    clk <= '1';
    -- --------------------
    wait for 50 ns;
    clk <= '0';
    -- --------------------
    wait for 50 ns;
    clk <= '1';
    -- --------------------
    wait for 50 ns;
    clk <= '0';

    -- check for asyncronous outputs

    rsel1 <= "00010";
    wait for 5 ns;
    if (rdat1 = v1) then
      println("PASSED   : rdat1 is asyncronous");
    else
      println("FAILED   : rdat1 is not a asyncronous mux");
      println("expected : ");
      printlv(v1);
      println("received : ");
      printlv(rdat1);
    end if;
    wait for 5 ns;

    rsel1 <= "00100";
    wait for 5 ns;
    if (rdat1 = v2) then
      println("PASSED   : rdat1 is asyncronous");
    else
      println("FAILED   : rdat1 is not a asyncronous mux");
      println("expected : ");
      printlv(v2);
      println("received : ");
      printlv(rdat1);
    end if;

    wait for 5 ns;

    rsel2 <= "01000";
    wait for 5 ns;
    if (rdat2 = v3) then
      println("PASSED   : rdat2 is asyncronous");
    else
      println("FAILED   : rdat2 is not a asyncronous mux");
      println("expected : ");
      printlv(v3);
      println("received : ");
      printlv(rdat1);
    end if;

    -- --------------------
    wait for 50 ns;
    clk <= '1';
    -- --------------------
    wait for 50 ns;
    clk <= '0';

    rsel1 <= "00010";
    rsel2 <= "00010";
    wait for 5 ns;
    if (rdat1 = rdat2) then
      println("PASSED            : rsel1 and rsel2 can read same register");
    else
      println("FAILED            : rdat1 and rdat2 are not reading same register");
      println("expected          : ");
      printlv(v1);
      println("received on rdat1 : ");
      printlv(rdat1);
      println("received on rdat2 : ");
      printlv(rdat2);
    end if;

    -- --------------------
    wait for 50 ns;
    clk <= '1';

    println("Test Complete");
    println("");

    -- end simulation
    wait;

  end process;
end testbench_arch;


