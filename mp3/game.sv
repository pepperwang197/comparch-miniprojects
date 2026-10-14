module game (
    input logic clk,
    input logic updating,
    input logic [5:0] current_pixel,
    output logic pixel_value
);

    logic [64:0] game_state = 64'b0011100000000000; // 64 bits, one for each pixel
    logic [64:0] next_game_state = 64'b0;

    always_comb begin
        next_game_state = 64'b0;
        if (updating) begin
            for(int i=0; i<64; i++) begin
                // if(i < 32) begin
                //     next_game_state[i] = 1'b1;
                // end else begin
                //     next_game_state[i] = 1'b0;
                // end
                case (
                    game_state[{i[5:3]-1'b1, i[2:0]-1'b1}] +
                    game_state[{i[5:3]-1'b1, i[2:0]}] +
                    game_state[{i[5:3]-1'b1, i[2:0]+1'b1}] +
                    game_state[{i[5:3], i[2:0]-1'b1}] +
                    game_state[{i[5:3], i[2:0]+1'b1}] +
                    game_state[{i[5:3]+1'b1, i[2:0]-1'b1}] +
                    game_state[{i[5:3]+1'b1, i[2:0]}] +
                    game_state[{i[5:3]+1'b1, i[2:0]+1'b1}]
                )
                    3'd2:
                        if (game_state[i]) begin
                            next_game_state[i] = 1'b1;
                        end else begin
                            next_game_state[i] = 1'b0;
                        end
                    3'd3:
                        next_game_state[i] = 1'b1;
                    default:
                        next_game_state[i] = 1'b0;
                endcase
            end
        end else begin
            next_game_state = game_state;
        end
    end

    always_ff @(negedge clk) begin
        game_state = next_game_state;
    end

    assign pixel_value = game_state[current_pixel];

endmodule