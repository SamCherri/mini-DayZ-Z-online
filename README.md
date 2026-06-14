# Mini DayZ Z Online RP

Projeto de fã para criar uma versão **survival RP multiplayer para Android**, inspirada na estrutura técnica do projeto aberto [`011eh/minidayz`](https://github.com/011eh/minidayz).

> Este repositório não é oficial, não é afiliado, autorizado ou endossado pela Bohemia Interactive. A proposta é criar um projeto de fã/estudo com identidade própria, preservando créditos e licenças do material usado como referência.

## Objetivo

Transformar uma base Godot 2D survival em um jogo mobile com foco em:

- APK Android como cliente de um survival RP multiplayer online.
- Servidor dedicado online, separado dos clientes e executado continuamente.
- Sobrevivência zumbi em mapa aberto.
- Criação de personagem com nome/sobrenome.
- Sistema de fome, sede, doença, sangue e stamina.
- Inventário, loot, armas, roupas e crafting.
- Chat local/global e comandos RP.
- Facções, famílias, profissões e áreas seguras.
- Servidor autoritativo para reduzir trapaças.
- Persistência online de contas e personagens.
- Evolução progressiva de capacidade até a meta futura de 100 jogadores
  simultâneos.

O host local/ENet existente não representa o produto final. Ele é somente um
**smoke test técnico inicial** para validar conexão, desconexão e os primeiros
contratos de sincronização entre duas instâncias. A experiência final não
dependerá de um jogador hospedando uma sessão por LAN: os APKs Android se
conectarão pela internet a um servidor dedicado e autoritativo.

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
4. Usar o multiplayer local apenas para validar a fundação técnica.
5. Implementar o servidor dedicado online e autoritativo.
6. Adaptar sistemas para RP mobile e escalar a capacidade de forma medida.

## MVP inicial

Primeira versão jogável:

- Menu inicial.
- Tela de login em conta online.
- Criação de personagem.
- Entrada no servidor dedicado.
- Spawn de jogador.
- Sincronização básica de posição.
- Chat local.
- Zumbis básicos.
- Loot simples.
- Inventário básico.
- Exportação para Android.

O MVP online começa com poucos jogadores para permitir validação segura. A
capacidade será ampliada somente após testes de carga e correções de rede,
servidor e persistência, seguindo os marcos de **2, 10, 20, 50 e, como objetivo
futuro, 100 jogadores simultâneos**.

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
6. Criar login, personagem e persistência no servidor.
7. Implementar sincronização por área de interesse.
8. Testar progressivamente 2, 10, 20, 50 e 100 jogadores.
9. Testar exportação Android conectada ao servidor online.

Veja também:

- [`docs/ROADMAP.md`](docs/ROADMAP.md)
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)
- [`docs/ONLINE_SERVER_ARCHITECTURE.md`](docs/ONLINE_SERVER_ARCHITECTURE.md)
- [`docs/DEDICATED_SERVER_DEPLOYMENT.md`](docs/DEDICATED_SERVER_DEPLOYMENT.md)
- [`docs/CODEX_TASKS.md`](docs/CODEX_TASKS.md)
- [`ATTRIBUTION.md`](ATTRIBUTION.md)

## Status

A base Godot pública já foi importada, e `world.tscn` já está configurada como
cena principal do projeto. A fundação multiplayer ENet local também já foi
adicionada para conexão host/client, sinais de sessão e sincronização inicial.
Essa fundação continua sendo somente um smoke test técnico, não o servidor do
produto final.

Um pacote Construct/Cordova de procedência incompatível foi descartado e não
foi usado como fonte. O histórico dessa validação está registrado em
[`docs/IMPORT_VALIDATION.md`](docs/IMPORT_VALIDATION.md).

A estrutura headless e os protocolos temporários de sessão, personagem,
spawn/despawn e movimento autorizado pelo servidor dedicado já foram
adicionados. O próximo passo é validar esse fluxo com dois clientes reais e
continuar a separação do servidor online, sem transformar o host local em
arquitetura de produção.
