#!/usr/bin/perl

use strict;
use warnings;

use Carp;
use File::Compare;

my @asm_files = @ARGV;

foreach my $file (@asm_files)
{
   print "Testing $file:\n";
   assemble($file);
   my $num_ins = simulate();
   my $pipe_cycles = vsim();
   my $pipe_cpi = $pipe_cycles / $num_ins;
   check_results() or print "pipeline failed for $file!\n";
   chdir("../project1");
   assemble($file);
   simulate();
   my $sc_cycles = vsim();
   my $sc_cpi = $sc_cycles / $num_ins;
   check_results() or print "singlecycle failed for $file\n";
   print "Instructions: $num_ins\n";
   print "Pipeline Cycles: $pipe_cycles\n";
   print "Pipeline CPI: $pipe_cpi\n";
   print "Singlecycle Cycles: $sc_cycles\n";
   print "Singlecycle CPI: $sc_cpi\n";
   chdir("../project2");
}

sub assemble
{
   my $file = shift;

   system("asm $file") == 0 or croak;

   return;
}

sub simulate
{
   my $sim_out = `sim -t`;

   $sim_out =~ m/TOTAL:\s+(\d+)/;

   return $1;
}

sub vsim
{
   my $vsim_out = `vsim -c -do "source modelsim.tcl; vsim tb_cpu; runq -a; quit;"`;

   $vsim_out =~ m/# Halted, cycles=(\d+)/;

   return $1;
}

# returns 1 if OK
sub check_results
{
   return !compare("memdump.hex", "memout.hex");
}

