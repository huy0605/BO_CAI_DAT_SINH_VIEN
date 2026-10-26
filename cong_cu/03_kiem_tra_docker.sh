#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════
#  03_kiem_tra_docker.sh — Kiem CHANG 3: Docker — cho hay vap nhat
#
#  Chay:  bash cong_cu/03_kiem_tra_docker.sh
#
#  Script nay CHI DOC. Khong cai gi, khong sua gi, khong xoa gi.
#  Chay bao nhieu lan cung duoc.
# ═══════════════════════════════════════════════════════════════════════
set -u
cd "$(dirname "${BASH_SOURCE[0]}")"
# shellcheck source=_chung.sh
source ./_chung.sh
cd ..

khung "CHANG 3 — KIEM TRA DOCKER" \
      "Day la chang hay vap nhat. Doc ky phan huong dan khi hong."

# ── 1. Co lenh docker khong ────────────────────────────────────────────
tieu "Lenh docker"
if co_lenh docker; then
    o "docker" "$(docker --version 2>/dev/null | head -1)"
else
    x "docker" "CHUA CO trong WSL"
    echo ""
    echo "  ${DAM}CACH DUNG — doc ky, day la cho hay sai nhat:${HET}"
    echo ""
    echo "   ${DO}KHONG dung 'sudo snap install docker'${HET} — no cai duoc nhung"
    echo "   Ubuntu trong WSL2 khong truy cap duoc."
    echo ""
    echo "   Cach dung la cai ${DAM}Docker Desktop tren WINDOWS${HET}, roi bat cau noi"
    echo "   sang WSL2. Ubuntu khong tu chay Docker — no MUON Docker cua Windows."
    echo ""
    them_viec "Tren WINDOWS: cai Docker Desktop tu docker.com"
    them_viec "Docker Desktop > Settings > General > bat 'Use the WSL 2 based engine'
      roi bam Apply & Restart"
    them_viec "Docker Desktop > Settings > Resources > WSL Integration:
      bat 'Enable integration with my default WSL distro'
      VA bat RIENG dong Ubuntu cua ban  <- day la buoc hay quen nhat
      roi bam Apply & Restart"
    them_viec "Trong PowerShell:  wsl --shutdown
      Roi mo lai Ubuntu va chay lai script nay."
    tong_ket "CHANG 3" ""
    exit 1
fi

# ── 2. Daemon co phan hoi khong ────────────────────────────────────────
tieu "Docker co that su chay khong"
if timeout 25 docker info >/dev/null 2>&1; then
    PB=$(docker info --format '{{.ServerVersion}}' 2>/dev/null)
    o "Docker daemon" "phan hoi — server ${PB:-?}"
else
    x "Docker daemon" "CO LENH nhung KHONG phan hoi"
    echo ""
    echo "  ${DAM}Ba cau hoi, kiem theo dung thu tu:${HET}"
    echo ""
    echo "   1. Docker Desktop tren Windows ${DAM}dang mo${HET} chua?"
    echo "      Bieu tuong ca voi phai hien o khay he thong."
    echo ""
    echo "   2. Settings > Resources > WSL Integration da bat ${DAM}RIENG${HET}"
    echo "      dong Ubuntu chua? Bat moi cai mac dinh la ${DO}CHUA DU${HET}."
    echo ""
    echo "   3. Da chay ${DAM}wsl --shutdown${HET} trong PowerShell sau khi bat chua?"
    echo "      WSL phai nap lai thi cau noi moi co hieu luc."
    echo ""
    them_viec "Lam lan luot ba viec tren, roi chay lai script nay."
    tong_ket "CHANG 3" ""
    exit 1
fi

# ── 3. Chay thu mot container ──────────────────────────────────────────
tieu "Chay thu container"
echo "         (dang tai anh hello-world, doi mot lat...)"
if timeout 180 docker run --rm hello-world 2>/dev/null | grep -q "Hello from Docker"; then
    o "docker run hello-world" "thay dong 'Hello from Docker!'"
else
    x "docker run hello-world" "khong chay duoc"
    ghi "Daemon phan hoi nhung khong chay duoc container."
    ghi "Thuong la loi mang khi tai anh, hoac loi quyen."
    them_viec "Chay tay de xem thong bao day du:  docker run hello-world"
fi

# ── 4. Cac goi OpenLane can ────────────────────────────────────────────
tieu "Goi he thong ma OpenLane can"
THIEU=""
for g in python3-venv python3-pip python3-tk; do
    if dpkg -s "$g" >/dev/null 2>&1; then o "$g" "da cai"
    else x "$g" "chua cai"; THIEU="$THIEU $g"; fi
done
[ -n "$THIEU" ] && them_viec "Cai:  sudo apt install -y$THIEU"

tong_ket "CHANG 3" "bash cong_cu/04_kiem_tra_openlane.sh"
