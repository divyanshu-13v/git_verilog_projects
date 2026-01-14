`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.01.2026 15:43:15
// Design Name: 
// Module Name: uart_top
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
module uart_top #(
    parameter CLK_FREQ = 1_000_000,
    parameter BAUD     = 9600
)(
    input  wire clk,
    input  wire rst,
    input  wire rx,
    output wire tx
);

    wire [7:0] rx_data;
    wire rx_done;
    reg  tx_start;
    reg  [7:0] tx_data;
    wire tx_done;

    // RX
    uart_rx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD(BAUD)
    ) u_rx (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .data(rx_data),
        .done(rx_done)
    );

    // TX
    uart_tx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD(BAUD)
    ) u_tx (
        .clk(clk),
        .rst(rst),
        .start(tx_start),
        .data(tx_data),
        .tx(tx),
        .done(tx_done)
    );

    // Echo logic
    always @(posedge clk) begin
        if (rst) begin
            tx_start <= 0;
            tx_data  <= 0;
        end else begin
            tx_start <= 0;
            if (rx_done) begin
                tx_data  <= rx_data;
                tx_start <= 1'b1;
            end
        end
    end

endmodule
