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

int fp_bmp;
int idx;

always @(negedge i_vsync) begin
  //fp_bmp_in = $fopen("24bpp-320x240.bmp", "wb");
  fp_bmp = $fopen("output.bmp", "wb");
  
  foreach(bfType          [i])  $fwrite(fp_bmp, "%c", bfType          [i]);
  foreach(bfSize          [i])  $fwrite(fp_bmp, "%c", bfSize          [i]);
  foreach(bfResrved1      [i])  $fwrite(fp_bmp, "%c", bfResrved1      [i]);
  foreach(bfResrved2      [i])  $fwrite(fp_bmp, "%c", bfResrved2      [i]);
  foreach(bfOffBits       [i])  $fwrite(fp_bmp, "%c", bfOffBits       [i]);

  foreach(biSize          [i])  $fwrite(fp_bmp, "%c", biSize          [i]);
  foreach(biWidth         [i])  $fwrite(fp_bmp, "%c", biWidth         [i]);
  foreach(biHeight        [i])  $fwrite(fp_bmp, "%c", biHeight        [i]);
  foreach(biPlanes        [i])  $fwrite(fp_bmp, "%c", biPlanes        [i]);
  foreach(biBitCount      [i])  $fwrite(fp_bmp, "%c", biBitCount      [i]);
  foreach(biCompression   [i])  $fwrite(fp_bmp, "%c", biCompression   [i]);
  foreach(biSizeImage     [i])  $fwrite(fp_bmp, "%c", biSizeImage     [i]);
  foreach(biXPelsPerMeter [i])  $fwrite(fp_bmp, "%c", biXPelsPerMeter [i]);
  foreach(biYPelsPerMeter [i])  $fwrite(fp_bmp, "%c", biYPelsPerMeter [i]);
  foreach(biClrUsed       [i])  $fwrite(fp_bmp, "%c", biClrUsed       [i]);
  foreach(biClrImportant  [i])  $fwrite(fp_bmp, "%c", biClrImportant  [i]);

  for(int rowCnt=0; rowCnt<VRES; rowCnt++) begin
    for(int colCnt=0; colCnt<HRES; colCnt++) begin
      idx = ((VRES-(rowCnt+1))*HRES)+colCnt;
      $fwrite(fp_bmp, "%c", mem[idx][ 0 +:8]);    // B
      $fwrite(fp_bmp, "%c", mem[idx][ 8 +:8]);    // G
      $fwrite(fp_bmp, "%c", mem[idx][16 +:8]);    // R
    end
  end

  //for(int i=0; i<HRES*VRES; i++) begin
  //  $fwrite(fp_bmp, "%c", mem[i][0  +:8]);    // B
  //  $fwrite(fp_bmp, "%c", mem[i][8  +:8]);    // G
  //  $fwrite(fp_bmp, "%c", mem[i][16 +:8]);    // R
  //  $display("idx : %0d\t %d %d %d", i, mem[i][0  +:8], mem[i][8  +:8], mem[i][16 +:8]);
  //end

end

// FILE CLOSE
always @(posedge i_vsync) begin
  $fclose(fp_bmp);
end

//// PPM FILE OPEN
//int fp_ppm;
//always @(negedge i_vsync) begin
//  fp_ppm = $fopen("output.ppm", "w");
//
//  $fdisplay(fp_ppm, "P3");
//  $fdisplay(fp_ppm, "%0d %0d", HRES, VRES);
//  $fdisplay(fp_ppm, "255");
//
//  for(int i=0; i<HRES*VRES; i++) begin
//    $fdisplay(fp_ppm,"%d %d %d", mem[i][16 +:8], mem[i][8  +:8], mem[i][ 0 +:8]);
//  end
//end
//
//// PPM FILE CLOSE
//always @(posedge i_vsync) begin
//  $fclose(fp_ppm);
//end

//typedef enum logic[2:0] { A, B, C, D, E } State; 
//
//State currentState, nextState;
//
//always_ff @( posedge clk, negedge rst_n ) begin 
//   if(!reset_n)     currentState <= A;
//   else             currentState <= nextState;
//end
//
//always_comb begin 
//   case (currentState)
//       A :  begin
//            if(X)   nextState = C;
//            else    nextState = B;
//       end
//
//       B :  begin
//            if(X)   nextState = D;
//            else    nextState = B;
//       end   
//
//       C :  begin
//            if(X)   nextState = C;
//            else    nextState = E;
//       end   
//
//       D :  begin
//            if(X)   nextState = C;
//            else    nextState = E;
//       end  
//
//       E :  begin
//            if(X)   nextState = D;
//            else    nextState = B;
//       end   
//
//       default:     nextState = A;
//   endcase 
//end
//
//assign Y = (currentState == D || currentState == E);

endmodule