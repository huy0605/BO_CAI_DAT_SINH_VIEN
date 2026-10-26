#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════
#  04_kiem_tra_openlane.sh — Kiem CHANG 4: OpenLane da dung xong chua
#
#  Chay:  bash cong_cu/04_kiem_tra_openlane.sh
#
#  Script nay CHI DOC. Khong cai gi, khong sua gi, khong xoa gi.
#  Chay bao nhieu lan cung duoc.
# ═══════════════════════════════════════════════════════════════════════
set -u
cd "$(dirname "${BASH_SOURCE[0]}")"
# shellcheck source=_chung.sh
source ./_chung.sh
cd ..

khung "CHANG 4 — KIEM TRA OPENLANE" "Chang cuoi. Xong la chay duoc RTL2GDSII."

OL="${OPENLANE_DIR:-$HOME/OpenLane}"

# ── 1. Da clone chua ───────────────────────────────────────────────────
tieu "Thu muc OpenLane"
if [ -d "$OL" ]; then
    o "Thu muc" "$OL"
else
    x "Thu muc" "khong thay $OL"
    them_viec "Tai ve:
       cd ~
       git clone https://github.com/The-OpenROAD-Project/OpenLane.git"
    tong_ket "CHANG 4" ""
    exit 1
fi

# ── 2. Cac file then chot ──────────────────────────────────────────────
tieu "File then chot"
[ -f "$OL/Makefile" ] && o "Makefile" "co" || x "Makefile" "khong thay"
if [ -f "$OL/flow.tcl" ]; then
    o "flow.tcl" "co — day la diem vao cua flow"
else
    x "flow.tcl" "khong thay"
    them_viec "Chay 'make' trong $OL de dung moi truong."
fi

# ── 3. Da chay make chua ───────────────────────────────────────────────
tieu "Da dung moi truong chua"
if [ -d "$OL/venv" ]; then o "venv/" "da tao"
else canh "venv/" "chua thay — co the 'make' chua chay xong"
     them_viec "Chay:  cd $OL && make"; fi

PDK="${PDK_ROOT:-$HOME/.ciel}"
if [ -d "$PDK" ] && [ -n "$(ls -A "$PDK" 2>/dev/null)" ]; then
    SO=$(find "$PDK" -maxdepth 2 -name "sky130*" 2>/dev/null | wc -l)
    o "PDK" "$SO ban tai $PDK"
elif [ -d "$HOME/.volare" ] && [ -n "$(ls -A "$HOME/.volare" 2>/dev/null)" ]; then
    o "PDK" "tai $HOME/.volare (kieu volare cu)"
else
    canh "PDK" "chua thay — 'make' se tu tai, vai GB"
    them_viec "Chay:  cd $OL && make"
fi

# ── 4. Anh Docker cua OpenLane ─────────────────────────────────────────
tieu "Anh Docker cua OpenLane"
if co_lenh docker && timeout 20 docker info >/dev/null 2>&1; then
    if docker images 2>/dev/null | grep -qiE "openlane|efabless"; then
        docker images --format '{{.Repository}}:{{.Tag}}  {{.Size}}' 2>/dev/null \
          | grep -iE "openlane|efabless" | head -3 | while read -r d; do
            o "Anh" "$d"
        done
    else
        canh "Anh OpenLane" "chua tai — 'make' se tu tai"
    fi
else
    x "Docker" "khong phan hoi — quay lai chang 3"
    them_viec "Chay:  bash cong_cu/03_kiem_tra_docker.sh"
fi

# ── 5. Thiet ke da dat vao chua ────────────────────────────────────────
tieu "Thiet ke trong OpenLane"
if [ -d "$OL/designs" ]; then
    SO_TK=$(ls -1 "$OL/designs" 2>/dev/null | wc -l)
    o "designs/" "$SO_TK thiet ke"
    if [ -d "$OL/designs/counter_4bit" ]; then
        o "counter_4bit" "da dat vao"
        [ -f "$OL/designs/counter_4bit/config.tcl" ] \
          && o "  config.tcl" "co" || x "  config.tcl" "thieu"
        [ -f "$OL/designs/counter_4bit/src/counter_4bit.v" ] \
          && o "  src/counter_4bit.v" "co" || x "  src/counter_4bit.v" "thieu"
    else
        canh "counter_4bit" "chua dat vao"
        them_viec "Dat lab0 vao OpenLane:
       cd $OL
       mkdir -p designs/counter_4bit/src
       cp ~/lab0_counter/rtl/counter_4bit.v   designs/counter_4bit/src/
       cp ~/lab0_counter/openlane/config.tcl  designs/counter_4bit/"
    fi
else
    x "designs/" "khong thay"
fi

# ── 6. Da tung chay chua ───────────────────────────────────────────────
tieu "Lan chay truoc do"
RUNS=$(find "$OL/designs" -maxdepth 3 -type d -name "RUN_*" 2>/dev/null | wc -l)
if [ "$RUNS" -gt 0 ]; then
    o "So lan da chay" "$RUNS"
    MOI=$(find "$OL/designs" -maxdepth 3 -type d -name "RUN_*" 2>/dev/null | sort | tail -1)
    ghi "Moi nhat: ${MOI#$OL/}"
    if find "$MOI" -name "*.gds" 2>/dev/null | grep -q .; then
        o "File GDS" "$(find "$MOI" -name '*.gds' 2>/dev/null | head -1 | sed "s|$OL/||")"
    else
        canh "File GDS" "chua co trong lan chay moi nhat"
    fi
else
    canh "Chua chay lan nao" "binh thuong neu vua cai xong"
fi

echo ""
echo "  ${DAM}Phep thu that su cua chang nay:${HET}"
echo ""
echo "      cd $OL && make test"
echo ""
echo "  Lenh do chay tron mot thiet ke mau qua ca flow. No la bang chung"
echo "  duy nhat cho biet OpenLane thuc su lam viec duoc — script nay chi"
echo "  kiem ${DAM}co mat${HET}, khong kiem ${DAM}chay duoc${HET}."

tong_ket "CHANG 4" "cd $OL && make test"
