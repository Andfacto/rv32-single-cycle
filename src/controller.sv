`timescale 1ns / 1ps

module controller
    import riscv_pkg::*;
    import custom_pkg::*;
    (
    input  logic [31:0] instr_i,
    output logic [17:0] ctrl_o
    );
    
    always_comb begin
        casez({instr_i[31:25], instr_i[24:20], instr_i[14:12], instr_i[6:0]})
            LUI    : ctrl_o = MI_LUI;
            AUIPC  : ctrl_o = MI_AUIPC;
            JAL    : ctrl_o = MI_JAL;
            JALR   : ctrl_o = MI_JALR;
            BEQ    : ctrl_o = MI_BEQ;
            BNE    : ctrl_o = MI_BNE;
            BLT    : ctrl_o = MI_BLT;
            BGE    : ctrl_o = MI_BGE;
            BLTU   : ctrl_o = MI_BLTU;
            BGEU   : ctrl_o = MI_BGEU;
            LB     : ctrl_o = MI_LB;
            LH     : ctrl_o = MI_LH;
            LW     : ctrl_o = MI_LW;
            LBU    : ctrl_o = MI_LBU;
            LHU    : ctrl_o = MI_LHU;
            SB     : ctrl_o = MI_SB;
            SH     : ctrl_o = MI_SH;
            SW     : ctrl_o = MI_SW;
            ADDI   : ctrl_o = MI_ADDI;
            SLTI   : ctrl_o = MI_SLTI;
            SLTIU  : ctrl_o = MI_SLTIU;
            XORI   : ctrl_o = MI_XORI;
            ORI    : ctrl_o = MI_ORI;
            ANDI   : ctrl_o = MI_ANDI;
            SLLI   : ctrl_o = MI_SLLI;
            CTZ    : ctrl_o = MI_CTZ;
            CLZ    : ctrl_o = MI_CLZ;
            CPOP   : ctrl_o = MI_CPOP;
            SRLI   : ctrl_o = MI_SRLI;
            SRAI   : ctrl_o = MI_SRAI;
            ADD    : ctrl_o = MI_ADD;
            SUB    : ctrl_o = MI_SUB;
            SLL    : ctrl_o = MI_SLL;
            SLT    : ctrl_o = MI_SLT;
            SLTU   : ctrl_o = MI_SLTU;
            XOR    : ctrl_o = MI_XOR;
            SRL    : ctrl_o = MI_SRL;
            SRA    : ctrl_o = MI_SRA;
            OR     : ctrl_o = MI_OR;
            AND    : ctrl_o = MI_AND;
            default: ctrl_o = MI_ADDI;
        endcase
    end
    
endmodule
