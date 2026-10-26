#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════
#  01_kiem_tra_wsl.sh — Kiem CHANG 1: WSL2 da san sang chua
#
#  Chay:  bash cong_cu/01_kiem_tra_wsl.sh
#
#  Script nay CHI DOC. Khong cai gi, khong sua gi, khong xoa gi.
#  Chay bao nhieu lan cung duoc.
# ═══════════════════════════════════════════════════════════════════════
set -u
cd "$(dirname "${BASH_SOURCE[0]}")"
# shellcheck source=_chung.sh
source ./_chung.sh
cd ..

khung "CHANG 1 — KIEM TRA WSL2" "Chay TRONG cua so Ubuntu, khong phai PowerShell"

# ── 1. Dang o dung cho khong ───────────────────────────────────────────
tieu "Dang chay o dau"
if dang_trong_wsl; then
    NHAN=$(grep -o 'Linux version [0-9.]*' /proc/version 2>/dev/null | head -1)
    o "Dang trong WSL" "${NHAN:-WSL}"
elif [ "$(uname -s)" = "Linux" ]; then
    canh "Linux nhung khong phai WSL" "may that hoac may ao — van chay tiep duoc"
else
    x "He dieu hanh" "khong phai Linux"
    ghi "Ban dang chay script nay o dau? No phai chay trong cua so Ubuntu"
    ghi "cua WSL2, khong phai PowerShell hay Command Prompt."
    them_viec "Mo Ubuntu tu Start Menu, hoac go 'wsl' trong PowerShell."
fi

# ── 2. Ban phan phoi ───────────────────────────────────────────────────
tieu "Ban phan phoi Linux"
if [ -r /etc/os-release ]; then
    . /etc/os-release
    o "Ban phan phoi" "$PRETTY_NAME"
    case "${ID:-}" in
        ubuntu|debian) : ;;
        *) canh "Khong phai Ubuntu/Debian" "lenh apt trong tai lieu co the khac" ;;
    esac
else
    canh "/etc/os-release" "khong doc duoc"
fi

# ── 3. Tai nguyen ──────────────────────────────────────────────────────
tieu "Tai nguyen may"
RAM_MB=$(awk '/MemTotal/ {print int($2/1024)}' /proc/meminfo 2>/dev/null)
if   [ "${RAM_MB:-0}" -ge 15000 ]; then o "RAM" "$((RAM_MB/1024)) GB — thoai mai"
elif [ "${RAM_MB:-0}" -ge 7000  ]; then canh "RAM" "$((RAM_MB/1024)) GB — chay duoc, 16 GB thi de tho hon"
else
    x "RAM" "$((RAM_MB/1024)) GB — CAN it nhat 8 GB"
    them_viec "Dong bot ung dung Windows, hoac them RAM. OpenLane can nhieu bo nho."
fi

TRONG_KB=$(df -Pk "$HOME" 2>/dev/null | awk 'NR==2 {print $4}')
TRONG_GB=$(( ${TRONG_KB:-0} / 1024 / 1024 ))
if   [ "$TRONG_GB" -ge 40 ]; then o "Dia trong" "${TRONG_GB} GB"
elif [ "$TRONG_GB" -ge 15 ]; then canh "Dia trong" "${TRONG_GB} GB — du cho mo phong, chua chac du cho OpenLane"
else
    x "Dia trong" "${TRONG_GB} GB — khong du"
    them_viec "Giai phong dia. Docker image va PDK chiem khoang 25-30 GB."
fi

SO_CPU=$(nproc 2>/dev/null || echo 0)
[ "$SO_CPU" -ge 2 ] && o "So nhan CPU" "$SO_CPU" \
                    || canh "So nhan CPU" "$SO_CPU — se cham"

# ── 4. Mang ────────────────────────────────────────────────────────────
tieu "Mang"
# Chu y: KHONG dung 'curl -f' o day. -f coi ma 4xx la that bai, ma proxy
# cua truong hoc rat hay tra 403 cho lenh HEAD du mang van thong.
# Ta chi can biet co CHAM DUOC toi server khong, chu khong can ma 200.
if co_lenh curl; then
    MA_HTTP=$(timeout 15 curl -s -o /dev/null -w '%{http_code}' https://github.com 2>/dev/null)
    case "${MA_HTTP:-000}" in
        000) x "Ra duoc github.com" "khong cham duoc toi server"
             ghi "Nghia la: het gio cho, bi chan, hoac khong co mang."
             them_viec "Kiem mang. Neu dung mang truong co proxy, hoi quan tri mang." ;;
        *)   o "Ra duoc github.com" "ma HTTP $MA_HTTP — cham duoc toi server" ;;
    esac
else
    canh "curl" "chua co — chua kiem duoc mang"
fi

# ── 5. Vi tri thu muc ──────────────────────────────────────────────────
tieu "Vi tri lam viec"
HT="$(pwd -P)"
case "$HT" in
    /mnt/[a-z]/*)
        canh "Thu muc hien tai" "dang o o Windows"
        ghi "$HT"
        ghi "Doc ghi qua /mnt/c/ CHAM hon nhieu lan. Mot lan chay OpenLane"
        ghi "doc ghi hang chuc nghin file — chenh lech co the la vai phut"
        ghi "so voi nua tieng."
        them_viec "Chep du an vao thu muc nha cua WSL2:  cp -r . ~/rtl2gds"
        ;;
    *)  o "Thu muc hien tai" "he tep WSL2 — toc do tot" ;;
esac

tong_ket "CHANG 1" "bash cong_cu/02_kiem_tra_cong_cu.sh"
