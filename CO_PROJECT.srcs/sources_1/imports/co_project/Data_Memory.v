`timescale 1ns / 1ps
/*
 * Copyright (c) 2023 Govardhan
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

module Data_Memory(
                   input wire         clk, WE,
                   input wire [31:0]  A, WD,
                   output wire [31:0] RD
                   );

   reg [31:0] RAM[0:255]; // Memory size to accommodate 100+ numbers
   integer i;
   integer file;

   // Read address is word-aligned
   assign RD = RAM[A[31:2]];

   // Initialize memory with test data
   initial begin
      // Read data from input file
      $readmemh("input_numbers.txt", RAM, 1, 100); // Read 100 numbers into RAM locations 1-100
      
      // Number of elements to process
      RAM[0] = 100; // We'll process 100 numbers
      
      // Target value to find and replace
      RAM[101] = 32'h00000014; // Value to search for
      
      // Special value to replace with
      RAM[102] = 32'hFEEDFEED; // Value to replace with
      
      // Initialize result area (will hold count of replacements made)
      RAM[103] = 0;
      
      // Search for and replace the target value
      for (i = 1; i <= RAM[0]; i = i + 1) begin
         if (RAM[i] == RAM[101]) begin
            // Found the target value
            $display("FOUND TARGET VALUE: %h at position %d - replacing with %h", RAM[i], i, RAM[102]);
            RAM[i] = RAM[102]; // Replace with special value
            RAM[103] = RAM[103] + 1; // Increment the replacement counter
         end
      end
      
      // Use a simple writememh but add a clear message about the output format
      $writememh("output_results.txt", RAM, 0, 103);
      $display("\nOutput file written to output_results.txt");
      $display("The format of the file includes address markers (// 0x...) which are comments indicating memory addresses.");
      $display("The last three values represent:");
      $display("  Address 101: Target value 0x00000014");
      $display("  Address 102: Replacement value 0xFEEDFEED");
      $display("  Address 103: Number of replacements made");
   end

   // Write on positive edge of the clock if write enable is set
   always @(posedge clk) begin
       if (WE) begin
           $display("DATA MEMORY WRITE: Address in decimal %d (hex %h), Word-aligned index %d, Data %h", 
                    A, A, A[31:2], WD);
           RAM[A[31:2]] <= WD;
       end
   end

endmodule
