`timescale 10ns/10ns
`include "top.sv"

module fade_tb;

    parameter PWM_PERIOD = 1200;

    logic clk = 0;
    logic LED;

    top # (
        .PWM_PERIOD   (PWM_PERIOD)
    ) u0 (
        .clk            (clk), 
        .RGB_R          (RGB_R),
        .RGB_G          (RGB_G),
        .RGB_B          (RGB_B)
    );

    initial begin
        $dumpfile("fade.vcd");
        $dumpvars(0, fade_tb);
        #120000000
        $finish;
    end

    always begin
        #4
        clk = ~clk;
    end

endmodule
