// ─────────────────────────────────────────────────────────────────────────
//  counter_4bit.v — Bộ đếm 4 bit đồng bộ
//
//  ĐẶC TẢ
//    clk    : xung nhịp
//    rst_n  : reset, TÍCH CỰC MỨC THẤP, BẤT ĐỒNG BỘ
//    en     : cho phép đếm
//    count  : giá trị đếm, 4 bit
//
//  QUY TẮC
//    rst_n = 0            -> count = 0
//    rst_n = 1 và en = 1  -> count tăng 1 tại sườn LÊN của clk
//    rst_n = 1 và en = 0  -> count giữ nguyên
//    count = 15           -> lần đếm tiếp theo quay về 0
// ─────────────────────────────────────────────────────────────────────────
`timescale 1ns/1ps

module counter_4bit (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       en,
    output reg  [3:0] count
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 4'b0000;
        end else if (en) begin
            count <= count + 4'b0001;
        end else begin
            count <= count;
        end
    end

endmodule

// ─────────────────────────────────────────────────────────────────────────
//  ĐIỀU CẦN HIỂU
//
//  1. Đây là mạch TUẦN TỰ, không phải tổ hợp — vì có thanh ghi count.
//
//  2. Dòng quan trọng nhất là danh sách nhạy cảm:
//         always @(posedge clk or negedge rst_n)
//     Nó nói: mạch thay đổi tại sườn LÊN của clk, HOẶC sườn XUỐNG của rst_n.
//     Vì rst_n nằm TRONG danh sách nhạy cảm nên đây là reset BẤT ĐỒNG BỘ.
//
//     Nếu viết  always @(posedge clk)  thì rst_n sẽ thành reset ĐỒNG BỘ —
//     chỉ được nhìn tới tại sườn nhịp. Tên tín hiệu không quyết định điều
//     này; danh sách nhạy cảm mới quyết định.
//
//  3. Dùng phép gán KHÔNG CHẶN  <=  cho mạch tuần tự. Với  <=  thì mọi vế
//     phải được đọc bằng giá trị CŨ rồi mới cùng lúc cập nhật — đúng hành vi
//     của flip-flop. Dùng  =  trong khối tuần tự là lỗi kinh điển.
// ─────────────────────────────────────────────────────────────────────────
