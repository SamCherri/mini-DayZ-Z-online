# Mini DayZ Z Online RP

Projeto de fã para criar uma versão **survival RP multiplayer para Android**, inspirada na estrutura técnica do projeto aberto [`011eh/minidayz`](https://github.com/011eh/minidayz).

> Este repositório não é oficial, não é afiliado, autorizado ou endossado pela Bohemia Interactive. A proposta é criar um projeto de fã/estudo com identidade própria, preservando créditos e licenças do material usado como referência.

## Objetivo

Transformar uma base Godot 2D survival em um jogo mobile com foco em:

- RP multiplayer online.
- Sobrevivência zumbi em mapa aberto.
- Criação de personagem com nome/sobrenome.
- Sistema de fome, sede, doença, sangue e stamina.
- Inventário, loot, armas, roupas e crafting.
- Chat local/global e comandos RP.
- Facções, famílias, profissões e áreas seguras.
- Servidor autoritativo para reduzir trapaças.
- Exportação Android/APK.

## Base técnica escolhida

Base de referência: [`011eh/minidayz`](https://github.com/011eh/minidayz)

Características relevantes da base:

- Engine: Godot.
- Linguagem: GDScript.
- Licença: Apache-2.0.
- Estrutura separada por módulos como personagem, itens, ambiente, mecânicas, status e interface.

## Direção do projeto

Este projeto deve seguir uma rota segura:

1. Usar a base técnica aberta como referência/derivação permitida pela licença.
2. Preservar atribuição ao projeto original.
3. Trocar nome, identidade visual, imagens, sons e marcas antes de qualquer publicação pública.
4. Implementar multiplayer com arquitetura cliente-servidor.
5. Adaptar sistemas para RP mobile.

## MVP inicial

Primeira versão jogável:

- Menu inicial.
- Tela de nome e senha/conta local.
- Criação de personagem.
- Entrada em servidor.
- Spawn de jogador.
- Sincronização básica de posição.
- Chat local.
- Zumbis básicos.
- Loot simples.
- Inventário básico.
- Exportação para Android.

## Estrutura planejada

```text
addons/                 Plugins Godot opcionais
asset/                  Artes e recursos do projeto
character/              Jogador, NPCs e zumbis
docs/                   Planejamento, arquitetura e tarefas Codex
environment/            Mundo, mapa, clima e objetos
gui/                    Interface mobile e HUD
item/                   Itens, armas, roupas, comida e loot
mechanics/              Sistemas principais de jogo
multiplayer/            Rede, servidor, sincronização e RPCs
server/                 Scripts/estrutura do servidor dedicado
status/                 Fome, sede, sangue, doença e stamina
test/                   Testes e cenas de validação
```

## Como o Codex deve trabalhar neste repositório

Prioridade para o Codex:

1. Importar/organizar a base Godot.
2. Criar branch para multiplayer.
3. Mapear cenas e scripts principais.
4. Implementar camada de rede mínima.
5. Criar servidor dedicado/headless.
6. Criar login simples e spawn multiplayer.
7. Testar exportação Android.

Veja também:

- [`docs/ROADMAP.md`](docs/ROADMAP.md)
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)
- [`docs/CODEX_TASKS.md`](docs/CODEX_TASKS.md)
- [`ATTRIBUTION.md`](ATTRIBUTION.md)

## Status

Repositório inicializado para planejamento e preparação da versão RP
multiplayer. A auditoria preliminar confirmou que a referência pública declara
Godot 4.6 e contém a cena `world.tscn`, mas a importação está bloqueada por
HTTP 403 no ambiente atual.

Um pacote Construct/Cordova de procedência incompatível foi descartado e não
foi usado como fonte. Consulte
[`docs/IMPORT_VALIDATION.md`](docs/IMPORT_VALIDATION.md) para ver os testes,
bloqueios e o procedimento seguro de continuação.

Próximo passo: importar a árvore pública Godot em um ambiente com acesso ao
GitHub, validar a execução offline e somente depois iniciar o multiplayer.
