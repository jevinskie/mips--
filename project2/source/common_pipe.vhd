-- this holds common type and record declarations for the pipelined
-- portion of the cpu

use work.common.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


package common_pipe is


   type ex_ctrl_type is record
      reg_dst     : std_logic;
      alu_src     : alu_src_type;
   end record;

   type mem_ctrl_type is record
      mem_read    : std_logic;
      mem_write   : std_logic;
   end record;

   type wb_ctrl_type is record
      reg_src     : reg_src_type;
      reg_write   : std_logic;
   end record;


   type if_id_reg_type is record
      ins : word;
   end record;

   type id_ex_reg_type is record
      rdat1    : word;
      rdat2    : word;
      sa       : shift_amount;
      imm      : immediate;
      rs       : reg_index;
      rt       : reg_index;
      rd       : reg_index;
      ex_ctrl  : ex_ctrl_type;
      mem_ctrl : mem_ctrl_type;
      wb_ctrl  : wb_ctrl_type;
      halt     : std_logic;
   end record;

   type ex_mem_reg_type is record
      alu_res  : word;
      mem_ctrl : mem_ctrl_type;
      wb_ctrl  : wb_ctrl_type;
      halt     : std_logic;
   end record;

   type mem_wb_reg_type is record
      alu_res  : word;
      lw_res   : word;
      wb_ctrl  : wb_ctrl_type;
      halt     : std_logic;
   end record;

   type all_pipe_reg_type is record
      if_id_reg   : if_id_reg_type;
      id_ex_reg   : id_ex_reg_type;
      ex_mem_reg  : ex_mem_reg_type;
      mem_wb_reg  : mem_wb_reg_type;
   end record;


end;


package body common_pipe is 
end;

