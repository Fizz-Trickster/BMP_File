`timescale 1ns / 1ns

module TB_BMP_FILE;

parameter           HRES = 320;
parameter           VRES = 240;

//logic             clk;    // 4-state, default : x
bit                 clk;    // 2-state, default : 0
bit                 rst_n;
logic               in;
logic               out;

// VSYNC, HSYNC, DE
logic               t_vsync;
logic               t_hsync;
logic               t_de;

logic               vsync;
logic               hsync;
logic               de;
logic        [23:0] data;

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

localparam CLK_PERIOD = 10;

always #(CLK_PERIOD/2) clk = ~clk;

//initial begin
//  $dumpfile("dump.vcd");
//  $dumpvars;
//end

//disp_sync_gen #(
//  .VPULSE  (3),
//  .HPULSE  (3),
//  .VRES    (VRES),
//  .HRES    (HRES),
//  .VBP     (3),
//  .VFP     (5),
//  .HBP     (3),
//  .HFP     (5)   
//)   u_disp_sync_gen (
//      .i_clk      (clk
//  ),  .rst_n      (rst_n
//  ),  .o_vsync    (t_vsync
//  ),  .o_hsync    (t_hsync
//  ),  .o_de       (t_de
//  ));

disp_sync_gen_fsm #(
  .VPULSE  (3),
  .HPULSE  (3),
  .VRES    (VRES),
  .HRES    (HRES),
  .VBP     (3),
  .VFP     (5),
  .HBP     (3),
  .HFP     (5)   
)   u_disp_sync_gen_fsm (
      .i_clk      (clk
  ),  .rst_n      (rst_n
  ),  .o_vsync    (t_vsync
  ),  .o_hsync    (t_hsync
  ),  .o_de       (t_de
  ));

PPM_FILE_READ_MODEL u_PPM_FILE_READ_MODEL(
      .clk        (clk
  ),  .rst_n      (rst_n
  ),  .i_vsync    (t_vsync
  ),  .i_hsync    (t_hsync
  ),  .i_de       (t_de
  ),  .o_vsync    (vsync
  ),  .o_hsync    (hsync
  ),  .o_de       (de
  ),  .o_data     (data
  ));

BMP_FILE_WRITE_MODEL #(
  .HRES   (HRES),
  .VRES   (VRES)
  ) u_BMP_FILE_WRITE_MODEL(
      .clk              (clk
  ),  .rst_n            (rst_n
  ),  .i_vsync          (vsync
  ),  .i_hsync          (hsync
  ),  .i_de             (de
  ),  .i_data           (data

  ),  .bfType           (bfType
  ),  .bfSize           (bfSize         
  ),  .bfResrved1       (bfResrved1     
  ),  .bfResrved2       (bfResrved2     
  ),  .bfOffBits        (bfOffBits 

  ),  .biSize           (biSize         
  ),  .biWidth          (biWidth        
  ),  .biHeight         (biHeight       
  ),  .biPlanes         (biPlanes       
  ),  .biBitCount       (biBitCount     
  ),  .biCompression    (biCompression    
  ),  .biSizeImage      (biSizeImage    
  ),  .biXPelsPerMeter  (biXPelsPerMeter
  ),  .biYPelsPerMeter  (biYPelsPerMeter
  ),  .biClrUsed        (biClrUsed      
  ),  .biClrImportant   (biClrImportant 
  ));

int     fp_in;
int     fp_out;
string  bmpfile_in;
string  bmpfile_out;

initial begin
  #(CLK_PERIOD*3) rst_n   <= 'd1;
  
  bmpfile_in  = "output.bmp";
  bmpfile_out = "output.bmp";

  //readBITMAPHEADER;
  setBITMAPHEADER;
  //writeBITMAPFILE;

  repeat(3) @(posedge vsync);
  
  repeat(5) @(posedge clk);
  $finish;
end

task readBITMAPHEADER;
begin
  fp_in = $fopen(bmpfile_in, "rb");

  $fread(bfType          ,fp_in);
  $fread(bfSize          ,fp_in);
  $fread(bfResrved1      ,fp_in);
  $fread(bfResrved2      ,fp_in);
  $fread(bfOffBits       ,fp_in);
  $fread(biSize          ,fp_in);
  $fread(biWidth         ,fp_in);
  $fread(biHeight        ,fp_in);
  $fread(biPlanes        ,fp_in);
  $fread(biBitCount      ,fp_in);
  $fread(biCompression   ,fp_in);
  $fread(biSizeImage     ,fp_in);
  $fread(biXPelsPerMeter ,fp_in);
  $fread(biYPelsPerMeter ,fp_in);
  $fread(biClrUsed       ,fp_in);
  $fread(biClrImportant  ,fp_in);
  
  $fclose(fp_in);
end 
endtask

task setBITMAPHEADER;
begin
  bfType            = 16'h424d        ; //[15:0]
  bfSize            = 32'h3684_0300   ; //[31:0]
  bfResrved1        = 16'h0000        ; //[15:0]
  bfResrved2        = 16'h0000        ; //[15:0]
  bfOffBits         = 32'h3600_0000   ; //[31:0]

  biSize            = 32'h2800_0000   ; //[31:0]                                      
  biWidth           = 32'h4001_0000   ; //[31:0]
  biHeight          = 32'hF000_0000   ; //[31:0]
  biPlanes          = 16'h0100        ; //[15:0]
  biBitCount        = 16'h1800        ; //[15:0]
  biCompression     = 32'h0000_0000   ; //[31:0]
  biSizeImage       = 32'h0084_0300   ; //[31:0]
  biXPelsPerMeter   = 32'hE803_0000   ; //[31:0]
  biYPelsPerMeter   = 32'hE803_0000   ; //[31:0]
  biClrUsed         = 32'h0000_0000   ; //[31:0]
  biClrImportant    = 32'h0000_0000   ; //[31:0]
end
endtask

task writeBITMAPFILE;
begin
  fp_out = $fopen(bmpfile_out, "wb");

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