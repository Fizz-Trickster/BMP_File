module BMP_FILE_WRITE_MODEL   #(
parameter HRES = 320,
parameter VRES = 240          )(
  input                 clk             ,
  input                 rst_n           ,

  input                 i_vsync         ,
  input                 i_hsync         ,
  input                 i_de            ,
  input         [23:0]  i_data          ,

  // BITMAP FILE HEADER
  input   [ 1:0][ 7:0]  bfType          ,
  input   [ 3:0][ 7:0]  bfSize          ,
  input   [ 1:0][ 7:0]  bfResrved1      ,
  input   [ 1:0][ 7:0]  bfResrved2      ,
  input   [ 3:0][ 7:0]  bfOffBits       ,

  // BITMAP INFO  HEADER
  input   [ 3:0][ 7:0]  biSize          ,
  input   [ 3:0][ 7:0]  biWidth         ,
  input   [ 3:0][ 7:0]  biHeight        ,
  input   [ 1:0][ 7:0]  biPlanes        ,
  input   [ 1:0][ 7:0]  biBitCount      ,
  input   [ 3:0][ 7:0]  biCompression   ,  
  input   [ 3:0][ 7:0]  biSizeImage     ,
  input   [ 3:0][ 7:0]  biXPelsPerMeter ,
  input   [ 3:0][ 7:0]  biYPelsPerMeter ,
  input   [ 3:0][ 7:0]  biClrUsed       ,
  input   [ 3:0][ 7:0]  biClrImportant  

);

logic   [19:0] pixCnt;

logic   [0:HRES*VRES-1][23:0] mem   ;

always @(posedge clk, negedge rst_n ) begin 
  if(!rst_n) begin     
    pixCnt <= 'd0;
  end else if(i_vsync) begin
    pixCnt <= 'd0;
  end else if(i_de) begin
    pixCnt <= pixCnt + 'd1;
  end
end

always @(posedge clk, negedge rst_n ) begin 
  if(!rst_n) begin     
    mem         <= 'd0;
  end else if(i_de) begin
    mem[pixCnt] <= i_data;
  end
end

int     fp;
int     idx;
int     frameCnt;
string  file_path;

always @(posedge i_vsync) begin
  frameCnt  = frameCnt + 'd1;
  $sformat(file_path, "output_%02d.bmp", frameCnt);

  fp = $fopen(file_path, "wb");
  writeBITMAPFILE;

  $fclose(fp);
end

task writeBITMAPFILE;
begin
  foreach(bfType          [i])  $fwrite(fp, "%c", bfType          [i]);
  foreach(bfSize          [i])  $fwrite(fp, "%c", bfSize          [i]);
  foreach(bfResrved1      [i])  $fwrite(fp, "%c", bfResrved1      [i]);
  foreach(bfResrved2      [i])  $fwrite(fp, "%c", bfResrved2      [i]);
  foreach(bfOffBits       [i])  $fwrite(fp, "%c", bfOffBits       [i]);

  foreach(biSize          [i])  $fwrite(fp, "%c", biSize          [i]);
  foreach(biWidth         [i])  $fwrite(fp, "%c", biWidth         [i]);
  foreach(biHeight        [i])  $fwrite(fp, "%c", biHeight        [i]);
  foreach(biPlanes        [i])  $fwrite(fp, "%c", biPlanes        [i]);
  foreach(biBitCount      [i])  $fwrite(fp, "%c", biBitCount      [i]);
  foreach(biCompression   [i])  $fwrite(fp, "%c", biCompression   [i]);
  foreach(biSizeImage     [i])  $fwrite(fp, "%c", biSizeImage     [i]);
  foreach(biXPelsPerMeter [i])  $fwrite(fp, "%c", biXPelsPerMeter [i]);
  foreach(biYPelsPerMeter [i])  $fwrite(fp, "%c", biYPelsPerMeter [i]);
  foreach(biClrUsed       [i])  $fwrite(fp, "%c", biClrUsed       [i]);
  foreach(biClrImportant  [i])  $fwrite(fp, "%c", biClrImportant  [i]);

  for(int rowCnt=0; rowCnt<VRES; rowCnt++) begin
    for(int colCnt=0; colCnt<HRES; colCnt++) begin
      idx = ((VRES-(rowCnt+1))*HRES)+colCnt;
      $fwrite(fp, "%c", mem[idx][ 0 +:8]);    // B
      $fwrite(fp, "%c", mem[idx][ 8 +:8]);    // G
      $fwrite(fp, "%c", mem[idx][16 +:8]);    // R
    end
  end
end
endtask

task writePPMFILE;
begin
  $fdisplay(fp, "P3");
  $fdisplay(fp, "%0d %0d", HRES, VRES);
  $fdisplay(fp, "255");

  for(int i=0; i<HRES*VRES; i++) begin
    $fdisplay(fp,"%d %d %d", mem[i][16 +:8], mem[i][8  +:8], mem[i][ 0 +:8]);
  end
end
endtask 

endmodule