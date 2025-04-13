`timescale 1ns / 1ps

module riscv_singlecycle
    import riscv_pkg::*;
    import custom_pkg::*;
    #(
    parameter DMemInitFile = "./dmem.mem",
    parameter IMemInitFile = "./imem.mem"
    )(
    input  logic             clk_i,       // system clock
    input  logic             rstn_i,      // system reset
    input  logic  [XLEN-1:0] addr_i,      // memory adddres input for reading
    output logic  [XLEN-1:0] data_o,      // memory data output for reading
    output logic             update_o,    // retire signal
    output logic  [XLEN-1:0] pc_o,        // retired program counter
    output logic  [XLEN-1:0] instr_o,     // retired instruction
    output logic  [     4:0] reg_addr_o,  // retired register address
    output logic  [XLEN-1:0] reg_data_o,  // retired register data
    output logic  [XLEN-1:0] mem_addr_o,  // retired memory address
    output logic  [XLEN-1:0] mem_data_o   // retired memory data
    );
    
    logic [31:0] alu_in1;
    logic [31:0] alu_in2;
    logic [31:0] alu_out;
    logic [31:0] imm_out;
    logic [ 0:0] branch;
    logic [31:0] data_rs1;
    logic [31:0] data_rs2;
    logic [31:0] dmem_out;
    logic [31:0] data_wb;
    logic [17:0] control;
    
    always_comb begin
        data_o     = dmem_out[addr_i];
        update_o   = control[`REG_FILE];
        reg_addr_o = instr_o[`RD];
        reg_data_o = data_wb;
        mem_addr_o = alu_out;
        mem_data_o = data_rs2;
    end
     
    always_comb begin
        alu_in1  = control[`OPERAND_1] ? pc_o    : data_rs1;
        alu_in2  = control[`OPERAND_2] ? imm_out : data_rs2;
    end
    
    always_comb begin
        case(control[`WRITEBACK])
            WB_MEM: data_wb = dmem_out;
            WB_ALU: data_wb = alu_out; 
            WB_PC4: data_wb = pc_o + 4;
            WB_IMM: data_wb = imm_out; 
        endcase
    end 
    
    always_ff@(posedge clk_i) begin
        if(!rstn_i) pc_o <= PC_INIT;
        else        pc_o <= branch ? alu_out : pc_o + 4;
    end
    
    controller controller_dut(
        .instr_i(instr_o),
        .ctrl_o (control )
    );
    
    imem #(
        .IMemInitFile(IMemInitFile)
    ) imem_dut(
        .addr_i(pc_o   ),
        .dout_o(instr_o)
    );
    
    imm_gen imm_gen_dut(
        .sel_imm_i(control[`IMM_TYPE]),
        .instr_i  (instr_o[`IMM]     ),
        .imm_o    (imm_out           )
    );
    
    reg_file reg_file_dut(
        .clk_i     (clk_i             ),
        .rstn_i    (rstn_i            ),
        .write_en_i(control[`REG_FILE]),
        .addr_rs1_i(instr_o[`RS1]     ),
        .addr_rs2_i(instr_o[`RS2]     ),
        .addr_rd_i (instr_o[`RD]      ),
        .data_rd_i (data_wb           ),
        .data_rs1_o(data_rs1          ),
        .data_rs2_o(data_rs2          )
    );
    
    branch_comp branch_comp_dut(
        .branch_type_i(control[`BRANCH]),
        .data_rs1_i   (data_rs1        ),
        .data_rs2_i   (data_rs2        ),
        .branch_o     (branch          )
    );
    
    ALU ALU_dut(
        .sel_i   (control[`ALU_OP]),
        .op1_i   (alu_in1         ),
        .op2_i   (alu_in2         ),
        .result_o(alu_out         )
    );
    
    dmem #(
        .DMemInitFile(DMemInitFile)
    ) dmem_dut(
        .clk_i (clk_i           ),
        .ctrl_i(control[`MEM_OP]),
        .addr_i(alu_out         ),
        .din_i (data_rs2        ),
        .dout_o(dmem_out        )
    );

endmodule
