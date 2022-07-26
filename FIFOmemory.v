module fifo_mem(data_out,fifo_full, fifo_empty, fifo_threshold, fifo_overflow, fifo_underflow,clk, rst_n, wr, rd, data_in);  
  
  input wr, rd, clk, rst_n;

  input[7:0] data_in;   
  
  output[7:0] data_out;  
  
  output fifo_full, fifo_empty, fifo_threshold, fifo_overflow, fifo_underflow;  
  
  wire[4:0] wptr,rptr;  
  
  wire fifo_we,fifo_rd;   
  
  write_pointer u1(wptr,fifo_we,wr,fifo_full,clk,rst_n);  
  
  read_pointer u2(rptr,fifo_rd,rd,fifo_empty,clk,rst_n);  
  
  memory_array u3(data_out, data_in, clk,fifo_we,fifo_rd, wptr,rptr);  
  
  status_signal u4(fifo_full, fifo_empty, fifo_threshold, fifo_overflow, fifo_underflow, wr, rd, fifo_we, fifo_rd, wptr,rptr,clk,rst_n);  

endmodule  

module read_pointer(rptr,fifo_rd,rd,fifo_empty,clk,rst_n);  
  
  input rd,fifo_empty,clk,rst_n;  
  
  output[4:0] rptr;  
  
  output fifo_rd;  
  
  reg[4:0] rptr;  
  
  assign fifo_rd = (~fifo_empty)& rd;  
  always @(posedge clk or negedge rst_n)  
  begin  
   if(~rst_n) rptr <= 5'b00000;  
   else if(fifo_rd)  
    rptr <= rptr + 5'b00001;  
   else  
    rptr <= rptr;  
  end  

endmodule 

module write_pointer(wptr,fifo_we,wr,fifo_full,clk,rst_n);  
  
  input wr,fifo_full,clk,rst_n;  
  
  output[4:0] wptr;  
  
  output fifo_we;  
  
  reg[4:0] wptr;  
  
  assign fifo_we = (~fifo_full)&wr;  
  always @(posedge clk or negedge rst_n)  
  begin  
   if(~rst_n) wptr <= 5'b00000;  
   else if(fifo_we)  
    wptr <= wptr + 5'b00001;  
   else  
    wptr <= wptr;  
  end  

endmodule  

module memory_array(data_out, data_in, clk,fifo_we,fifo_rd, wptr,rptr);  
  
  input[7:0] data_in;  
  
  input clk,fifo_we,fifo_rd;  
  
  input[4:0] wptr,rptr;  
  
  output[7:0] data_out;  
  
  reg[7:0] data_out2[31:0];  
  
  reg[7:0] data_out;  
  always @(posedge clk)  
  begin  
   if(fifo_we)   
      data_out2[wptr[4:0]] <=data_in ;  
  end  
  always @(posedge clk) 
  begin
    if(fifo_rd)
      data_out <= data_out2[rptr[4:0]]; 
  end

endmodule

module status_signal(fifo_full, fifo_empty, fifo_threshold, fifo_overflow, fifo_underflow, wr, rd, fifo_we, fifo_rd, wptr,rptr,clk,rst_n);  
  
  input wr, rd, fifo_we, fifo_rd,clk,rst_n;  
  
  input[4:0] wptr, rptr;  
  
  output fifo_full, fifo_empty, fifo_threshold, fifo_overflow, fifo_underflow;  
  
  wire fbit_comp, overflow_set, underflow_set;  
  wire pointer_equal;  
  wire[4:0] pointer_result;  
  
  reg fifo_full, fifo_empty, fifo_threshold, fifo_overflow, fifo_underflow;  
  
  assign fbit_comp = wptr[4] ^ rptr[4];  
  assign pointer_equal = (wptr[3:0] - rptr[3:0]) ? 0:1;  
  assign overflow_set = fifo_full & wr;  
  assign underflow_set = fifo_empty&rd;  
  
  always @(*)  
  begin  
   fifo_full =(wptr>=5'b11111)? 1:0;  
   fifo_empty <= (~fbit_comp) & pointer_equal;  
   fifo_threshold = (wptr>=5'b01111) ? 1:0;  
  end  
  
  always @(posedge clk or negedge rst_n)  
  begin  
  if(~rst_n) fifo_overflow <=0;  
  else if((overflow_set==1)&&(fifo_rd==0))  
   fifo_overflow <=1;  
   else if(fifo_rd)  
    fifo_overflow <=0;  
    else  
     fifo_overflow <= fifo_overflow;  
  end  
  
  always @(posedge clk or negedge rst_n)  
  begin  
  if(~rst_n) fifo_underflow <=0;  
  else if((underflow_set==1)&&(fifo_we==0))  
   fifo_underflow <=1;  
   else if(fifo_we)  
    fifo_underflow <=0;  
    else  
     fifo_underflow <= fifo_underflow;  
  end  

endmodule  
