# Zero Mission Expandido — app para Nintendo Switch (.nro)

App homebrew com nome e ícone próprios. Por dentro é o mGBA 0.10.5 com estas mudanças:

- Abre direto no jogo, sem navegador de arquivos. Ao sair do jogo, o app fecha.
- Procura a ROM em `romfs:/game.gba` (embutida no .nro) e depois em `/switch/zm-expandido/zm-expandido.gba`.
- Saves, estados e capturas ficam em `/switch/zm-expandido/`, sem mexer na configuração do mGBA, se você também usa o mGBA normal.
- Tela no modo "Aspect-Ratio Fit": a imagem do GBA ocupa a altura toda.
- ZL e ZR também funcionam como L e R.
- Não grava associação de arquivos no menu de homebrew (isso continua sendo do mGBA instalado).

## Controles

| Switch | GBA |
| --- | --- |
| Direcional ou analógico esquerdo | Direcional |
| A / B | A / B |
| L / R e ZL / ZR | L / R |
| + / − | Start / Select |
| X | Menu do emulador: estados, configurações, sair |

## Jeito mais fácil: compilar no GitHub (sem instalar nada)

1. Crie um repositório **privado** vazio no GitHub, por exemplo `zm-expandido-switch`.
2. Envie todos os arquivos desta pasta para ele, incluindo a pasta `.github` (na web: "Add file" > "Upload files").
3. Abra a aba **Actions**. A compilação começa sozinha e leva alguns minutos.
4. Quando terminar, abra a execução e baixe o artefato `zm-expandido-nro`. Ele também fica no branch `build-output`.

Não envie a ROM para o repositório.

## 1. Instalar o que precisa para compilar no computador (uma vez)

- **Git:** https://git-scm.com
- **Docker Desktop:** https://www.docker.com/products/docker-desktop. É o caminho mais simples, porque a imagem `devkitpro/devkita64` já vem com tudo para compilar homebrew de Switch.

Alternativa sem Docker: instalar o devkitPro (https://devkitpro.org/wiki/Getting_Started) com o grupo `switch-dev` e as bibliotecas que o mGBA usa (`switch-mesa`, `switch-libdrm_nouveau`, `switch-zlib`, `switch-libpng`). Depois rode o script com `USE_DOCKER=0`.

## 2. Compilar

Coloque esta pasta no seu computador e rode um dos scripts:

**Windows (PowerShell):**

```
.\compilar.ps1
```

**Linux, macOS ou WSL:**

```
chmod +x compilar.sh
./compilar.sh
```

A primeira vez demora: o Docker baixa a imagem do devkitPro (alguns GB) e o mGBA é compilado do zero. No fim aparece o arquivo `zm-expandido.nro`.

Para embutir a ROM no próprio .nro, passe o caminho dela: `.\compilar.ps1 C:\jogos\zm-expandido.gba`. Esse .nro contém o jogo, então é só para uso pessoal.

## 3. Copiar para o cartão SD

```
/switch/zm-expandido/zm-expandido.nro
/switch/zm-expandido/zm-expandido.gba   <- a ROM do hack (pule se embutiu)
```

A ROM é o arquivo `Zero Mission Expandido PT-BR v0.1.gba` (dentro do .zip), renomeado para `zm-expandido.gba`.

## 4. Jogar

Abra o menu de homebrew e escolha **Zero Mission Expandido**. Prefira abrir o menu de homebrew segurando R ao iniciar um jogo instalado (modo de memória cheia), em vez de usar o álbum. O mGBA funciona nos dois modos, mas o modo de memória cheia é mais estável.

Na lista de idiomas do jogo, desça até **Português**.

## Problemas comuns

- **"ROM nao encontrada"**: confira o nome `zm-expandido.gba` e a pasta `/switch/zm-expandido/`.
- **`git apply` falhou**: o script precisa do mGBA na versão 0.10.5. Apague a pasta `mgba` e rode de novo.
- **Erro no Docker**: confira se o Docker Desktop está aberto. No Windows, a pasta do projeto precisa estar num disco compartilhado com o Docker.

## Licenças

O mGBA é distribuído sob a MPL-2.0. As mudanças deste app estão em `zm-expandido-switch.patch`. O app não inclui o jogo.
