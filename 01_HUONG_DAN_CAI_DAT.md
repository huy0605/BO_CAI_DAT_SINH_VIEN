# Hướng dẫn cài môi trường local cho RTL, mô phỏng và tổng hợp trên Windows

**Bắt đầu từ số 0.** Tài liệu này giả định máy bạn chưa cài gì cả — chỉ có
Windows vừa mua về.

**Môn học:** EEE703128 — Nhập môn Thiết kế Vi mạch Tích hợp
**Áp dụng cho:** Windows 10 (build 19041 trở lên) và Windows 11, CPU x64

---

## Mục lục

| | Bước | Thời gian | Tải về | Đĩa dùng thêm |
|---|---|---|---|---|
| | **PHẦN I — BẮT BUỘC** | **~50 phút** | **~1 GB** | **~3 GB** |
| 0 | [Kiểm tra máy Windows](#bước-0--kiểm-tra-máy-windows-trước-khi-cài-gì-cả) | 5 phút | 0 | 0 |
| 1 | [Cài WSL2 + Ubuntu](#bước-1--cài-wsl2-và-ubuntu) | 15 phút | ~500 MB | ~2 GB |
| 2 | [Mở Ubuntu lần đầu](#bước-2--mở-ubuntu-lần-đầu) | 5 phút | 0 | 0 |
| 3 | [Cập nhật hệ thống](#bước-3--cập-nhật-hệ-thống) | 10 phút | ~200 MB | ~500 MB |
| 4 | [Cài bộ công cụ mô phỏng + tổng hợp](#bước-4--cài-bộ-công-cụ-mô-phỏng-và-tổng-hợp) | 5 phút | ~300 MB | ~800 MB |
| 5 | [Lấy bộ bài và chạy lab 0](#bước-5--lấy-bộ-bài-và-chạy-lab-0) ⭐ | 10 phút | nhỏ | nhỏ |
| | **PHẦN II — TỰ CHỌN: P&R LOCAL / ĐIỂM CỘNG** | **~2–3 giờ** | **~15 GB** | **~30 GB** |
| 6 | [Docker Desktop](#bước-6--docker-desktop-trên-windows) | 30 phút | ~600 MB | ~2 GB |
| 7 | [Bật WSL Integration](#bước-7--bật-wsl-integration--bước-hay-vấp-nhất) | 5 phút | 0 | 0 |
| 8 | [Tải và dựng OpenLane](#bước-8--tải-và-dựng-openlane) | 1–2 giờ | ~14 GB | ~28 GB |
| 9 | [Chạy trọn chuỗi RTL → GDSII](#bước-9--chạy-trọn-chuỗi-rtl--gdsii) | 20 phút | 0 | nhỏ |

> **Đọc kỹ dòng này trước khi bắt đầu.**
> **Phần I là bắt buộc với mọi sinh viên.** Xong Phần I là bạn làm được toàn bộ
> bài tập viết RTL, mô phỏng, kiểm thử và tổng hợp của môn học.
> **B2 chính thức không yêu cầu Phần II.** GDS và reports của B2 được sinh trên GitHub Actions bằng LibreLane + sky130A. Phần II chỉ để thử P&R local/đối chiếu, tốn khoảng 30 GB và vài giờ.

---

## Quy ước trong tài liệu này

Mỗi bước đều có đúng năm mục, luôn theo thứ tự này:

| Ký hiệu | Nghĩa |
|---|---|
| 🎯 **Mục đích** | Xong bước này thì bạn *làm được gì* mà trước đó chưa làm được |
| 🔍 **Kiểm tra trước** | Gõ lệnh này trước khi cài. Nếu đã có rồi thì **bỏ qua bước**, đừng cài đè |
| ⌨️ **Lệnh** | Gõ đúng như vậy. Copy được thì copy, đừng gõ tay |
| ✅ **Kiểm tra sau** | Kết quả *phải* ra như thế nào thì mới coi là xong |
| ❌ **Nếu sai** | Bảng: thông báo lỗi → nguyên nhân → cách sửa |

Còn ký hiệu cửa sổ:

| Ký hiệu | Gõ ở đâu |
|---|---|
| 🪟 **PowerShell** | Cửa sổ PowerShell của **Windows**. Bấm Start, gõ "PowerShell" |
| 🐧 **Ubuntu** | Cửa sổ **Ubuntu** trong WSL2. Bấm Start, gõ "Ubuntu" |
| 🐳 **Trong Docker** | Sau khi đã gõ `make mount` — dấu nhắc sẽ đổi |

**Gõ nhầm cửa sổ là lỗi số 1 của sinh viên.** Lệnh `wsl` chỉ chạy được ở
PowerShell. Lệnh `iverilog` chỉ chạy được ở Ubuntu. Trước mỗi khối lệnh đều có
ký hiệu — nhìn nó.

---

## Bức tranh tổng thể — cái gì nằm ở đâu

```
   MÁY TÍNH CỦA BẠN (Windows)
   ┌──────────────────────────────────────────────────────────────┐
   │                                                               │
   │   PowerShell                    Docker Desktop                │
   │   (quản lý WSL)                 (chạy TRÊN Windows)           │
   │        │                              │                       │
   │        │ wsl --install                │ WSL Integration       │
   │        ▼                              │  (cây cầu)            │
   │   ┌───────────────────────────────────┼───────────────────┐  │
   │   │  WSL2 — một máy Linux thật, gọn   │                   │  │
   │   │  ┌────────────────────────────────▼────────────────┐  │  │
   │   │  │  Ubuntu 24.04                                    │  │  │
   │   │  │                                                  │  │  │
   │   │  │   PHẦN I — cài bằng apt:                         │  │  │
   │   │  │     iverilog · yosys · gtkwave · git · python3   │  │  │
   │   │  │     ~800 MB. Đủ cho toàn bộ bài tập môn học.     │  │  │
   │   │  │                                                  │  │  │
   │   │  │   PHẦN II — TU CHON: OpenLane local trong Docker  │  │  │
   │   │  │   ┌──────────────────────────────────────────┐   │  │  │
   │   │  │   │  OpenROAD · Magic · Netgen · KLayout     │   │  │  │
   │   │  │   │  + PDK sky130 (thư viện ô của nhà máy)   │   │  │  │
   │   │  │   │  ~28 GB.                                  │   │  │  │
   │   │  │   └──────────────────────────────────────────┘   │  │  │
   │   │  └──────────────────────────────────────────────────┘  │  │
   │   └────────────────────────────────────────────────────────┘  │
   └──────────────────────────────────────────────────────────────┘
```

**Ba điều cần nhớ từ hình này:**

1. **WSL2 không phải máy ảo nặng nề.** Nó là một nhân Linux thật do Windows chạy
   sẵn. Khởi động dưới một giây, dùng chung file với Windows.
2. **Docker Desktop chạy trên Windows, không nằm trong Ubuntu.** Ubuntu chỉ
   *mượn* Docker qua cây cầu tên là WSL Integration. Đây là chỗ vấp phổ biến
   nhất, và là lý do Bước 7 có riêng một mục.
3. **Phần I và Phần II độc lập nhau.** Cài Phần II hỏng cũng không làm hư Phần I.

---
---

# PHẦN I — BẮT BUỘC

---

## Bước 0 — Kiểm tra máy Windows trước khi cài gì cả

### 🎯 Mục đích

Biết trước máy bạn có đủ điều kiện không, **trước khi** tải 15 GB về rồi mới
phát hiện CPU chưa bật ảo hoá. Bước này không cài gì, không sửa gì.

### 🔍 Kiểm tra trước

Không cần — đây *là* bước kiểm tra.

Nhưng phải giải nén bộ bài ra trước đã. Chép thư mục `BO_CAI_DAT_SINH_VIEN` vào
một chỗ **đường dẫn không dấu**, ví dụ:

```
C:\rtl2gds\BO_CAI_DAT_SINH_VIEN
```

> **Vì sao phải không dấu:** một số công cụ dòng lệnh xử lý sai đường dẫn có dấu
> tiếng Việt. `C:\Users\Nguyễn Văn A\Tài liệu\...` sẽ gây lỗi khó hiểu. Đừng để
> trong OneDrive nữa — OneDrive đồng bộ liên tục sẽ khoá file lúc đang chạy.

### ⌨️ Lệnh

🪟 **PowerShell** — mở tại thư mục đó (bấm Shift + chuột phải trong thư mục →
"Open PowerShell window here"), rồi gõ:

```powershell
powershell -ExecutionPolicy Bypass -File .\cong_cu\00_kiem_tra_windows.ps1
```

> **`-ExecutionPolicy Bypass` là gì và có nguy hiểm không?**
> Mặc định Windows không cho chạy file `.ps1` tải từ ngoài về, để phòng mã độc.
> Cờ này bảo "lần này thì cho phép" — chỉ áp dụng cho **đúng lần chạy này**, cho
> **đúng file này**, không đổi cài đặt hệ thống. File này chỉ đọc thông tin máy,
> bạn mở ra bằng Notepad đọc được toàn bộ.

### ✅ Kiểm tra sau

Ra bảng như thế này:

```
  ==============================================================
   CHANG 0 - KIEM TRA MAY WINDOWS
   Chay TRUOC khi cai bat ky thu gi
  ==============================================================

  -- Phien ban Windows --
  [ OK ]  Phien ban Windows              Windows 11 (build 22631)

  -- Kien truc CPU --
  [ OK ]  Kien truc                      x64 - dung loai anh Docker cua OpenLane

  -- Ao hoa (virtualization) --
  [ OK ]  Ao hoa                         dang bat va dang chay
  ...
  ==============================================================
   Dat: 12      Canh bao: 2      Hong: 0
  ==============================================================

  CHANG 0: DAT.
```

**Điều kiện đi tiếp: dòng `Hong: 0`.**

Còn `[ !! ]` (cảnh báo) thì vẫn đi tiếp được — nó chỉ nhắc chỗ sau này có thể
chậm hoặc vướng.

### ❌ Nếu sai

| Script báo | Nghĩa là | Làm gì |
|---|---|---|
| `Ao hoa TAT trong BIOS/UEFI` | CPU có hỗ trợ ảo hoá nhưng đang tắt | Khởi động lại, vào BIOS (bấm F2/F10/DEL/ESC lúc vừa bật máy), tìm **Intel VT-x** / **Intel Virtualization Technology** / **AMD-V** / **SVM Mode**, chuyển Enabled, lưu, khởi động lại |
| `Phien ban Windows ... QUA CU` | Windows cũ hơn build 19041 | Settings → Windows Update → Check for updates. Không lên được thì máy quá cũ — báo giảng viên để mượn máy phòng lab |
| `Kien truc ARM64` | Máy Snapdragon / Surface ARM | Phần I chạy được bình thường. Phần II (OpenLane) **không** — ảnh Docker build cho x64. Báo giảng viên |
| `Dia C: con trong ... khong du` | Thiếu đĩa | Phần I chỉ cần ~3 GB. Phần II cần thêm 30 GB. Dọn đĩa hoặc chỉ làm Phần I |
| `khong the load file ... vi viec chay tap lenh bi vo hieu hoa` | Chưa có `-ExecutionPolicy Bypass` | Gõ lại đúng cả dòng lệnh ở trên, có cả phần `-ExecutionPolicy Bypass` |
| PowerShell báo `The term ... is not recognized` | Đang đứng sai thư mục | Gõ `dir` xem có thấy thư mục `cong_cu` không. Không thấy thì `cd` vào đúng chỗ |

---

## Bước 1 — Cài WSL2 và Ubuntu

### 🎯 Mục đích

Có một máy Linux thật chạy bên trong Windows. Mọi công cụ thiết kế vi mạch mã
nguồn mở đều viết cho Linux — đây là cách chạy chúng mà không phải cài lại máy.

### 🔍 Kiểm tra trước

🪟 **PowerShell**:

```powershell
wsl --list --verbose
```

Ba khả năng:

**(a) Đã có Ubuntu, VERSION là 2** → **bỏ qua Bước 1**, sang thẳng Bước 2.

```
  NAME      STATE       VERSION
* Ubuntu    Stopped     2
```

**(b) Có Ubuntu nhưng VERSION là 1** → phải chuyển:

```powershell
wsl --set-version Ubuntu 2
```

Mất vài phút. Xong rồi kiểm lại bằng `wsl --list --verbose`.

> **WSL1 khác WSL2 chỗ nào mà phải đổi?** WSL1 dịch lệnh Linux sang lệnh Windows
> — không có nhân Linux thật, nên Docker không chạy được. WSL2 chạy nhân Linux
> thật trong một máy ảo siêu nhẹ. Môn này bắt buộc WSL2.

**(c) Báo lỗi, hoặc không có bản phân phối nào** → đi tiếp phần dưới.

### ⌨️ Lệnh

🪟 **PowerShell với quyền Administrator.** Bấm phải vào nút Start → **Terminal
(Admin)** hoặc **Windows PowerShell (Admin)**.

```powershell
wsl --install -d Ubuntu-24.04
```

Rồi **khởi động lại máy**. Có nhắc hay không cũng khởi động lại.

> **Vì sao chọn đúng Ubuntu 24.04, không phải bản khác?**
> Đây không phải sở thích. Ubuntu 24.04 là bản mà `apt install yosys` cho ra
> **đúng yosys 0.33** — cùng phiên bản với tài liệu tham chiếu của môn học:
>
> ```
> $ yosys -V
> Yosys 0.33 (git sha1 2584903a060)
> ```
>
> Nghĩa là số ô, số flip-flop mà máy bạn in ra sẽ **khớp từng con số** với bảng
> kết quả chuẩn trong bài. Chấm bài, so sánh, hỏi đáp đều dễ hơn hẳn.
> Ubuntu 22.04 cho yosys cũ hơn, số ô sẽ lệch chút — vẫn học được, nhưng phải
> giải thích thêm mỗi lần đối chiếu.

Nếu lệnh trên báo lỗi, có cách thứ hai: mở **Microsoft Store**, tìm
"Ubuntu 24.04", bấm Get.

### ✅ Kiểm tra sau

🪟 **PowerShell**:

```powershell
wsl --list --verbose
```

Phải ra:

```
  NAME              STATE       VERSION
* Ubuntu-24.04      Stopped     2
```

Cột `VERSION` phải là **2**. Chạy lại script kiểm tra cho chắc:

```powershell
powershell -ExecutionPolicy Bypass -File .\cong_cu\00_kiem_tra_windows.ps1
```

### ❌ Nếu sai

| Thông báo | Nguyên nhân | Cách sửa |
|---|---|---|
| `WslRegisterDistribution failed with error: 0x80370102` | Ảo hoá chưa bật trong BIOS | Bật Intel VT-x hoặc AMD-V (SVM) trong BIOS. Xem Bước 0 |
| `Error: 0x800701bc ... WSL 2 requires an update to its kernel component` | Nhân WSL2 cũ | 🪟 `wsl --update` rồi khởi động lại |
| `Yeu cau nay khong duoc ho tro` / `The requested operation requires elevation` | Chưa mở PowerShell bằng quyền Administrator | Bấm phải Start → Terminal (Admin) |
| Cài xong mà `wsl -l -v` vẫn trống | Chưa khởi động lại máy | Khởi động lại |
| Tải Ubuntu bị treo giữa chừng | Mạng chập chờn / proxy trường | Thử lại. Vẫn hỏng thì tải qua Microsoft Store |
| `There is no distribution with the supplied name` | Gõ sai tên bản phân phối | Xem tên đúng bằng: `wsl --list --online` |

---

## Bước 2 — Mở Ubuntu lần đầu

### 🎯 Mục đích

Tạo tài khoản người dùng trong Ubuntu. Lần đầu mở sẽ mất 1–2 phút để nó tự dựng
hệ thống tệp.

### 🔍 Kiểm tra trước

Không có gì để kiểm — đây là lần đầu.

### ⌨️ Lệnh

Bấm **Start**, gõ **Ubuntu**, bấm vào ứng dụng Ubuntu. Hoặc 🪟 gõ `wsl` trong
PowerShell.

Nó sẽ hỏi:

```
Enter new UNIX username:
```

Gõ một cái tên **viết thường, không dấu, không khoảng trắng**. Ví dụ `sinhvien`,
`sv2024`, `anhnv`.

```
New password:
```

**Gõ mật khẩu — bạn sẽ KHÔNG thấy gì hiện lên.** Không phải bàn phím hỏng. Linux
cố tình không hiện, kể cả dấu sao. Cứ gõ rồi Enter, gõ lại lần nữa để xác nhận.

> **Nhớ mật khẩu này.** Nó dùng cho mọi lệnh `sudo` về sau. Quên thì đặt lại
> được (🪟 `wsl -u root passwd <tên-của-bạn>`) nhưng lích kích.

### ✅ Kiểm tra sau

🐧 **Ubuntu** — phải thấy dấu nhắc kiểu:

```
sinhvien@DESKTOP-ABC123:~$
```

Gõ thử:

```bash
whoami
pwd
```

Mong đợi:

```
sinhvien
/home/sinhvien
```

Và kiểm xem đúng đang trong WSL không:

```bash
uname -r
```

Kết quả phải **có chữ `microsoft`**, ví dụ:

```
5.15.167.4-microsoft-standard-WSL2
```

### ❌ Nếu sai

| Hiện tượng | Nguyên nhân | Cách sửa |
|---|---|---|
| Gõ mật khẩu không thấy gì | **Đây là bình thường**, không phải lỗi | Cứ gõ rồi Enter |
| `Sorry, try again` khi gõ `sudo` | Sai mật khẩu | Gõ lại. Quên thật thì: 🪟 `wsl -u root passwd <tên>` |
| Cửa sổ mở rồi tắt ngay | Bản phân phối hỏng lúc cài | 🪟 `wsl --unregister Ubuntu-24.04` rồi cài lại Bước 1. **Lệnh này xoá sạch mọi thứ trong Ubuntu** — chỉ dùng khi chưa có gì để mất |
| `uname -r` không có chữ `microsoft` | Đang ở máy Linux khác, không phải WSL | Vẫn học được. Bỏ qua mọi phần nói về Windows |

---

## Bước 3 — Cập nhật hệ thống

### 🎯 Mục đích

Ubuntu vừa cài xong mang danh sách gói cũ. Không cập nhật thì bước sau sẽ báo
"không tìm thấy gói".

### 🔍 Kiểm tra trước

🐧 **Ubuntu**:

```bash
cat /etc/os-release | head -2
```

Mong đợi:

```
PRETTY_NAME="Ubuntu 24.04.4 LTS"
NAME="Ubuntu"
```

Và kiểm mạng — bước sau tải vài trăm MB:

```bash
curl -s -o /dev/null -w '%{http_code}\n' https://archive.ubuntu.com
```

Ra một số ba chữ số (200, 301, 403… đều được) là mạng thông. Ra `000` là không
ra được Internet — xử lý mạng trước đã.

### ⌨️ Lệnh

🐧 **Ubuntu**:

```bash
sudo apt update
```

```bash
sudo apt upgrade -y
```

> **`apt update` và `apt upgrade` khác nhau thế nào?**
> `update` chỉ tải **danh mục** — như lấy cuốn catalogue mới của cửa hàng, chưa
> mua gì. `upgrade` mới thật sự **tải và cài** các gói mới hơn. Luôn chạy
> `update` trước `upgrade`, nếu không nó sẽ cài theo catalogue cũ.
>
> **`sudo` là gì?** "Chạy lệnh này với quyền quản trị." Cài phần mềm là việc
> sửa vào hệ thống, nên cần quyền. Nó sẽ hỏi mật khẩu bạn đặt ở Bước 2.
>
> **`-y` là gì?** "Có, cứ làm, đừng hỏi lại." Không có nó thì nó dừng hỏi
> `Do you want to continue? [Y/n]` và chờ.

### ✅ Kiểm tra sau

```bash
sudo apt update
```

Chạy lần thứ hai phải thấy dòng cuối là:

```
All packages are up to date.
```

### ❌ Nếu sai

| Thông báo | Nguyên nhân | Cách sửa |
|---|---|---|
| `Could not resolve 'archive.ubuntu.com'` | Không phân giải được tên miền | `sudo nano /etc/resolv.conf`, thêm dòng `nameserver 8.8.8.8`, lưu (Ctrl+O, Enter, Ctrl+X) |
| `Temporary failure resolving` | Mạng chưa lên hẳn | Đợi 30 giây, thử lại. Vẫn hỏng thì 🪟 `wsl --shutdown` rồi mở lại Ubuntu |
| `Could not get lock /var/lib/dpkg/lock-frontend` | Đang có tiến trình apt khác chạy | Đợi nó xong. Vẫn kẹt sau 5 phút: `sudo killall apt apt-get`, rồi thử lại |
| `E: Unable to locate package` | Chưa chạy `apt update` | Chạy `sudo apt update` trước |
| Tải rất chậm | Máy chủ mặc định ở xa | Đổi sang gương Việt Nam: `sudo sed -i 's|http://archive.ubuntu.com|http://vn.archive.ubuntu.com|g' /etc/apt/sources.list.d/ubuntu.sources` rồi `sudo apt update` |

---

## Bước 4 — Cài bộ công cụ mô phỏng và tổng hợp

### 🎯 Mục đích

Đây là **bộ công cụ cốt lõi của môn học**. Xong bước này bạn viết được Verilog,
mô phỏng được, xem được dạng sóng, và tổng hợp được ra cổng logic.

| Công cụ | Làm gì |
|---|---|
| `iverilog` | Trình biên dịch Verilog — biến file `.v` thành chương trình mô phỏng chạy được |
| `vvp` | Chạy chương trình mà `iverilog` sinh ra |
| `gtkwave` | Xem dạng sóng (file `.vcd`) — nhìn tín hiệu lên xuống theo thời gian |
| `yosys` | Trình tổng hợp — biến Verilog thành mạng lưới cổng logic thật |
| `git` | Tải mã nguồn, quản lý phiên bản |
| `make` | Chạy quy trình nhiều bước theo kịch bản |
| `python3` | Chạy các script phân tích kết quả |

### 🔍 Kiểm tra trước

🐧 **Ubuntu**:

```bash
for t in iverilog vvp yosys gtkwave git make python3; do
    printf "%-12s " "$t"
    command -v "$t" >/dev/null 2>&1 && echo "DA CO" || echo "chua co"
done
```

Cái nào "DA CO" thì `apt` sẽ tự bỏ qua, không cài đè. Cứ chạy lệnh cài bên dưới.

### ⌨️ Lệnh

```bash
sudo apt install -y build-essential git make tree curl python3 python3-pip
```

```bash
sudo apt install -y iverilog gtkwave yosys
```

> **Tại sao tách làm hai lệnh?** Lệnh đầu là công cụ chung mà mọi việc lập trình
> đều cần. Lệnh sau mới là công cụ riêng của thiết kế vi mạch. Tách ra để khi
> lỗi, bạn biết ngay lỗi thuộc nhóm nào.

### ✅ Kiểm tra sau

Không tự đọc bằng mắt — **để script kiểm hộ**. Nó không chỉ xem lệnh có tồn
tại, mà **biên dịch thật một file Verilog nhỏ và tổng hợp thật một module** rồi
so kết quả:

```bash
cd /mnt/c/rtl2gds/BO_CAI_DAT_SINH_VIEN     # sửa cho đúng chỗ bạn để bộ bài
bash cong_cu/02_kiem_tra_cong_cu.sh
```

Mong đợi kết thúc bằng:

```
  ══════════════════════════════════════════════════════════════
   Dat: 14      Canh bao: 0      Hong: 0
  ══════════════════════════════════════════════════════════════

  CHANG 2: DAT.
```

Muốn kiểm tay thì hai lệnh này là quan trọng nhất:

```bash
iverilog -V | head -1
yosys -V
```

Mong đợi (đúng từng chữ với Ubuntu 24.04):

```
Icarus Verilog version 12.0 (stable) ()
Yosys 0.33 (git sha1 2584903a060)
```

> **Số phiên bản của bạn hơi khác cũng không sao.** Cả hai vẫn chạy được bài.
> Chỉ là **số ô sau khi tổng hợp có thể lệch một hai đơn vị** so với bảng chuẩn
> — đó là chuyện bình thường giữa các phiên bản yosys, không phải bạn làm sai.

### ❌ Nếu sai

| Thông báo | Nguyên nhân | Cách sửa |
|---|---|---|
| `E: Unable to locate package yosys` | Danh mục cũ, hoặc thiếu kho universe | `sudo apt update` rồi thử lại. Vẫn hỏng: `sudo add-apt-repository universe && sudo apt update` |
| `gtkwave: cannot open display` | Chưa có máy chủ đồ hoạ | **Không cản trở gì cả** ở giai đoạn này. Mô phỏng vẫn chạy, vẫn sinh file `.vcd`. Windows 11 có WSLg sẵn nên thường mở được; Windows 10 thì cần cài thêm — để sau |
| `iverilog: command not found` sau khi đã cài | Cửa sổ cũ chưa nạp lại `PATH` | Đóng cửa sổ Ubuntu, mở lại |
| `dpkg: error processing package` | Cài dở dang lần trước | `sudo apt --fix-broken install` rồi thử lại |
| Script báo `Dang o o Windows` | Bộ bài để trong `/mnt/c/...` | Đọc mục ngay dưới đây |

### 📌 Về chỗ để bộ bài: `/mnt/c/` chạy được nhưng chậm

Ubuntu trong WSL2 nhìn thấy ổ C: của Windows ở đường dẫn `/mnt/c/`. Rất tiện —
bạn sửa file bằng Notepad trên Windows, chạy lệnh bên Ubuntu.

**Nhưng đọc ghi qua `/mnt/c/` chậm hơn nhiều lần.** Mỗi lần truy cập file phải
đi qua một lớp dịch giữa hai hệ thống tệp. Với vài file thì không thấy gì. Với
OpenLane — đọc ghi hàng chục nghìn file mỗi lần chạy — chênh lệch có thể là
**vài phút so với nửa tiếng**.

**Khuyến nghị:**

* **Phần I (mô phỏng, tổng hợp):** để ở `/mnt/c/` cũng được. Chậm không đáng kể.
* **Nếu chọn Phần II local (OpenLane):** nên/bắt buộc chuyển workspace vào thư mục nhà Ubuntu để tránh I/O rất chậm trên `/mnt/c/`.

Chuyển sang thư mục nhà:

```bash
cp -r /mnt/c/rtl2gds/BO_CAI_DAT_SINH_VIEN ~/rtl2gds
cd ~/rtl2gds
pwd
```

Mong đợi `pwd` in ra đường dẫn **không bắt đầu bằng `/mnt/`**:

```
/home/sinhvien/rtl2gds
```

> **Đổi lại, file trong `~/` không mở trực tiếp bằng Notepad được.** Muốn mở
> bằng File Explorer thì gõ trong Ubuntu: `explorer.exe .`

---

## Bước 5 — Lấy bộ bài và chạy lab 0

### 🎯 Mục đích

**Đây là mốc quan trọng nhất của Phần I.** Chạy được lab 0 nghĩa là toàn bộ tầng
mô phỏng + tổng hợp đã đúng — chứng minh bằng kết quả chạy thật, không phải bằng
việc "cài xong rồi thấy không báo lỗi".

### 🔍 Kiểm tra trước

🐧 **Ubuntu** — đứng ở thư mục gốc bộ bài:

```bash
cd ~/rtl2gds          # hoặc chỗ bạn để bộ bài
ls -1
```

Mong đợi thấy **đúng bảy dòng này** (thứ tự đúng như vậy):

```
00_DOC_TRUOC.md
01_HUONG_DAN_CAI_DAT.md
02_XU_LY_LOI.md
03_CHAY_LAB.md
04_THE_TRA_NHANH.md
cong_cu
lab0_counter
```

> Thiếu dòng nào nghĩa là giải nén chưa hết. Giải nén lại từ file gốc.

Kiểm hai chặng đầu đã qua chưa:

```bash
bash cong_cu/kiem_tra_tat_ca.sh
```

Chặng 1 và chặng 2 phải `[x]`. Chặng 3, 4 còn `[ ]` là bình thường ở đây.

### ⌨️ Lệnh

```bash
bash lab0_counter/sim/run_sim.sh
```

```bash
bash lab0_counter/synth/run_synth.sh
```

### ✅ Kiểm tra sau

Lệnh thứ nhất — mô phỏng tự kiểm — phải kết thúc bằng:

```
  ================================================
   LAB 0 — kiem tra tu dong bo dem 4 bit
  ================================================

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

**Ba chỗ phải khớp: 8 dòng `ok`, `51 phep so sanh`, và `ALL TESTS PASSED`.**

Lệnh thứ hai — tổng hợp — phải kết thúc bằng:

```
   chi so                    cua ban      chuan   danh gia
   ────────────────────── ────────── ──────────   ────────
   so o chuan                     10         10   khop
   so flip-flop                    4          4   khop

   Khop hoan toan voi ket qua chuan.
```

> **Con số nào được phép lệch, con số nào không?**
>
> * **`so flip-flop` = 4 thì KHÔNG được lệch.** Bộ đếm 4 bit thì phải đúng 4 phần
>   tử nhớ. Ra 5 hay 3 nghĩa là RTL sai, không phải phiên bản công cụ khác.
> * **`so o chuan` = 10 thì lệch một hai đơn vị được**, nếu yosys của bạn không
>   phải 0.33. Đó là do bộ tối ưu khác nhau, không phải lỗi.

### ❌ Nếu sai

| Hiện tượng | Nguyên nhân | Cách sửa |
|---|---|---|
| `$'\r': command not found` | File `.sh` mang xuống dòng kiểu Windows (CRLF) | `find . -name '*.sh' -exec sed -i 's/\r$//' {} +` — xem giải thích ở dưới |
| `bash: lab0_counter/sim/run_sim.sh: No such file or directory` | Đang đứng sai thư mục | `pwd` xem đang ở đâu, `cd` về gốc bộ bài |
| `iverilog: command not found` | Chưa xong Bước 4 | Quay lại Bước 4 |
| `Permission denied` | File chưa có quyền chạy | Cứ gõ `bash <file>` là chạy được, không cần quyền. Hoặc `chmod +x <file>` |
| `so flip-flop` ra khác 4 | RTL bị sửa | Lấy lại file gốc `lab0_counter/rtl/counter_4bit.v` từ bộ bài giảng viên phát |
| Có dòng `FAIL` trong kết quả mô phỏng | RTL bị sửa | Như trên |
| Chữ hiện ra như `â??` hoặc ô vuông | Cửa sổ chưa dùng bảng mã UTF-8 | Dùng **Windows Terminal** thay cho cửa sổ Ubuntu cũ. Hoặc trong PowerShell gõ `chcp 65001` trước khi vào `wsl` |

### 📌 Về lỗi CRLF — đọc một lần cho hiểu, đỡ mất buổi

Windows và Linux đánh dấu **hết dòng** bằng byte khác nhau:

| | Byte kết thúc dòng | Viết tắt |
|---|---|---|
| Windows | `0D 0A` (hai byte) | CRLF |
| Linux | `0A` (một byte) | LF |

Khi một file `.sh` viết kiểu Windows chạy trên Linux, bash đọc dòng
`cd "$THU_MUC"` thành `cd "$THU_MUC"` **cộng thêm một ký tự `\r` vô hình**. Nó
báo lỗi trông rất khó hiểu:

```
run_sim.sh: line 12: $'\r': command not found
cd: /home/sinhvien/lab0$'\r': No such file or directory
```

Cái `$'\r'` trong thông báo chính là dấu hiệu. **Thấy `$'\r'` thì gõ:**

```bash
find . -name '*.sh' -exec sed -i 's/\r$//' {} +
```

**Quy tắc ngược lại cũng đúng:** file `.ps1` và `.bat` (chạy trên Windows) thì
**phải** dùng CRLF. Đừng "sửa" chúng thành LF.

Kiểm nhanh một file dùng kiểu nào:

```bash
file lab0_counter/sim/run_sim.sh
```

Có chữ `CRLF` là kiểu Windows. Không có gì là kiểu Linux (đúng cho `.sh`).

---

## 🏁 MỐC 1 — HẾT PHẦN BẮT BUỘC

Đến đây bạn đã có:

* ✅ Máy Linux thật chạy trong Windows
* ✅ Viết, biên dịch, mô phỏng, kiểm thử tự động Verilog
* ✅ Tổng hợp RTL thành cổng logic, đọc được số ô và số flip-flop
* ✅ Xem được dạng sóng
* ✅ Đủ để làm **toàn bộ bài tập bắt buộc của môn học**

**Dừng ở đây là đúng lộ trình bắt buộc.** B2 chính thức chạy GitHub Actions + LibreLane nên không cần cài Docker/OpenLane local. Phần II chỉ là nhánh tự chọn để khám phá P&R local, tốn thêm ~30 GB đĩa và 2–3 giờ.

Trước khi sang Phần II, hãy đọc `03_CHAY_LAB.md` để hiểu bốn bước của quy trình
và ý nghĩa từng con số trong kết quả.

---
---

# PHẦN II — TỰ CHỌN: P&R LOCAL / ĐIỂM CỘNG

> **Điều kiện tiên quyết:** Bước 5 đã đạt, cả hai lệnh đều ra kết quả khớp
> chuẩn. Chưa đạt mà làm tiếp thì lỗi về sau sẽ chồng lên nhau, không biết
> gỡ từ đâu.
>
> **Đĩa trống cần thêm: 30 GB.** Kiểm ngay bây giờ:
> ```bash
> df -h ~ | tail -1
> ```

---

## Bước 6 — Docker Desktop trên Windows

### 🎯 Mục đích

OpenLane cần khoảng mười công cụ khác nhau — OpenROAD, Magic, Netgen, KLayout —
mỗi cái có phiên bản thư viện riêng, dễ đá nhau. Docker đóng gói tất cả vào một
"hộp" đã dựng sẵn, đã kiểm chứng. Bạn tải hộp về là chạy, không phải tự cài từng
cái.

### 🔍 Kiểm tra trước

🐧 **Ubuntu**:

```bash
bash cong_cu/03_kiem_tra_docker.sh
```

Nếu đã hiện `CHANG 3: DAT.` thì **bỏ qua Bước 6 và Bước 7**, sang thẳng Bước 8.

### ⚠️ Cạm bẫy: KHÔNG cài Docker bằng snap hay apt trong Ubuntu

```bash
sudo snap install docker        # ❌ KHÔNG DÙNG ĐƯỢC trong WSL2
sudo apt install docker.io      # ❌ cũng không nên
```

Cả hai **cài xong không báo lỗi** — nên rất dễ tưởng là được. Nhưng WSL2 không
chạy `systemd` theo cách mà các bản này trông đợi, nên tiến trình nền (daemon)
không khởi động, và mọi lệnh `docker` sau đó sẽ treo rồi báo *"cannot connect to
the Docker daemon"*.

**Cách đúng duy nhất: cài Docker Desktop trên Windows, rồi bắc cầu sang Ubuntu.**

### ⌨️ Lệnh

Không phải lệnh — làm bằng tay trên Windows:

1. Mở trình duyệt, vào `https://www.docker.com/products/docker-desktop/`
2. Tải **Docker Desktop for Windows** (bản x64, khoảng 600 MB)
3. Chạy file cài. Ở màn hình tuỳ chọn, **giữ nguyên dấu tích ở
   "Use WSL 2 instead of Hyper-V"**
4. Cài xong, khởi động lại máy nếu được nhắc
5. Mở **Docker Desktop** từ Start Menu
6. **Đợi cho đến khi biểu tượng con cá voi ở góc dưới phải ngừng nhấp nháy** và
   trong cửa sổ Docker Desktop hiện chữ **Engine running** màu xanh

> **Bước 6 quan trọng hơn vẻ ngoài của nó.** Docker Desktop mất 30–60 giây để
> khởi động xong. Gõ lệnh `docker` trong lúc nó còn đang khởi động thì sẽ báo
> lỗi y hệt như khi chưa cài. Nhiều người lúc này quay lại gỡ ra cài lại — trong
> khi chỉ cần đợi thêm nửa phút.

### ✅ Kiểm tra sau

🪟 **PowerShell** (chưa phải Ubuntu — Ubuntu là Bước 7):

```powershell
docker run hello-world
```

Mong đợi có dòng:

```
Hello from Docker!
This message shows that your installation appears to be working correctly.
```

### ❌ Nếu sai

| Thông báo | Nguyên nhân | Cách sửa |
|---|---|---|
| `error during connect ... The system cannot find the file specified` | Docker Desktop chưa chạy | Mở Docker Desktop, đợi hiện "Engine running" |
| `WSL 2 installation is incomplete` | Nhân WSL2 cũ | 🪟 `wsl --update`, khởi động lại |
| Docker Desktop mở lên rồi tắt | Xung đột Hyper-V, hoặc ảo hoá tắt | Kiểm lại Bước 0. Bật "Windows Hypervisor Platform" trong "Turn Windows features on or off" |
| `not enough disk space` | Thiếu đĩa | Cần ≥30 GB trống trên C: |
| Máy chậm hẳn sau khi cài | Docker Desktop tự khởi động cùng Windows | Settings → General → bỏ tích "Start Docker Desktop when you sign in". Khi nào cần thì mở tay |

---

## Bước 7 — Bật WSL Integration — bước hay vấp nhất

### 🎯 Mục đích

Docker đang chạy trên Windows. Ubuntu chưa nhìn thấy nó. Bước này bắc cây cầu.

> **Đây là bước bị bỏ sót nhiều nhất trong tất cả các bước của tài liệu này.**
> Tài liệu lab gốc phải dành hẳn một mục riêng để gỡ chuyện này.

### 🔍 Kiểm tra trước

🐧 **Ubuntu**:

```bash
docker info 2>&1 | head -3
```

Thấy `Server Version:` là đã thông rồi — bỏ qua bước này.
Thấy `Cannot connect to the Docker daemon` là chưa — làm tiếp.

### ⌨️ Lệnh

Làm trong giao diện Docker Desktop:

**7.1 — Bật động cơ WSL2**

```
Settings ⚙ → General → ☑ Use the WSL 2 based engine
```

Bấm **Apply & Restart**.

**7.2 — Bật tích hợp cho ĐÚNG bản phân phối của bạn** ← chỗ hay sai

```
Settings ⚙ → Resources → WSL Integration
```

Ở đây có **hai thứ khác nhau**, phải bật **cả hai**:

```
   ☑  Enable integration with my default WSL distro
                                                        ← nhiều người dừng ở đây
   Enable integration with additional distros:
   ☑  Ubuntu-24.04                                      ← PHẢI bật cả cái này
```

Bấm **Apply & Restart**.

> **Vì sao bật cái trên chưa đủ?** "Default WSL distro" là bản phân phối mặc
> định *theo góc nhìn của Docker Desktop* — không phải lúc nào cũng là Ubuntu
> của bạn. Nếu máy từng cài `docker-desktop-data` hay một bản phân phối khác,
> "default" có thể trỏ vào cái đó. Bật đích danh `Ubuntu-24.04` là cách chắc
> chắn.

**7.3 — Khởi động lại WSL**

🪟 **PowerShell**:

```powershell
wsl --shutdown
```

Đợi 10 giây, rồi mở lại cửa sổ Ubuntu.

> **Không bỏ qua bước này.** Cây cầu chỉ dựng lúc WSL khởi động. Cửa sổ Ubuntu
> đang mở sẽ không thấy Docker cho đến khi tắt hẳn rồi mở lại. Đây là lý do
> nhiều người bật đúng hết mà vẫn báo lỗi.

### ✅ Kiểm tra sau

🐧 **Ubuntu**:

```bash
docker --version
docker run hello-world
```

Mong đợi:

```
Docker version 27.x.x, build ...

Hello from Docker!
This message shows that your installation appears to be working correctly.
```

Rồi chạy script kiểm tra:

```bash
bash cong_cu/03_kiem_tra_docker.sh
```

Phải ra `CHANG 3: DAT.`

### ❌ Nếu sai

**Chưa thấy `Hello from Docker!` thì DỪNG LẠI. Đừng sang Bước 8.**

Mọi lỗi OpenLane về sau sẽ khó gỡ gấp bội nếu tầng Docker chưa vững — vì bạn sẽ
không biết lỗi thuộc tầng nào.

Ba câu hỏi, kiểm **theo đúng thứ tự này**:

| # | Câu hỏi | Kiểm thế nào | Nếu "chưa" |
|---|---|---|---|
| 1 | Docker Desktop trên Windows đang mở? | Nhìn khay hệ thống góc dưới phải, có con cá voi | Mở nó lên, đợi "Engine running" |
| 2 | WSL Integration đã bật **riêng** distro Ubuntu? | Settings → Resources → WSL Integration | Bật đích danh `Ubuntu-24.04`, Apply & Restart |
| 3 | Đã chạy `wsl --shutdown` **sau khi** bật? | — | 🪟 `wsl --shutdown`, đợi 10 giây, mở lại Ubuntu |

Các lỗi khác:

| Thông báo | Nguyên nhân | Cách sửa |
|---|---|---|
| `permission denied while trying to connect to the Docker daemon socket` | Người dùng chưa thuộc nhóm docker | `sudo usermod -aG docker $USER`, rồi 🪟 `wsl --shutdown`, mở lại |
| `docker: command not found` trong Ubuntu | Cầu chưa dựng | Làm lại 7.2 và 7.3 |
| `Ubuntu-24.04` không hiện trong danh sách WSL Integration | Docker Desktop chưa thấy bản phân phối | 🪟 `wsl -l -v` xác nhận tên chính xác. Khởi động lại Docker Desktop |
| Vẫn hỏng sau cả ba bước | — | Chạy `bash cong_cu/bao_cao_su_co.sh` rồi gửi file cho giảng viên |

---

## Bước 8 — Tải và dựng OpenLane

### 🎯 Mục đích

Lấy về toàn bộ chuỗi công cụ RTL → GDSII, cộng với **PDK sky130** — thư viện ô
chuẩn của nhà máy SkyWater 130 nm. Không có PDK thì không biết một cổng NAND
thật rộng bao nhiêu micromet, trễ bao nhiêu picogiây.

### 🔍 Kiểm tra trước

🐧 **Ubuntu**:

```bash
df -h ~ | tail -1
```

Cột `Avail` phải còn **ít nhất 30 GB**.

```bash
docker run hello-world | head -2
```

Phải ra `Hello from Docker!`. Chưa ra thì quay lại Bước 7.

```bash
ls ~/OpenLane 2>/dev/null && echo "DA CO OPENLANE" || echo "chua co"
```

Đã có rồi thì bỏ qua phần `git clone`.

### ⌨️ Lệnh

```bash
sudo apt install -y build-essential python3 python3-venv python3-pip python3-tk curl make git
```

```bash
cd ~
git clone https://github.com/The-OpenROAD-Project/OpenLane.git
cd OpenLane
```

```bash
make
```

> **Lệnh `make` này là lệnh lâu nhất trong toàn bộ tài liệu.** Nó tải ảnh Docker
> của OpenLane và toàn bộ PDK — khoảng 14 GB. Với mạng trường 1–2 giờ là bình
> thường. **Cứ để đấy, đừng tắt cửa sổ.** Nó sẽ in ra rất nhiều dòng — đó là
> bình thường.
>
> Máy tính có thể ngủ giữa chừng và làm đứt kết nối. Trước khi chạy `make`, vào
> Windows Settings → System → Power → đặt "Screen and sleep" thành **Never**
> trong lúc chờ.
>
> Đứt giữa chừng thì chạy lại `make` — nó tiếp tục từ chỗ dở, không tải lại từ
> đầu.

Xong `make` rồi chạy phép thử của chính OpenLane:

```bash
make test
```

Cái này chạy trọn một thiết kế mẫu qua toàn bộ chuỗi. Mất 5–15 phút.

### ✅ Kiểm tra sau

`make test` phải kết thúc bằng:

```
Basic test passed
```

Rồi:

```bash
cd ~/rtl2gds
bash cong_cu/04_kiem_tra_openlane.sh
```

Phải ra `CHANG 4: DAT.`

### ❌ Nếu sai

| Thông báo | Nguyên nhân | Cách sửa |
|---|---|---|
| `no space left on device` | Hết đĩa giữa chừng | Dọn đĩa rồi chạy lại `make`. Xoá rác Docker: `docker system prune -a` (⚠️ xoá mọi ảnh Docker không dùng) |
| `Cannot connect to the Docker daemon` | Docker Desktop tắt giữa chừng | Mở lại Docker Desktop, chạy lại `make` |
| `make: *** [Makefile:...] Error 1` | Nhiều nguyên nhân | Xem **30 dòng cuối** của thông báo — dòng lỗi thật thường ở đó, không phải ở dòng cuối cùng |
| Tải rất chậm hoặc đứt liên tục | Mạng trường chặn Docker Hub | Thử mạng khác (4G điện thoại). Vẫn hỏng thì báo giảng viên — có thể cần bản sao ngoại tuyến |
| `make test` chạy mãi không xong | Bộ bài để trong `/mnt/c/` | **Đây là nguyên nhân hay gặp.** Chuyển OpenLane vào `~/`, đừng để `/mnt/c/`. Xem lại mục cuối Bước 4 |
| `Permission denied` khi `git clone` | Thư mục không ghi được | `cd ~` trước rồi mới clone |

---

## Bước 9 — Chạy trọn chuỗi RTL → GDSII

### 🎯 Mục đích

Đưa thiết kế lab 0 qua flow P&R local và thu được layout ở dạng GDS để học cách đọc kết quả. File này là đầu ra layout của flow giáo dục, **không đồng nghĩa tape-out, sign-off hay chip đã được chế tạo**.

### 🔍 Kiểm tra trước

```bash
ls ~/OpenLane/flow.tcl && echo "OK"
ls ~/rtl2gds/lab0_counter/openlane/config.tcl && echo "OK"
```

Cả hai phải in `OK`.

### ⌨️ Lệnh

Chuẩn bị thư mục thiết kế:

```bash
cd ~/OpenLane
mkdir -p designs/counter_4bit/src
cp ~/rtl2gds/lab0_counter/rtl/counter_4bit.v      designs/counter_4bit/src/
cp ~/rtl2gds/lab0_counter/openlane/config.tcl     designs/counter_4bit/
tree designs/counter_4bit
```

Mong đợi:

```
designs/counter_4bit
├── config.tcl
└── src
    └── counter_4bit.v
```

Vào môi trường Docker:

```bash
make mount
```

Dấu nhắc sẽ đổi thành kiểu `bash-4.2$` hoặc tương tự. Xác nhận đúng chỗ:

```bash
ls flow.tcl
```

Rồi chạy:

```bash
./flow.tcl -design counter_4bit
```

Mất 5–15 phút. Nó đi qua: synthesis → floorplan → placement → CTS → routing →
signoff.

### ✅ Kiểm tra sau

Thoát Docker:

```bash
exit
```

🐧 **Ubuntu** (ngoài Docker):

```bash
cd ~/OpenLane/designs/counter_4bit
RUN_DIR=$(ls -td runs/RUN_* | head -1)
echo "$RUN_DIR"
find "$RUN_DIR" -name "*.gds"
```

Phải in ra ít nhất một file `.gds`. **Đây là tệp layout/GDS do flow tạo ra, không phải con chip.**

Xem bảng số:

```bash
cat "$RUN_DIR/reports/metrics.csv" | head -2
```

### ❌ Nếu sai

| Thông báo | Nguyên nhân | Cách sửa |
|---|---|---|
| `[ERROR]: Design counter_4bit not found` | Sai chỗ đặt thư mục, hoặc sai tên | Thư mục phải là `~/OpenLane/designs/counter_4bit`, tên trong lệnh phải khớp tên thư mục |
| `[ERROR]: Cell ... not found in the library` | Sai PDK | Kiểm `config.tcl` — phải là `sky130A` và `sky130_fd_sc_hd` |
| Dừng ở bước `floorplan` với lỗi về mật độ | Thiết kế quá nhỏ so với vùng bố trí | Mở `config.tcl`, giảm `FP_CORE_UTIL` xuống `10` |
| Dừng ở `routing`, hết tài nguyên | Chật quá | Giảm `PL_TARGET_DENSITY` xuống `0.35` |
| `make mount` rồi mà `ls` không thấy `flow.tcl` | Chưa vào đúng thư mục | `cd ~/OpenLane` trước rồi mới `make mount` |
| Chạy xong nhưng không có file `.gds` | Chuỗi dừng giữa chừng | Xem `$RUN_DIR/openlane.log`, 40 dòng cuối |

---

## 🏁 MỐC 2 — XONG TOÀN BỘ

Bạn đã có một môi trường đưa được Verilog thành GDSII trên máy mình.

**Việc tiếp theo:** đọc `03_CHAY_LAB.md` — nó giải thích mỗi con số trong báo
cáo nghĩa là gì và bạn đánh đổi cái gì lấy cái gì.

---
---

## Phụ lục A — Toàn bộ lệnh, gom một chỗ

Dùng để tra nhanh khi cài lại. **Đừng dán cả khối này một lần** — mỗi lệnh cần
xác nhận kết quả trước khi sang lệnh sau.

```powershell
# ══ PHẦN I ══ 🪟 PowerShell (Administrator)
wsl --install -d Ubuntu-24.04
# ... khởi động lại máy ...
wsl --list --verbose
```

```bash
# 🐧 Ubuntu
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential git make tree curl python3 python3-pip
sudo apt install -y iverilog gtkwave yosys
iverilog -V | head -1
yosys -V

cp -r /mnt/c/rtl2gds/BO_CAI_DAT_SINH_VIEN ~/rtl2gds
cd ~/rtl2gds
bash cong_cu/kiem_tra_tat_ca.sh
bash lab0_counter/sim/run_sim.sh
bash lab0_counter/synth/run_synth.sh
```

```powershell
# ══ PHẦN II ══ 🪟 sau khi cài Docker Desktop và bật WSL Integration
wsl --shutdown
```

```bash
# 🐧 Ubuntu
docker run hello-world

sudo apt install -y python3-venv python3-tk
cd ~ && git clone https://github.com/The-OpenROAD-Project/OpenLane.git
cd OpenLane && make && make test

mkdir -p designs/counter_4bit/src
cp ~/rtl2gds/lab0_counter/rtl/counter_4bit.v  designs/counter_4bit/src/
cp ~/rtl2gds/lab0_counter/openlane/config.tcl designs/counter_4bit/
make mount
./flow.tcl -design counter_4bit
```

---

## Phụ lục B — Bảng các lệnh kiểm tra

| Chặng | Lệnh | Cửa sổ | Kiểm cái gì |
|---|---|---|---|
| 0 | `powershell -ExecutionPolicy Bypass -File .\cong_cu\00_kiem_tra_windows.ps1` | 🪟 | Windows, ảo hoá, đĩa, RAM, WSL, Docker Desktop |
| 1 | `bash cong_cu/01_kiem_tra_wsl.sh` | 🐧 | Đang ở WSL2, tài nguyên, mạng, vị trí thư mục |
| 2 | `bash cong_cu/02_kiem_tra_cong_cu.sh` | 🐧 | **Biên dịch và tổng hợp thật** một file thử |
| 3 | `bash cong_cu/03_kiem_tra_docker.sh` | 🐧 | Daemon phản hồi, kéo được ảnh |
| 4 | `bash cong_cu/04_kiem_tra_openlane.sh` | 🐧 | Thư mục, PDK, các lần chạy |
| tất cả | `bash cong_cu/kiem_tra_tat_ca.sh` | 🐧 | Chạy cả 4 chặng, vẽ bản đồ "bạn đang ở đâu" |
| khi tắc | `bash cong_cu/bao_cao_su_co.sh` | 🐧 | Sinh file báo cáo để gửi giảng viên |

---

## Phụ lục C — Ba con số phải nhớ

Ba con số này là **mốc đối chiếu**. Chúng đến từ tài liệu lab tham chiếu, chạy
trên yosys 0.33, và đã được tái lập độc lập.

| Con số | Giá trị | Lệch được không |
|---|---|---|
| Số phép so sánh trong mô phỏng lab 0 | **51** | ❌ Không. Lệch nghĩa là testbench bị sửa |
| Số flip-flop sau tổng hợp lab 0 | **4** | ❌ Không. Bộ đếm 4 bit phải đúng 4 phần tử nhớ |
| Số ô chuẩn sau tổng hợp lab 0 | **10** | ✅ Lệch 1–2 được, nếu yosys khác 0.33 |

---

## Khi bị tắc

**Đừng ngồi thử mò quá 20 phút.** Chạy lệnh này rồi gửi file sinh ra cho giảng
viên:

```bash
bash cong_cu/bao_cao_su_co.sh
```

Nó sinh một file `bao_cao_su_co_<ngày>_<giờ>.txt` trả lời sẵn mười câu mà giảng
viên sẽ phải hỏi. **Mở file ra điền phần đầu** — nhất là mục *"Đã thử những cách
nào rồi"*, đó là mục giúp gỡ nhanh nhất và cũng là mục hay bị bỏ trống nhất.

File đó **không chứa mật khẩu, khoá SSH hay nội dung file cá nhân**. Bạn mở ra
đọc được toàn bộ trước khi gửi.

Đưa file sang Windows để đính kèm email:

```bash
explorer.exe .
```
