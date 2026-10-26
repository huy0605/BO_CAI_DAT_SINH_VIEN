#!/usr/bin/env bash
# EEE703128 v2.4 — dashboard môi trường local
# Chặng 1–2: BẮT BUỘC cho Lab0/local RTL. Chặng 3–4: TỰ CHỌN cho P&R local.
# B2 chính thức chạy GitHub Actions + LibreLane, không phụ thuộc chặng 3–4.
set -u
cd "$(dirname "${BASH_SOURCE[0]}")"
# shellcheck source=_chung.sh
source ./_chung.sh
cd ..
GON=0; [ "${1:-}" = "--gon" ] && GON=1
DS_TEN=("WSL2 san sang" "Cong cu mo phong + tong hop" "Docker chay duoc" "OpenLane local san sang")
DS_FILE=("01_kiem_tra_wsl.sh" "02_kiem_tra_cong_cu.sh" "03_kiem_tra_docker.sh" "04_kiem_tra_openlane.sh")
DS_BB=(1 1 0 0)
DS_MO=("go duoc lenh trong Ubuntu" "chay duoc Lab0 local" "TU CHON: P&R local" "TU CHON: P&R local")
KQ=(); TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
khung "KIEM TRA TOAN BO" "chang 1-2 bat buoc; chang 3-4 tu chon"
echo; echo "  Dang chay..."; echo
for i in "${!DS_FILE[@]}"; do
  f="cong_cu/${DS_FILE[$i]}"; n=$((i+1)); printf "  Chang %d/4  %-32s " "$n" "${DS_TEN[$i]}"
  if [ ! -f "$f" ]; then printf "${DO}THIEU FILE${HET}\n"; KQ+=("thieu"); continue; fi
  if bash "$f" > "$TMP/$n.txt" 2>&1; then printf "${XANH}DAT${HET}\n"; KQ+=("dat"); else printf "${DO}CHUA DAT${HET}\n"; KQ+=("hong"); fi
done

echo; echo "  ${LAM}══════════════════════════════════════════════════════════════${HET}"
echo "  ${LAM}${DAM} BAN DANG O DAU${HET}"; echo "  ${LAM}══════════════════════════════════════════════════════════════${HET}"; echo
for i in "${!KQ[@]}"; do
  n=$((i+1)); [ "${KQ[$i]}" = dat ] && dau="${XANH}[x]${HET}" || dau="${DO}[ ]${HET}"
  loai="BAT BUOC"; [ "${DS_BB[$i]}" -eq 0 ] && loai="TU CHON"
  printf "   %b  Chang %d — %-28s %-8s · %s\n" "$dau" "$n" "${DS_TEN[$i]}" "$loai" "${DS_MO[$i]}"
done

echo
REQ_FAIL=0
for i in 0 1; do [ "${KQ[$i]:-thieu}" = dat ] || REQ_FAIL=$((i+1)); done
OPT_OK=1
for i in 2 3; do [ "${KQ[$i]:-thieu}" = dat ] || OPT_OK=0; done

if [ "$REQ_FAIL" -ne 0 ]; then
  echo "  ${DO}${DAM}CHUA SAN SANG cho Lab0: con loi o chang bat buoc $REQ_FAIL.${HET}"
  echo "  Xem chi tiet: bash cong_cu/${DS_FILE[$((REQ_FAIL-1))]}"
  if [ "$GON" -eq 0 ] && [ -f "$TMP/$REQ_FAIL.txt" ]; then
    echo; sed 's/\x1b\[[0-9;]*m//g' "$TMP/$REQ_FAIL.txt" | grep -a -E '^[[:space:]]+\[HONG\]' | sed 's/^/  /' || true
  fi
  RC=1
else
  echo "  ${XANH}${DAM}SAN SANG cho tuyen BAT BUOC: Lab0 / mo phong / tong hop local.${HET}"
  echo "  B2 chinh thuc: tiep tuc Lab A/B -> GitHub template -> Actions -> artifacts."
  if [ "$OPT_OK" -eq 1 ]; then
    echo "  ${XANH}Nhanh P&R local tu chon cung dang san sang.${HET}"
  else
    echo "  ${VANG}Docker/OpenLane local chua san sang — KHONG chan B2 va KHONG phai loi bat buoc.${HET}"
  fi
  RC=0
fi

echo; echo "  Windows pre-check (PowerShell):"
echo "      powershell -ExecutionPolicy Bypass -File .\\cong_cu\\00_kiem_tra_windows.ps1"
echo; echo "  Bi tac local? bash cong_cu/bao_cao_su_co.sh"; echo
exit "$RC"
