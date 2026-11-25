#!/usr/bin/env bash
# Compila o app "Zero Mission Expandido" (.nro) para Nintendo Switch.
#
# Uso:
#   ./compilar.sh                  -> app sem ROM embutida (procura a ROM no cartão SD)
#   ./compilar.sh caminho/rom.gba  -> app com a ROM embutida (não compartilhe esse .nro)
#
# Requer Docker (usa a imagem oficial devkitpro/devkita64) ou, com USE_DOCKER=0,
# um devkitPro instalado com a variável DEVKITPRO configurada.
set -euo pipefail

AQUI="$(cd "$(dirname "$0")" && pwd)"
ROM="${1:-}"
MGBA_TAG="0.10.5"

cd "$AQUI"
if [ ! -d mgba ]; then
  echo "== Baixando o mGBA $MGBA_TAG"
  git clone --depth 1 --branch "$MGBA_TAG" https://github.com/mgba-emu/mgba.git mgba
fi

cd mgba
echo "== Aplicando as mudanças do app"
git checkout -- .
rm -f src/platform/switch/copy_if_exists.cmake
git apply "$AQUI/zm-expandido-switch.patch"
cp "$AQUI/icon.jpg" src/platform/switch/icon.jpg

rm -rf res/zm
if [ -n "$ROM" ]; then
  echo "== Embutindo a ROM: $ROM"
  mkdir -p res/zm
  cp "$ROM" res/zm/game.gba
fi

rm -rf build-switch
CMAKE_CMD='mkdir -p build-switch && cd build-switch && \
  cmake -DCMAKE_TOOLCHAIN_FILE=../src/platform/switch/CMakeToolchain.txt \
        -DCMAKE_BUILD_TYPE=Release .. && \
  make -j"$(nproc)"'

if [ "${USE_DOCKER:-1}" = "1" ]; then
  echo "== Compilando no Docker (devkitpro/devkita64)"
  docker run --rm -v "$PWD":/src -w /src devkitpro/devkita64 bash -c "$CMAKE_CMD"
else
  echo "== Compilando com o devkitPro instalado"
  : "${DEVKITPRO:?Configure a variável DEVKITPRO (ex.: /opt/devkitpro)}"
  bash -c "$CMAKE_CMD"
fi

NRO="$(find build-switch -name 'mgba.nro' | head -n1)"
if [ -z "$NRO" ]; then
  echo "ERRO: o .nro não foi gerado. Veja as mensagens acima." >&2
  exit 1
fi
cp "$NRO" "$AQUI/zm-expandido.nro"
echo
echo "Pronto: $AQUI/zm-expandido.nro"
echo "Copie para o cartão SD em /switch/zm-expandido/"
