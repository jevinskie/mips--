-- control block

use work.common.all;
use work.ctrl_pkg.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity ctrl_r is
   port (
      d : in  ctrl_in_type;
      q : out ctrl_out_type
   );
end;


architecture twoproc of ctrl_r is

begin
   
   
   -- combinatiorial process
   comb : process(d)
   begin
      -- module algorithm

      q.reg_dst            <= '0';
      
      q.ex_ctrl.alu_src    <= imm_alu_src;
      q.ex_ctrl.alu_op     <= sll_alu_op;

      q.mem_ctrl.mem_read  <= '0';
      q.mem_ctrl.mem_write <= '0';
      
      q.wb_ctrl.reg_src <= alu_reg_src;
      q.wb_ctrl.reg_write <= '1';

      case d.r_ins.op is
         -- R-type instructions
         when special_op =>
            q.reg_dst <= '1';
            q.ex_ctrl.alu_src <= reg_alu_src;
            case d.r_ins.func is
               when addu_s_func =>
                  q.ex_ctrl.alu_op     <= add_alu_op;

               when and_s_func =>
                  q.ex_ctrl.alu_op     <= and_alu_op;

               when jr_s_func =>
                  q.wb_ctrl.reg_write  <= '0';

               when nor_s_func =>
                  q.ex_ctrl.alu_op     <= nor_alu_op;

               when or_s_func =>
                  q.ex_ctrl.alu_op     <= or_alu_op;

               when slt_s_func =>
                  q.ex_ctrl.alu_op     <= slt_alu_op;

               when sltu_s_func =>
                  q.ex_ctrl.alu_op     <= sltu_alu_op;

               when sll_s_func =>
                  q.ex_ctrl.alu_src    <= sa_alu_src;
                  q.ex_ctrl.alu_op     <= sll_alu_op;

               when srl_s_func =>
                  q.ex_ctrl.alu_src    <= sa_alu_src;
                  q.ex_ctrl.alu_op     <= srl_alu_op;

               when subu_s_func =>
                  q.ex_ctrl.alu_op     <= sub_alu_op;

               when xor_s_func =>
                  q.ex_ctrl.alu_op     <= xor_alu_op;

               when others =>
                  -- nothing
            end case;

         -- I-type instructions
         when addiu_op =>
            q.ex_ctrl.alu_op     <= add_alu_op;

         when andi_op =>
            q.ex_ctrl.alu_src    <= immu_alu_src;
            q.ex_ctrl.alu_op     <= and_alu_op;

         when beq_op =>
            q.ex_ctrl.alu_src    <= reg_alu_src;
            q.ex_ctrl.alu_op     <= sub_alu_op;
            q.wb_ctrl.reg_write  <= '0';

         when bne_op =>
            q.ex_ctrl.alu_src    <= reg_alu_src;
            q.ex_ctrl.alu_op     <= sub_alu_op;
            q.wb_ctrl.reg_write  <= '0';

         when lui_op =>
            -- since rs is defined by the ISA as $0 for LUI
            -- we can OR $0 with the shifted lui alu source to get the result
            q.ex_ctrl.alu_src    <= lui_alu_src;
            q.ex_ctrl.alu_op     <= or_alu_op;

         when lw_op =>
            q.ex_ctrl.alu_op     <= add_alu_op;
            q.wb_ctrl.reg_src    <= mem_reg_src;
            q.mem_ctrl.mem_read  <= '1';

         when ori_op =>
            q.ex_ctrl.alu_src    <= immu_alu_src;
            q.ex_ctrl.alu_op     <= or_alu_op;

         when slti_op =>
            q.ex_ctrl.alu_op     <= slt_alu_op;

         when sltiu_op =>
            q.ex_ctrl.alu_op     <= sltu_alu_op;

         when sw_op =>
            q.ex_ctrl.alu_op     <= add_alu_op;
            q.mem_ctrl.mem_write <= '1';
            q.wb_ctrl.reg_write  <= '0';

         when ll_op =>

         when xori_op =>
            q.ex_ctrl.alu_src    <= immu_alu_src;
            q.ex_ctrl.alu_op     <= xor_alu_op;

         -- J-type instructions
         when j_op =>
            q.wb_ctrl.reg_write  <= '0';
         
         when jal_op =>
            q.wb_ctrl.reg_src    <= pc_reg_src;

         when halt_op =>
            q.mem_ctrl.mem_write <= '0';
            q.wb_ctrl.reg_write  <= '0';

         when others =>
            -- nothing
      end case;


   end process;

end;

