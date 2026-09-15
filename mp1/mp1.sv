module top(
    input logic     clk,
    output logic    RGB_R,
    output logic    RGB_G,
    output logic    RGB_B
);

    // CLK frequency is 12MHz, so 6,000,000 cycles is 0.5s
    parameter BLINK_INTERVAL = 2000000;
    logic [$clog2(BLINK_INTERVAL) - 1:0] count = 0;
    logic [2:0] color_state = 0;

    initial begin
        RGB_R = 1'b0;
        RGB_G = 1'b1;
        RGB_B = 1'b1;
    end

    always_ff @(posedge clk) begin
        if (count == BLINK_INTERVAL - 1) begin
            count <= 0;
            color_state = color_state==5 ? 0 : color_state+1;

            if (color_state <= 1 || color_state == 5) begin
                RGB_R <= 1'b0;
            end else begin
                RGB_R <= 1'b1;
            end

            if (color_state >= 1 && color_state <= 3) begin
                RGB_G <= 1'b0;
            end else begin
                RGB_G <= 1'b1;
            end

            if (color_state >= 3) begin
                RGB_B <= 1'b0;
            end else begin
                RGB_B <= 1'b1;
            end

        end else begin
            count <= count + 1;
        end
    end

endmodule
