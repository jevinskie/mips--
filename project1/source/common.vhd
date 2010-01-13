-- this holds common type and record declarations


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


package common is

   constant num_regs : integer := 32;

   subtype byte is unsigned(7 downto 0);
   subtype hword is unsigned(15 downto 0);
   subtype word is unsigned(31 downto 0);
   subtype doubleword is unsigned(63 downto 0);

   subtype reg_index is integer range 0 to num_regs-1;

   function to_reg_index(i_slv : std_logic_vector)
      return reg_index;

end;

package body common is

      function to_reg_index(i_slv : std_logic_vector)
      return reg_index
   is
      variable i : integer;
   begin
      i := to_integer(unsigned(i_slv));
      if i >= reg_index'low and i <= reg_index'high then
         return i;
      else
         assert false;
         return 0;
      end if;
   end;

end;
