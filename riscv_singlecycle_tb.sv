module riscv_singlecycle_tb;
    import riscv_pkg::XLEN;
    import custom_pkg::*;

    logic            clk;
    logic            rstn;
    logic            update;
    logic [XLEN-1:0] addr;
    logic [XLEN-1:0] data;
    logic [XLEN-1:0] pc;
    logic [XLEN-1:0] instr;
    logic [     4:0] reg_addr;
    logic [XLEN-1:0] reg_data;
    logic [XLEN-1:0] mem_addr;
    logic [XLEN-1:0] mem_data;

    riscv_singlecycle riscv_singlecycle0(
        .clk_i     (clk     ),
        .rstn_i    (rstn    ),
        .addr_i    (addr    ),
        .update_o  (update  ),
        .data_o    (data    ),
        .pc_o      (pc      ),
        .instr_o   (instr   ),
        .reg_addr_o(reg_addr),
        .reg_data_o(reg_data),
        .mem_addr_o(mem_addr),
        .mem_data_o(mem_data)
    );
    
    integer file;
    
    initial begin
        file = $fopen("model.log", "w");
        #4
        forever begin
            if(instr === 32'hXXXX_XXXX) begin
            
                $fclose(file);
                $finish;
                
            end else if(instr[`OPCODE] == OP_BRANCH) begin
               
                $fwrite(file, "0x%8h (0x%8h) \n", pc, instr);

            end else if(instr[`OPCODE] == OP_STORE) begin
            
                $fwrite(file, "0x%8h (0x%8h) mem 0x%8h 0x%8h \n", pc, instr, mem_addr, mem_data);
                
            end else if(instr[`OPCODE] == OP_LOAD) begin

                if(reg_addr > 9)
                    $fwrite(file, "0x%8h (0x%8h) x%0d 0x%8h mem 0x%8h \n", pc, instr, reg_addr, reg_data, mem_addr);
                else if(reg_addr != 0)
                    $fwrite(file, "0x%8h (0x%8h) x%0d  0x%8h mem 0x%8h \n", pc, instr, reg_addr, reg_data, mem_addr);
                else
                    $fwrite(file, "0x%8h (0x%8h)", pc, instr);
            end else begin
            
                if(reg_addr > 9)
                    $fwrite(file, "0x%8h (0x%8h) x%0d 0x%8h \n", pc, instr, reg_addr, reg_data);
                else if(reg_addr != 0)
                    $fwrite(file, "0x%8h (0x%8h) x%0d  0x%8h \n", pc, instr, reg_addr, reg_data);
                else
                    $fwrite(file, "0x%8h (0x%8h)\n", pc, instr);
                    
            end
            #2;
        end
    end
    
    always begin
        #1 clk = ~clk;
    end
    
    initial begin
        rstn = 0;
        clk  = 0;
        #4
        rstn = 1;
    end
        
   initial begin
      $dumpfile("dump.vcd");
      $dumpvars();
   end
    
endmodule