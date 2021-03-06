import state_pkg::*;

module disp_sync_gen_fsm  ( 
//========================================== 
// Input / Output Description
//========================================== 
  input             i_clk,
  input             rst_n,

  input   [ 3:0]    VPULSE,
  input   [ 7:0]    VBP,
  input   [10:0]    VRES,
  input   [ 7:0]    VFP,

  input   [ 3:0]    HPULSE,
  input   [ 7:0]    HBP,
  input   [10:0]    HRES,
  input   [ 7:0]    HFP,

  output  Vstate_t  Vstate,
  output  Hstate_t  Hstate,

  output            o_hsync,
  output            o_vsync,
  output            o_de 
);

//========================================== 
// Internal Signal Description
//========================================== 
Vstate_t            cur_Vstate, nxt_Vstate;
Hstate_t            cur_Hstate, nxt_Hstate;

logic     [11:0]    clkCnt;
logic     [11:0]    hsyncCnt;

logic               t_vsync;
logic               t_hsync;
logic               t_de;

logic               vsync_d;
logic     [1:0]     hsync_d;
logic     [1:0]     de_d;


// LUT : 185, FF:35
// HSYNC 
//always @(posedge i_clk, negedge rst_n) begin
//  if(~rst_n) begin 
//    cur_Hstate  <= S_HIDLE;
//  end else begin
//    cur_Hstate  <= nxt_Hstate;
//  end
//end
//
//always @(*) begin
//  nxt_Hstate = cur_Hstate; // default 
//  case (cur_Hstate)
//    S_HIDLE   : if(rst_n              ) nxt_Hstate = S_HPULSE;              
//    S_HPULSE  : if(clkCnt == HPULSE-1 ) nxt_Hstate = S_HBP;
//    S_HBP     : if(clkCnt == HBP-1    ) nxt_Hstate = S_HACTIVE;
//    S_HACTIVE : if(clkCnt == HRES- 1  ) nxt_Hstate = S_HFP;
//    S_HFP     : if(clkCnt == HFP-1    ) nxt_Hstate = S_HPULSE;
//  endcase
//end
//
//always @(posedge i_clk, negedge rst_n ) begin
//  if(~rst_n) begin
//    clkCnt <= 'd0;
//  end else begin
//    case(cur_Hstate)
//      S_HIDLE   : clkCnt <= clkCnt;
//      S_HPULSE  : begin
//        if(clkCnt == HPULSE-1)  clkCnt <= 'd0;
//        else                    clkCnt <= clkCnt +'d1;
//      end
//      S_HBP     : begin
//        if(clkCnt == HBP-1)     clkCnt <= 'd0;
//        else                    clkCnt <= clkCnt +'d1;
//      end
//      S_HACTIVE : begin
//        if(clkCnt == HRES-1)    clkCnt <= 'd0;
//        else                    clkCnt <= clkCnt +'d1;
//      end
//      S_HFP     : begin
//        if(clkCnt == HFP-1)     clkCnt <= 'd0;
//        else                    clkCnt <= clkCnt +'d1;
//      end
//    endcase
//  end
//end
//
//// VSYNC 
//always @(posedge i_clk, negedge rst_n) begin
//  if(~rst_n) begin 
//    cur_Vstate  <= S_VIDLE;
//  end else if(cur_Hstate == S_HPULSE && clkCnt == 'd0) begin
//    cur_Vstate  <= nxt_Vstate;
//  end
//end
//always @(*) begin
//  nxt_Vstate = cur_Vstate; // default 
//  case (cur_Vstate)
//    S_VIDLE   : if(rst_n                ) nxt_Vstate = S_VPULSE;              
//    S_VPULSE  : if(hsyncCnt == VPULSE-1 ) nxt_Vstate = S_VBP;
//    S_VBP     : if(hsyncCnt == VBP-1    ) nxt_Vstate = S_VACTIVE;
//    S_VACTIVE : if(hsyncCnt == VRES- 1  ) nxt_Vstate = S_VFP;
//    S_VFP     : if(hsyncCnt == VFP-1    ) nxt_Vstate = S_VPULSE;
//  endcase
//end
//
//always @(posedge i_clk, negedge rst_n ) begin
//  if(~rst_n) begin
//    hsyncCnt <= 'd0;
//  end else if(cur_Hstate == S_HPULSE && clkCnt == 'd0) begin
//    case(cur_Vstate)
//      S_VIDLE   : hsyncCnt <= hsyncCnt;
//      S_VPULSE  : begin
//        if(hsyncCnt == VPULSE-1)  hsyncCnt <= 'd0;
//        else                      hsyncCnt <= hsyncCnt +'d1;
//      end
//      S_VBP     : begin
//        if(hsyncCnt == VBP-1)     hsyncCnt <= 'd0;
//        else                      hsyncCnt <= hsyncCnt +'d1;
//      end
//      S_VACTIVE : begin
//        if(hsyncCnt == VRES-1)    hsyncCnt <= 'd0;
//        else                      hsyncCnt <= hsyncCnt +'d1;
//      end
//      S_VFP     : begin
//        if(hsyncCnt == VFP-1)     hsyncCnt <= 'd0;
//        else                      hsyncCnt <= hsyncCnt +'d1;
//      end
//    endcase
//  end
//end
//
//assign t_hsync  = (cur_Hstate == S_HPULSE ) && (clkCnt      <= HPULSE-1   );
//assign t_vsync  = (cur_Vstate == S_VPULSE ) && (hsyncCnt    <= VPULSE-1   );
//assign t_de     = (cur_Hstate == S_HACTIVE) && (cur_Vstate  == S_VACTIVE  );

// LUT : 81, FF:35
// HSYNC 
always @(posedge i_clk, negedge rst_n) begin
  if(~rst_n) begin 
    cur_Hstate  <= S_HIDLE;
  end else begin
    cur_Hstate  <= nxt_Hstate;
  end
end

always @(*) begin
  nxt_Hstate = cur_Hstate; // default 
  case (cur_Hstate)
    S_HIDLE   : if(rst_n              ) nxt_Hstate = S_HPULSE;              
    S_HPULSE  : if(clkCnt == HPULSE   ) nxt_Hstate = S_HBP;
    S_HBP     : if(clkCnt == HBP      ) nxt_Hstate = S_HACTIVE;
    S_HACTIVE : if(clkCnt == HRES     ) nxt_Hstate = S_HFP;
    S_HFP     : if(clkCnt == HFP      ) nxt_Hstate = S_HPULSE;
  endcase
end

always @(posedge i_clk, negedge rst_n ) begin
  if(~rst_n) begin
    clkCnt <= 'd1;
  end else begin
    case(cur_Hstate)
      S_HIDLE   : clkCnt <= clkCnt;
      S_HPULSE  : begin
        if(clkCnt == HPULSE)    clkCnt <= 'd1;
        else                    clkCnt <= clkCnt +'d1;
      end
      S_HBP     : begin
        if(clkCnt == HBP)       clkCnt <= 'd1;
        else                    clkCnt <= clkCnt +'d1;
      end
      S_HACTIVE : begin
        if(clkCnt == HRES)      clkCnt <= 'd1;
        else                    clkCnt <= clkCnt +'d1;
      end
      S_HFP     : begin
        if(clkCnt == HFP)       clkCnt <= 'd1;
        else                    clkCnt <= clkCnt +'d1;
      end
    endcase
  end
end

// VSYNC 
always @(posedge i_clk, negedge rst_n) begin
  if(~rst_n) begin 
    cur_Vstate  <= S_VIDLE;
  end else if(cur_Hstate == S_HPULSE && clkCnt == 'd1) begin
    cur_Vstate  <= nxt_Vstate;
  end
end
always @(*) begin
  nxt_Vstate = cur_Vstate; // default 
  case (cur_Vstate)
    S_VIDLE   : if(rst_n                ) nxt_Vstate = S_VPULSE;              
    S_VPULSE  : if(hsyncCnt == VPULSE   ) nxt_Vstate = S_VBP;
    S_VBP     : if(hsyncCnt == VBP      ) nxt_Vstate = S_VACTIVE;
    S_VACTIVE : if(hsyncCnt == VRES     ) nxt_Vstate = S_VFP;
    S_VFP     : if(hsyncCnt == VFP      ) nxt_Vstate = S_VPULSE;
  endcase
end

always @(posedge i_clk, negedge rst_n ) begin
  if(~rst_n) begin
    hsyncCnt <= 'd1;
  end else if(cur_Hstate == S_HPULSE && clkCnt == 'd1) begin
    case(cur_Vstate)
      S_VIDLE   : hsyncCnt <= hsyncCnt;
      S_VPULSE  : begin
        if(hsyncCnt == VPULSE)    hsyncCnt <= 'd1;
        else                      hsyncCnt <= hsyncCnt +'d1;
      end
      S_VBP     : begin
        if(hsyncCnt == VBP)       hsyncCnt <= 'd1;
        else                      hsyncCnt <= hsyncCnt +'d1;
      end
      S_VACTIVE : begin
        if(hsyncCnt == VRES)      hsyncCnt <= 'd1;
        else                      hsyncCnt <= hsyncCnt +'d1;
      end
      S_VFP     : begin
        if(hsyncCnt == VFP)       hsyncCnt <= 'd1;
        else                      hsyncCnt <= hsyncCnt +'d1;
      end
    endcase
  end
end

assign t_hsync  = (cur_Hstate == S_HPULSE ) && (clkCnt      <= HPULSE     );
assign t_vsync  = (cur_Vstate == S_VPULSE ) && (hsyncCnt    <= VPULSE     );
assign t_de     = (cur_Hstate == S_HACTIVE) && (cur_Vstate  == S_VACTIVE  );

always @(posedge i_clk, negedge rst_n) begin
  if(~rst_n) begin 
    hsync_d <= 'd0;
    de_d    <= 'd0;
    vsync_d <= 'd0;
  end else begin
    hsync_d <= {hsync_d[0], t_hsync };
    de_d    <= {de_d[0]   , t_de    };
    vsync_d <= t_vsync;
  end
end

assign o_vsync  = vsync_d   ;
assign o_hsync  = hsync_d[1];
assign o_de     = de_d[1]   ;

assign Vstate   = cur_Vstate;
assign Hstate   = cur_Hstate;

endmodule