# Protocolo inicial de movimento autorizado pelo servidor

## Objetivo

Esta etapa adiciona movimento básico ao avatar temporário
`multiplayer/simple_avatar.tscn`, sem usar o personagem final
`character/player/player.tscn`.

O contrato compartilhado fica em `multiplayer/MovementProtocol.gd`, registrado
como autoload no mesmo caminho no cliente e no servidor dedicado.

## Fluxo autoritativo

1. O cliente lê a direção local e envia somente a intenção por
   `submit_movement_input`.
2. O RPC não recebe um `peer_id` escolhido pelo cliente. O servidor identifica
   o jogador com `multiplayer.get_remote_sender_id()`.
3. Direções não finitas são rejeitadas e direções com comprimento maior que
   um são normalizadas.
4. `server/ServerMain.gd` procura o peer conectado, calcula a nova posição com
   uma velocidade e passo temporários seguros e atualiza `connected_peers`.
5. O servidor envia `movement_snapshot(peer_id, position)` a todos os clientes.
6. No cliente, o protocolo converte o snapshot em sinal local. O
   `WorldSpawner` encaminha o estado ao `SimpleAvatar` correto, e o
   `PlayerSync` interpola a representação visual.

Assim, no modo dedicado, o cliente não escolhe nem replica diretamente a
posição final. O fluxo host/client local anterior continua disponível como
smoke test técnico e ainda usa a sincronização visual legada.

## Smoke test

Execute:

```bash
./scripts/smoke_test_dedicated_spawn.sh
```

O primeiro cliente é iniciado com `--test-move`, que gera intenção automática
para a direita somente durante o teste headless. Sem esse argumento, o jogo
normal usa apenas os controles configurados em `project.godot`.

Além de conexão, spawn e despawn, os logs devem conter:

- `ServerMain: movimento do peer ... calculado`: o servidor recebeu a intenção
  e calculou a posição;
- `MovementProtocol: snapshot recebido`: o cliente recebeu a posição decidida
  pelo servidor.

## Limitações

- ainda não existe colisão real com o mapa no processo servidor;
- o passo de movimento é temporário e não usa simulação física completa;
- ainda não há anti-cheat completo, limite robusto de frequência, predição,
  reconciliação, latência simulada ou área de interesse;
- o avatar continua sendo uma forma visual simples, não o personagem final;
- posições ficam apenas em memória e não são persistidas;
- o teste headless valida mensagens e processos, não pixels renderizados;
- esta etapa não valida internet pública, Android ou 100 jogadores;
- nenhum sistema de inventário, zumbis, loot, dano, status, login ou banco de
  dados foi alterado.
