# Compila o app "Zero Mission Expandido" (.nro) no Windows, usando o Docker Desktop.
#
# Uso (PowerShell, na pasta deste arquivo):
#   .\compilar.ps1                        -> app sem ROM embutida (procura a ROM no cartão SD)
#   .\compilar.ps1 C:\caminho\rom.gba     -> app com a ROM embutida (não compartilhe esse .nro)
param([string]$Rom = "")
$ErrorActionPreference = "Stop"

$Aqui = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $Aqui

if (-not (Test-Path "mgba")) {
    Write-Host "== Baixando o mGBA 0.10.5"
    git clone --depth 1 --branch 0.10.5 https://github.com/mgba-emu/mgba.git mgba
}

Set-Location mgba
Write-Host "== Aplicando as mudanças do app"
git checkout -- .
Remove-Item -Force -ErrorAction SilentlyContinue src\platform\switch\copy_if_exists.cmake
git apply --ignore-whitespace "$Aqui\zm-expandido-switch.patch"
Copy-Item "$Aqui\icon.jpg" src\platform\switch\icon.jpg -Force

Remove-Item -Recurse -Force -ErrorAction SilentlyContinue res\zm
if ($Rom -ne "") {
    Write-Host "== Embutindo a ROM: $Rom"
    New-Item -ItemType Directory -Force res\zm | Out-Null
    Copy-Item $Rom res\zm\game.gba
}

Remove-Item -Recurse -Force -ErrorAction SilentlyContinue build-switch
Write-Host "== Compilando no Docker (devkitpro/devkita64)"
docker run --rm -v "${PWD}:/src" -w /src devkitpro/devkita64 bash -c `
  'mkdir -p build-switch && cd build-switch && cmake -DCMAKE_TOOLCHAIN_FILE=../src/platform/switch/CMakeToolchain.txt -DCMAKE_BUILD_TYPE=Release .. && make -j$(nproc)'

$Nro = Get-ChildItem -Recurse build-switch -Filter mgba.nro | Select-Object -First 1
if (-not $Nro) { throw "O .nro não foi gerado. Veja as mensagens acima." }
Copy-Item $Nro.FullName "$Aqui\zm-expandido.nro" -Force
Write-Host ""
Write-Host "Pronto: $Aqui\zm-expandido.nro"
Write-Host "Copie para o cartão SD em /switch/zm-expandido/"
