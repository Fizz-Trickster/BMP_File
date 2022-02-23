module disp_sync_gen 	  #(
//========================================== 
// Parameter Description
//========================================== 
parameter VPULSE  = 1,
parameter HPULSE  = 1,
parameter VRES    = 4,
parameter HRES    = 4,
parameter VBP     = 3,
parameter VFP     = 5,
parameter HBP     = 3,
parameter HFP     = 5   )(
//========================================== 
// Input / Output Description
//========================================== 
  input			i_clk,
  input			rst_n,
  output		o_hsync,
  output		o_vsync,
  output 		o_de 
);

localparam V_TOTAL = VPULSE + VBP + VRES + VFP;
localparam H_TOTAL = HPULSE + HBP + HRES + HFP; 
//========================================== 
// Internal Signal Description
//========================================== 
reg     [11:0]      h_cnt;
reg     [11:0]      v_cnt;
reg                 hs_delay;
reg                 vs_delay;
wire                hs;
wire                vs;
wire                data_en;
reg                 de_delay;

always @(posedge i_clk, negedge rst_n) begin
  if(~rst_n) begin 
    v_cnt <= 'd0;
    h_cnt <= 'd0;
  end else if(h_cnt == H_TOTAL -'d1) begin
    if(v_cnt == V_TOTAL - 'd1) begin
      v_cnt ='d0;
      h_cnt ='d0;
    end else begin
      v_cnt = v_cnt + 'd1;
      h_cnt = 'd0;
    end
  end else begin
    h_cnt = h_cnt + 'd1;
  end
end

assign vs       = (v_cnt >= 'd0 && v_cnt <= VPULSE - 'd1);
assign hs       = (h_cnt >= 'd0 && h_cnt <= HPULSE - 'd1);
assign data_en  = (v_cnt >= VPULSE+VBP && v_cnt < V_TOTAL-VFP) && (h_cnt >= HPULSE+HBP && h_cnt < H_TOTAL-HFP);

always @(posedge i_clk, negedge rst_n) begin
  if(~rst_n)              hs_delay <= 'd0;
  else                    hs_delay <= hs;
end

always @(posedge i_clk, negedge rst_n) begin
  if(~rst_n)              vs_delay <= 'd0;
  else                    vs_delay <= vs;
end

always @(posedge i_clk, negedge rst_n) begin
  if(~rst_n)              de_delay <= 'd0;
  else                    de_delay <= data_en;
end

assign o_hsync    = hs_delay;
assign o_vsync    = vs_delay;
assign o_de       = de_delay;  
  
endmodule