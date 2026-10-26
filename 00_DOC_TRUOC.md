# Đọc trước — bắt đầu từ đây

Bộ này giúp bạn dựng môi trường thiết kế vi mạch trên máy Windows, **bắt đầu từ
một máy chưa cài gì cả**, rồi chạy được bài thực hành đầu tiên.

**Môn học:** EEE703128 — Nhập môn Thiết kế Vi mạch Tích hợp
**Giảng viên phụ trách:** Đinh Văn Nam

---

## Làm gì ngay bây giờ — ba việc

**1.** Chép thư mục này vào một chỗ **đường dẫn không dấu**, ví dụ:

```
C:\rtl2gds\BO_CAI_DAT_SINH_VIEN
```

Đừng để trong OneDrive, đừng để trong thư mục có dấu tiếng Việt hay khoảng
trắng.

**2.** Mở **PowerShell** tại thư mục đó (Shift + chuột phải trong thư mục →
"Open PowerShell window here") rồi gõ:

```powershell
powershell -ExecutionPolicy Bypass -File .\cong_cu\00_kiem_tra_windows.ps1
```

Lệnh này **không cài gì, không sửa gì**. Nó chỉ đọc thông tin máy và cho biết
máy bạn có đủ điều kiện không.

**3.** Mở `01_HUONG_DAN_CAI_DAT.md` và làm theo từ Bước 0.

---

## Trong bộ này có gì

| File | Đọc khi nào |
|---|---|
| **`00_DOC_TRUOC.md`** | Bạn đang đọc |
| **`01_HUONG_DAN_CAI_DAT.md`** | ⭐ Tài liệu chính. Từng bước, từ số 0 |
| **`02_XU_LY_LOI.md`** | Khi gặp lỗi. Tra theo thứ nhìn thấy trên màn hình |
| **`03_CHAY_LAB.md`** | Sau khi cài xong. Giải thích **mọi con số** trong kết quả |
| **`04_THE_TRA_NHANH.md`** | In ra dán cạnh máy |
| `cong_cu/` | Các script kiểm tra. Không tự mở ra sửa |
| `lab0_counter/` | Bài thực hành đầu tiên — bộ đếm 4 bit |

---

## Hai phần, và bạn có thể dừng ở giữa

```
   PHAN I  — BAT BUOC voi moi sinh vien           ~50 phut,  ~3 GB dia
   ┌──────────────────────────────────────────────────────────────┐
   │  WSL2 + Ubuntu + iverilog + yosys + gtkwave                   │
   │  -> viet, mo phong, kiem thu, tong hop Verilog                │
   │  -> DU cho toan bo bai tap cua mon hoc                        │
   └──────────────────────────────────────────────────────────────┘
                              │
                              ▼
   PHAN II — TU CHON: thu P&R local             ~3 gio,  ~30 GB dia
   ┌──────────────────────────────────────────────────────────────┐
   │  Docker Desktop + OpenLane + PDK sky130                       │
   │  -> tao layout/GDS local de hoc va doi chieu                  │
   │  -> KHONG phai dieu kien de lam B2 chinh thuc                 │
   └──────────────────────────────────────────────────────────────┘
```

**Xong Phần I là bạn đã đủ môi trường local để học RTL/mô phỏng/tổng hợp.** B2 chính thức sinh GDS bằng GitHub Actions + LibreLane, nên **không cần Phần II**. Phần II chỉ là nhánh tự chọn để thử P&R local, tốn khoảng 30 GB và vài giờ.

---

## Ba quy tắc

**1. Nhìn ký hiệu cửa sổ trước mỗi khối lệnh.**

* 🪟 = gõ ở **PowerShell** của Windows
* 🐧 = gõ ở cửa sổ **Ubuntu**

Gõ nhầm cửa sổ là lỗi phổ biến nhất. `iverilog` không tồn tại ở PowerShell.

**2. Còn dòng `[HONG]` thì dừng lại, đừng đi tiếp.**

Mỗi bước dựa trên bước trước. Bỏ qua một tầng hỏng thì lỗi ở tầng trên sẽ khó
gấp bội, vì bạn không biết nó thuộc tầng nào.

**3. Bị tắc quá 20 phút thì đừng mò nữa.**

```bash
bash cong_cu/bao_cao_su_co.sh
```

Nó sinh một file trả lời sẵn mười câu giảng viên sẽ phải hỏi. Mở ra điền phần
đầu rồi gửi.

---

## Biết mình đang ở đâu — một lệnh

Bất cứ lúc nào, trong cửa sổ Ubuntu:

```bash
bash cong_cu/kiem_tra_tat_ca.sh
```

```
   [x]  Chang 1 — WSL2 san sang               go duoc lenh trong Ubuntu
   [x]  Chang 2 — Cong cu mo phong + tong hop chay duoc lab0
   [ ]  Chang 3 — Docker chay duoc            TU CHON: P&R local
   [ ]  Chang 4 — OpenLane san sang           TU CHON: P&R local
```

---

## Đích đến của Phần I

Sau khoảng 50 phút, hai lệnh này phải chạy được:

```bash
bash lab0_counter/sim/run_sim.sh
bash lab0_counter/synth/run_synth.sh
```

và cho ra đúng ba con số:

| Con số | Giá trị |
|---|---|
| Số phép so sánh trong mô phỏng | **51** |
| Số flip-flop sau tổng hợp | **4** |
| Số ô chuẩn sau tổng hợp | **10** |

Ba con số này là **mốc đối chiếu chung của cả lớp**. Khớp nghĩa là máy bạn và
máy giảng viên đang nói cùng một ngôn ngữ.

---

## Về quyền riêng tư

Mọi script trong `cong_cu/` đều **chỉ đọc** — không cài, không sửa, không xoá,
và **không gửi gì đi đâu**. Bạn mở bằng Notepad đọc được toàn bộ nội dung.

`bao_cao_su_co.sh` sinh ra một file văn bản nằm tại chỗ. Nó **không** thu thập
mật khẩu, khoá SSH, hay nội dung file cá nhân của bạn. Bạn đọc file đó trước rồi
mới quyết định gửi hay không.
