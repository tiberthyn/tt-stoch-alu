`timescale 1ns/1ps
module tb_stoch_alu;
    reg  [7:0] ui_in;
    wire [7:0] uo_out;
    reg  [7:0] uio_reg;
    wire [7:0] uio;
    reg  clk, rst_n;

    assign uio = uio_reg;
    tt_um_stoch_alu dut (
        .ui_in(ui_in), .uo_out(uo_out), .uio(uio),
        .clk(clk), .rst_n(rst_n)
    );

    initial clk = 0;
    always #20 clk = ~clk; // 25 MHz

    initial begin
        $dumpfile("sim.vcd"); $dumpvars(0, tb_stoch_alu);
        rst_n = 0; ui_in = 0; uio_reg = 0;
        #100 rst_n = 1; #40;

        // Test 1: MUL Exacto (5 * 3 = 15)
        $display("[TEST 1] MUL Exacto: 5 x 3");
        ui_in = 8'h05; uio_reg = {1'b0, 3'd0, 4'h03};
        #100; $display("  Result: %d | Conf: %b", uo_out[6:0], uo_out[7]);

        // Test 2: MUL Estocástico (mismo caso)
        $display("\n[TEST 2] MUL Stochastic: 5 x 3");
        ui_in = 8'h05; uio_reg = {1'b1, 3'd0, 4'h03};
        #3000; $display("  Result: %d | Conf: %b", uo_out[6:0], uo_out[7]);

        // Test 3: ADD Estocástico
        $display("\n[TEST 3] ADD Stochastic: avg(200, 40)");
        ui_in = 8'hC8; uio_reg = {1'b1, 3'd1, 4'h8};
        #3000; $display("  Result: %d | Conf: %b", uo_out[6:0], uo_out[7]);

        #200;
        $display("\n Simulación completada. Revisa sim.vcd con GTKWave.");
        $finish;
    end
endmodule
