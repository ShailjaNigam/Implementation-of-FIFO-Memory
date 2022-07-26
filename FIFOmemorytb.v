`timescale     10 ps/ 10 ps 
module     tb_fifo_32;  
reg     clk;  
reg     rst_n;  
reg     wr;  
reg     rd;  
reg     [7:0] data_in;  
wire     [7:0] data_out;  
wire     fifo_empty;  
wire     fifo_full;  
wire     fifo_threshold;  
wire     fifo_overflow;  
wire     fifo_underflow;  
integer i;  
 
fifo_mem tb ( data_out, fifo_full, fifo_empty, fifo_threshold, fifo_overflow,   
              fifo_underflow,clk, rst_n, wr, rd, data_in );  
 
initial  begin  
     clk     = 1'b0;  
     rst_n     = 1'b0;  
     wr     = 1'b0;  
     rd     = 1'b0;  
     data_in     = 8'd0;
     #1 rst_n = 1'b1;
     $display("Writing without reading atleast once.\n");
     for (i = 0; i < 34; i = i + 1) begin: WRE  
               #1 
               wr <= 1'b1;  
               data_in <= data_in + 8'd1;  
               #1  
               wr <= 1'b0; 
               $display("TIME = %d, wr = %b, rd = %b, data_in = %b data_out = %b\n",$time, wr, rd, data_in, data_out);  
               $display("fifo_full = %d,  fifo_empty = %b, fifo_threshold = %b, fifo_overflow = %b fifo_underflow = %b\n",fifo_full, fifo_empty,fifo_threshold, fifo_overflow, fifo_underflow);   
     end 
    
    //68
    
     wr <= 1'b0;
     rd <= 1'b1;
     data_in <= data_in; 
     $display("Now we read data without writing any thing.\n");
     for (i = 0; i < 34; i = i + 1) begin: RE  
               #2 
               $display("TIME = %d, wr = %b, rd = %b, data_in = %b data_out = %b\n",$time, wr, rd, data_in, data_out);  
               $display("fifo_full = %d,  fifo_empty = %b, fifo_threshold = %b, fifo_overflow = %b fifo_underflow = %b\n",fifo_full, fifo_empty,fifo_threshold, fifo_overflow, fifo_underflow);   
     end 

     //136
     
     $display("Now we reset every thing .\n");
     $display("And we write and read the data simultaneously.\n");
     rst_n = 1'b0;
     #2 rst_n = 1'b1;
     data_in = 8'd0;
     for (i = 0; i < 34; i = i + 1) begin: WRA  
               #1 
               wr <= 1'b1;  
               data_in <= data_in + 8'd1;  
               #1  
               wr <= 1'b0; 
               $display("TIME = %d, wr = %b, rd = %b, data_in = %b data_out = %b\n",$time, wr, rd, data_in, data_out);  
               $display("fifo_full = %d,  fifo_empty = %b, fifo_threshold = %b, fifo_overflow = %b fifo_underflow = %b\n",fifo_full, fifo_empty,fifo_threshold, fifo_overflow, fifo_underflow);   
     end 

end
    always #1 clk = ~clk;
    initial #210 $finish;

initial
  begin
    $dumpfile("reg.vcd");
    $dumpvars;

  end
endmodule
