#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════
#  02_kiem_tra_cong_cu.sh — Kiem CHANG 2: cong cu mo phong va tong hop
#
#  Chay:  bash cong_cu/02_kiem_tra_cong_cu.sh
#
#  Script nay CHI DOC. Khong cai gi, khong sua gi, khong xoa gi.
#  Chay bao nhieu lan cung duoc.
# ═══════════════════════════════════════════════════════════════════════
set -u
cd "$(dirname "${BASH_SOURCE[0]}")"
# shellcheck source=_chung.sh
source ./_chung.sh
cd ..

khung "CHANG 2 — KIEM TRA CONG CU MO PHONG VA TONG HOP" \
      "Xong chang nay la lam duoc lab0 buoc 1, 2, 3"

# ── 1. Cong cu nen ─────────────────────────────────────────────────────
tieu "Cong cu nen"
THIEU=""
kiem_cong_cu git     "quan ly ma nguon"            can || THIEU="$THIEU git"
kiem_cong_cu python3 "chay cac script"             can || THIEU="$THIEU python3"
kiem_cong_cu make    "chay Makefile"               can || THIEU="$THIEU make"
kiem_cong_cu tree    "xem cay thu muc"             nen || THIEU="$THIEU tree"
kiem_cong_cu curl    "tai file tu mang"            nen || THIEU="$THIEU curl"

# ── 2. Cong cu EDA ─────────────────────────────────────────────────────
tieu "Cong cu thiet ke vi mach"
kiem_cong_cu iverilog "MO PHONG Verilog"           can || THIEU="$THIEU iverilog"
kiem_cong_cu yosys    "TONG HOP RTL -> mach logic" can || THIEU="$THIEU yosys"
kiem_cong_cu gtkwave  "xem dang song .vcd"         nen || THIEU="$THIEU gtkwave"

# vvp di kem iverilog nhung kiem rieng cho chac
if co_lenh vvp; then o "vvp" "chay file mo phong da bien dich"
else x "vvp" "CHUA CO — thuong di kem iverilog"; THIEU="$THIEU iverilog"; fi

if [ -n "$THIEU" ]; then
    them_viec "Cai cac goi con thieu:
       sudo apt update
       sudo apt install -y$THIEU"
    them_viec "Se hoi mat khau LINUX (dat luc cai Ubuntu, khong phai mat khau
      Windows). Go mat khau khong hien gi ca — do la binh thuong."
fi

# ── 3. Thu bien dich that ──────────────────────────────────────────────
tieu "Thu bien dich va chay that"
if co_lenh iverilog && co_lenh vvp; then
    TMP=$(mktemp -d)
    cat > "$TMP/thu.v" <<'VERILOG'
`timescale 1ns/1ps
module thu;
  reg [3:0] d = 0;
  integer i;
  initial begin
    for (i = 0; i < 3; i = i + 1) begin #1 d = d + 1; end
    if (d === 4'd3) $display("KET_QUA_DUNG");
    else            $display("KET_QUA_SAI d=%0d", d);
  end
endmodule
VERILOG
    if iverilog -g2012 -o "$TMP/thu" "$TMP/thu.v" 2>"$TMP/loi"; then
        KQ=$(vvp "$TMP/thu" 2>/dev/null)
        if echo "$KQ" | grep -q KET_QUA_DUNG; then
            o "iverilog + vvp" "bien dich va chay ra ket qua dung"
        else
            x "iverilog + vvp" "chay duoc nhung ket qua sai"
            ghi "Dau ra: $KQ"
        fi
    else
        x "iverilog" "khong bien dich duoc file thu don gian"
        ghi "$(head -3 "$TMP/loi")"
    fi
    rm -rf "$TMP"
else
    canh "Thu bien dich" "bo qua — thieu iverilog hoac vvp"
fi

if co_lenh yosys; then
    TMP=$(mktemp -d)
    printf 'module t(input a,b,output y); assign y=a&b; endmodule\n' > "$TMP/t.v"
    if yosys -q -p "read_verilog $TMP/t.v; synth -top t" >/dev/null 2>&1; then
        o "yosys" "tong hop duoc mot module thu"
    else
        x "yosys" "khong tong hop duoc module thu"
    fi
    rm -rf "$TMP"
fi

# ── 4. Lab0 co san khong ───────────────────────────────────────────────
tieu "Bo bai thuc hanh"
if [ -f lab0_counter/rtl/counter_4bit.v ]; then
    o "lab0_counter/" "co san"
    [ -x lab0_counter/sim/run_sim.sh ] && o "run_sim.sh" "co quyen chay" \
        || { canh "run_sim.sh" "chua co quyen chay"
             them_viec "Cap quyen:  chmod +x lab0_counter/sim/*.sh lab0_counter/synth/*.sh"; }
else
    canh "lab0_counter/" "khong thay o thu muc hien tai"
    ghi "Dang dung o: $(pwd)"
    them_viec "Chay script nay tu thu muc goc cua bo cai dat."
fi

# ── 5. Ky tu xuong dong ────────────────────────────────────────────────
tieu "Ky tu xuong dong cua cac script"
SO_CRLF=$(grep -rlU $'\r' . --include='*.sh' 2>/dev/null | wc -l)
if [ "$SO_CRLF" -eq 0 ]; then
    o "Xuong dong" "moi file .sh dung kieu Linux (LF)"
else
    x "Xuong dong" "$SO_CRLF file .sh dang dung kieu Windows (CRLF)"
    ghi "Bash se bao loi kieu:  \$'\r': command not found"
    ghi "Loi nay rat kho doan vi mat thuong khong nhin thay ky tu \r."
    them_viec "Sua bang:  find . -name '*.sh' -exec sed -i 's/\r\$//' {} +"
fi

tong_ket "CHANG 2" "bash lab0_counter/sim/run_sim.sh"
