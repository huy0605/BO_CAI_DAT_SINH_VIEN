# Xử lý lỗi

Tra theo **thứ bạn nhìn thấy trên màn hình**, không phải theo thứ bạn đoán là
nguyên nhân.

---

## Trước khi tra: ba việc làm trong 60 giây

### 1. Đọc thông báo lỗi cho đúng chỗ

**Dòng cuối cùng thường KHÔNG phải lỗi thật.** Nó chỉ là dòng báo "có gì đó
hỏng". Lỗi thật nằm ở dòng đầu tiên có chữ `Error`, `ERROR` hoặc `error:`.

```
  make: *** [Makefile:42: test] Error 1          ← dong cuoi, VO NGHIA
  make: Leaving directory '/home/sinhvien/OpenLane'  ← cung vo nghia
```

Cuộn ngược lên tìm dòng kiểu:

```
  ERROR: Cannot connect to the Docker daemon      ← DAY moi la loi that
```

Cách nhanh, hứng cả log ra rồi lọc:

```bash
./flow.tcl -design counter_4bit 2>&1 | tee /tmp/log.txt
grep -n -i -m5 "error" /tmp/log.txt
```

### 2. Xác định lỗi thuộc tầng nào

```
   TANG 4   OpenLane        ./flow.tcl, make mount, config.tcl
   TANG 3   Docker          docker run, daemon, WSL Integration
   TANG 2   Cong cu Linux   iverilog, yosys, apt
   TANG 1   WSL2 / Ubuntu   wsl --install, quyen, duong dan
   TANG 0   Windows         ao hoa, dia, phien ban
```

**Luôn sửa từ tầng thấp lên.** Lỗi tầng 4 rất hay là triệu chứng của tầng 3.
Một lệnh cho biết bạn đang hỏng ở tầng nào:

```bash
bash cong_cu/kiem_tra_tat_ca.sh
```

### 3. Chạy lại đúng một lần

Nhiều lỗi mạng và lỗi Docker là nhất thời. Chạy lại một lần trước khi tra.
**Chỉ một lần** — chạy lại lần thứ ba mà vẫn thế thì nó không nhất thời.

---
---

# TẦNG 0 — Windows

| Bạn thấy | Nguyên nhân | Cách sửa |
|---|---|---|
| `WslRegisterDistribution failed with error: 0x80370102` | Ảo hoá tắt trong BIOS | Khởi động lại → vào BIOS (F2/F10/DEL/ESC) → bật **Intel VT-x** hoặc **AMD-V (SVM)** → lưu → khởi động lại |
| `0x80370114` | Thiếu tính năng Virtual Machine Platform | 🪟 Admin: `dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart` rồi khởi động lại |
| `Error: 0x800701bc` — WSL 2 requires an update to its kernel component | Nhân WSL2 cũ | 🪟 `wsl --update` |
| `The requested operation requires elevation` | Chưa mở PowerShell bằng quyền Administrator | Bấm phải Start → **Terminal (Admin)** |
| `khong the load file ... viec chay tap lenh bi vo hieu hoa tren he thong nay` | Chính sách chạy script | Gõ đủ: `powershell -ExecutionPolicy Bypass -File .\cong_cu\00_kiem_tra_windows.ps1` |
| Script `.ps1` mở ra bằng Notepad thay vì chạy | Windows liên kết `.ps1` với Notepad | Đừng bấm đúp. Gõ lệnh trong PowerShell |
| `not enough disk space` | Thiếu đĩa | Phần I cần ~3 GB, Phần II cần thêm ~30 GB |

---
---

# TẦNG 1 — WSL2 và Ubuntu

| Bạn thấy | Nguyên nhân | Cách sửa |
|---|---|---|
| `wsl -l -v` in ra trống sau khi cài | Chưa khởi động lại máy | Khởi động lại |
| Cột `VERSION` là `1` | Bản phân phối đang chạy WSL1 | 🪟 `wsl --set-version Ubuntu-24.04 2` — mất vài phút |
| `There is no distribution with the supplied name` | Sai tên | 🪟 `wsl -l -v` xem tên đúng. Chú ý `Ubuntu` khác `Ubuntu-24.04` |
| Cửa sổ Ubuntu mở rồi tắt ngay | Bản phân phối hỏng | 🪟 `wsl --unregister Ubuntu-24.04` rồi cài lại. ⚠️ **Xoá sạch mọi thứ trong Ubuntu** |
| Gõ mật khẩu không thấy ký tự nào | **Bình thường.** Linux cố ý không hiện | Cứ gõ rồi Enter |
| `Sorry, try again` khi dùng `sudo` | Sai mật khẩu | 🪟 `wsl -u root passwd <tên-của-bạn>` để đặt lại |
| `Could not resolve 'archive.ubuntu.com'` | Hỏng phân giải tên miền | `sudo nano /etc/resolv.conf` → thêm `nameserver 8.8.8.8` → Ctrl+O, Enter, Ctrl+X |
| `Could not get lock /var/lib/dpkg/lock-frontend` | Có tiến trình apt khác đang chạy | Đợi. Sau 5 phút vẫn kẹt: `sudo killall apt apt-get` |
| WSL rất chậm, RAM ăn hết | WSL2 mặc định lấy nhiều RAM | Tạo `C:\Users\<tên>\.wslconfig` với nội dung: `[wsl2]` xuống dòng `memory=8GB` xuống dòng `processors=4`. Rồi 🪟 `wsl --shutdown` |
| Không tìm thấy file mình vừa tạo bên Windows | Hai hệ thống tệp khác nhau | File Windows nằm ở `/mnt/c/...`. File Ubuntu mở bằng Explorer: gõ `explorer.exe .` |

---
---

# TẦNG 2 — Công cụ Linux

## Lỗi CRLF — lỗi số 1, nhận ra ngay bằng chuỗi `$'\r'`

```
run_sim.sh: line 12: $'\r': command not found
cd: /home/sinhvien/lab0$'\r': No such file or directory
'un_sim.sh: line 3: syntax error near unexpected token `
```

**Thấy `$'\r'` hoặc dấu nháy lẻ ở đầu dòng lỗi thì đúng là nó.**

Nguyên nhân: file `.sh` mang xuống dòng kiểu Windows. Windows kết thúc dòng bằng
hai byte `0D 0A` (gọi là CRLF), Linux bằng một byte `0A` (LF). Bash đọc byte
`0D` thừa như một ký tự thuộc về lệnh.

Sửa mọi file `.sh` trong bộ bài:

```bash
find . -name '*.sh' -exec sed -i 's/\r$//' {} +
```

Kiểm một file:

```bash
file lab0_counter/sim/run_sim.sh
```

* Có chữ `CRLF line terminators` → còn kiểu Windows, chưa sửa xong
* Không có gì → đúng kiểu Linux

> ⚠️ **Quy tắc ngược lại cũng đúng.** File `.ps1` và `.bat` chạy trên Windows thì
> **phải** giữ CRLF. Đừng chạy lệnh `sed` ở trên cho chúng. Đó là lý do lệnh trên
> chỉ lọc `*.sh`.

Vì sao nó xảy ra: bạn giải nén bộ bài bằng một công cụ tự đổi xuống dòng, hoặc
mở file bằng Notepad rồi lưu lại, hoặc `git` cấu hình `core.autocrlf=true`. Tắt
cho kho này:

```bash
git config --global core.autocrlf input
```

## Các lỗi công cụ khác

| Bạn thấy | Nguyên nhân | Cách sửa |
|---|---|---|
| `E: Unable to locate package yosys` | Danh mục cũ | `sudo apt update` rồi thử lại |
| `iverilog: command not found` sau khi cài | Cửa sổ cũ chưa nạp lại `PATH` | Đóng cửa sổ Ubuntu, mở lại |
| `iverilog: command not found` trong PowerShell | **Sai cửa sổ** | `iverilog` chỉ có trong Ubuntu. Mở cửa sổ Ubuntu |
| `gtkwave: cannot open display` | Chưa có máy chủ đồ hoạ | Không cản trở gì. Bài vẫn làm được. Windows 11 có WSLg sẵn; Windows 10 cần cài VcXsrv |
| `Permission denied` khi chạy `.sh` | File chưa có quyền chạy | Gõ `bash <file>` là đủ. Hoặc `chmod +x <file>` |
| `syntax error near unexpected token` | Hoặc CRLF, hoặc file bị cắt cụt | Kiểm CRLF trước. Rồi `wc -l <file>` xem có bị cụt không |
| Chữ hiện ra `â??` hoặc ô vuông | Cửa sổ không dùng UTF-8 | Dùng **Windows Terminal**. Hoặc 🪟 `chcp 65001` trước khi vào `wsl` |
| `dpkg: error processing package` | Cài dở dang lần trước | `sudo apt --fix-broken install` |

## Lỗi biên dịch Verilog

| Bạn thấy | Nghĩa là | Cách sửa |
|---|---|---|
| `syntax error` kèm số dòng | Thiếu `;`, `end`, `endmodule`, hoặc thừa dấu ngoặc | Đến **đúng dòng đó**, rồi nhìn cả dòng ngay TRƯỚC nó — lỗi thiếu `;` báo ở dòng sau |
| `Unable to bind wire/reg/memory 'x'` | Dùng tên chưa khai báo, hoặc gõ sai tên | Kiểm chính tả. Verilog phân biệt hoa thường: `count` khác `Count` |
| `reg 'x' is not a valid l-value` | Gán vào `wire` bằng `always` | Đổi khai báo thành `reg` (hoặc `logic` nếu dùng `-g2012`) |
| `Port ... is not a port of ...` | Nối sai tên cổng khi khởi tạo module | So tên cổng trong khai báo `module` với tên trong lời gọi |
| `error: Task ... not defined` | Gọi task chưa khai báo, hoặc khai báo sau chỗ gọi | Chuyển khai báo task lên trước |
| Biên dịch được nhưng `count` luôn là `x` | Chưa reset, hoặc chưa nối `clk` | Xem dạng sóng: tín hiệu nào là `x` trước tiên thì lỗi ở đó |

> **Mẹo đọc lỗi Verilog:** `iverilog` báo lỗi ở dòng nơi nó *phát hiện* vấn đề,
> không phải nơi bạn *gây ra* vấn đề. Thiếu `;` ở dòng 20 thường báo lỗi ở dòng
> 21 hoặc 22. Luôn nhìn thêm 1–2 dòng phía trên.

## Lỗi tổng hợp (yosys)

| Bạn thấy | Nghĩa là | Cách sửa |
|---|---|---|
| `ERROR: Module ... not found` | Sai tên module đỉnh trong `hierarchy -top` | Tên phải khớp `module <tên>` trong file RTL |
| `Warning: Identifier ... is implicitly declared` | Dùng tên chưa khai báo | Khai báo nó. Cảnh báo này rất hay dẫn tới lỗi thật |
| `Warning: Wire ... is used but has no driver` | Có dây không ai lái | Thường là gõ nhầm tên. Kiểm chính tả |
| `Number of processes` khác 0 | Chưa chạy `proc`, hoặc RTL có cấu trúc không tổng hợp được | Kiểm kịch bản `.ys` có lệnh `proc`. Kiểm RTL có `#delay` hoặc `$display` không |
| Số flip-flop nhiều hơn dự kiến | Suy ra thanh ghi ngoài ý muốn | Thường do gán trong `always @(*)` mà thiếu nhánh `else` → sinh ra **chốt (latch)** |
| `Latch inferred for signal ...` | Sinh ra chốt | Trong `always @(*)`, mọi nhánh phải gán cho mọi tín hiệu. Thêm `else`, hoặc gán giá trị mặc định ở đầu khối |

> **Cảnh báo `Latch inferred` là cảnh báo đáng sợ nhất trong tổng hợp.** Chốt là
> phần tử nhớ *không có xung nhịp* — nó rất khó phân tích thời gian và hay gây
> lỗi ngẫu nhiên trên chip thật. Không bao giờ được bỏ qua.

---
---

# TẦNG 3 — Docker

## `Cannot connect to the Docker daemon` — lỗi số 1 của tầng này

```
Cannot connect to the Docker daemon at unix:///var/run/docker.sock.
Is the docker daemon running?
```

**Kiểm ba câu hỏi, đúng thứ tự này. Đừng bỏ qua câu nào.**

| # | Câu hỏi | Kiểm | Nếu "chưa" |
|---|---|---|---|
| 1 | Docker Desktop trên **Windows** đang mở? | Nhìn khay hệ thống, có con cá voi. Mở cửa sổ Docker Desktop, phải thấy **Engine running** | Mở nó lên. Đợi 30–60 giây cho khởi động xong |
| 2 | WSL Integration đã bật **riêng** distro Ubuntu? | Docker Desktop → Settings → Resources → **WSL Integration** | Bật đích danh `Ubuntu-24.04`, **không phải chỉ** dòng "default distro". Apply & Restart |
| 3 | Đã `wsl --shutdown` **sau khi** bật? | — | 🪟 `wsl --shutdown`, đợi 10 giây, mở lại Ubuntu |

> **Câu 2 là chỗ sai nhiều nhất.** Ô "Enable integration with my default WSL
> distro" và danh sách "additional distros" là **hai thứ khác nhau**. Bật cái
> trên mà không tích Ubuntu ở dưới thì cầu chưa nối tới Ubuntu của bạn.
>
> **Câu 3 là chỗ sai nhiều thứ hai.** Cây cầu chỉ dựng lúc WSL khởi động. Cửa sổ
> Ubuntu đang mở sẽ không thấy Docker cho tới khi tắt hẳn WSL rồi mở lại.

## Các lỗi Docker khác

| Bạn thấy | Nguyên nhân | Cách sửa |
|---|---|---|
| `permission denied while trying to connect to the Docker daemon socket` | Người dùng chưa thuộc nhóm `docker` | `sudo usermod -aG docker $USER` → 🪟 `wsl --shutdown` → mở lại |
| `docker: command not found` trong Ubuntu | Cầu chưa dựng | Xem ba câu hỏi ở trên |
| Đã cài `docker` bằng `snap` hoặc `apt` mà không chạy | **Cách cài sai** | Gỡ đi: `sudo snap remove docker` / `sudo apt remove docker.io`. Cài Docker Desktop trên Windows |
| `Ubuntu-24.04` không hiện trong WSL Integration | Docker Desktop chưa thấy bản phân phối | 🪟 `wsl -l -v` xác nhận tên. Khởi động lại Docker Desktop |
| `no space left on device` | Hết đĩa | `docker system prune -a` — ⚠️ xoá mọi ảnh Docker không dùng |
| `toomanyrequests: You have reached your pull rate limit` | Docker Hub giới hạn tải cho tài khoản ẩn danh | Đợi 6 tiếng, hoặc `docker login` bằng tài khoản Docker Hub miễn phí |
| Kéo ảnh rất chậm hoặc đứt liên tục | Mạng trường chặn Docker Hub | Thử mạng khác (4G điện thoại). Vẫn hỏng thì báo giảng viên |
| Máy chậm hẳn sau khi cài Docker Desktop | Nó tự chạy cùng Windows | Settings → General → bỏ tích "Start Docker Desktop when you sign in" |

---
---

# TẦNG 4 — OpenLane

| Bạn thấy | Nguyên nhân | Cách sửa |
|---|---|---|
| `[ERROR]: Design <tên> not found` | Sai chỗ đặt thư mục hoặc sai tên | Thư mục phải là `~/OpenLane/designs/<tên>/` và tên trong `./flow.tcl -design <tên>` phải khớp |
| `make mount` xong `ls` không thấy `flow.tcl` | Chưa vào đúng thư mục trước khi mount | `cd ~/OpenLane` rồi mới `make mount` |
| `make` chạy mãi không xong | Đang để trong `/mnt/c/` | Chuyển vào `~/`. Xem mục dưới |
| `make test` báo lỗi PDK | PDK tải dở | Xoá `~/.volare` (hoặc `~/.ciel`) rồi chạy lại `make` |
| `[ERROR]: Cell ... not found in the library` | Sai PDK trong cấu hình | `config.tcl` phải có `sky130A` và `sky130_fd_sc_hd` |
| Dừng ở `floorplan`, lỗi về `utilization` | Thiết kế quá nhỏ so với vùng bố trí | Trong `config.tcl`, giảm `FP_CORE_UTIL` xuống `10` |
| Dừng ở `placement`, lỗi mật độ | Chật quá | Giảm `PL_TARGET_DENSITY` xuống `0.35` |
| Dừng ở `routing`, `congestion` | Không đủ chỗ nối dây | Giảm `PL_TARGET_DENSITY`, hoặc tăng diện tích khung |
| `magic_drc` khác 0 | Vi phạm luật vẽ của nhà máy | Thường do chật. Giảm `FP_CORE_UTIL` |
| `wns` âm | Mạch không chạy nổi ở tần số đặt ra | Tăng `CLOCK_PERIOD` trong `config.tcl` (số lớn hơn = tần số thấp hơn) |
| Chạy xong nhưng không có file `.gds` | Chuỗi dừng giữa chừng | Xem `$RUN_DIR/openlane.log`, 40 dòng cuối |

## Vì sao `/mnt/c/` làm OpenLane chậm kinh khủng

Ubuntu nhìn thấy ổ C: của Windows ở `/mnt/c/`. Mỗi lần đọc hay ghi một file qua
đó đều phải đi qua một lớp dịch giữa hai hệ thống tệp khác nhau.

Với vài file thì không thấy gì. Một lần chạy OpenLane đọc ghi **hàng chục nghìn**
file — chênh lệch có thể là vài phút so với nửa tiếng.

```bash
cp -r /mnt/c/rtl2gds/BO_CAI_DAT_SINH_VIEN ~/rtl2gds
cd ~/rtl2gds
pwd        # phai KHONG bat dau bang /mnt/
```

OpenLane thì **luôn** clone vào `~/`:

```bash
cd ~
git clone https://github.com/The-OpenROAD-Project/OpenLane.git
```

## Tìm lỗi thật trong log của OpenLane

```bash
cd ~/OpenLane/designs/counter_4bit
RUN_DIR=$(ls -td runs/RUN_* | head -1)

tail -n 60 "$RUN_DIR/openlane.log"          # 60 dong cuoi
grep -n -i "error" "$RUN_DIR/openlane.log" | head -20
cat "$RUN_DIR/warnings.log"
```

Mỗi bước còn có log riêng trong `$RUN_DIR/logs/` — chia theo chặng
(`synthesis/`, `floorplan/`, `placement/`, `cts/`, `routing/`).

---
---

# Vẫn không xong — gửi giảng viên thế nào cho nhanh

**Đừng ngồi thử mò quá 20 phút.**

```bash
bash cong_cu/bao_cao_su_co.sh
```

Nó sinh một file `bao_cao_su_co_<ngày>_<giờ>.txt`. **Mở ra điền phần đầu**:

```
│  Ho ten:
│  MSSV:
│  Lop:
│  Dang lam den buoc nao:
│  Lenh vua go:
│  Thong bao loi (dan 3-5 dong quanh cho loi that):
│  Da thu nhung cach nao roi (phan nay quan trong nhat):
```

> **Mục "Đã thử những cách nào rồi" là mục giúp gỡ nhanh nhất, và cũng là mục
> hay bị bỏ trống nhất.** Không có nó, giảng viên sẽ bảo bạn làm lại đúng những
> việc bạn đã làm.

Đưa file sang Windows để đính kèm email:

```bash
explorer.exe .
```

**Về quyền riêng tư:** file đó không chứa mật khẩu, khoá SSH hay nội dung file
cá nhân. Nếu URL proxy của bạn có tên đăng nhập/mật khẩu thì phần đó đã bị thay
bằng `***AN***`. Bạn mở ra đọc được toàn bộ trước khi gửi.

---

## Cách hỏi cho được trả lời nhanh

| ❌ Đừng viết | ✅ Viết thế này |
|---|---|
| "Em bị lỗi ạ" | "Em kẹt ở Bước 7, lệnh `docker run hello-world`" |
| "Nó không chạy" | Dán **5 dòng quanh chỗ lỗi**, không phải cả 500 dòng |
| Chụp màn hình cả desktop | Chép chữ (text) — tra cứu được, dán lại được |
| Không nói đã thử gì | "Em đã thử `wsl --shutdown` và bật WSL Integration rồi" |
| Hỏi lúc 11 giờ đêm hạn nộp | Cài đặt xong trong tuần đầu |

---
---

# Phụ lục — thuật ngữ hay gặp trong thông báo lỗi

| Từ | Nghĩa |
|---|---|
| **daemon** | Tiến trình chạy nền, không có cửa sổ. "Docker daemon" = phần Docker làm việc thật |
| **socket** | Cái "ổ cắm" để hai chương trình nói chuyện. `/var/run/docker.sock` là ổ cắm của Docker |
| **PATH** | Danh sách thư mục hệ thống tìm lệnh. `command not found` thường nghĩa là lệnh có nhưng không nằm trong PATH |
| **shell** | Chương trình nhận lệnh bạn gõ. `bash` là một shell |
| **stdout / stderr** | Hai luồng ra: bình thường và lỗi. `2>&1` nghĩa là "gộp luồng lỗi vào luồng thường" |
| **exit code** | Số một lệnh trả về khi xong. `0` = thành công, khác 0 = hỏng |
| **repository (repo)** | Kho chứa mã nguồn |
| **image / container** | *Image* là khuôn đúc (chỉ đọc). *Container* là một bản đang chạy từ khuôn đó |
| **mount** | Gắn một thư mục vào một chỗ khác để truy cập được. `make mount` gắn thư mục của bạn vào trong container |
| **PDK** | *Process Design Kit* — bộ tài liệu và thư viện của nhà máy: có những loại ô nào, mỗi ô rộng bao nhiêu, trễ bao nhiêu |
| **netlist** | Danh sách các ô và cách nối chúng. Kết quả của tổng hợp |
| **RTL** | *Register Transfer Level* — mức mô tả bằng thanh ghi và phép biến đổi giữa chúng. Chính là Verilog bạn viết |
| **GDSII** | Định dạng dữ liệu layout hình học. Trong học phần, đây là đầu ra của flow RTL-to-GDSII; có file GDS **không** đồng nghĩa tape-out/sign-off/chip đã sản xuất |
| **DRC** | *Design Rule Check* — kiểm bản vẽ có vi phạm luật nhà máy không |
| **LVS** | *Layout Versus Schematic* — kiểm bản vẽ có đúng là mạch bạn thiết kế không |
| **slack** | Thời gian còn dư của một đường tín hiệu. Âm = không kịp |
| **WNS / TNS** | *Worst / Total Negative Slack* — chỗ tệ nhất, và tổng mọi chỗ tệ |
| **CTS** | *Clock Tree Synthesis* — dựng cây phân phối xung nhịp tới mọi flip-flop |
| **latch (chốt)** | Phần tử nhớ không có xung nhịp. Sinh ra ngoài ý muốn thì là lỗi |
| **CRLF / LF** | Hai cách đánh dấu hết dòng. Windows dùng CRLF, Linux dùng LF |
