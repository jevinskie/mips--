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

      q.reg_dst   <= '0';
      q.mem_read  <= '0';
      -- ALERT
      q.reg_src   <= alu_reg_src;
      q.mem_write <= '0';
      -- ALERT
      q.alu_src   <= imm_alu_src;
      -- ALERT not 0
      q.reg_write <= '1';
      -- ALERT
      q.alu_op    <= sll_alu_op;

      case d.r_ins.op is
         -- R-type instructions
         when special_op =>
            q.reg_dst      <= '1';
            q.alu_src      <= reg_alu_src;
            case d.r_ins.func is
               when addu_s_func =>
                  q.alu_op    <= add_alu_op;

               when and_s_func =>
                  q.alu_op    <= and_alu_op;

               when jr_s_func =>
                  q.reg_write <= '0';

               when nor_s_func =>
                  q.alu_op    <= nor_alu_op;

               when or_s_func =>
                  q.alu_op    <= or_alu_op;

               when slt_s_func =>
                  q.alu_op    <= slt_alu_op;

               when sltu_s_func =>
                  q.alu_op    <= sltu_alu_op;

               when sll_s_func =>
                  q.alu_op    <= sll_alu_op;
                  q.alu_src   <= sa_alu_src;

               when srl_s_func =>
                  q.alu_op    <= srl_alu_op;
                  q.alu_src   <= sa_alu_src;

               when subu_s_func =>
                  q.alu_op    <= sub_alu_op;

               when xor_s_func =>
                  q.alu_op    <= xor_alu_op;

               when others =>
                  -- nothing
            end case;

         -- I-type instructions
         when addiu_op =>
            q.alu_op    <= add_alu_op;

         when andi_op =>
            q.alu_op    <= and_alu_op;
            q.alu_src   <= immu_alu_src;

         when beq_op =>
            q.alu_src   <= reg_alu_src;
            q.alu_op    <= sub_alu_op;
            q.reg_write <= '0';

         when bne_op =>
            q.alu_src   <= reg_alu_src;
            q.alu_op    <= sub_alu_op;
            q.reg_write <= '0';

         when lui_op =>
            -- since rs is defined by the ISA as $0 for LUI
            -- we can OR $0 with the shifted lui alu source to get the result
            q.alu_op    <= or_alu_op;
            q.alu_src   <= lui_alu_src;

         when lw_op =>
            q.alu_op    <= add_alu_op;
            q.reg_src   <= mem_reg_src;

         when ori_op =>
            q.alu_op    <= or_alu_op;
            q.alu_src   <= immu_alu_src;

         when slti_op =>
            q.alu_op    <= slt_alu_op;

         when sltiu_op =>
            q.alu_op    <= sltu_alu_op;

         when sw_op =>
            q.alu_op    <= add_alu_op;
            q.reg_write <= '0';
            q.mem_write <= '1';

         when ll_op =>

         when xori_op =>
            q.alu_op    <= xor_alu_op;
            q.alu_src   <= immu_alu_src;

         -- J-type instructions
         when j_op =>
            q.reg_write <= '0';
         
         when jal_op =>
            q.reg_src   <= pc_reg_src;

         when halt_op =>
            q.reg_write <= '0';
            q.mem_write <= '0';

         when others =>
            -- nothing
      end case;


   end process;

end;

