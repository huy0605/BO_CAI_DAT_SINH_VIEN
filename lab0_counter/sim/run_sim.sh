#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────
#  run_sim.sh — Chay mo phong lab0.
#
#     bash sim/run_sim.sh            chay testbench TU KIEM (mac dinh)
#     bash sim/run_sim.sh --thuong   chay testbench thuong, in tung dong
#
#  Chay tu thu muc goc cua lab0.
# ─────────────────────────────────────────────────────────────────────────
set -u
cd "$(dirname "$0")/.."

XANH=$'\033[32m'; DO=$'\033[31m'; VANG=$'\033[33m'; DAM=$'\033[1m'; HET=$'\033[0m'

if ! command -v iverilog >/dev/null 2>&1; then
    echo ""
    echo "  ${DO}Khong tim thay iverilog.${HET}"
    echo "  Cai bang:  sudo apt install -y iverilog"
    echo "  Neu dang o PowerShell: sai cho roi — phai chay trong WSL2."
    echo ""
    exit 1
fi

mkdir -p sim/waveforms sim/build

if [ "${1:-}" = "--thuong" ]; then
    TB="tb/tb_counter_4bit.v"
    TEN="tb_counter_4bit"
    VCD="sim/waveforms/counter_4bit.vcd"
    NHAN="testbench THUONG (tu nhin ket qua)"
else
    TB="tb/tb_counter_4bit_selfcheck.v"
    TEN="tb_counter_4bit_selfcheck"
    VCD="sim/waveforms/counter_4bit_selfcheck.vcd"
    NHAN="testbench TU KIEM (may tu danh gia)"
fi

echo ""
echo "  Chay: $NHAN"
echo "  iverilog $(iverilog -V 2>/dev/null | head -1 | awk '{print $4}')"
echo ""

# ── Buoc 1: bien dich ────────────────────────────────────────────────────
echo "  [1/2] Bien dich..."
if ! iverilog -g2012 -o "sim/build/$TEN" rtl/counter_4bit.v "$TB"; then
    echo ""
    echo "  ${DO}BIEN DICH THAT BAI.${HET}"
    echo "  Doc thong bao loi o tren — no chi ro file va so dong."
    echo ""
    exit 1
fi
echo "      ok"

# ── Buoc 2: chay ─────────────────────────────────────────────────────────
echo "  [2/2] Chay mo phong..."
echo ""

# Chay va GIU LAI ket qua. Ly do: vvp luon thoat voi ma 0, ke ca khi
# testbench bao FAILED — vi $finish cua Verilog khong mang ma loi ra ngoai.
# Neu khong tu kiem o day thi moi cong cu cham bai tu dong (va ca
# kiem_tra_tat_ca.sh) se coi mot bai SAI la bai DAT.
KQ=$(mktemp)
if ! vvp "sim/build/$TEN" 2>&1 | tee "$KQ"; then
    echo ""
    echo "  ${DO}MO PHONG THAT BAI.${HET}"
    rm -f "$KQ"
    echo ""
    exit 1
fi

# ── Kiem ket qua ─────────────────────────────────────────────────────────
# Lay DUNG file song cua lan chay nay. Truoc day cho nay dung
# 'ls sim/waveforms/*.vcd | head -1' — no lay file dau bang chu cai,
# nen sau khi chay ca hai testbench thi bao sai ten file.
if [ -f "$VCD" ]; then
    echo "  File song: $VCD  ($(du -h "$VCD" | cut -f1))"
    echo "  Xem bang:  gtkwave $VCD"
else
    echo "  ${VANG}Canh bao: khong sinh duoc file .vcd${HET}"
fi
echo ""

# ── Ket luan: bien ket qua thanh MA THOAT ────────────────────────────────
if [ "$TEN" = "tb_counter_4bit_selfcheck" ]; then
    if grep -q "ALL TESTS PASSED" "$KQ"; then
        rm -f "$KQ"
        exit 0
    else
        echo "  ${DO}KHONG DAT.${HET} Doc lai cac dong FAIL o tren."
        echo "  Sua rtl/counter_4bit.v roi chay lai. ${DAM}Dung tong hop khi chua dat.${HET}"
        echo ""
        rm -f "$KQ"
        exit 1
    fi
fi
rm -f "$KQ"
