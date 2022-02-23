module BMP_FILE_WRITE_MODEL  (
  input                 clk             ,
  input                 rst_n           ,

  input                 vs_in           ,
  input                 hs_in           ,
  input                 de_in           ,
  input         [23:0]  data_in         ,
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