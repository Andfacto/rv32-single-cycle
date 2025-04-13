`timescale 1ns / 1ps

package custom_pkg;
    
    import riscv_pkg::*;
    
    `define OPCODE  6:0
    `define RD     11:7
    `define FUNCT3 14:12
    `define RS1    19:15
    `define RS2    24:20
    `define FUNCT7 31:25
    `define IMM    31:7
    
    `define OPERAND_1 17:17
    `define OPERAND_2 16:16
    `define IMM_TYPE  15:13
    `define WRITEBACK 12:11
    `define REG_FILE  10:10
    `define ALU_OP    9:6
    `define BRANCH    5:3
    `define MEM_OP    2:0

    localparam logic [31:0] PC_INIT    = 32'h8000_0000;
    
    localparam logic [31:0] RAM_LOWER  = 32'h8000_0000 >> 2;
    localparam logic [31:0] RAM_HIGHER = 32'h8000_FFFF >> 2;
    
    localparam logic [31:0] ROM_LOWER  = 32'h8000_0000 >> 2;
    localparam logic [31:0] ROM_HIGHER = 32'h8000_FFFF >> 2;
    
    typedef enum logic [6:0] {
        OP_LUI    = 7'b0110111,
        OP_AUIPC  = 7'b0010111,
        OP_JAL    = 7'b1101111,
        OP_JALR   = 7'b1100111,
        OP_BRANCH = 7'b1100011,
        OP_LOAD   = 7'b0000011,
        OP_STORE  = 7'b0100011,
        OP_REGIMM = 7'b0010011,
        OP_REG    = 7'b0110011
    } opcode_t;
    
    typedef enum logic [3:0] {
        ALU_ADD  = 4'b0000,
        ALU_SUB  = 4'b0001,
        ALU_OR   = 4'b0100,
        ALU_AND  = 4'b0101,
        ALU_XOR  = 4'b0110,
        ALU_SLL  = 4'b1000,
        ALU_SRL  = 4'b1001,
        ALU_SRA  = 4'b1010,
        ALU_SLT  = 4'b1100,
        ALU_SLTU = 4'b1101,
        ALU_CTZ  = 4'b0010,
        ALU_CLZ  = 4'b0011,
        ALU_CPOP = 4'b1111
    } alu_op_t;
    
    typedef enum logic [2:0] {
        IMM_U    = 3'b000,
        IMM_J    = 3'b001,
        IMM_I    = 3'b010,
        IMM_B    = 3'b011,
        IMM_S    = 3'b100,
        IMM_NONE = 3'b111 
    } imm_op_t;
    
    typedef enum logic [2:0] {
        MEM_LB  = 3'b000,  // Load Byte
        MEM_LH  = 3'b001,  // Load Half-word
        MEM_LW  = 3'b010,  // Load Word
        MEM_LBU = 3'b011,  // Load Byte Unsigned
        MEM_LHU = 3'b100,  // Load Half-word Unsigned
        MEM_SB  = 3'b101,  // Store Byte
        MEM_SH  = 3'b110,  // Store Half-word
        MEM_SW  = 3'b111   // Store Word
    } mem_op_t;
    
    typedef enum logic [1:0] {
        WB_MEM = 2'b00,
        WB_ALU = 2'b01,
        WB_PC4 = 2'b10,
        WB_IMM = 2'b11 
    } wb_op_t;
    
    typedef enum logic [2:0] {
            BRANCH_JAL  = 3'b000,
            BRANCH_EQ   = 3'b001,
            BRANCH_NE   = 3'b010,
            BRANCH_LT   = 3'b011,
            BRANCH_GE   = 3'b100,
            BRANCH_LTU  = 3'b101,
            BRANCH_GEU  = 3'b110,
            BRANCH_NONE = 3'b111
    } branch_op_t;
    
    typedef enum logic [21:0] {
        LUI    = 22'b???????_?????_???_0110111,  // Load Upper Immediate
        AUIPC  = 22'b???????_?????_???_0010111,  // Add Upper Immediate to PC
        JAL    = 22'b???????_?????_???_1101111,  // Jump and Link
        JALR   = 22'b???????_?????_???_1100111,  // Jump and Link Register
        BEQ    = 22'b???????_?????_000_1100011,  // Branch if Equal
        BNE    = 22'b???????_?????_001_1100011,  // Branch if Not Equal
        BLT    = 22'b???????_?????_100_1100011,  // Branch if Less Than
        BGE    = 22'b???????_?????_101_1100011,  // Branch if Greater Than or Equal
        BLTU   = 22'b???????_?????_110_1100011,  // Branch if Less Than Unsigned
        BGEU   = 22'b???????_?????_111_1100011,  // Branch if Greater Than or Equal Unsigned
        LB     = 22'b???????_?????_000_0000011,  // Load Byte
        LH     = 22'b???????_?????_001_0000011,  // Load Halfword
        LW     = 22'b???????_?????_010_0000011,  // Load Word
        LBU    = 22'b???????_?????_100_0000011,  // Load Byte Unsigned
        LHU    = 22'b???????_?????_101_0000011,  // Load Halfword Unsigned
        SB     = 22'b???????_?????_000_0100011,  // Store Byte
        SH     = 22'b???????_?????_001_0100011,  // Store Halfword
        SW     = 22'b???????_?????_010_0100011,  // Store Word
        ADDI   = 22'b???????_?????_000_0010011,  // Add Immediate
        SLTI   = 22'b???????_?????_010_0010011,  // Set Less Than Immediate
        SLTIU  = 22'b???????_?????_011_0010011,  // Set Less Than Immediate Unsigned
        XORI   = 22'b???????_?????_100_0010011,  // XOR Immediate
        ORI    = 22'b???????_?????_110_0010011,  // OR Immediate
        ANDI   = 22'b???????_?????_111_0010011,  // AND Immediate
        SLLI   = 22'b?00????_?????_001_0010011,  // Shift Left Logical Immediate
        CTZ    = 22'b?11????_00001_001_0010011,  // Count Trailing Zeros
        CLZ    = 22'b?11????_00000_001_0010011,  // Count Leading Zeros
        CPOP   = 22'b?11????_00010_001_0010011,  // Count Population
        SRLI   = 22'b?0?????_?????_101_0010011,  // Shift Right Logical Immediate
        SRAI   = 22'b?1?????_?????_101_0010011,  // Shift Right Arithmetic Immediate
        ADD    = 22'b?0?????_?????_000_0110011,  // Add
        SUB    = 22'b?1?????_?????_000_0110011,  // Subtract
        SLL    = 22'b???????_?????_001_0110011,  // Shift Left Logical
        SLT    = 22'b???????_?????_010_0110011,  // Set Less Than
        SLTU   = 22'b???????_?????_011_0110011,  // Set Less Than Unsigned
        XOR    = 22'b???????_?????_100_0110011,  // XOR
        SRL    = 22'b?0?????_?????_101_0110011,  // Shift Right Logical
        SRA    = 22'b?1?????_?????_101_0110011,  // Shift Right Arithmetic
        OR     = 22'b???????_?????_110_0110011,  // OR
        AND    = 22'b???????_?????_111_0110011   // AND
    } instr_t;
    
    typedef enum logic [17:0] {
        MI_LUI    = 18'b0_1_000_11_1_0000_111_000,
        MI_AUIPC  = 18'b1_1_000_01_1_0000_111_000,
        MI_JAL    = 18'b1_1_001_10_1_0000_000_000,
        MI_JALR   = 18'b0_1_010_10_1_0000_000_000,
        MI_BEQ    = 18'b1_1_011_11_0_0000_001_000,
        MI_BNE    = 18'b1_1_011_11_0_0000_010_000,
        MI_BLT    = 18'b1_1_011_11_0_0000_011_000,
        MI_BGE    = 18'b1_1_011_11_0_0000_100_000,
        MI_BLTU   = 18'b1_1_011_11_0_0000_101_000,
        MI_BGEU   = 18'b1_1_011_11_0_0000_110_000,
        MI_LB     = 18'b0_1_010_00_1_0000_111_000,
        MI_LH     = 18'b0_1_010_00_1_0000_111_001,
        MI_LW     = 18'b0_1_010_00_1_0000_111_010,
        MI_LBU    = 18'b0_1_010_00_1_0000_111_011,
        MI_LHU    = 18'b0_1_010_00_1_0000_111_100,
        MI_SB     = 18'b0_1_100_11_0_0000_111_101,
        MI_SH     = 18'b0_1_100_11_0_0000_111_110,
        MI_SW     = 18'b0_1_100_11_0_0000_111_111,
        MI_ADDI   = 18'b0_1_010_01_1_0000_111_000,
        MI_SLTI   = 18'b0_1_010_01_1_1100_111_000,
        MI_SLTIU  = 18'b0_1_010_01_1_1101_111_000,
        MI_XORI   = 18'b0_1_010_01_1_0110_111_000,
        MI_ORI    = 18'b0_1_010_01_1_0100_111_000,
        MI_ANDI   = 18'b0_1_010_01_1_0101_111_000,
        MI_SLLI   = 18'b0_1_010_01_1_1000_111_000,
        MI_CTZ    = 18'b0_0_111_01_1_0010_111_000,
        MI_CLZ    = 18'b0_0_111_01_1_0011_111_000,
        MI_CPOP   = 18'b0_0_111_01_1_1111_111_000,
        MI_SRLI   = 18'b0_1_010_01_1_1001_111_000,
        MI_SRAI   = 18'b0_1_010_01_1_1010_111_000,
        MI_ADD    = 18'b0_0_111_01_1_0000_111_000,
        MI_SUB    = 18'b0_0_111_01_1_0001_111_000,
        MI_SLL    = 18'b0_0_111_01_1_1000_111_000,
        MI_SLT    = 18'b0_0_111_01_1_1100_111_000,
        MI_SLTU   = 18'b0_0_111_01_1_1101_111_000,
        MI_XOR    = 18'b0_0_111_01_1_0110_111_000,
        MI_SRL    = 18'b0_0_111_01_1_1001_111_000,
        MI_SRA    = 18'b0_0_111_01_1_1010_111_000,
        MI_OR     = 18'b0_0_111_01_1_0100_111_000,
        MI_AND    = 18'b0_0_111_01_1_0101_111_000
    } control_t;

endpackage