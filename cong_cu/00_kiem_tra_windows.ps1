<#
================================================================
  00_kiem_tra_windows.ps1
  KIEM TRA MAY WINDOWS TRUOC KHI CAI BAT KY THU GI

  Chay trong PowerShell (khong phai Ubuntu):

      powershell -ExecutionPolicy Bypass -File .\cong_cu\00_kiem_tra_windows.ps1

  Script nay CHI DOC. Khong cai gi, khong sua gi, khong xoa gi,
  khong gui gi di dau. Chay bao nhieu lan cung duoc.
================================================================
#>

$ErrorActionPreference = 'Continue'

# WSL in ra kieu UTF-16 tren nhieu ban Windows. Khong dat hai dong duoi
# thi ket qua se hien ra kieu "W.S.L. .v.e.r.s.i.o.n" - roi mat.
$env:WSL_UTF8 = '1'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch { }

$script:Dat  = 0
$script:Hong = 0
$script:Canh = 0
$script:Viec = New-Object System.Collections.ArrayList

function Muc-OK   { param($t, $g) Write-Host "  [ OK ]  " -NoNewline -ForegroundColor Green
                    Write-Host ("{0,-30} {1}" -f $t, $g); $script:Dat++ }
function Muc-Hong { param($t, $g) Write-Host "  [HONG]  " -NoNewline -ForegroundColor Red
                    Write-Host ("{0,-30} {1}" -f $t, $g); $script:Hong++ }
function Muc-Canh { param($t, $g) Write-Host "  [ !! ]  " -NoNewline -ForegroundColor Yellow
                    Write-Host ("{0,-30} {1}" -f $t, $g); $script:Canh++ }
function Ghi      { param($t)     Write-Host ("         {0}" -f $t) -ForegroundColor DarkGray }
function Tieu     { param($t)     Write-Host ""
                    Write-Host ("  -- {0} --" -f $t) -ForegroundColor Cyan }
function Them-Viec{ param($t)     [void]$script:Viec.Add($t) }

Write-Host ""
Write-Host "  ==============================================================" -ForegroundColor Cyan
Write-Host "   CHANG 0 - KIEM TRA MAY WINDOWS" -ForegroundColor Cyan
Write-Host "   Chay TRUOC khi cai bat ky thu gi" -ForegroundColor Cyan
Write-Host "  ==============================================================" -ForegroundColor Cyan

# Script nay chi co nghia tren Windows. Chay o cho khac se ra so lieu vo nghia.
if ([Environment]::OSVersion.Platform -ne 'Win32NT') {
    Write-Host ""
    Write-Host "  DUNG LAI: day khong phai Windows." -ForegroundColor Red
    Write-Host ("  He dieu hanh phat hien duoc: {0}" -f [Environment]::OSVersion.Platform)
    Write-Host ""
    Write-Host "  File .ps1 nay chi de chay trong PowerShell TREN WINDOWS."
    Write-Host "  Neu ban dang o trong cua so Ubuntu cua WSL thi hay chay:"
    Write-Host ""
    Write-Host "      bash cong_cu/01_kiem_tra_wsl.sh"
    Write-Host ""
    exit 2
}

# ---------------------------------------------------------------- 1
Tieu "Phien ban Windows"

$os = $null
try { $os = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop } catch { }
$build = [int][Environment]::OSVersion.Version.Build

if ($os) { Write-Host ("         {0}" -f $os.Caption) -ForegroundColor DarkGray }

if ($build -ge 22000) {
    Muc-OK "Phien ban Windows" ("Windows 11 (build {0})" -f $build)
} elseif ($build -ge 19041) {
    Muc-OK "Phien ban Windows" ("Windows 10 build {0} - du dieu kien" -f $build)
} elseif ($build -gt 0) {
    Muc-Hong "Phien ban Windows" ("build {0} - QUA CU" -f $build)
    Ghi "WSL2 can Windows 10 build 19041 (ban 2004, thang 5/2020) tro len."
    Ghi "Build cua ban thap hon moc do."
    Them-Viec "Cap nhat Windows: Settings > Windows Update > Check for updates."
} else {
    Muc-Canh "Phien ban Windows" "khong doc duoc"
}

# ---------------------------------------------------------------- 2
Tieu "Kien truc CPU"

$kt = $env:PROCESSOR_ARCHITECTURE
if ([string]::IsNullOrWhiteSpace($kt)) {
    Muc-Canh "Kien truc" "khong doc duoc bien PROCESSOR_ARCHITECTURE"
} elseif ($kt -eq 'AMD64') {
    Muc-OK "Kien truc" "x64 - phu hop cho lo trinh bat buoc"
} elseif ($kt -eq 'ARM64') {
    Muc-Canh "Kien truc" "ARM64 - lo trinh local P&R khong duoc xac nhan"
    Ghi "B2 chinh thuc chay tren GitHub Actions, nen khong bi chan boi kien truc may."
    Ghi "Phan Docker/OpenLane local la TU CHON va co the khong tuong thich tren ARM64."
} else {
    Muc-Canh "Kien truc" ("{0} - la" -f $kt)
}

# ---------------------------------------------------------------- 3
Tieu "Ao hoa (virtualization)"

$cs = $null
try { $cs = Get-CimInstance Win32_ComputerSystem -ErrorAction Stop } catch { }

$hvChay = $false
if ($cs -and $cs.HypervisorPresent) { $hvChay = $true }

if ($hvChay) {
    Muc-OK "Ao hoa" "dang bat va dang chay"
} else {
    $fw = $null
    try {
        $fw = (Get-CimInstance Win32_Processor -ErrorAction Stop |
               Select-Object -First 1).VirtualizationFirmwareEnabled
    } catch { }

    if ($fw -eq $false) {
        Muc-Hong "Ao hoa" "TAT trong BIOS/UEFI"
        Ghi "Day la nguyen nhan so 1 khien 'wsl --install' that bai."
        Ghi "Bat lai: khoi dong lai may, vao BIOS/UEFI (thuong bam F2, F10,"
        Ghi "DEL hoac ESC luc vua bat may), tim muc ten la mot trong so:"
        Ghi "   Intel VT-x / Intel Virtualization Technology"
        Ghi "   AMD-V / SVM Mode"
        Ghi "chuyen sang Enabled, luu lai roi khoi dong lai."
        Them-Viec "Bat Intel VT-x hoac AMD-V (SVM) trong BIOS/UEFI."
    } else {
        Muc-Canh "Ao hoa" "chua co hypervisor nao chay"
        Ghi "Dieu nay BINH THUONG neu ban chua bat tinh nang WSL."
        Ghi "Sau khi bat va khoi dong lai, chay lai script nay de kiem."
    }
}

# ---------------------------------------------------------------- 4
Tieu "Tinh nang Windows can bat"

function Trang-Thai-Tinh-Nang {
    param($ten)
    try {
        $f = Get-CimInstance -ClassName Win32_OptionalFeature `
             -Filter ("Name='{0}'" -f $ten) -ErrorAction Stop
        if ($null -eq $f) { return 'khong-thay' }
        if ($f.InstallState -eq 1) { return 'bat' }
        return 'tat'
    } catch { return 'khong-doc-duoc' }
}

$dsTinhNang = @(
    @{ Ten = 'Microsoft-Windows-Subsystem-Linux'; Mo = 'Windows Subsystem for Linux' },
    @{ Ten = 'VirtualMachinePlatform';            Mo = 'Virtual Machine Platform' }
)

foreach ($tn in $dsTinhNang) {
    $tt = Trang-Thai-Tinh-Nang $tn.Ten
    switch ($tt) {
        'bat'  { Muc-OK   $tn.Mo "da bat" }
        'tat'  {
            Muc-Hong $tn.Mo "CHUA bat"
            Them-Viec ("Bat tinh nang '{0}'. Lenh o cuoi bao cao nay." -f $tn.Mo)
        }
        default { Muc-Canh $tn.Mo ("khong xac dinh duoc ({0})" -f $tt) }
    }
}

# ---------------------------------------------------------------- 5
Tieu "WSL"

$coWsl = $null -ne (Get-Command wsl.exe -ErrorAction SilentlyContinue)

if (-not $coWsl) {
    Muc-Hong "Lenh wsl" "khong tim thay wsl.exe"
    Them-Viec "Cai WSL: mo PowerShell voi quyen Administrator roi go 'wsl --install'."
} else {
    $tt = ''
    $global:LASTEXITCODE = 0
    try { $tt = (& wsl.exe --status 2>&1 | Out-String) } catch { }
    $tt = $tt -replace "`0", ''
    $maThoat = $LASTEXITCODE

    # Windows 10/11 co san mot wsl.exe "vo" trong System32 ke ca khi CHUA cai WSL.
    # Vay nen "co lenh wsl" chua chung minh duoc gi - phai xem no co tra loi khong.
    if ($maThoat -ne 0 -or $tt -match 'not installed|khong duoc cai') {
        Muc-Hong "Lenh wsl" "co file wsl.exe nhung WSL CHUA duoc cai that"
        Ghi "Windows co san file wsl.exe ke ca khi chua cai WSL, nen viec"
        Ghi "'go wsl thay co phan hoi' khong chung minh duoc dieu gi."
        Ghi "Thong bao that:"
        foreach ($d in @($tt -split "`r?`n" | Where-Object { $_ -match '\S' } |
                         Select-Object -First 4)) { Ghi ("   " + $d.Trim()) }
        Them-Viec "Cai WSL: mo PowerShell voi quyen Administrator roi go 'wsl --install'."
    } else {
        Muc-OK "Lenh wsl" "co va phan hoi binh thuong"
    }

    if ($tt -match 'Default Version:\s*(\d)') {
        if ($Matches[1] -eq '2') {
            Muc-OK "Phien ban WSL mac dinh" "2"
        } else {
            Muc-Hong "Phien ban WSL mac dinh" ("{0} - phai la 2" -f $Matches[1])
            Them-Viec "Chuyen mac dinh sang WSL2:  wsl --set-default-version 2"
        }
    }

    $pb = ''
    try { $pb = (& wsl.exe --version 2>&1 | Out-String) -replace "`0", '' } catch { }
    if ($pb -match 'WSL version:\s*([0-9][0-9.]*)') {
        Muc-OK "Phien ban WSL" $Matches[1]
    } elseif ($tt.Trim().Length -gt 0) {
        Muc-Canh "Phien ban WSL" "ban WSL cu (kieu tich hop san trong Windows)"
        Ghi "Van chay duoc. Neu muon ban moi: wsl --update"
    }

    # Danh sach ban phan phoi da cai
    $ds = ''
    try { $ds = (& wsl.exe --list --verbose 2>&1 | Out-String) -replace "`0", '' } catch { }
    $dong = @($ds -split "`r?`n" | Where-Object { $_ -match '\S' })

    $coUbuntu = $false
    $ubuntuV1 = $false
    foreach ($d in $dong) {
        if ($d -match 'Ubuntu') {
            $coUbuntu = $true
            if ($d -match '\s1\s*$') { $ubuntuV1 = $true }
        }
    }

    if ($coUbuntu) {
        if ($ubuntuV1) {
            Muc-Hong "Ban phan phoi Ubuntu" "dang chay o WSL phien ban 1"
            Ghi "WSL1 khong chay duoc Docker. Phai chuyen sang WSL2."
            Them-Viec "Chuyen sang WSL2:  wsl --set-version Ubuntu 2   (mat vai phut)"
        } else {
            Muc-OK "Ban phan phoi Ubuntu" "da cai, dang o WSL2"
        }
        Ghi "Danh sach day du:"
        foreach ($d in $dong) { Ghi ("   " + $d.Trim()) }
    } else {
        Muc-Hong "Ban phan phoi Ubuntu" "chua cai"
        Them-Viec "Cai Ubuntu:  wsl --install -d Ubuntu-24.04"
    }
}

# ---------------------------------------------------------------- 6
Tieu "Tai nguyen may"

if ($cs) {
    $ramGB = [math]::Round($cs.TotalPhysicalMemory / 1GB, 1)
    if ($ramGB -ge 8)     { Muc-OK   "RAM" ("{0} GB - du cho lo trinh bat buoc" -f $ramGB) }
    elseif ($ramGB -ge 4) { Muc-Canh "RAM" ("{0} GB - co the cham; B2 chinh thuc van chay tren GitHub" -f $ramGB) }
    else {
        Muc-Hong "RAM" ("{0} GB - qua thap cho WSL/lab local" -f $ramGB)
        Them-Viec "Dung may khac cho Lab0 local; B2 chinh thuc van co the chay tren GitHub Actions."
    }
} else {
    Muc-Canh "RAM" "khong doc duoc"
}

$oC = $null
try { $oC = Get-PSDrive -Name C -ErrorAction Stop } catch { }
if ($oC) {
    $trongGB = [math]::Round($oC.Free / 1GB, 1)
    if ($trongGB -ge 60)     { Muc-OK   "Dia C: con trong" ("{0} GB" -f $trongGB) }
    elseif ($trongGB -ge 30) { Muc-Canh "Dia C: con trong" ("{0} GB - hoi chat" -f $trongGB) }
    else {
        Muc-Hong "Dia C: con trong" ("{0} GB - khong du" -f $trongGB)
        Ghi "Rieng anh Docker cua OpenLane + PDK da khoang 25-30 GB,"
        Ghi "chua ke ban phan phoi Ubuntu va cac lan chay."
        Them-Viec "Giai phong it nhat 60 GB tren o C:."
    }
} else {
    Muc-Canh "Dia C: con trong" "khong doc duoc o C:"
}

$soNhan = [int]$env:NUMBER_OF_PROCESSORS
if ($soNhan -ge 4)      { Muc-OK   "So nhan CPU" $soNhan }
elseif ($soNhan -ge 2)  { Muc-Canh "So nhan CPU" ("{0} - chay duoc nhung cham" -f $soNhan) }
else                    { Muc-Canh "So nhan CPU" $soNhan }

# ---------------------------------------------------------------- 7
Tieu "Docker Desktop"

$coDocker = $null -ne (Get-Command docker -ErrorAction SilentlyContinue)
$ddChay   = $null -ne (Get-Process -Name 'Docker Desktop' -ErrorAction SilentlyContinue)

if (-not $coDocker) {
    Muc-Canh "Docker Desktop" "chua cai"
    Ghi "Chua can o buoc nay. Chi can khi ban toi phan chay OpenLane."
} else {
    $v = ''
    try { $v = (& docker --version 2>&1 | Out-String).Trim() } catch { }
    Muc-OK "Lenh docker" $v

    if ($ddChay) {
        Muc-OK "Tien trinh Docker Desktop" "dang chay"
    } else {
        Muc-Canh "Tien trinh Docker Desktop" "khong chay (chi anh huong nhanh P&R local tu chon)"
        Ghi "Da cai nhung chua mo. Trong WSL, moi lenh docker se treo"
        Ghi "roi bao 'cannot connect to the Docker daemon'."
        Them-Viec "Mo Docker Desktop tu Start Menu, doi den khi bieu tuong ca voi het nhap nhay."
    }
}

# ---------------------------------------------------------------- 8
Tieu "Vai tro va duong dan"

$quanTri = $false
try {
    $quanTri = ([Security.Principal.WindowsPrincipal] `
                [Security.Principal.WindowsIdentity]::GetCurrent()
               ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
} catch { }

if ($quanTri) {
    Muc-OK "Cua so PowerShell nay" "co quyen Administrator"
} else {
    Muc-Canh "Cua so PowerShell nay" "KHONG co quyen Administrator"
    Ghi "Doc kiem tra thi khong can. Nhung cac lenh CAI DAT (wsl --install,"
    Ghi "bat tinh nang Windows) thi BAT BUOC phai co."
    Ghi "Mo lai: bam phai vao Start > Terminal (Admin) hoac PowerShell (Admin)."
}

if ([string]::IsNullOrWhiteSpace($env:USERPROFILE)) {
    Muc-Canh "Thu muc nguoi dung" "khong doc duoc bien USERPROFILE"
} elseif ($env:USERPROFILE -match 'OneDrive') {
    Muc-Canh "Thu muc nguoi dung" "nam trong OneDrive"
    Ghi $env:USERPROFILE
    Ghi "OneDrive dong bo lien tuc se lam cham va doi khi khoa file."
    Ghi "Dat thu muc du an ngoai OneDrive, vi du C:\rtl2gds."
} else {
    Muc-OK "Thu muc nguoi dung" $env:USERPROFILE
}

$noiChay = (Get-Location).Path
if ($noiChay -match '[^\x20-\x7E]') {
    Muc-Canh "Duong dan hien tai" "co dau tieng Viet hoac ky tu la"
    Ghi $noiChay
    Ghi "Mot so cong cu dong lenh xu ly sai duong dan co dau."
    Them-Viec "Chuyen bo bai vao duong dan khong dau, vi du C:\rtl2gds."
} else {
    Muc-OK "Duong dan hien tai" "khong co ky tu la"
}

# ---------------------------------------------------------------- Tong ket
Write-Host ""
Write-Host "  ==============================================================" -ForegroundColor Cyan
Write-Host "   Dat: " -NoNewline; Write-Host $script:Dat -NoNewline -ForegroundColor Green
Write-Host "      Canh bao: " -NoNewline; Write-Host $script:Canh -NoNewline -ForegroundColor Yellow
Write-Host "      Hong: " -NoNewline; Write-Host $script:Hong -ForegroundColor Red
Write-Host "  ==============================================================" -ForegroundColor Cyan
Write-Host ""

if ($script:Hong -eq 0) {
    Write-Host "  CHANG 0: DAT." -ForegroundColor Green
    Write-Host ""
    Write-Host "  Buoc ke tiep - mo cua so Ubuntu roi chay:"
    Write-Host ""
    Write-Host "      bash cong_cu/01_kiem_tra_wsl.sh"
} else {
    Write-Host ("  CHANG 0: CHUA DAT - con {0} muc hong." -f $script:Hong) -ForegroundColor Red
    Write-Host ""
    Write-Host "  DUNG LAI O DAY. Dung di tiep khi con muc [HONG]."
    Write-Host "  Moi buoc deu dua tren buoc truoc; bo qua se lam loi ve sau"
    Write-Host "  kho gap boi vi khong biet no thuoc tang nao."
}

if ($script:Viec.Count -gt 0) {
    Write-Host ""
    Write-Host "  Viec can lam:"
    Write-Host ""
    for ($i = 0; $i -lt $script:Viec.Count; $i++) {
        Write-Host ("   {0}. {1}" -f ($i + 1), $script:Viec[$i])
    }
}

if ($script:Hong -gt 0) {
    Write-Host ""
    Write-Host "  -- LENH BAT TINH NANG WINDOWS (can quyen Administrator) --"
    Write-Host ""
    Write-Host "      dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart"
    Write-Host "      dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart"
    Write-Host ""
    Write-Host "  Sau do KHOI DONG LAI MAY, roi chay lai script nay."
    Write-Host "  Tren Windows 10/11 doi moi, mot lenh 'wsl --install' la du thay"
    Write-Host "  ca hai lenh tren - no bat tinh nang, cai WSL2 va cai Ubuntu."
}

Write-Host ""
Write-Host "  Bi tac? Chup man hinh nay gui giang vien, hoac chay trong Ubuntu:"
Write-Host ""
Write-Host "      bash cong_cu/bao_cao_su_co.sh"
Write-Host ""
