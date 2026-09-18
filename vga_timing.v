module vga_timing(
    input  wire clk25,
    output reg  Hsync,
    output reg  Vsync,
    output reg  [9:0] x = 0,
    output reg  [9:0] y = 0,
    output wire video_on
);

    always @(posedge clk25)
        begin
            if (x==799) 
                begin
                    x<=0;
                    if (y==524)
                        y<=0;
                    else
                        y<=y+1;
                end
            else 
                begin
                    x<=x+1;
                end
        end

    assign video_on = (x<640 && y<480);

    always @* 
        begin
            Hsync = ~((x>=656) && (x<752));
            Vsync = ~((y>=490) && (y<492));
        end
endmodule