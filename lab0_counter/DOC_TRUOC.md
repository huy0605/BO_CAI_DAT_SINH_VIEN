# Lab 0 — Bộ đếm 4 bit đi trọn RTL → GDSII

Đây là bài thực hành nền tảng. Mạch rất đơn giản — **đó là chủ ý**. Mục tiêu
không phải thiết kế mạch khó, mà là **đi hết một lượt quy trình** để biết mỗi
bước làm gì.

## Bốn bước, chạy đúng thứ tự

```
   1. MO PHONG        rtl + testbench  ->  ket qua dung chua?
          │              iverilog, vvp
          ▼
   2. TU KIEM         may tu danh gia  ->  ALL TESTS PASSED
          │              iverilog, vvp
          ▼
   3. TONG HOP        RTL -> mach logic ->  10 o, 4 flip-flop
          │              yosys
          ▼
   4. RTL2GDSII       mach -> layout    ->  file .gds
                         OpenLane hoac LibreLane
```

> **Quy tắc không được phá:** bước nào chưa xong thì **không đi tiếp**. Nếu mô
> phỏng chưa đúng mà đã chạy OpenLane, bạn sẽ mất cả buổi để gỡ một lỗi lẽ ra
> tìm ra trong ba giây.

## Chạy

Đứng ở **thư mục gốc của bộ bài** (chỗ có `01_HUONG_DAN_CAI_DAT.md`):

```bash
cd ~/rtl2gds

bash lab0_counter/sim/run_sim.sh --thuong    # buoc 1 — xem tung dong in ra
bash lab0_counter/sim/run_sim.sh             # buoc 2 — may tu danh gia
bash lab0_counter/synth/run_synth.sh         # buoc 3 — tong hop
```

Ba script này tự tìm đường về thư mục `lab0_counter/`, nên gọi từ đâu cũng chạy
đúng.

Bước 4 xem `../01_HUONG_DAN_CAI_DAT.md` phần OpenLane.

## Kết quả chuẩn — đối chiếu để biết mình làm đúng

| Bước | Phải thấy |
|---|---|
| 1 — mô phỏng | các dòng `time=… count=…`, giá trị đếm tăng dần |
| 2 — tự kiểm | `ALL TESTS PASSED` |
| 3 — tổng hợp | `Number of cells: 10` · `$_DFFE_PN0P_ 4` |
| 4 — RTL2GDSII | file `.gds`, DRC = 0, LVS sạch |

**Con số ở bước 3 có ý nghĩa:** 4 flip-flop = 4 bit của `count[3:0]`. Một bộ
đếm 4 bit thì phải cần đúng 4 phần tử nhớ. Nếu ra số khác, hoặc bạn đã sửa RTL,
hoặc phiên bản Yosys khác — script `run_synth.sh` sẽ nói rõ.

## Cấu trúc thư mục

```
lab0_counter/
├── rtl/counter_4bit.v                    thiet ke that
├── tb/tb_counter_4bit.v                  testbench thuong
├── tb/tb_counter_4bit_selfcheck.v        testbench tu kiem
├── sim/run_sim.sh                        chay mo phong
├── sim/waveforms/                        file .vcd sinh ra o day
├── synth/counter_4bit.ys                 kich ban yosys
├── synth/run_synth.sh                    chay tong hop + doi chieu
├── synth/reports/                        log tong hop
├── synth/netlist/                        netlist sinh ra
└── openlane/config.tcl + config.json     cau hinh cho ca hai flow
```

**Vì sao tách `rtl/` và `tb/`:** `rtl/` chứa thứ **sẽ thành phần cứng thật**.
`tb/` chứa thứ **chỉ tồn tại trong mô phỏng**. Nhầm lẫn hai thứ này là lỗi hay
gặp — testbench có `$display`, `#delay`, `initial` mà phần cứng không có.
