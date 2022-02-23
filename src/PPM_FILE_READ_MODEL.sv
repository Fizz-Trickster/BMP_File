module PPM_FILE_READ_MODEL  (
  input                 clk             ,
  input                 rst_n           ,

  input                 i_vsync         ,
  input                 i_hsync         ,
  input                 i_de            ,

  output  logic         o_vsync         ,
  output  logic         o_hsync         ,
  output  logic         o_de            ,
  output  logic [23:0]  o_data          
);

integer fp_in;

// PPM FILE HEADER
string  PPMHEADER_IDENTIFIER;
integer PPMHEADER_HRES;
integer PPMHEADER_VRES;
integer PPMHEADER_MAXVALUE;

logic [ 7:0]  data_R  ;
logic [ 7:0]  data_G  ;
logic [ 7:0]  data_B  ;
logic [23:0]  pixData ;

logic [ 2:1]  vsync_d ;
logic [ 2:1]  hsync_d ;
logic [ 2:1]  de_d    ;

// FILE OPEN
always @(negedge i_vsync) begin
  fp_in = $fopen("24bpp-320x240.ppm", "r");
  
  // FILE Check
  if(!fp_in) begin
    $display("File Read Error");
  end else begin
    $fscanf(fp_in, "%s\n",    PPMHEADER_IDENTIFIER);
    $fscanf(fp_in, "%d %d\n", PPMHEADER_HRES, PPMHEADER_VRES);
    $fscanf(fp_in, "%d\n",    PPMHEADER_MAXVALUE);
  end
end

// FILE CLOSE
always @(posedge i_vsync) begin
  $fclose(fp_in);
end

// FILE READ
always @(posedge clk) begin
  if(i_de) begin
    #1;
    $fscanf(fp_in, "%d %d %d\n", data_R, data_G, data_B);
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

endmodule