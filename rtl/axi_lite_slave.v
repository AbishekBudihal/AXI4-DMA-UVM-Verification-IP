//  AXI4-Lite Slave Peripheral
module axi_lite_slave #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter NUM_REGS   = 4
)(
    // Global
    input  wire                    clk,
    input  wire                    rst,
 
    // Write Address Channel (AW)
    input  wire                    awvalid,
    input  wire [ADDR_WIDTH-1:0]   awaddr,
    output reg                     awready,
 
    // Write Data Channel (W)
    input  wire                    wvalid,
    input  wire [DATA_WIDTH-1:0]   wdata,
    input  wire [DATA_WIDTH/8-1:0] wstrb,
    output reg                     wready,
 
    // Write Response Channel (B)
    output reg                     bvalid,
    output reg  [1:0]              bresp,
    input  wire                    bready,
 
    // Read Address Channel (AR)
    input  wire                    arvalid,
    input  wire [ADDR_WIDTH-1:0]   araddr,
    output reg                     arready,
 
    // Read Data Channel (R)
    output reg                     rvalid,
    output reg  [DATA_WIDTH-1:0]   rdata,
    output reg  [1:0]              rresp,
    input  wire                    rready
);
 
// ─── Response code constants ──────────────────────────────────
localparam RESP_OKAY   = 2'b00;
localparam RESP_SLVERR = 2'b10;  // slave error (e.g. read-only write)
localparam RESP_DECERR = 2'b11;  // decode error (unmapped address)
 
// ─── Write FSM states ─────────────────────────────────────────
localparam W_IDLE  = 2'd0;   // waiting for AW
localparam W_DATA  = 2'd1;   // AW accepted, waiting for W
localparam W_RESP  = 2'd2;   // W accepted, sending B response
 
// ─── Read FSM states ──────────────────────────────────────────
localparam R_IDLE  = 1'd0;   // waiting for AR
localparam R_DATA  = 1'd1;   // sending R response
 
// ─── Register file ────────────────────────────────────────────
reg [DATA_WIDTH-1:0] regfile [0:NUM_REGS-1];
 
// ─── Internal registers ───────────────────────────────────────
reg [1:0]            w_state;
reg                  r_state;
reg [ADDR_WIDTH-1:0] aw_addr_lat;   // latched write address
reg                  addr_valid_w;  // write address in range
reg                  addr_valid_r;  // read  address in range
integer              i;
 
// ─── Address decode ───────────────────────────────────────────
// Word address = byte_address[ADDR_WIDTH-1:2]
// Valid range  = 0 to NUM_REGS-1
wire [$clog2(NUM_REGS)-1:0] wr_reg_idx = aw_addr_lat[($clog2(NUM_REGS)+1):2];
wire [$clog2(NUM_REGS)-1:0] rd_reg_idx = araddr[($clog2(NUM_REGS)+1):2];
 
wire aw_in_range = (awaddr[ADDR_WIDTH-1:2] < NUM_REGS);
wire ar_in_range = (araddr[ADDR_WIDTH-1:2] < NUM_REGS);
 
// ─── Write FSM ────────────────────────────────────────────────
always @(posedge clk) begin
    if (rst) begin
        awready    <= 1'b0;
        wready     <= 1'b0;
        bvalid     <= 1'b0;
        bresp      <= RESP_OKAY;
        aw_addr_lat<= {ADDR_WIDTH{1'b0}};
        addr_valid_w<= 1'b0;
        w_state    <= W_IDLE;
        for (i = 0; i < NUM_REGS; i = i + 1)
            regfile[i] <= {DATA_WIDTH{1'b0}};
    end else begin
        // Default de-assertions
        awready <= 1'b0;
        wready  <= 1'b0;
 
        case (w_state)
 
            // ── IDLE: watch for write address ──────────────
            W_IDLE: begin
                if (awvalid) begin
                    awready     <= 1'b1;
                    aw_addr_lat <= awaddr;
                    addr_valid_w<= aw_in_range;
                    w_state     <= W_DATA;
                end
            end
 
            // ── W_DATA: watch for write data ───────────────
            W_DATA: begin
                if (wvalid) begin
                    wready  <= 1'b1;
                    w_state <= W_RESP;
 
                    if (addr_valid_w) begin
                        // Apply byte-lane write strobe
                        if (wstrb[0]) regfile[wr_reg_idx][7:0]   <= wdata[7:0];
                        if (wstrb[1]) regfile[wr_reg_idx][15:8]  <= wdata[15:8];
                        if (wstrb[2]) regfile[wr_reg_idx][23:16] <= wdata[23:16];
                        if (wstrb[3]) regfile[wr_reg_idx][31:24] <= wdata[31:24];
                        bresp <= RESP_OKAY;
                    end else begin
                        // Address out of range — decode error
                        bresp <= RESP_DECERR;
                    end
 
                    bvalid <= 1'b1;
                end
            end
 
            // ── W_RESP: hold B channel until master accepts ─
            W_RESP: begin
                if (bvalid && bready) begin
                    bvalid  <= 1'b0;
                    bresp   <= RESP_OKAY;
                    w_state <= W_IDLE;
                end
            end
 
            default: w_state <= W_IDLE;
        endcase
    end
end
 
// ─── Read FSM ─────────────────────────────────────────────────
always @(posedge clk) begin
    if (rst) begin
        arready <= 1'b0;
        rvalid  <= 1'b0;
        rdata   <= {DATA_WIDTH{1'b0}};
        rresp   <= RESP_OKAY;
        r_state <= R_IDLE;
    end else begin
        arready <= 1'b0;  // default
 
        case (r_state)
 
            // ── IDLE: watch for read address ───────────────
            R_IDLE: begin
                if (arvalid) begin
                    arready <= 1'b1;
                    r_state <= R_DATA;
 
                    if (ar_in_range) begin
                        rdata  <= regfile[rd_reg_idx];
                        rresp  <= RESP_OKAY;
                    end else begin
                        rdata  <= {DATA_WIDTH{1'b0}};
                        rresp  <= RESP_DECERR;
                    end
 
                    rvalid <= 1'b1;
                end
            end
 
            // ── R_DATA: hold R channel until master accepts ─
            R_DATA: begin
                if (rvalid && rready) begin
                    rvalid  <= 1'b0;
                    rresp   <= RESP_OKAY;
                    r_state <= R_IDLE;
                end
            end
 
            default: r_state <= R_IDLE;
        endcase
    end
end
 
endmodule
