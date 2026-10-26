#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════
#  bao_cao_su_co.sh — Sinh mot file bao cao de gui giang vien khi bi tac.
#
#     bash cong_cu/bao_cao_su_co.sh
#
#  VI SAO CAN: khi ban nhan tin "em bi loi", giang vien phai hoi lai muoi
#  cau moi biet ban dang o dau. File nay tra loi san ca muoi cau.
#
#  Script CHI DOC. Khong cai gi, khong sua gi, khong gui gi di dau.
#  File sinh ra nam trong thu muc hien tai — ban tu quyet dinh gui hay khong.
#
#  KHONG thu thap: mat khau, khoa SSH, noi dung file ca nhan, thong tin
#  dang nhap. Ban co the mo file ra doc truoc khi gui.
# ═══════════════════════════════════════════════════════════════════════
set -u
cd "$(dirname "${BASH_SOURCE[0]}")/.."

TEN="bao_cao_su_co_$(date +%Y%m%d_%H%M%S).txt"

{
echo "══════════════════════════════════════════════════════════════════════"
echo " BAO CAO SU CO — MOI TRUONG RTL2GDSII"
echo " Sinh luc: $(date '+%Y-%m-%d %H:%M:%S %z')"
echo "══════════════════════════════════════════════════════════════════════"
echo ""
echo "┌─ PHAN SINH VIEN TU DIEN ─────────────────────────────────────────┐"
echo "│                                                                   │"
echo "│  Ho ten:                                                          │"
echo "│  MSSV:                                                            │"
echo "│  Lop:                                                             │"
echo "│                                                                   │"
echo "│  Dang lam den buoc nao:                                           │"
echo "│                                                                   │"
echo "│  Lenh vua go:                                                     │"
echo "│                                                                   │"
echo "│  Thong bao loi (dan 3-5 dong quanh cho loi that):                 │"
echo "│                                                                   │"
echo "│                                                                   │"
echo "│  Da thu nhung cach nao roi (phan nay quan trong nhat):            │"
echo "│                                                                   │"
echo "│                                                                   │"
echo "└───────────────────────────────────────────────────────────────────┘"
echo ""

echo "══ 1. HE THONG ══════════════════════════════════════════════════════"
echo "Nhan:            $(uname -srm 2>/dev/null)"
if grep -qi microsoft /proc/version 2>/dev/null; then
    echo "Moi truong:      WSL  ($(grep -o 'Linux version [0-9.]*' /proc/version | head -1))"
else
    echo "Moi truong:      KHONG PHAI WSL"
fi
[ -r /etc/os-release ] && { . /etc/os-release; echo "Ban phan phoi:   ${PRETTY_NAME:-?}"; }
echo "So nhan CPU:     $(nproc 2>/dev/null || echo '?')"
echo "RAM:             $(awk '/MemTotal/ {printf "%.1f GB", $2/1048576}' /proc/meminfo 2>/dev/null)"
echo "RAM con trong:   $(awk '/MemAvailable/ {printf "%.1f GB", $2/1048576}' /proc/meminfo 2>/dev/null)"
echo ""
echo "Dia:"
df -h "$HOME" 2>/dev/null | sed 's/^/  /'
echo ""
echo "Thu muc hien tai: $(pwd -P)"
case "$(pwd -P)" in
    /mnt/[a-z]/*) echo "  >> DANG O O WINDOWS — cham hon nhieu lan, nen chuyen sang ~/" ;;
esac
echo ""

echo "══ 2. CONG CU ═══════════════════════════════════════════════════════"
for t in git python3 pip3 make tree curl iverilog vvp yosys gtkwave \
         docker klayout magic netgen openroad nix librelane; do
    if command -v "$t" >/dev/null 2>&1; then
        PB=$( { "$t" --version 2>&1; "$t" -V 2>&1; } \
              | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1 )
        printf "  %-12s CO      %s\n" "$t" "${PB:-(khong doc duoc phien ban)}"
    else
        printf "  %-12s KHONG\n" "$t"
    fi
done
echo ""

echo "══ 3. DOCKER ════════════════════════════════════════════════════════"
if command -v docker >/dev/null 2>&1; then
    echo "Lenh docker:     $(docker --version 2>&1 | head -1)"
    if timeout 20 docker info >/dev/null 2>&1; then
        echo "Daemon:          PHAN HOI"
        echo "Server version:  $(docker info --format '{{.ServerVersion}}' 2>/dev/null)"
        echo ""
        echo "Anh Docker co lien quan:"
        docker images --format '  {{.Repository}}:{{.Tag}}  {{.Size}}' 2>/dev/null \
          | grep -iE "openlane|librelane|efabless|hello-world" | head -6
        [ -z "$(docker images -q 2>/dev/null)" ] && echo "  (chua co anh nao)"
    else
        echo "Daemon:          KHONG PHAN HOI  <<< DAY RAT CO THE LA NGUYEN NHAN"
        echo ""
        echo "Thong bao that:"
        timeout 20 docker info 2>&1 | head -6 | sed 's/^/  /'
        echo ""
        echo "Kiem theo thu tu:"
        echo "  1. Docker Desktop tren Windows dang mo chua?"
        echo "  2. Settings > Resources > WSL Integration da bat RIENG distro Ubuntu chua?"
        echo "  3. Da chay 'wsl --shutdown' trong PowerShell sau khi bat chua?"
    fi
else
    echo "Lenh docker:     KHONG CO"
fi
echo ""

echo "══ 4. OPENLANE ══════════════════════════════════════════════════════"
OL="${OPENLANE_DIR:-$HOME/OpenLane}"
if [ -d "$OL" ]; then
    echo "Thu muc:         $OL"
    echo "Kich thuoc:      $(du -sh "$OL" 2>/dev/null | cut -f1)"
    [ -f "$OL/flow.tcl" ] && echo "flow.tcl:        CO" || echo "flow.tcl:        KHONG"
    [ -d "$OL/venv" ]     && echo "venv/:           CO" || echo "venv/:           KHONG"
    if [ -d "$OL/.git" ]; then
        echo "Nhanh git:       $(git -C "$OL" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null)"
        echo "Commit:          $(git -C "$OL" --no-optional-locks rev-parse --short HEAD 2>/dev/null)"
    fi
    echo ""
    echo "Thiet ke trong designs/:"
    ls -1 "$OL/designs" 2>/dev/null | head -10 | sed 's/^/  /'
    echo ""
    echo "Cac lan chay gan day:"
    find "$OL/designs" -maxdepth 3 -type d -name "RUN_*" 2>/dev/null \
      | sort | tail -3 | sed "s|$OL/|  |"
    MOI=$(find "$OL/designs" -maxdepth 3 -type d -name "RUN_*" 2>/dev/null | sort | tail -1)
    if [ -n "$MOI" ]; then
        echo ""
        echo "─── 40 dong CUOI cua openlane.log (lan chay moi nhat) ───"
        if [ -f "$MOI/openlane.log" ]; then
            tail -n 40 "$MOI/openlane.log" 2>/dev/null | sed 's/^/  /'
        else
            echo "  (khong co openlane.log)"
        fi
        echo ""
        echo "─── 20 dong CUOI cua warnings.log ───"
        [ -f "$MOI/warnings.log" ] && tail -n 20 "$MOI/warnings.log" 2>/dev/null | sed 's/^/  /' \
                                   || echo "  (khong co warnings.log)"
    fi
else
    echo "Thu muc $OL:  KHONG CO"
fi
echo ""

echo "══ 5. PDK ═══════════════════════════════════════════════════════════"
THAY_PDK=0
for d in "$HOME/.ciel" "$HOME/.volare" "${PDK_ROOT:-}"; do
    [ -n "$d" ] && [ -d "$d" ] && {
        THAY_PDK=1
        echo "$d  ($(du -sh "$d" 2>/dev/null | cut -f1))"
        find "$d" -maxdepth 2 \( -name "sky130*" -o -name "gf180*" \) 2>/dev/null \
          | head -4 | sed 's/^/  /'
    }
done
if [ "$THAY_PDK" -eq 0 ]; then
    echo "KHONG tim thay PDK o ~/.ciel, ~/.volare hay \$PDK_ROOT."
    echo "  Neu ban chua chay 'make pdk' trong ~/OpenLane thi dieu nay la BINH THUONG."
    echo "  Neu ban da chay roi ma van khong thay: rat co the buoc do that bai."
fi
echo "Bien moi truong PDK_ROOT: ${PDK_ROOT:-(chua dat)}"
echo "Bien moi truong PDK:      ${PDK:-(chua dat)}"
echo ""

echo "══ 6. MANG ══════════════════════════════════════════════════════════"
echo "(chi kiem co ra duoc Internet khong — KHONG gui gi ve may nao ca)"
for u in https://github.com https://registry-1.docker.io/v2/ https://pypi.org; do
    MA=$(curl -s -m 8 -o /dev/null -w '%{http_code}' "$u" 2>/dev/null)
    case "$MA" in
        000|"") printf "  %-34s KHONG RA DUOC  (het gio / chan / khong co mang)\n" "$u" ;;
        *)      printf "  %-34s ma HTTP %s\n" "$u" "$MA" ;;
    esac
done
echo "  (BAT KY ma 3 chu so nao cung nghia la da ra duoc toi server —"
echo "   200, 301, 400, 401 deu duoc. Chi '000' moi la KHONG ra duoc.)"
echo ""
# Che phan user:mat-khau trong URL proxy neu co — bao cao nay khong duoc chua mat khau.
che_proxy () { [ -z "${1:-}" ] && { echo "(khong)"; return; }; echo "$1" | sed -E 's#://[^/@]*@#://***AN***@#'; }
echo "Proxy dang dat:"
echo "  http_proxy  = $(che_proxy "${http_proxy:-}")"
echo "  https_proxy = $(che_proxy "${https_proxy:-}")"
echo "  (neu URL proxy co ten dang nhap/mat khau, no da bi thay bang ***AN***)"
echo ""

echo "══ 7. BO BAI THUC HANH ══════════════════════════════════════════════"
if [ -d lab0_counter ]; then
    echo "lab0_counter/:   CO"
    for f in rtl/counter_4bit.v tb/tb_counter_4bit_selfcheck.v \
             sim/run_sim.sh synth/run_synth.sh openlane/config.tcl; do
        [ -f "lab0_counter/$f" ] && printf "  %-38s CO\n" "$f" \
                                 || printf "  %-38s THIEU\n" "$f"
    done
    echo ""
    echo "File .sh co quyen chay khong  (_chung.sh khong can quyen chay — no duoc nap vao):"
    find lab0_counter cong_cu -name "*.sh" 2>/dev/null | sort | while read -r f; do
        case "$f" in
            */_chung.sh) printf "  %-40s -  (khong can)\n" "$f" ;;
            *) [ -x "$f" ] && printf "  %-40s co\n" "$f" \
                           || printf "  %-40s KHONG  <<< sua bang: chmod +x %s\n" "$f" "$f" ;;
        esac
    done
    echo ""
    SO_CRLF=$(grep -rlU $'\r' . --include='*.sh' 2>/dev/null | wc -l)
    echo "So file .sh dung xuong dong Windows (CRLF): $SO_CRLF"
    [ "$SO_CRLF" -gt 0 ] && {
        echo "  >> DAY LA VAN DE. Bash se bao loi \$'\\r': command not found"
        echo "  >> Sua:  find . -name '*.sh' -exec sed -i 's/\\r\$//' {} +"
    }
else
    echo "lab0_counter/:   KHONG THAY  (dang dung o $(pwd -P))"
fi
echo ""

echo "══ 8. THU CHAY LAB0 ═════════════════════════════════════════════════"
echo "(day la phep thu doc lap: neu phan nay DAT thi may ban chay duoc"
echo " mo phong + tong hop, va loi cua ban nam o cho khac.)"
echo ""
if [ ! -f lab0_counter/rtl/counter_4bit.v ]; then
    echo "(bo qua — khong thay lab0_counter/rtl/counter_4bit.v)"
elif ! command -v iverilog >/dev/null 2>&1; then
    echo "(bo qua — chua co iverilog)"
else
    echo "─── Mo phong tu kiem ───"
    bash lab0_counter/sim/run_sim.sh 2>&1 | sed 's/\x1b\[[0-9;]*m//g' | tail -22 | sed 's/^/  /'
    echo ""
    if command -v yosys >/dev/null 2>&1; then
        echo "─── Tong hop ───"
        bash lab0_counter/synth/run_synth.sh 2>&1 | sed 's/\x1b\[[0-9;]*m//g' \
          | sed -n '/DOI CHIEU/,$p' | head -22 | sed 's/^/  /'
    else
        echo "─── Tong hop: bo qua, chua co yosys ───"
    fi
fi
echo ""

echo "══════════════════════════════════════════════════════════════════════"
echo " HET BAO CAO"
echo "══════════════════════════════════════════════════════════════════════"
} > "$TEN" 2>&1

DONG=$(wc -l < "$TEN")
KB=$(du -k "$TEN" | cut -f1)

cat <<EOF

  ══════════════════════════════════════════════════════════════
   DA SINH BAO CAO
  ══════════════════════════════════════════════════════════════

   File:   $TEN
   Dai:    $DONG dong, $KB KB

   ── LAM GI TIEP ──

   1. MO FILE RA DOC. Dien phan "SINH VIEN TU DIEN" o dau file —
      dac biet la muc "Da thu nhung cach nao roi". Do la muc giup
      giang vien nhieu nhat va cung la muc hay bi bo trong nhat.

         nano $TEN

   2. Gui file cho giang vien.

   ── DUA FILE NAY SANG WINDOWS DE DINH KEM EMAIL ──

       cp $TEN /mnt/c/Users/\$(cmd.exe /c 'echo %USERNAME%' 2>/dev/null | tr -d '\r')/Desktop/

   Hoac mo thu muc hien tai bang File Explorer:

       explorer.exe .

   ── VE QUYEN RIENG TU ──

   File nay KHONG chua mat khau, khoa SSH hay noi dung file ca nhan.
   Ban mo ra doc duoc truoc khi gui.

EOF
