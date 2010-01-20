-- adder/subtractor block (record style) for the alu

use work.common.all;
use work.addsub_pkg.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity addsub_r is
   port (
      d : in  addsub_in_type;
      q : out addsub_out_type
   );
end;


architecture dataflow of addsub_r is
begin

end;

