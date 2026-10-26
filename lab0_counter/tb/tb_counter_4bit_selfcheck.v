// ─────────────────────────────────────────────────────────────────────────
//  tb_counter_4bit_selfcheck.v — Testbench TỰ KIỂM
//
//  Khác testbench thường ở chỗ: nó TỰ TÍNH giá trị mong đợi, TỰ SO với đầu
//  ra thật, rồi in PASS hoặc FAIL. Không cần nhìn sóng bằng mắt.
//
//  Đây là bước quan trọng nhất của kiểm chứng thiết kế số: chuyển việc đánh
//  giá từ mắt người sang máy. Mắt người mỏi, máy thì không.
// ─────────────────────────────────────────────────────────────────────────
`timescale 1ns/1ps

module tb_counter_4bit_selfcheck;

    reg        clk;
    reg        rst_n;
    reg        en;
    wire [3:0] count;

    integer so_loi   = 0;
    integer so_kiem  = 0;
    reg [3:0] mong_doi;      // mo hinh tham chieu — tinh doc lap voi DUT

    counter_4bit dut (
        .clk   (clk),
        .rst_n (rst_n),
        .en    (en),
        .count (count)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // ── Mo hinh tham chieu ───────────────────────────────────────────────
    // Tinh gia tri mong doi bang MOT DUONG DOC LAP, khong nhin vao count.
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)      mong_doi <= 4'd0;
        else if (en)     mong_doi <= mong_doi + 4'd1;
    end

    // ── So sanh moi chu ky ───────────────────────────────────────────────
    // Kiem tai suon XUONG de tranh doc dung luc gia tri dang doi.
    always @(negedge clk) begin
        if (rst_n === 1'b1) begin
            so_kiem = so_kiem + 1;
            if (count !== mong_doi) begin
                $display("  FAIL  t=%0t : count=%0d, mong doi %0d",
                         $time, count, mong_doi);
                so_loi = so_loi + 1;
            end
        end
    end

    task ktra (input [3:0] gia_tri, input [8*44-1:0] nhan);
        begin
            so_kiem = so_kiem + 1;
            if (count !== gia_tri) begin
                $display("  FAIL  %0s : count=%0d, mong doi %0d",
                         nhan, count, gia_tri);
                so_loi = so_loi + 1;
            end else begin
                $display("  ok    %0s : count=%0d", nhan, count);
            end
        end
    endtask

    integer i;

    initial begin
        $dumpfile("sim/waveforms/counter_4bit_selfcheck.vcd");
        $dumpvars(0, tb_counter_4bit_selfcheck);

        $display("");
        $display("  ================================================");
        $display("   LAB 0 — kiem tra tu dong bo dem 4 bit");
        $display("  ================================================");
        $display("");

        // ── Ca 1: reset ──────────────────────────────────────────────────
        rst_n = 0; en = 0; mong_doi = 4'd0;
        @(negedge clk); @(negedge clk);
        ktra(4'd0, "Ca 1  reset -> count = 0");

        // ── Ca 2: nha reset, en=0 thi phai DUNG YEN ──────────────────────
        rst_n = 1;
        repeat (4) @(negedge clk);
        ktra(4'd0, "Ca 2  en=0 -> dung yen");

        // ── Ca 3: dem len 5 lan ──────────────────────────────────────────
        en = 1;
        repeat (5) @(negedge clk);
        ktra(4'd5, "Ca 3  dem 5 nhip -> count = 5");

        // ── Ca 4: dung dem giua chung ────────────────────────────────────
        en = 0;
        repeat (3) @(negedge clk);
        ktra(4'd5, "Ca 4  en=0 giua chung -> giu 5");

        // ── Ca 5: dem tiep toi khi TRAN ──────────────────────────────────
        en = 1;
        repeat (10) @(negedge clk);
        ktra(4'd15, "Ca 5  dem toi 15");

        // ── Ca 6: tran ve 0 ──────────────────────────────────────────────
        @(negedge clk);
        ktra(4'd0, "Ca 6  15 + 1 -> tran ve 0");

        // ── Ca 7: reset bat dong bo GIUA chu ky ──────────────────────────
        repeat (3) @(negedge clk);
        #2 rst_n = 0;            // ha giua chu ky, KHONG trung suon nhip
        #1;
        ktra(4'd0, "Ca 7  reset bat dong bo giua chu ky");

        // ── Ca 8: chay tron mot vong 16 gia tri ──────────────────────────
        // Bat dau tu trang thai SACH. Ba dong duoi day khong thua:
        //   en = 0            : en van con bat tu Ca 5. De nguyen thi bo dem
        //                       nhay them mot nhip truoc khi vong lap kip
        //                       bat dau, va moi phep so sau do lech 1.
        //   giu reset 1 nhip  : cho ca DUT lan mo hinh tham chieu cung ve 0
        //                       tai cung mot suon, khong ai som hon ai.
        //   nha reset roi doi : mot nhip nua de moi thu on dinh.
        en = 0;
        @(negedge clk);
        rst_n = 1;
        @(negedge clk);
        en = 1;
        for (i = 1; i <= 16; i = i + 1) begin
            @(negedge clk);
            if (count !== (i % 16)) begin
                $display("  FAIL  Ca 8  nhip %0d : count=%0d, mong doi %0d",
                         i, count, i % 16);
                so_loi = so_loi + 1;
            end
        end
        if (so_loi == 0)
            $display("  ok    Ca 8  tron mot vong 16 gia tri");

        // ── Ket luan ─────────────────────────────────────────────────────
        $display("");
        $display("  ------------------------------------------------");
        $display("   Da kiem: %0d phep so sanh", so_kiem);
        if (so_loi == 0) begin
            $display("   Ket qua: ALL TESTS PASSED");
        end else begin
            $display("   Ket qua: FAILED — %0d loi", so_loi);
        end
        $display("  ------------------------------------------------");
        $display("");

        $finish;
    end

endmodule
