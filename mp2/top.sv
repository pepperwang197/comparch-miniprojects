`include "fade.sv"
`include "pwm.sv"

// Fade top level module

module top #(
    parameter PWM_PERIOD = 1200,        // CLK frequency is 12MHz, so 1,200 cycles is 100us
    parameter STATE_INTERVAL = 2000000  // state changes every 1/6 second
)(
    input logic     clk,
    output logic    RGB_R,
    output logic    RGB_G,
    output logic    RGB_B
);

    logic [$clog2(PWM_PERIOD) - 1:0] pwm_value; // how pwm is the pwm
    logic [$clog2(STATE_INTERVAL) - 1:0] count = 0;
    logic [2:0] color_state = 0;
    logic pwm_out; // actual binary value that gets passed to led

    fade #(
        .PWM_PERIOD   (PWM_PERIOD)
    ) u1 (
        .clk            (clk), 
        .pwm_value      (pwm_value)
    );

    pwm #(
        .PWM_PERIOD   (PWM_PERIOD)
    ) u2 (
        .clk            (clk), 
        .pwm_value      (pwm_value), 
        .pwm_out        (pwm_out)
    );

    always_ff @(posedge clk) begin
        if (count == STATE_INTERVAL - 1) begin
            count <= 0;
            color_state <= color_state==5 ? 0 : color_state+1;
        end else begin
            count <= count + 1;
        end
    end

    always_comb begin

        case (color_state)
            0: begin
                RGB_R = 1'b0;
                RGB_G = ~pwm_out;
                RGB_B = 1'b1;
            end
            1: begin
                RGB_R = ~pwm_out;
                RGB_G = 1'b0;
                RGB_B = 1'b1;
            end
            2: begin
                RGB_R = 1'b1;
                RGB_G = 1'b0;
                RGB_B = ~pwm_out;
            end
            3: begin
                RGB_R = 1'b1;
                RGB_G = ~pwm_out;
                RGB_B = 1'b0;
            end
            4: begin
                RGB_R = ~pwm_out;
                RGB_G = 1'b1;
                RGB_B = 1'b0;
            end
            5: begin
                RGB_R = 1'b0;
                RGB_G = 1'b1;
                RGB_B = ~pwm_out;
            end
            default begin
                RGB_R = 1'bx;
                RGB_G = 1'bx;
                RGB_B = 1'bx;
            end
        endcase
    end

endmodule
