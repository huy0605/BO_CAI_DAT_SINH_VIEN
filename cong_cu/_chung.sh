#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════
#  _chung.sh — Ham dung chung cho moi script kiem tra.
#  KHONG chay truc tiep file nay. Cac script khac se nap no vao.
# ═══════════════════════════════════════════════════════════════════════

XANH=$'\033[32m'; DO=$'\033[31m'; VANG=$'\033[33m'
LAM=$'\033[36m';  DAM=$'\033[1m';  HET=$'\033[0m'

DAT=0; HONG=0; CANH=0
declare -a VIEC_TIEP=()

# ── In ket qua tung muc ────────────────────────────────────────────────
o    () { printf "  ${XANH}[ OK ]${HET}  %-30s %s\n" "$1" "${2:-}"; DAT=$((DAT+1)); }
x    () { printf "  ${DO}[HONG]${HET}  %-30s %s\n" "$1" "${2:-}"; HONG=$((HONG+1)); }
canh () { printf "  ${VANG}[ !! ]${HET}  %-30s %s\n" "$1" "${2:-}"; CANH=$((CANH+1)); }
ghi  () { printf "         %s\n" "$1"; }

tieu () {
    echo ""
    echo "  ${LAM}${DAM}── $1 ──${HET}"
}

khung () {
    echo ""
    echo "  ${LAM}══════════════════════════════════════════════════════════════${HET}"
    echo "  ${LAM}${DAM} $1${HET}"
    [ -n "${2:-}" ] && echo "  ${LAM} $2${HET}"
    echo "  ${LAM}══════════════════════════════════════════════════════════════${HET}"
}

them_viec () { VIEC_TIEP+=("$1"); }

# ── Tien ich ───────────────────────────────────────────────────────────
co_lenh () { command -v "$1" >/dev/null 2>&1; }

# In phien ban cua mot cong cu, thu ca --version lan -V
phien_ban () {
    { "$1" --version 2>&1; "$1" -V 2>&1; } \
      | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1
}

# Kiem mot cong cu: $1 lenh, $2 mo ta, $3 = "can" hoac "nen"
kiem_cong_cu () {
    local lenh="$1" mota="$2" muc="${3:-can}"
    if co_lenh "$lenh"; then
        local pb; pb=$(phien_ban "$lenh")
        o "$lenh" "${pb:-co} — $mota"
        return 0
    else
        if [ "$muc" = "can" ]; then
            x "$lenh" "CHUA CO — $mota"
        else
            canh "$lenh" "chua co (tuy chon) — $mota"
        fi
        return 1
    fi
}

dang_trong_wsl () { grep -qi microsoft /proc/version 2>/dev/null; }

# ── Tong ket ───────────────────────────────────────────────────────────
tong_ket () {
    local ten_chang="$1" lenh_tiep="${2:-}"
    echo ""
    echo "  ${LAM}══════════════════════════════════════════════════════════════${HET}"
    printf "   Dat: ${XANH}%d${HET}      Canh bao: ${VANG}%d${HET}      Hong: ${DO}%d${HET}\n" \
           "$DAT" "$CANH" "$HONG"
    echo "  ${LAM}══════════════════════════════════════════════════════════════${HET}"
    echo ""

    if [ "$HONG" -eq 0 ]; then
        echo "  ${XANH}${DAM}$ten_chang: DAT.${HET}"
        [ -n "$lenh_tiep" ] && { echo ""; echo "  Buoc ke tiep:"; echo ""; echo "      $lenh_tiep"; }
    else
        echo "  ${DO}${DAM}$ten_chang: CHUA DAT — con $HONG muc hong.${HET}"
        echo ""
        echo "  ${DAM}DUNG LAI O DAY.${HET} Dung di tiep khi con muc [HONG]."
        echo "  Moi buoc deu dua tren buoc truoc; bo qua se lam loi ve sau"
        echo "  kho gap boi vi khong biet no thuoc tang nao."
    fi

    if [ "${#VIEC_TIEP[@]}" -gt 0 ]; then
        echo ""
        echo "  ${DAM}Viec can lam:${HET}"
        echo ""
        local i=1
        for v in "${VIEC_TIEP[@]}"; do
            echo "   $i. $v"
            i=$((i+1))
        done
    fi

    echo ""
    echo "  Bi tac? Chay lenh nay roi gui file sinh ra cho giang vien:"
    echo ""
    echo "      bash cong_cu/bao_cao_su_co.sh"
    echo ""

    [ "$HONG" -eq 0 ]
}
