# Thẻ tra nhanh

*In hai mặt, dán cạnh máy.*

---

## 1. Gõ ở cửa sổ nào

| | 🪟 **PowerShell** (Windows) | 🐧 **Ubuntu** (WSL2) |
|---|---|---|
| Mở bằng | Start → "PowerShell" | Start → "Ubuntu" |
| Dấu nhắc | `PS C:\Users\...>` | `ten@MAY:~$` |
| Lệnh của nó | `wsl`, `docker` (trên Windows), `explorer` | `apt`, `iverilog`, `yosys`, `make`, `git` |
| Đường dẫn | `C:\rtl2gds\...` | `/home/ten/rtl2gds` hoặc `/mnt/c/rtl2gds` |

**Gõ nhầm cửa sổ là lỗi phổ biến nhất.** `iverilog` không tồn tại ở PowerShell.
`wsl` không tồn tại ở Ubuntu.

---

## 2. Bảy lệnh dùng nhiều nhất

```bash
cd ~/rtl2gds                                  # ve thu muc bo bai
bash cong_cu/kiem_tra_tat_ca.sh               # ban dang o dau
bash lab0_counter/sim/run_sim.sh              # mo phong tu kiem
bash lab0_counter/sim/run_sim.sh --thuong     # mo phong, in tung dong
bash lab0_counter/synth/run_synth.sh          # tong hop + doi chieu chuan
gtkwave lab0_counter/sim/waveforms/*.vcd      # xem dang song
bash cong_cu/bao_cao_su_co.sh                 # bi tac: sinh bao cao gui GV
```

---

## 3. Kiểm tra theo chặng

| Chặng | Lệnh | Cửa sổ |
|---|---|---|
| 0 — Windows | `powershell -ExecutionPolicy Bypass -File .\cong_cu\00_kiem_tra_windows.ps1` | 🪟 |
| 1 — WSL2 | `bash cong_cu/01_kiem_tra_wsl.sh` | 🐧 |
| 2 — Công cụ | `bash cong_cu/02_kiem_tra_cong_cu.sh` | 🐧 |
| 3 — Docker **(tự chọn)** | `bash cong_cu/03_kiem_tra_docker.sh` | 🐧 |
| 4 — OpenLane **(tự chọn)** | `bash cong_cu/04_kiem_tra_openlane.sh` | 🐧 |
| Tất cả | `bash cong_cu/kiem_tra_tat_ca.sh` | 🐧 |

**Quy tắc:** chặng 1–2 là bắt buộc. Chặng 3–4 chỉ xét nếu em chủ động làm P&R local.

---

## 4. Ba con số phải khớp

| Con số | Giá trị | Lệch được? |
|---|---|---|
| Số phép so sánh trong mô phỏng lab 0 | **51** | ❌ Không |
| Số flip-flop sau tổng hợp lab 0 | **4** | ❌ Không |
| Số ô chuẩn sau tổng hợp lab 0 | **10** | ✅ Lệch 1–2 được (nếu yosys khác 0.33) |

Phiên bản tham chiếu:

```
Icarus Verilog version 12.0 (stable)
Yosys 0.33 (git sha1 2584903a060)
```

---

## 5. Bốn bước của quy trình

```
   1. MO PHONG     iverilog + vvp   ->  gia tri in ra dung chua
   2. TU KIEM      iverilog + vvp   ->  ALL TESTS PASSED
   3. TONG HOP     yosys            ->  10 o, 4 flip-flop
   4. RTL2GDSII    OpenLane local   ->  TU CHON; B2 chinh thuc chay tren GitHub
```

**Bước nào chưa xong thì không đi tiếp.**

---

## 6. Sáu lỗi hay gặp — sửa trong một dòng

| Thấy | Gõ |
|---|---|
| `$'\r': command not found` | `find . -name '*.sh' -exec sed -i 's/\r$//' {} +` |
| `Cannot connect to the Docker daemon` | Mở Docker Desktop → bật WSL Integration cho Ubuntu → 🪟 `wsl --shutdown` |
| `permission denied ... docker.sock` | `sudo usermod -aG docker $USER` rồi 🪟 `wsl --shutdown` |
| `E: Unable to locate package ...` | `sudo apt update` |
| `command not found` sau khi vừa cài | Đóng cửa sổ Ubuntu, mở lại |
| `No such file or directory` | `pwd` xem đang đứng đâu, rồi `cd ~/rtl2gds` |

---

## 7. Ba câu hỏi khi Docker không chạy

1. **Docker Desktop trên Windows đang mở?** → phải thấy **Engine running**
2. **WSL Integration đã bật RIÊNG `Ubuntu-24.04`?** → không phải chỉ dòng "default distro"
3. **Đã `wsl --shutdown` SAU KHI bật?** → cây cầu chỉ dựng lúc WSL khởi động

Kiểm theo đúng thứ tự này. Câu 2 và câu 3 là hai chỗ sai nhiều nhất.

---

## 8. Lệnh Linux tối thiểu

| Lệnh | Làm gì |
|---|---|
| `pwd` | Đang đứng ở thư mục nào |
| `ls` · `ls -la` | Liệt kê file · kèm chi tiết và file ẩn |
| `cd <thư-mục>` · `cd ..` · `cd ~` | Chuyển thư mục · lùi một cấp · về thư mục nhà |
| `cat <file>` | In cả file ra màn hình |
| `head -20 <file>` · `tail -40 <file>` | 20 dòng đầu · 40 dòng cuối |
| `grep -n "chữ" <file>` | Tìm chữ, kèm số dòng |
| `nano <file>` | Sửa file. Lưu: Ctrl+O, Enter. Thoát: Ctrl+X |
| `cp <a> <b>` · `cp -r <a> <b>` | Chép file · chép cả thư mục |
| `mkdir -p <đường/dẫn>` | Tạo thư mục, kể cả nhiều cấp |
| `rm <file>` · `rm -rf <thư-mục>` | Xoá file · xoá cả thư mục ⚠️ **không hỏi lại, không hoàn tác** |
| `find . -name "*.v"` | Tìm mọi file `.v` từ đây trở xuống |
| `df -h ~` | Xem đĩa còn trống bao nhiêu |
| `explorer.exe .` | Mở thư mục hiện tại bằng File Explorer của Windows |
| Ctrl + C | Dừng lệnh đang chạy |
| Phím ↑ | Gọi lại lệnh vừa gõ |
| Phím Tab | Tự điền nốt tên file — **dùng nhiều vào, đỡ gõ sai** |

---

## 9. Đường dẫn: hai thế giới

```
   Windows                          Ubuntu (WSL2)
   ─────────────────────────        ────────────────────────────
   C:\rtl2gds\...            ←→     /mnt/c/rtl2gds/...
   (khong co)                       /home/ten/rtl2gds     ← NHANH HON
```

* **Phần I** (mô phỏng, tổng hợp): để ở `/mnt/c/` cũng được
* **Nếu chọn Phần II local** (OpenLane): workspace nên ở `~/`, nếu không I/O qua `/mnt/c/` có thể rất chậm

Chuyển sang thư mục nhà:

```bash
cp -r /mnt/c/rtl2gds/BO_CAI_DAT_SINH_VIEN ~/rtl2gds && cd ~/rtl2gds
```

---

## 10. Chạy OpenLane local (Phần II — TỰ CHỌN)

```bash
cd ~/OpenLane
mkdir -p designs/counter_4bit/src
cp ~/rtl2gds/lab0_counter/rtl/counter_4bit.v  designs/counter_4bit/src/
cp ~/rtl2gds/lab0_counter/openlane/config.tcl designs/counter_4bit/

make mount                          # vao Docker, dau nhac se doi
./flow.tcl -design counter_4bit
exit                                # ra khoi Docker

cd ~/OpenLane/designs/counter_4bit
RUN_DIR=$(ls -td runs/RUN_* | head -1)
find "$RUN_DIR" -name "*.gds"       # tep layout/GDS do flow tao ra
cat "$RUN_DIR/reports/metrics.csv"  # moi con so
```

Bốn chỉ số phải nhìn trong `metrics.csv`:

| Chỉ số | Muốn thấy |
|---|---|
| `cell_count` | (lớn hơn 10 — có thêm bộ đệm và cây xung nhịp) |
| `wns` | **≥ 0** — âm là mạch không chạy nổi ở tần số đó |
| `tns` | **0** |
| `magic_drc` | **0** là mục tiêu — khác 0 nghĩa là còn vi phạm DRC trong flow |

---

## 11. Khi bị tắc

```bash
bash cong_cu/bao_cao_su_co.sh
```

Mở file sinh ra, **điền phần đầu** — nhất là *"Đã thử những cách nào rồi"* — rồi
gửi giảng viên.

**Đừng ngồi mò quá 20 phút.**
