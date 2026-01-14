`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.01.2026 15:46:18
// Design Name: 
// Module Name: uart_tx
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


module uart_tx #(
    parameter CLK_FREQ = 1000000,
    parameter BAUD_RATE = 9600
)(
    input wire clk,
    input wire rst,
    input wire start,       // Pulse to start transmission
    input wire [7:0] data,  // Data to send
    output reg tx,          // UART transmit pin
    output reg done         // High for 1 clock cycle when finished
);

    // Calculate max counter value
    localparam BAUD_CNT_MAX = (CLK_FREQ / BAUD_RATE);

    reg [13:0] baud_cnt; 
    reg [3:0] bit_cnt;   
    reg [9:0] shift_reg; // 1 Start + 8 Data + 1 Stop = 10 bits
    reg busy;

    always @(posedge clk) begin
        if (rst) begin
            tx <= 1'b1;         // UART Idle is HIGH
            done <= 1'b0;
            baud_cnt <= 0;
            bit_cnt <= 0;
            busy <= 1'b0;
            shift_reg <= 10'b1111111111;
        end else begin
            
            // Default done to 0 unless we finish this cycle
            done <= 1'b0; 

            // --- START LOGIC ---
            if (start && !busy) begin
                // Load the frame: {Stop_Bit, Data[7:0], Start_Bit}
                // Stop = 1, Data = data, Start = 0
                shift_reg <= {1'b1, data, 1'b0}; 
                busy <= 1'b1;
                baud_cnt <= 0;
                bit_cnt <= 0;
            end

            // --- TRANSMISSION LOGIC ---
            if (busy) begin
                
                // IMPORTANT: Drive TX based on the current LSB of shift_reg
                // This ensures Start bit (0) goes out immediately after loading
                tx <= shift_reg[0]; 

                // Timer Logic
                if (baud_cnt < BAUD_CNT_MAX - 1) begin
                    baud_cnt <= baud_cnt + 1;
                end else begin
                    // One bit period is over
                    baud_cnt <= 0;
                    bit_cnt <= bit_cnt + 1;
                    
                    // Shift the data to bring the next bit to LSB
                    shift_reg <= shift_reg >> 1;

                    // Check if we have sent all 10 bits (Start + 8 Data + Stop)
                    if (bit_cnt == 9) begin
                        busy <= 1'b0;
                        done <= 1'b1; // Pulse done signal
                        tx <= 1'b1;   // Return to Idle state (High)
                    end
                end
            end
        end
    end

endmodule
