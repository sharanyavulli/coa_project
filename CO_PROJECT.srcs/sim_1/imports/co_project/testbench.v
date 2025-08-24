`timescale 1ns / 1ps

module testbench();
  reg clk, reset;
  wire [31:0] WriteData, DataAddr;
  wire MemWrite;
  integer i;
  integer replaced_count;
  
  // Instantiate the top-level design unit
  Single_Cycle_Top dut(
    .clk(clk),
    .reset(reset),
    .WriteData(WriteData),
    .DataAddr(DataAddr),
    .MemWrite(MemWrite)
  );
  
  // Generate clock
  always begin
    clk = 0; #5; clk = 1; #5;
  end
  
  // Track memory writes and key events
  always @(posedge clk) begin
    if (MemWrite) begin
      $display("MEM WRITE at t=%0t: Address=%h Data=%h", $time, DataAddr, WriteData);
      $display("  Decoding address: Full=%h, Word Address=%h, Byte offset=%h", 
                DataAddr, DataAddr[31:2], DataAddr[1:0]);
      
      // Check for writes to the result counter
      if (DataAddr == 103 << 2) begin
        $display("");
        $display("*******************************");
        $display("* SEARCH & REPLACE RESULTS    *");
        $display("*******************************");
        $display("* Target value: 0x00000014    *");
        $display("* Replacements made: %d        *", WriteData);
        $display("*******************************");
        $display("");
      end
    end
  end
  
  // Initialize test
  initial begin
    // Add waveform dumping
    $dumpfile("riscv_sim.vcd");
    $dumpvars(0, testbench);
    
    // Display the initial state of memory
    $display("======= INITIAL MEMORY STATE =======");
    $display("Target value to find and replace: 0x00000014");
    for (i = 1; i <= 10; i = i + 1) begin
      $display("Element %d: %h %s", i, dut.Data_Memory.RAM[i], 
               (dut.Data_Memory.RAM[i] == 32'h00000014) ? "<-- TARGET VALUE" : "");
    end
    $display("Target value at 101: %h", dut.Data_Memory.RAM[101]);
    $display("Replacement value at 102: %h", dut.Data_Memory.RAM[102]);
    $display("===================================");
    
    reset = 1; #10; reset = 0;
    
    // Run for a fixed amount of time - longer for 100 numbers
    #150000;
    
    // Display final state
    $display("");
    $display("======= FINAL MEMORY STATE =======");
    
    // Show number of elements
    $display("Total elements: %d", dut.Data_Memory.RAM[0]);
    
    // Display sample values
    $display("Sample values:");
    for (i = 1; i <= 10; i = i + 1) begin
      $display("Element %d: %h %s", i, dut.Data_Memory.RAM[i], 
               (dut.Data_Memory.RAM[i] == 32'hFEEDFEED) ? "<-- REPLACED" : "");
    end
    
    // Display value at position 20 (expecting to see a replacement)
    $display("Element 20: %h %s", dut.Data_Memory.RAM[20], 
             (dut.Data_Memory.RAM[20] == 32'hFEEDFEED) ? "<-- REPLACED" : "");
             
    // Display value at position 84 (expecting to see a replacement)
    $display("Element 84: %h %s", dut.Data_Memory.RAM[84], 
             (dut.Data_Memory.RAM[84] == 32'hFEEDFEED) ? "<-- REPLACED" : "");
    
    // Display some samples from the middle and end
    for (i = 30; i <= 100; i = i + 20) begin
      $display("Element %d: %h %s", i, dut.Data_Memory.RAM[i], 
               (dut.Data_Memory.RAM[i] == 32'hFEEDFEED) ? "<-- REPLACED" : "");
    end
    
    // Count replacements
    replaced_count = 0;
    for (i = 1; i <= 100; i = i + 1) begin
      if (dut.Data_Memory.RAM[i] == 32'hFEEDFEED) begin
        replaced_count = replaced_count + 1;
      end
    end
    
    // Show the total replacements
    $display("Manually counted replacements: %d", replaced_count);
    $display("Total replacements in counter: %d", dut.Data_Memory.RAM[103]);
    $display("==================================");
    
    $finish;
  end
  
  // Enhanced monitoring
  initial begin
    $monitor("Time=%0t, PC=%h, Instr=%h", $time, dut.PC, dut.Instr);
  end
endmodule 