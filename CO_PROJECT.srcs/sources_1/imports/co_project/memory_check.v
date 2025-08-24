`timescale 1ns / 1ps

module memory_check();
  reg clk;
  wire [31:0] RD;
  reg [31:0] A, WD;
  reg WE;
  integer i;
  
  // Instantiate Data Memory
  Data_Memory dm (
    .clk(clk),
    .WE(WE),
    .A(A),
    .WD(WD),
    .RD(RD)
  );
  
  // Generate clock
  always begin
    clk = 0; #5; clk = 1; #5;
  end
  
  // Test procedure
  initial begin
    // Initialize
    WE = 0;
    A = 0;
    WD = 0;
    
    // Display number of elements
    #10;
    A = 0;
    #10;
    $display("Number of elements: %d", RD);
    
    // Display all memory values to check the pattern
    $display("\nChecking initial memory values:");
    
    // Display first 10 elements
    for (i = 1; i <= 10; i = i + 1) begin
      A = i << 2;  // Multiply by 4 for byte addressing
      #10;
      $display("RAM[%0d]: 0x%h", i, RD);
    end
    
    // Display the replacement value
    A = 101 << 2;
    #10;
    $display("\nReplacement value at address 101: 0x%h", RD);
    
    // Display the replacement counter
    A = 102 << 2;
    #10;
    $display("Replacement counter at address 102: %d", RD);
    
    $finish;
  end
endmodule 