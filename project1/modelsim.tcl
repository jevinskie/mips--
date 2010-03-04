
# a run command that suppresses metavalue warnings before reset
proc runq args {
   global NumericStdNoWarnings;
   set NumericStdNoWarnings 1;
   echo "Suppressing numeric_std warnings during reset";
   when -label enable_numeric_std_warn \
      { /tb_cpu/dut/cpu_b/nrst == '1' } \
      { echo "Re-enabled numeric_std warnings"; set NumericStdNoWarnings 0; nowhen enable_numeric_std_warn; };
   run $args;
}

