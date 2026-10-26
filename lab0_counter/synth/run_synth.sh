#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────
#  run_synth.sh — Chay tong hop lab0 bang Yosys, va DOI CHIEU voi ket qua
#                 chuan da biet.
#
#     bash synth/run_synth.sh
# ─────────────────────────────────────────────────────────────────────────
set -u
cd "$(dirname "$0")/.."

XANH=$'\033[32m'; DO=$'\033[31m'; VANG=$'\033[33m'; DAM=$'\033[1m'; HET=$'\033[0m'

if ! command -v yosys >/dev/null 2>&1; then
    echo ""
    echo "  ${DO}Khong tim thay yosys.${HET}"
    echo "  Cai bang:  sudo apt install -y yosys"
    echo ""
    exit 1
fi

mkdir -p synth/reports synth/netlist

echo ""
echo "  Tong hop lab0 bang $(yosys -V 2>/dev/null | head -1)"
echo ""

if ! yosys -s synth/counter_4bit.ys | tee synth/reports/counter_4bit_yosys.log; then
    echo ""
    echo "  ${DO}TONG HOP THAT BAI.${HET} Doc log o tren."
    echo ""
    exit 1
fi

# ── Doi chieu voi ket qua chuan ──────────────────────────────────────────
LOG=synth/reports/counter_4bit_yosys.log
SO_O=$(awk '/^=== /{n=0} /Number of cells/{n=$NF} END{print n+0}' "$LOG")
SO_FF=$(awk '/^=== /{s=0} /DFF/{s+=$NF} END{print s+0}' "$LOG")

echo ""
echo "  ================================================================"
echo "   DOI CHIEU VOI KET QUA CHUAN"
echo "  ================================================================"
echo ""
printf "   %-22s %10s %10s   %s\n" "chi so" "cua ban" "chuan" "danh gia"
printf "   %-22s %10s %10s   %s\n" "──────────────────────" "──────────" "──────────" "────────"

danh_gia () {  # $1 nhan  $2 gia tri  $3 chuan
    if [ "$2" = "$3" ]; then
        printf "   %-22s %10s %10s   ${XANH}khop${HET}\n" "$1" "$2" "$3"
        return 0
    else
        printf "   %-22s %10s %10s   ${VANG}lech${HET}\n" "$1" "$2" "$3"
        return 1
    fi
}

LECH=0
danh_gia "so o chuan"     "$SO_O"  "10" || LECH=1
danh_gia "so flip-flop"   "$SO_FF" "4"  || LECH=1

echo ""
if [ "$LECH" = "0" ]; then
    echo "   ${XANH}Khop hoan toan voi ket qua chuan.${HET}"
    echo ""
    echo "   Ket qua chuan lay tu lab guide '4bit counter RTL-to-GDSII',"
    echo "   chay tren Yosys 0.33. Neu ban dung phien ban khac, so o co the"
    echo "   lech doi chut — do la BINH THUONG, khong phai loi."
else
    echo "   ${VANG}Co lech so voi ket qua chuan.${HET}"
    echo ""
    echo "   Nguyen nhan thuong gap, theo thu tu de kiem:"
    echo "     1. Phien ban Yosys khac 0.33  -> chay 'yosys -V' de xem"
    echo "     2. Da sua file rtl/counter_4bit.v"
    echo "   Lech vi phien ban thi KHONG PHAI LOI. Lech vi sua RTL thi phai"
    echo "   xem lai da sua dung y dinh chua."
fi
echo ""
echo "   4 flip-flop = 4 bit cua count[3:0]. Day la con so PHAI khop voi"
echo "   thiet ke: mot bo dem 4 bit thi can dung 4 phan tu nho."
echo ""
echo "   Netlist:  synth/netlist/counter_4bit_synth.v"
echo "   Log:      $LOG"
echo ""

# ── Ket luan: bien ket qua thanh MA THOAT ────────────────────────────────
# Chi so O duoc phep lech (phien ban yosys khac nhau thi bo toi uu khac
# nhau). So FLIP-FLOP thi KHONG: mot bo dem 4 bit phai dung 4 phan tu nho,
# khong phu thuoc phien ban. Nen chi so FF moi quyet dinh ma thoat.
if [ "$SO_FF" != "4" ]; then
    echo "   ${DO}${DAM}KHONG DAT: so flip-flop la $SO_FF, phai la 4.${HET}"
    echo "   Day KHONG phai chuyen phien ban cong cu. Xem lai rtl/counter_4bit.v."
    echo ""
    exit 1
fi
exit 0
