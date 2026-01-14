`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.01.2026 15:44:37
// Design Name: 
// Module Name: tb_uart_top
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


module tb_uart_top;

    localparam CLK_FREQ  = 1_000_000;
    localparam BAUD      = 9600;
    localparam BIT_TIME  = 104_000; // ns (close enough)

    reg clk;
    reg rst;
    reg rx;
    wire tx;

    uart_top #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD(BAUD)
    ) dut (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .tx(tx)
    );

    // Clock 1 MHz
    initial clk = 0;
    always #500 clk = ~clk;

    // Send UART byte
    task send_uart_byte(input [7:0] b);
        integer i;
        begin
            rx = 0; #(BIT_TIME);
            for (i=0;i<8;i=i+1) begin
                rx = b[i];
                #(BIT_TIME);
            end
            rx = 1; #(BIT_TIME);
        end
    endtask

    initial begin
        $display("UART ECHO TEST START");

        rst = 1;
        rx  = 1;
        #5000;
        rst = 0;

        #5000;
        $display("Sending 0x55");
        send_uart_byte(8'h55);

        #2_000_000;
        $display("Check waveform: TX should echo RX");

        $finish;
    end

endmodule


