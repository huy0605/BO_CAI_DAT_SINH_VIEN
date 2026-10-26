# Chạy lab và đọc kết quả

Cài xong rồi thì tài liệu này dạy bạn **hiểu những gì hiện ra trên màn hình**.

Mục tiêu: sau khi đọc xong, mỗi con số trong kết quả bạn đều giải thích được
*nó ở đâu ra*, chứ không phải chỉ so xem có khớp bảng chuẩn hay không.

---

## Bốn bước, và mỗi bước trả lời một câu hỏi

```
   BƯỚC 1  MÔ PHỎNG            "Mạch có chạy đúng không?"
      │     iverilog + vvp       → nhìn giá trị in ra, tự đánh giá bằng mắt
      ▼
   BƯỚC 2  TỰ KIỂM             "Máy có tự khẳng định là đúng không?"
      │     iverilog + vvp       → ALL TESTS PASSED hoặc dòng FAIL
      ▼
   BƯỚC 3  TỔNG HỢP            "Mạch này tốn bao nhiêu phần cứng?"
      │     yosys                → 10 ô, 4 flip-flop
      ▼
   BƯỚC 4  RTL → GDSII         "Đặt lên silicon thì trông thế nào?"
            OpenLane            → file .gds, diện tích, thời gian, DRC
```

**Quy tắc không được phá: bước nào chưa xong thì không đi tiếp.**

Mô phỏng sai mà đã chạy OpenLane thì bạn sẽ mất cả buổi gỡ một lỗi lẽ ra tìm ra
trong ba giây. Chuỗi công cụ không kiểm hộ bạn cái gì cả — nó **thi hành trung
thực** một mạch sai và cho ra một con chip sai.

---

# Bước 1 — Mô phỏng thường

```bash
cd ~/rtl2gds
bash lab0_counter/sim/run_sim.sh --thuong
```

Bạn sẽ thấy từng dòng kiểu:

```
time=0 | rst_n=0 | en=0 | count= 0
time=20000 | rst_n=1 | en=0 | count= 0
time=40000 | rst_n=1 | en=1 | count= 0
time=45000 | rst_n=1 | en=1 | count= 1
time=55000 | rst_n=1 | en=1 | count= 2
time=65000 | rst_n=1 | en=1 | count= 3
```

> **Vì sao `time` nhảy hàng chục nghìn?** Dòng đầu file RTL có
> `` `timescale 1ns/1ps `` — đơn vị là 1 ns nhưng **độ phân giải là 1 ps**. Khi
> in bằng `%0t`, Verilog in theo đơn vị nhỏ nhất, tức picogiây. `45000 ps` =
> 45 ns. Chu kỳ nhịp là 10 ns nên các mốc cách nhau 10000.

## Chuyện gì vừa xảy ra

Ba việc, do hai lệnh làm:

```
  rtl/counter_4bit.v  ──┐
                        ├─►  iverilog  ──►  sim/build/tb_counter_4bit
  tb/tb_counter_4bit.v ─┘                    (mot chuong trinh chay duoc)
                                                     │
                                                     ▼
                                                    vvp
                                                     │
                                        ┌────────────┴────────────┐
                                        ▼                         ▼
                                 chu in ra man hinh        file .vcd (song)
```

* **`iverilog`** là *trình biên dịch*. Nó đọc Verilog và tạo ra một chương trình.
  Chương trình này **không phải phần cứng** — nó là phần mềm giả lập phần cứng.
* **`vvp`** chạy chương trình đó.
* Kết quả có hai đường ra: chữ in ra màn hình (do `$display` / `$monitor` trong
  testbench) và **file dạng sóng** `.vcd`.

## Testbench là gì và vì sao nó không phải phần cứng

| | `rtl/counter_4bit.v` | `tb/tb_counter_4bit.v` |
|---|---|---|
| Thành phần cứng thật? | ✅ Có | ❌ Không bao giờ |
| Được phép dùng `#10` (chờ 10 ns)? | ❌ Không | ✅ Có |
| Được phép dùng `$display`, `$finish`? | ❌ Không | ✅ Có |
| Có cổng vào/ra? | ✅ Có | ❌ Không — nó là `module tb;` rỗng |
| Ai sinh ra `clk`? | Không ai — `clk` là **đầu vào** | Testbench sinh |

Đây là lý do bộ bài tách hai thư mục `rtl/` và `tb/`. Trộn lẫn hai thứ là lỗi
kinh điển: viết `#10` trong file RTL thì mô phỏng vẫn chạy đúng, nhưng tổng hợp
sẽ **im lặng bỏ qua** nó, và mạch thật hoạt động khác hẳn mô phỏng.

## Xem dạng sóng

```bash
gtkwave lab0_counter/sim/waveforms/counter_4bit.vcd
```

Cửa sổ mở ra, bên trái là cây tín hiệu. Bấm `tb` → chọn `clk`, `rst_n`, `en`,
`count` → bấm **Insert**.

Ba thứ đáng nhìn nhất:

1. **`count` đổi giá trị ngay sau sườn LÊN của `clk`** — không phải sườn xuống,
   không phải giữa chu kỳ. Đó là ý nghĩa của `always @(posedge clk)`.
2. **Khi `rst_n` xuống 0, `count` về 0 NGAY LẬP TỨC**, không đợi sườn clk. Đó là
   ý nghĩa của chữ *bất đồng bộ* trong `always @(posedge clk or negedge rst_n)`.
3. **Khi `en` = 0, `count` nằm im** dù `clk` vẫn đập.

> **`gtkwave` không mở được cửa sổ?** Windows 11 có sẵn WSLg nên thường mở được.
> Windows 10 thì cần cài thêm máy chủ đồ hoạ (VcXsrv). **Không mở được cũng
> không cản trở gì** — mọi bài đều làm được qua bước 2 (tự kiểm). Xem dạng sóng
> là để *hiểu*, không phải để *chấm*.

---

# Bước 2 — Tự kiểm

```bash
bash lab0_counter/sim/run_sim.sh
```

```
  ok    Ca 1  reset -> count = 0 : count=0
  ok    Ca 2  en=0 -> dung yen : count=0
  ok    Ca 3  dem 5 nhip -> count = 5 : count=5
  ok    Ca 4  en=0 giua chung -> giu 5 : count=5
  ok    Ca 5  dem toi 15 : count=15
  ok    Ca 6  15 + 1 -> tran ve 0 : count=0
  ok    Ca 7  reset bat dong bo giua chu ky : count=0
  ok    Ca 8  tron mot vong 16 gia tri

  ------------------------------------------------
   Da kiem: 51 phep so sanh
   Ket qua: ALL TESTS PASSED
  ------------------------------------------------
```

## Khác bước 1 chỗ nào

Bước 1 in số ra để **bạn** nhìn. Bước 2 để **máy tự đánh giá**.

Sự khác biệt không nhỏ. Nhìn bằng mắt thì với 16 giá trị còn được; với một bộ
xử lý vài nghìn dòng thì không ai nhìn nổi. Mọi thiết kế thật đều kiểm kiểu
bước 2.

## `51 phép so sánh` ở đâu ra

Testbench tự kiểm có **hai phần**:

**Phần 1 — 8 ca kiểm có chủ đích.** Mỗi ca dựng một tình huống rồi so một lần:

```verilog
kiem("Ca 3  dem 5 nhip -> count = 5", count, 4'd5);
```

**Phần 2 — một mô hình đối chiếu chạy song song suốt bài.** Đây mới là phần sinh
ra phần lớn trong 51 phép so sánh:

```verilog
// mo hinh doi chieu: viet LAI dac ta mot cach doc lap
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)      mong_doi <= 4'd0;
    else if (en)     mong_doi <= mong_doi + 4'd1;
end

// moi chu ky deu so, khong bo sot chu ky nao
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
```

**51 chia ra thế nào:**

| Nguồn | Số phép so |
|---|---|
| Bảy lần gọi `ktra(...)` — Ca 1 đến Ca 7 | 7 |
| Bộ so liên tục, mỗi sườn xuống có `rst_n = 1` | 44 |
| | **51** |

(Vòng lặp của Ca 8 kiểm bằng đường riêng, chỉ cộng vào `so_loi` khi sai, nên
không nằm trong 51.)

Con số này cố định vì kịch bản kích thích cố định — nó lệch nghĩa là testbench
đã bị sửa.

> **Vì sao so ở sườn XUỐNG (`negedge clk`) mà không phải sườn lên?**
> Ở sườn lên, thanh ghi đang thay đổi — đọc lúc đó là đọc vào đúng khoảnh khắc
> giá trị chưa ổn định, kết quả tuỳ thuộc thứ tự lập lịch của trình mô phỏng.
> Nửa chu kỳ sau, mọi thứ đã yên. Đây là quy ước chuẩn trong kiểm chứng.

> **Vì sao `!==` mà không phải `!=`?**
> `!=` trả về `x` (không biết) khi một vế có bit `x` hoặc `z` — và `if (x)` được
> coi là sai, nên **lỗi bị bỏ sót**. `!==` so từng bit kể cả `x`/`z`, luôn trả
> về 0 hoặc 1. Trong kiểm chứng, luôn dùng `===` và `!==`.

## Bài tập: cố tình làm sai để thấy nó bắt được

Đây là bài tập quan trọng nhất trong tài liệu này. **Một bộ kiểm thử chưa từng
báo sai thì bạn không biết nó có hoạt động không.**

```bash
cp lab0_counter/rtl/counter_4bit.v /tmp/counter_goc.v
```

Mở `lab0_counter/rtl/counter_4bit.v`, sửa dòng đếm:

```verilog
count <= count + 4'b0001;      // goc
count <= count + 4'b0010;      // sua thanh: dem 2 mot lan
```

Chạy lại:

```bash
bash lab0_counter/sim/run_sim.sh
```

Phải thấy hàng loạt dòng `FAIL` và kết thúc bằng số lỗi khác 0 — đúng như thế
này:

```
  ok    Ca 1  reset -> count = 0 : count=0
  ok    Ca 2  en=0 -> dung yen : count=0
  FAIL  t=70000 : count=2, mong doi 1
  FAIL  t=80000 : count=4, mong doi 2
  FAIL  t=90000 : count=6, mong doi 3
  ...
  ------------------------------------------------
   Da kiem: 51 phep so sanh
   Ket qua: FAILED — 54 loi
  ------------------------------------------------
```

**Ba điều đáng chú ý trong kết quả này:**

1. **Ca 1 và Ca 2 vẫn `ok`.** Vì lúc đó `en = 0`, bộ đếm chưa chạy — lỗi chưa lộ.
   Một bộ kiểm thử chỉ có Ca 1 và Ca 2 sẽ **báo đạt** cho một mạch sai.
2. **`Da kiem` vẫn là 51.** Số phép so không đổi; chỉ số phép *sai* đổi. Đó là
   cách đọc đúng: `51` nói bộ kiểm thử chạy đủ, `54 loi` nói mạch sai.
3. **Dòng `FAIL` đầu tiên ở `t=70000`** — bộ so liên tục bắt được ngay nhịp đếm
   đầu tiên, sớm hơn hẳn `ktra` của Ca 3. Đó là lợi ích của việc so **mọi chu
   kỳ** thay vì chỉ so ở vài mốc.

Trả lại nguyên trạng:

```bash
cp /tmp/counter_goc.v lab0_counter/rtl/counter_4bit.v
bash lab0_counter/sim/run_sim.sh
```

Lại `ALL TESTS PASSED`.

> **Kỹ thuật này có tên: kiểm thử đột biến (mutation testing).** Bạn cố tình gieo
> một lỗi rồi xem bộ kiểm thử có giết được nó không. Bộ kiểm thử nào không giết
> được lỗi gieo vào thì nó chỉ đang trang trí.

---

# Bước 3 — Tổng hợp

```bash
bash lab0_counter/synth/run_synth.sh
```

## Đọc khối thống kê

Phần đáng đọc nhất trong toàn bộ log:

```
=== counter_4bit ===

   Number of wires:                  7
   Number of wire bits:             19
   Number of public wires:           4
   Number of public wire bits:       7
   Number of memories:               0
   Number of memory bits:            0
   Number of processes:              0
   Number of cells:                 10
     $_AND_                          2
     $_DFFE_PN0P_                    4
     $_NOT_                          1
     $_XOR_                          3
```

Từng dòng:

| Dòng | Nghĩa | Ghi chú |
|---|---|---|
| `Number of wires` | Số **tên dây** trong netlist | `count` tính là 1 dây |
| `Number of wire bits` | Số **đường dẫn vật lý** | `count[3:0]` tính là 4 bit |
| `Number of public wires` | Số dây có tên do bạn đặt | 4 = `clk`, `rst_n`, `en`, `count` |
| `Number of memories` | Số khối nhớ được suy ra | 0 — bộ đếm không có RAM |
| `Number of processes` | Số khối `always` **chưa** chuyển thành netlist | **Phải là 0.** Khác 0 nghĩa là yosys chưa xử lý xong, số ô không đáng tin |
| `Number of cells` | **Số cổng logic** | Đây là con số quan trọng nhất |

> **`Number of processes: 0` là dòng nhiều người bỏ qua nhưng rất đáng nhìn.**
> Nó khác 0 khi bạn quên chạy lệnh `proc`, hoặc khi RTL có cấu trúc yosys không
> tổng hợp được. Số ô lúc đó vô nghĩa.

## Mười ô đó tính bằng tay được

Đây không phải hộp đen. Bộ đếm tăng dần có công thức rất gọn: **bit thứ *k* đảo
trạng thái khi tất cả các bit thấp hơn nó đều bằng 1.**

| Bit | Giá trị kế tiếp | Cổng cần |
|---|---|---|
| `count[0]` | `~count[0]` | 1 × NOT |
| `count[1]` | `count[1] ^ count[0]` | 1 × XOR |
| `count[2]` | `count[2] ^ (count[1] & count[0])` | 1 × AND, 1 × XOR |
| `count[3]` | `count[3] ^ (count[2] & (count[1] & count[0]))` | 1 × AND, 1 × XOR |
| | **Cộng lại** | **1 NOT + 2 AND + 3 XOR = 6** |
| Cộng 4 thanh ghi giữ `count[3:0]` | | **+ 4 flip-flop** |
| | | **= 10 ô** ✅ |

Mở netlist ra đối chiếu, đúng từng dòng:

```bash
grep "assign" lab0_counter/synth/netlist/counter_4bit_synth.v | sed 's/(\*.*\*)//'
```

```
  assign _01_[0] = ~count[0];                ← NOT
  assign _02_[2] = count[2] ^  _00_[1];      ← XOR 2
  assign _02_[3] = count[3] ^  _00_[2];      ← XOR 3
  assign _00_[1] = count[1] &  count[0];     ← AND 1
  assign _00_[2] = count[2] &  _00_[1];      ← AND 2
  assign _02_[1] = count[1] ^  count[0];     ← XOR 1
  assign _00_[0] = count[0];                 ← chi doi ten, khong ton o
  assign _01_[3:1] = count[3:1];             ← chi doi ten, khong ton o
  assign _02_[0] = _01_[0];                  ← chi doi ten, khong ton o
```

> **Chín dòng `assign` nhưng chỉ sáu ô.** Ba dòng cuối chỉ là *đổi tên dây* —
> nối thẳng đầu này sang đầu kia, không có cổng logic nào ở giữa. Đó là lý do
> `Number of cells` (10) và số dòng netlist không bằng nhau. Khi đọc netlist,
> luôn phân biệt **dây** với **ô**.

> **Đây là điều đáng nhớ nhất của Bước 3.** Tổng hợp không phải phép màu. Với
> mạch nhỏ, bạn kiểm được kết quả của nó bằng giấy bút. Thói quen này giữ được
> khi mạch lớn lên: bạn không kiểm từng cổng nữa, nhưng bạn vẫn biết *bậc độ
> lớn* phải là bao nhiêu, và biết khi nào con số ra vô lý.

## Đọc tên ô `$_DFFE_PN0P_`

Tên này không ngẫu nhiên. Nó **mã hoá đúng đặc tả bạn viết trong RTL**:

```
   $_DFFE_ P N 0 P _
           │ │ │ └── cho phep (Enable) tich cuc muc cao   ← en = 1 thi dem
           │ │ └──── reset ve gia tri 0                   ← count <= 4'b0000
           │ └────── reset tich cuc muc thap (N)          ← rst_n
           └──────── clock lay suon LEN (Positive)        ← posedge clk
```

Đối chiếu với RTL:

```verilog
always @(posedge clk or negedge rst_n) begin   // P ... N
    if (!rst_n)   count <= 4'b0000;            // ... 0
    else if (en)  count <= count + 4'b0001;    // ... P
```

**Khớp từng chữ.** Đây là cách nhanh nhất để phát hiện mình viết nhầm đặc tả:
nếu tên ô ra `$_DFFE_PP0P_` thì reset của bạn đang tích cực mức **cao**, không
phải mức thấp — dù mô phỏng có thể vẫn "chạy được".

## Con số nào được phép lệch

| Con số | Lệch được không | Vì sao |
|---|---|---|
| `Number of processes: 0` | ❌ Không | Khác 0 = tổng hợp chưa xong |
| Số flip-flop = **4** | ❌ Không | 4 bit thì phải đúng 4 phần tử nhớ. Ra 5 hay 3 = RTL sai |
| Số ô = **10** | ✅ Lệch 1–2 được | Phiên bản yosys khác thì bộ tối ưu khác |
| Tên ô `$_DFFE_PN0P_` | ❌ Không | Nó phản ánh đặc tả, không phải phiên bản |

## Đọc kịch bản yosys

File `lab0_counter/synth/counter_4bit.ys` là một danh sách lệnh, chạy tuần tự:

| Lệnh | Làm gì | Bỏ đi thì sao |
|---|---|---|
| `read_verilog` | Đọc mã nguồn | Không có gì để làm |
| `hierarchy -check -top` | Kiểm cây phân cấp, chỉ rõ module đỉnh | Yosys có thể chọn nhầm module đỉnh |
| `proc` | Chuyển khối `always` thành netlist | `Number of processes` khác 0, số ô vô nghĩa |
| `opt` | Tối ưu — bỏ logic thừa | Số ô nhiều hơn thực tế |
| `fsm` | Nhận diện máy trạng thái | Bộ đếm không có FSM nên không đổi gì |
| `memory` | Suy ra khối nhớ | Bộ đếm không có nhớ nên không đổi gì |
| `techmap` | Ánh xạ sang cổng logic cơ bản | Còn ở dạng toán tử `+`, chưa ra cổng |
| `clean` | Dọn dây và ô không dùng | Có ô rác trong thống kê |
| `stat` | **In thống kê** | Không thấy con số nào |
| `write_verilog` | Ghi netlist ra file | Không có gì để đối chiếu |

Thử bỏ `opt` và `clean` xem số ô đổi thế nào — đó là một bài tập tốt.

---

# Bước 4 — RTL → GDSII local (TỰ CHỌN)

*Bước này là nhánh local tự chọn và cần Phần II của `01_HUONG_DAN_CAI_DAT.md`. B2 chính thức dùng GitHub Actions + LibreLane, không cần bước local này.*

```bash
cd ~/OpenLane
make mount
./flow.tcl -design counter_4bit
exit
```

## Chuỗi đi qua sáu chặng

```
   synthesis   RTL  ->  netlist cong logic cua NHA MAY (sky130)
        ▼            khac buoc 3: gio la o that, co dien tich va tre that
   floorplan   quyet dinh khung/vung dat cho design trong flow
        ▼
   placement   dat tung o vao mot toa do cu the
        ▼
   cts         dung cay phan phoi xung nhip toi moi flip-flop
        ▼            (Clock Tree Synthesis)
   routing     noi day giua cac o, tren nhieu lop kim loai
        ▼
   signoff     kiem tra cuoi: DRC, LVS, thoi gian
```

## Tìm kết quả ở đâu

```bash
cd ~/OpenLane/designs/counter_4bit
RUN_DIR=$(ls -td runs/RUN_* | head -1)
echo "$RUN_DIR"
```

Cấu trúc bên trong:

| Đường dẫn | Chứa gì |
|---|---|
| `results/synthesis/` | Netlist sau tổng hợp — ánh xạ vào standard cell của thư viện sky130 |
| `results/floorplan/` | File `.def` — khung chip |
| `results/placement/` | Vị trí từng ô |
| `results/cts/` | Netlist sau khi thêm cây xung nhịp |
| `results/routing/` | Sau khi nối dây |
| `results/final/` | **File `.gds` — layout do flow tạo ra; không phải bằng chứng tape-out/sign-off** |
| `reports/metrics.csv` | ⭐ **Một dòng, mọi con số. Đọc file này trước** |
| `reports/manufacturability_report.csv` | DRC, LVS, antenna |
| `openlane.log` | Nhật ký đầy đủ. Lỗi thì tìm ở đây |
| `warnings.log` | Chỉ các cảnh báo |

## Bốn con số phải nhìn trong `metrics.csv`

```bash
python3 -c "
import csv,sys
r=list(csv.DictReader(open('$RUN_DIR/reports/metrics.csv')))[0]
for k in ['design','cell_count','wns','tns','magic_drc','lvs_total_errors','die_area']:
    print(f'{k:22} {r.get(k,\"(khong co)\")}')
"
```

| Chỉ số | Nghĩa | Muốn thấy gì |
|---|---|---|
| `cell_count` | Số ô thật của nhà máy | Lớn hơn số ở Bước 3 — vì thêm bộ đệm, cây xung nhịp, ô lấp chỗ trống |
| `wns` | *Worst Negative Slack* — chỗ chậm nhất còn dư bao nhiêu thời gian | **≥ 0**. Âm nghĩa là mạch không chạy nổi ở tần số đã đặt |
| `tns` | *Total Negative Slack* — cộng dồn mọi chỗ trễ | **= 0** nếu `wns ≥ 0` |
| `magic_drc` | Số vi phạm DRC mà flow báo | **= 0** là mục tiêu của flow. Khác 0 nghĩa là còn vi phạm hình học cần xử lý |

> **`wns` là chỉ số quan trọng mà sinh viên hay bỏ qua.** WNS âm nghĩa là thiết kế **không đáp ứng ràng buộc timing đã đặt** trong mô hình STA hiện tại. Điều đó không tự động chứng minh sai chức năng logic, và cũng không phải phép đo trên silicon. Muốn nói về tần số tối đa phải nêu rõ giả định, corner và ràng buộc.

## Quan sát layout

```bash
find "$RUN_DIR" -name "*.gds"
klayout "$RUN_DIR/results/final/gds/counter_4bit.gds"
```

Chưa có `klayout` thì cài trên Windows (bản Windows, mở file qua `/mnt/c/`) —
nó không bắt buộc cho môn học.

---

## Bảng tra nhanh: gặp con số này thì nghĩ gì

| Thấy | Nghĩ ngay tới |
|---|---|
| `ALL TESTS PASSED` | Chức năng đúng. **Chưa nói gì về diện tích hay tốc độ** |
| Có dòng `FAIL` | Dừng. Sửa RTL. Đừng tổng hợp |
| `Number of processes` khác 0 | Tổng hợp chưa hoàn tất, mọi số phía dưới vô nghĩa |
| Số flip-flop khác số bit thanh ghi | RTL sai, hoặc bạn suy ra thanh ghi ngoài ý muốn |
| Số ô tăng vọt sau khi sửa RTL nhỏ | Có thể đã vô tình sinh ra bộ nhân, bộ chia, hoặc chốt (latch) |
| `wns` âm | Mạch không chạy nổi ở tần số đặt ra. Giảm tần số hoặc chia nhỏ đường tổ hợp |
| `magic_drc` khác 0 | Bố trí vi phạm luật nhà máy. Thường do quá chật — giảm `FP_CORE_UTIL` |
| Chuỗi dừng ở `routing` | Chật quá. Giảm `PL_TARGET_DENSITY` |

---

## Việc tiếp theo

* Không hiểu một từ nào đó → tra `02_XU_LY_LOI.md` phần cuối, hoặc từ điển
  thuật ngữ của môn học
* Gặp lỗi → `02_XU_LY_LOI.md`
* Cần tra lệnh nhanh → `04_THE_TRA_NHANH.md`
