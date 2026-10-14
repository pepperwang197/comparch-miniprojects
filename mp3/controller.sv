`include "game.sv"

module controller (
    input logic clk, 
    output logic load_sreg, 
    output logic transmit_pixel,
    output logic pixel_value
);

    localparam TRANSMIT_FRAME       = 2'b01;
    localparam CALCULATE_NEXT_FRAME = 2'b10;
    localparam IDLE                 = 2'b00;

    localparam [2:0] TRANSMIT_IDLE  = 3'b001;
    localparam [2:0] LOAD_SREG      = 3'b010;
    localparam [2:0] TRANSMIT_PIXEL = 3'b100;

    localparam [8:0] TRANSMIT_CYCLES    = 9'd360;       // = 24 bits / pixel x 15 cycles / bit
    localparam [22:0] IDLE_CYCLES       = 22'd3000000;   // = 375000 - 64 x (360 + 2) for 32 frames / second

    // 3 million clk cycles for 1/4th of a second

    // initialize FSM state
    logic [1:0] state = TRANSMIT_FRAME;
    logic [1:0] next_state;

    // initialize inner FSM state
    logic [2:0] transmit_phase = LOAD_SREG;
    logic [2:0] next_transmit_phase;

    // initialize counters
    logic [5:0] current_pixel = 6'd0; // current pixel that we are transmitting (0-63)
    logic [8:0] transmit_counter = 9'd0; // how many clk cycles have we been transmitting this pixel?
    logic [22:0] idle_counter = 22'd0; // how long have we been idling?

    logic transmit_pixel_done;
    logic idle_done;

    assign transmit_pixel_done = (transmit_counter == TRANSMIT_CYCLES - 1);
    assign idle_done = (idle_counter == IDLE_CYCLES - 1);

    // update both states to next state
    always_ff @(negedge clk) begin
        state <= next_state;
        transmit_phase <= next_transmit_phase;
    end

    // set next state
    always_comb begin
        next_state = 1'bx;
        unique case (state)
            TRANSMIT_FRAME:
                if ((current_pixel == 6'd63) && (transmit_pixel_done))
                    next_state = CALCULATE_NEXT_FRAME;
                else
                    next_state = TRANSMIT_FRAME;
            CALCULATE_NEXT_FRAME:
                next_state = IDLE;
            IDLE:
                if (idle_done)
                    next_state = TRANSMIT_FRAME;
                else
                    next_state = IDLE;
        endcase
    end

    // set next transmit state
    always_comb begin
        next_transmit_phase = 1'bx;
        if (state == TRANSMIT_FRAME) begin
            case (transmit_phase)
                TRANSMIT_IDLE:
                    next_transmit_phase = LOAD_SREG;
                LOAD_SREG:
                    next_transmit_phase = TRANSMIT_PIXEL;
                TRANSMIT_PIXEL:
                    next_transmit_phase = transmit_pixel_done ? LOAD_SREG : TRANSMIT_PIXEL;
            endcase
        end else begin
            next_transmit_phase = TRANSMIT_IDLE;
        end
    end

    // increment pixel when done with pixel
    always_ff @(negedge clk) begin
        if ((state == TRANSMIT_FRAME) && transmit_pixel_done) begin
            current_pixel <= current_pixel + 1;
        end
    end

    // increment or reset transmit_counter
    always_ff @(negedge clk) begin
        if (transmit_phase == TRANSMIT_PIXEL) begin
            transmit_counter <= transmit_counter + 1;
        end
        else begin
            transmit_counter <= 9'd0;
        end
    end

    // increment or reset idle counter
    always_ff @(negedge clk) begin
        if (state == IDLE) begin
            idle_counter <= idle_counter + 1;
        end
        else begin
            idle_counter <= 20'd0;
        end
    end

    assign pixel = current_pixel;

    assign load_sreg = (transmit_phase == LOAD_SREG);
    assign transmit_pixel = (transmit_phase == TRANSMIT_PIXEL);
    assign updating = (state == CALCULATE_NEXT_FRAME);

    game game_module (
        .clk           (clk),
        .updating      (updating),
        .current_pixel (current_pixel),
        .pixel_value   (pixel_value)
    );

endmodule
