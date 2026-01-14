`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.01.2026 15:43:29
// Design Name: 
// Module Name: uart_rx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module uart_rx #(
    parameter CLK_FREQ = 1000000,
    parameter BAUD = 9600
)(
    input wire clk,
    input wire rst,
    input wire rx,      // Async input
    output reg [7:0] data,
    output reg done
);

    localparam BAUD_CNT_MAX = CLK_FREQ / BAUD;

    reg [13:0] baud_cnt;
    reg [3:0] bit_cnt;
    reg busy;
    
    // Synchronize the asynchronous RX signal to our clock domain
    // (Prevents metastability/glitches)
    reg rx_sync, rx_temp;
    always @(posedge clk) begin
        rx_temp <= rx;
        rx_sync <= rx_temp; 
    end

    always @(posedge clk) begin
        if (rst) begin
            baud_cnt <= 0;
            bit_cnt <= 0;
            busy <= 0;
            done <= 0;
            data <= 0;
        end else begin
            done <= 0;

            // --- DETECT START BIT ---
            if (!busy && rx_sync == 0) begin
                busy <= 1;
                // Prepare to sample the MIDDLE of the start bit
                baud_cnt <= BAUD_CNT_MAX / 2;
                bit_cnt <= 0; 
            end

            // --- RECEIVE BITS ---
            if (busy) begin
                if (baud_cnt == 0) begin
                    // Timer expired: We are now in the middle of a bit!
                    
                    // Reset timer for the next full bit duration
                    baud_cnt <= BAUD_CNT_MAX - 1; 

                    case (bit_cnt)
                        0: begin
                            // Start Bit Logic:
                            // Check if input is still 0 (valid start bit)
                            if (rx_sync == 1'b0) begin
                                bit_cnt <= bit_cnt + 1;
                            end else begin
                                // It was a glitch (noise), go back to idle
                                busy <= 0; 
                            end
                        end
                        
                        1,2,3,4,5,6,7,8: begin
                            // Data Bits Logic:
                            // Shift bit into position. 
                            // Note: bit_cnt 1 corresponds to data[0]
                            data[bit_cnt - 1] <= rx_sync;
                            bit_cnt <= bit_cnt + 1;
                        end

                        9: begin
                            // Stop Bit Logic:
                            // Stop bit should be high. We finish regardless.
                            busy <= 0;
                            done <= 1;
                            bit_cnt <= 0;
                        end
                    endcase
                    
                end else begin
                    // Decrement timer
                    baud_cnt <= baud_cnt - 1;
                end
            end
        end
    end

endmodule
