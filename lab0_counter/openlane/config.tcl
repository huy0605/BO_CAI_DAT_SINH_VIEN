# ═════════════════════════════════════════════════════════════════════════
#  config.tcl — Cau hinh OPENLANE 1 cho lab0
#
#  Cach dung:
#      cd ~/OpenLane
#      mkdir -p designs/counter_4bit/src
#      cp ~/lab0_counter/rtl/counter_4bit.v        designs/counter_4bit/src/
#      cp ~/lab0_counter/openlane/config.tcl       designs/counter_4bit/
#      make mount
#      ./flow.tcl -design counter_4bit
# ═════════════════════════════════════════════════════════════════════════

# ── Bat buoc ────────────────────────────────────────────────────────────
set ::env(DESIGN_NAME) counter_4bit
#   PHAI trung TEN MODULE trong file Verilog. Sai la loi
#   "Top module mismatch".

set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/counter_4bit.v]
#   DESIGN_DIR la bien OpenLane tu dat = thu muc chua file config nay.

set ::env(CLOCK_PORT)   "clk"
#   PHAI trung TEN CHAN nhip trong Verilog. Sai la loi
#   "Clock port not found".

set ::env(CLOCK_PERIOD) "10"
#   Don vi nano giay. 10 ns = 100 MHz.
#   Day la RANG BUOC BAN DAT RA, khong phai ket qua do duoc.

# ── Mat bang ────────────────────────────────────────────────────────────
set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 100 100"
#   Vung layout 100 x 100 micromet. Du rong rai cho 10 o chuan.
#   Neu dinh tuyen that bai vi thieu cho: tang len "0 0 150 150".

set ::env(PL_TARGET_DENSITY) 0.45
#   Mat do sap xep muc tieu, dang PHAN SO (0..1).
#
#   CHU Y: LibreLane doi ten thanh PL_TARGET_DENSITY_PCT va dung dang
#   PHAN TRAM. Cung y nghia nhung 0.45 o day = 45 ben kia.
