param(
    [int]$Port = 51234,
    [ValidateSet('debug', 'release')]
    [string]$Profile = 'release',
    [string]$Distro = $env:MAELSTROM_WSL_DISTRO,
    [switch]$NoBuild,
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

function Normalize-WslText {
    param(
        [AllowEmptyString()]
        [string]$Text = ''
    )

    $normalized = $Text -replace "\u0000", ''
    $normalized = $normalized -replace "\uFEFF", ''
    $normalized = $normalized -replace "[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]", ''
    $normalized
}

function Invoke-Wsl {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Args
    )

    $output = & wsl.exe @Args 2>&1
    $exitCode = $LASTEXITCODE

    $combined = ($output | ForEach-Object { $_.ToString() }) -join "`n"
    $text = Normalize-WslText -Text ($combined.Trim())
    if ($exitCode -ne 0) {
        $argsText = ($Args | ForEach-Object { if ($_ -match '\\s') { '"' + $_ + '"' } else { $_ } }) -join ' '
        if ($text) {
            throw "WSL call failed (exit=$exitCode): wsl.exe $argsText`n$text"
        }
        throw "WSL call failed (exit=$exitCode): wsl.exe $argsText"
    }

    $text
}

$repoWin = (Resolve-Path -LiteralPath $PSScriptRoot).Path
$repoWinForWslPath = $repoWin -replace '\\', '/'

try {
    $distrosText = Invoke-Wsl -Args @('--list', '--quiet')
} catch {
    throw "WSL is required. Install it and a Linux distro (e.g., Ubuntu).`nExample: wsl --install -d Ubuntu`n$($_.Exception.Message)"
}
$distros = $distrosText -split "(?:\r\n|\n)" |
    ForEach-Object { (Normalize-WslText -Text $_).Trim() } |
    Where-Object { $_.Length -gt 0 }

$unsupportedDistros = @('docker-desktop', 'docker-desktop-data')
$usableDistros = $distros |
    Where-Object { $unsupportedDistros -notcontains $_ }

if ($Distro -and $Distro.Trim().Length -gt 0) {
    $Distro = $Distro.Trim()
    if ($unsupportedDistros -contains $Distro) {
        throw "WSL distro '$Distro' is not suitable. Install/select a normal distro (e.g., Ubuntu)."
    }
    if (-not ($distros -contains $Distro)) {
        $distrosPretty = if ($distros.Count -gt 0) { $distros -join ', ' } else { '(none)' }
        throw "WSL distro not found: $Distro`nAvailable: $distrosPretty"
    }
} else {
    $Distro = $usableDistros | Select-Object -First 1
    if (-not $Distro) {
        $distrosPretty = if ($distros.Count -gt 0) { $distros -join ', ' } else { '(none)' }
        throw "A normal WSL Linux distro is required (e.g., Ubuntu). Found: $distrosPretty`nInstall example: wsl --install -d Ubuntu"
    }
}

$repoWsl = (Invoke-Wsl -Args @('-d', $Distro, '--', 'wslpath', '-a', '-u', $repoWinForWslPath)).Trim()
if (-not $repoWsl) {
    throw "WSL path conversion failed: $repoWin"
}

$cargoBuildArgs = @('cargo', 'build', '--bin', 'maelstrom-broker', '--bin', 'maelstrom-worker')
$targetProfileDir = 'debug'
if ($Profile -eq 'release') {
    $cargoBuildArgs += '--release'
    $targetProfileDir = 'release'
}

$cargoBuild = ($cargoBuildArgs -join ' ')
$buildCmd = "set -euo pipefail; cd '$repoWsl'; $cargoBuild"

$brokerAddr = "[::1]:$Port"

$brokerCmd = "set -euo pipefail; cd '$repoWsl'; exec ./target/$targetProfileDir/maelstrom-broker -p $Port"
$workerCmd = "set -euo pipefail; cd '$repoWsl'; exec ./target/$targetProfileDir/maelstrom-worker --broker '$brokerAddr'"
if ($DryRun) {
    Write-Output $buildCmd
    Write-Output $brokerCmd
    Write-Output $workerCmd
    return
}

if (-not $NoBuild) {
    Invoke-Wsl -Args @('-d', $Distro, '--', 'bash', '-lc', $buildCmd) | Out-Null
}

Start-Process -FilePath 'wsl.exe' -ArgumentList @('-d', $Distro, '--', 'bash', '-lc', $brokerCmd)

Start-Sleep -Seconds 1

Start-Process -FilePath 'wsl.exe' -ArgumentList @('-d', $Distro, '--', 'bash', '-lc', $workerCmd)

Write-Output "broker: $brokerAddr"
