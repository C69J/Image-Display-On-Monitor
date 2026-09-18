module top(
    input  wire       clk,
    output wire       Hsync,
    output wire       Vsync,
    output reg  [3:0] Red,
    output reg  [3:0] Green,
    output reg  [3:0] Blue
);

    //CLOCK
    wire clk25;
    clock_divider u_clk (
          .clk(clk),
          .clk25(clk25));

    //VGA
    wire [9:0] x, y;
    wire video_on;

    vga_timing u_vga (
        .clk25(clk25),
        .Hsync(Hsync),
        .Vsync(Vsync),
        .x(x),
        .y(y),
        .video_on(video_on)
    );

    //IMAGE PARAMETERS
    localparam IMG_W = 64;
    localparam IMG_H = 64;
    localparam GAP   = 10;

    localparam LEFT_X  = (640 - (2*IMG_W + GAP)) / 2;
    localparam RIGHT_X = LEFT_X + IMG_W + GAP;
    localparam IMG_Y   = (480 - IMG_H) / 2;

    //ADDRESS
    reg [11:0] addr1, addr2;
    wire draw_left, draw_right;

    assign draw_left =
        video_on &&
        x >= LEFT_X && x < LEFT_X + IMG_W &&
        y >= IMG_Y  && y < IMG_Y  + IMG_H;

    assign draw_right =
        video_on &&
        x >= RIGHT_X && x < RIGHT_X + IMG_W &&
        y >= IMG_Y   && y < IMG_Y  + IMG_H;

    always @* 
        begin
            addr1 = 12'd0;
            addr2 = 12'd0;
            
            if (draw_left)
                addr1 = (y - IMG_Y) * IMG_W + (x - LEFT_X);
            else if (draw_right)
                addr2 = (y - IMG_Y) * IMG_W + (x - RIGHT_X);
        end

    //BRAM
    wire [15:0] pixel1, pixel2;

    image_bram #(.INIT_FILE("CAT1.hex")) img1 (
        .clk(clk25),
        .addr(addr1),
        .dout(pixel1)
    );

    image_bram #(.INIT_FILE("CAT2.hex")) img2 (
        .clk(clk25),
        .addr(addr2),
        .dout(pixel2)
    );

    //RGB REGISTER (1-CYCLE PIPELINE)
    always @(posedge clk25) 
        begin
            if (video_on) 
                begin
                    if (draw_left)
                        begin
                            Red  <= pixel1[15:12];
                            Green<= pixel1[10:7];
                            Blue <= pixel1[4:1];
                        end
                    else if (draw_right) 
                        begin
                            Red  <= pixel2[15:12];
                            Green<= pixel2[10:7];
                            Blue <= pixel2[4:1];
                        end
                    else 
                        begin
                            Red  <=0;
                            Green<=0; 
                            Blue <=0;
                        end
                end
            else 
                begin
                    Red  <=0; 
                    Green<=0; 
                    Blue <=0;
                end
        end

endmodule