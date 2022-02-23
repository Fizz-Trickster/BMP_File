`timescale 1ns / 1ps

module TB_BMP_FILE;
  parameter           HRES = 512;
  parameter           VRES = 512;

  //logic             clk;    // 4-state, default : x
  bit                 clk;    // 2-state, default : 0
  logic               rst_n;
  logic               in;
  logic               out;

  // BITMAP FILE HEADER
  logic   [1:0][7:0] bfType;
  logic   [3:0][7:0] bfSize;
  logic   [1:0][7:0] bfResrved1;
  logic   [1:0][7:0] bfResrved2;
  logic   [3:0][7:0] bfOffBits;

  // BITMAP INFO HEADER
  logic   [3:0][7:0]  biSize;
  logic   [3:0][7:0]  biWidth;
  logic   [3:0][7:0]  biHeight;
  logic   [1:0][7:0]  biPlanes;
  logic   [1:0][7:0]  biBitCount;
  logic   [3:0][7:0]  biCompression;
  logic   [3:0][7:0]  biSizeImage;
  logic   [3:0][7:0]  biXPelsPerMeter;
  logic   [3:0][7:0]  biYPelsPerMeter;
  logic   [3:0][7:0]  biClrUsed;
  logic   [3:0][7:0]  biClrImportant;

  logic   [7:0] mem   [0:HRES*VRES*3-1];

localparam CLK_PERIOD = 10;

always #(CLK_PERIOD/2) clk = ~clk;

initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
end

initial begin
    //in      <= 0;
    //clk     <=0;
    //#(CLK_PERIOD*3) rst_n   <=1;
    //#(CLK_PERIOD*3) rst_n   <=0; 

    setBITMAPHEADER;
    writeBITMAPFILE;
    readBITMAPFILE;
    //repeat(5) @(posedge clk);
    //rst_n <= 1;

    //repeat(2) @(posedge clk);
    //in      <= 1;

    //repeat(2) @(posedge clk);
    //in      <= 1;

    //repeat(2) @(posedge clk);
    //in      <= 1;

    //repeat(2) @(posedge clk);
    //in      <= 0;

    //repeat(2) @(posedge clk);
    $finish;
end

task readBITMAPFILE;
  integer fp_in;
  logic [7:0] data;
  begin
    fp_in = $fopen("output.bmp","rb");
    $fread(bfType          ,fp_in)
    $fread(bfSize          ,fp_in)
    $fread(bfResrved1      ,fp_in)
    $fread(bfResrved2      ,fp_in)
    $fread(bfOffBits       ,fp_in)
    $fread(biSize          ,fp_in)
    $fread(biWidth         ,fp_in)
    $fread(biHeight        ,fp_in)
    $fread(biPlanes        ,fp_in)
    $fread(biBitCount      ,fp_in)
    $fread(biCompression   ,fp_in)
    $fread(biSizeImage     ,fp_in)
    $fread(biXPelsPerMeter ,fp_in)
    $fread(biYPelsPerMeter ,fp_in)
    $fread(biClrUsed       ,fp_in)
    $fread(biClrImportant  ,fp_in)
    
    //for(int i=0;i<32;i++) begin 
    //  #10;
    //  $fread(data, fp_in);
    //  $display("Line read : %c", data);
    //end
    $fclose(fp_in);
  end 

endtask

task setBITMAPHEADER;
  begin
    bfType            = 16'h424d        ; //[15:0]
    bfSize            = 32'h3600_0c00   ; //[31:0]
    bfResrved1        = 16'h0000        ; //[15:0]
    bfResrved2        = 16'h0000        ; //[15:0]
    bfOffBits         = 32'h3600_0000   ; //[31:0]

    biSize            = 32'h2800_0000   ; //[31:0]                                      
    biWidth           = 32'h0002_0000   ; //[31:0]
    biHeight          = 32'h0002_0000   ; //[31:0]
    biPlanes          = 16'h0100        ; //[15:0]
    biBitCount        = 16'h1800        ; //[15:0]
    biCompression     = 32'h0000_0000   ; //[31:0]
    biSizeImage       = 32'h0000_0c00   ; //[31:0]
    biXPelsPerMeter   = 32'h0000_0000   ; //[31:0]
    biYPelsPerMeter   = 32'h0000_0000   ; //[31:0]
    biClrUsed         = 32'h0000_0000   ; //[31:0]
    biClrImportant    = 32'h0000_0000   ; //[31:0]
  end
endtask

task writeBITMAPFILE;
  integer fp_out;
  begin
    fp_out = $fopen("output.bmp","wb");

    foreach(bfType          [i])  $fwrite(fp_out, "%c", bfType          [i]);
    foreach(bfSize          [i])  $fwrite(fp_out, "%c", bfSize          [i]);
    foreach(bfResrved1      [i])  $fwrite(fp_out, "%c", bfResrved1      [i]);
    foreach(bfResrved2      [i])  $fwrite(fp_out, "%c", bfResrved2      [i]);
    foreach(bfOffBits       [i])  $fwrite(fp_out, "%c", bfOffBits       [i]);

    foreach(biSize          [i])  $fwrite(fp_out, "%c", biSize          [i]);
    foreach(biWidth         [i])  $fwrite(fp_out, "%c", biWidth         [i]);
    foreach(biHeight        [i])  $fwrite(fp_out, "%c", biHeight        [i]);
    foreach(biPlanes        [i])  $fwrite(fp_out, "%c", biPlanes        [i]);
    foreach(biBitCount      [i])  $fwrite(fp_out, "%c", biBitCount      [i]);
    foreach(biCompression   [i])  $fwrite(fp_out, "%c", biCompression   [i]);
    foreach(biSizeImage     [i])  $fwrite(fp_out, "%c", biSizeImage     [i]);
    foreach(biXPelsPerMeter [i])  $fwrite(fp_out, "%c", biXPelsPerMeter [i]);
    foreach(biYPelsPerMeter [i])  $fwrite(fp_out, "%c", biYPelsPerMeter [i]);
    foreach(biClrUsed       [i])  $fwrite(fp_out, "%c", biClrUsed       [i]);
    foreach(biClrImportant  [i])  $fwrite(fp_out, "%c", biClrImportant  [i]);


    $fclose(fp_out);
  end 
endtask

endmodule