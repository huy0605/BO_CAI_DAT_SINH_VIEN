// ─────────────────────────────────────────────────────────────────────────
//  tb_counter_4bit.v — Testbench THƯỜNG
//
//  Nó chỉ tạo tín hiệu và in ra. Việc đánh giá đúng/sai là do MẮT NGƯỜI.
//  Bước sau (tb_counter_4bit_selfcheck.v) sẽ để MÁY tự đánh giá.
// ─────────────────────────────────────────────────────────────────────────
`timescale 1ns/1ps

module tb_counter_4bit;

    reg        clk;
    reg        rst_n;
    reg        en;
    wire [3:0] count;

    // Nối thiết kế cần kiểm tra (DUT = Design Under Test)
    counter_4bit dut (
        .clk   (clk),
        .rst_n (rst_n),
        .en    (en),
        .count (count)
    );

    // Sinh xung nhịp: chu kỳ 10 ns (nửa chu kỳ 5 ns)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Kịch bản kiểm tra
    initial begin
        $dumpfile("sim/waveforms/counter_4bit.vcd");
        $dumpvars(0, tb_counter_4bit);

        rst_n = 0;      // giu reset
        en    = 0;

        #20;
        rst_n = 1;      // nha reset

        #20;
        en = 1;         // bat dau dem

        #120;
        en = 0;         // dung dem, count phai GIU NGUYEN

        #40;
        en = 1;         // dem tiep

        #80;
        rst_n = 0;      // reset giua chung

        #20;
        rst_n = 1;

        #40;
        $finish;
    end

    // In ra mỗi khi có tín hiệu đổi
    initial begin
        $monitor("time=%0t | rst_n=%b | en=%b | count=%2d",
                 $time, rst_n, en, count);
    end

endmodule
