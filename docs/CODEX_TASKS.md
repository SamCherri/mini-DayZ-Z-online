# Tarefas para Codex

Este arquivo orienta o trabalho técnico no repositório.

## Contexto

Objetivo: criar um survival RP multiplayer para Android usando Godot/GDScript.

Base de referência técnica:

- https://github.com/011eh/minidayz

O projeto deve manter atribuição, licença e aviso de projeto de fã.

## Missão 1 — Preparar base Godot

1. Importar a base Godot de referência.
2. Manter os créditos e avisos de licença.
3. Confirmar a versão do Godot.
4. Identificar a cena principal.
5. Rodar a versão offline.
6. Registrar erros encontrados.

Critério de pronto:

- Projeto abre no Godot.
- Cena principal roda.
- Personagem aparece.
- Movimento básico funciona.

## Missão 2 — Multiplayer mínimo

Criar arquivos planejados:

```text
multiplayer/NetworkManager.gd
multiplayer/PlayerSync.gd
server/ServerMain.gd
```

Implementar:

- Fluxo para conectar ao servidor local.
- Spawn de dois jogadores.
- Sincronização de posição simples.
- Remoção do jogador ao desconectar.

Critério de pronto:

- Dois clientes entram.
- Cada cliente vê o outro jogador.
- Movimento básico é replicado.

## Missão 3 — Chat RP

Criar:

```text
gui/chat/ChatBox.tscn
gui/chat/ChatBox.gd
mechanics/rp/RPCommands.gd
```

Comandos planejados:

```text
/me
/do
/try
/ooc
/pm
/radio
```

Critério de pronto:

- Mensagens são enviadas.
- Mensagens aparecem para jogadores próximos.
- Comandos possuem formatação diferente.
- Existe limite simples contra spam.

## Missão 4 — Persistência

Criar:

```text
server/Persistence.gd
server/schema.sql
```

Salvar dados básicos:

- ID do personagem.
- Nome RP.
- Posição.
- Status.
- Inventário em JSON.

Critério de pronto:

- Jogador sai e volta mantendo estado básico.

## Missão 5 — Android

1. Configurar export Android.
2. Ajustar controles touch.
3. Criar build de teste.
4. Testar conexão com IP local.
5. Documentar problemas.

Critério de pronto:

- Build Android abre.
- Cliente conecta ao servidor.
- Player aparece no mapa.

## Regras

- Não remover avisos de projeto de fã.
- Não afirmar que o projeto é oficial.
- Preservar atribuição e licença.
- Fazer commits pequenos.
- Priorizar servidor autoritativo.
- Priorizar Godot/GDScript.
