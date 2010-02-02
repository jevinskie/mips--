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

      q.reg_dst      <= '0';
      q.jump         <= '0';
      q.branch       <= '0';
      q.mem_read     <= '0';
      -- ALERT not 0
      q.mem_to_reg   <= '1';
      q.mem_write    <= '0';
      -- ALERT
      q.alu_src      <= imm_alu_src;
      -- ALERT not 0
      q.reg_write    <= '1';

      case d.r_ins.op is
         -- R-type instructions
         when special_op =>
            q.reg_dst      <= '1';
            q.alu_src      <= reg_alu_src;
            case d.r_ins.func is
               when addu_s_func =>
               
               when and_s_func =>

               when jr_s_func =>
                  q.reg_write <= '0';

               when nor_s_func =>

               when or_s_func =>

               when slt_s_func =>

               when sltu_s_func =>

               when sll_s_func =>
                  q.alu_src <= sa_alu_src;

               when srl_s_func =>
                  q.alu_src <= sa_alu_src;

               when subu_s_func =>

               when xor_s_func =>

               when others =>
                  -- nothing
            end case;

         -- I-type instructions
         when addiu_op =>

         when andi_op =>
            q.alu_src      <= immu_alu_src;

         when lui_op =>
            q.alu_src      <= lui_alu_src;

         when lw_op =>

         when ori_op =>
            q.alu_src      <= immu_alu_src;

         when slti_op =>

         when sltiu_op =>

         when sw_op =>

         when ll_op =>

         when xori_op =>
            q.alu_src      <= immu_alu_src;

         -- J-type instructions
         when j_op =>
            q.jump         <= '1';
         
         when jal_op =>
            q.branch       <= '1';

         when halt_op =>
            q.reg_write    <= '0';
            q.mem_write    <= '0';

         when others =>
            -- nothing
      end case;


   end process;

end;

