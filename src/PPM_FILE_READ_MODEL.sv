module PPM_FILE_READ_MODEL  (
  input   logic         clk             ,
  input   logic         rst_n           ,

  input   logic         i_vsync         ,
  input   logic         i_hsync         ,
  input   logic         i_de            ,

  output  logic         o_vsync         ,
  output  logic         o_hsync         ,
  output  logic         o_de            ,
  output  logic [23:0]  o_data          
);

int     fp;

// PPM FILE HEADER
string  PPMHEADER_IDENTIFIER;
int     PPMHEADER_HRES;
int     PPMHEADER_VRES;
int     PPMHEADER_MAXVALUE;

logic [ 7:0]  data_R  ;
logic [ 7:0]  data_G  ;
logic [ 7:0]  data_B  ;
logic [23:0]  pixData ;

logic [ 2:1]  vsync_d ;
logic [ 2:1]  hsync_d ;
logic [ 2:1]  de_d    ;

// FILE OPEN
always @(negedge i_vsync) begin
  fp = $fopen("24bpp-320x240.ppm", "r");
  writePPMHEADER;
end

// FILE CLOSE
always @(posedge i_vsync) begin
  $fclose(fp);
end

// FILE READ
always @(posedge clk) begin
  if(i_de) begin
    #1 $fscanf(fp, "%d %d %d\n", data_R, data_G, data_B);
  end
end

assign pixData = {data_R, data_G, data_B};

always @(posedge clk, negedge rst_n) begin
  if(!rst_n) begin
    vsync_d <= 'd0;
    hsync_d <= 'd0;
    de_d    <= 'd0;  
    o_data  <= 'd0;
  end else begin       
    vsync_d <= {vsync_d[1], i_vsync };
    hsync_d <= {hsync_d[1], i_hsync };
    de_d    <= {de_d[1],    i_de    };  
    o_data  <= pixData;
  end
end

assign o_vsync  = vsync_d[2];
assign o_hsync  = hsync_d[2];
assign o_de     = de_d[2]   ;

task writePPMHEADER;
begin
  $fscanf(fp, "%s\n",    PPMHEADER_IDENTIFIER);
  $fscanf(fp, "%d %d\n", PPMHEADER_HRES, PPMHEADER_VRES);
  $fscanf(fp, "%d\n",    PPMHEADER_MAXVALUE);
end
endtask

endmodule