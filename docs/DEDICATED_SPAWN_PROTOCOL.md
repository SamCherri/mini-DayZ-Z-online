# Protocolo inicial de spawn do servidor dedicado

## Objetivo

Esta etapa cria o primeiro contrato compartilhado para o servidor dedicado
autorizar a representação visual dos peers conectados. O servidor continua
headless e não carrega `world.tscn`; somente os clientes instanciam
`multiplayer/simple_avatar.tscn`.

O protocolo é deliberadamente pequeno. Ele não representa o sistema final de
personagem e não adiciona login, persistência, inventário, combate, zumbis,
loot, status ou autoridade completa de movimento.

## Fluxo

`multiplayer/SpawnProtocol.gd` é um autoload presente no mesmo caminho de nó em
cliente e servidor. Seus RPCs confiáveis aceitam chamadas remotas apenas da
autoridade multiplayer, que no ENet do Godot é o peer servidor de ID `1`.

Quando um peer conecta, `server/ServerMain.gd`:

1. registra em memória o horário e uma posição temporária;
2. envia ao novo cliente os peers que já estavam conectados;
3. anuncia o novo peer aos clientes existentes;
4. envia ao novo cliente o spawn dele mesmo.

Quando um peer desconecta, o servidor o remove do registro e envia
`despawn_peer` aos clientes restantes.

No cliente, o protocolo emite:

- `spawn_peer_received(peer_id, position)`;
- `despawn_peer_received(peer_id)`.

`multiplayer/WorldSpawner.gd` escuta esses sinais e cria ou remove o avatar
temporário. Ao receber o primeiro evento dedicado, ele limpa os avatares
preparados pelo fluxo genérico do smoke test local e passa a respeitar as
posições enviadas pelo servidor.

## Como testar

É necessário Godot 4.6. No primeiro terminal:

```bash
godot --headless --path . server/server_main.tscn -- --dedicated-server
```

Em outros dois terminais:

```bash
godot --path . -- --connect 127.0.0.1
godot --path . -- --connect 127.0.0.1
```

Cada cliente deve mostrar os dois avatares simples nas posições temporárias
enviadas pelo servidor. Ao fechar um cliente, o avatar correspondente deve
desaparecer no cliente restante.

O smoke test host/client local anterior permanece disponível:

```bash
godot --path . -- --host
godot --path . -- --connect 127.0.0.1
```

Esse fluxo continua usando os sinais do `NetworkManager`; ele não se torna um
servidor de produção.

## Limitações

- posições são temporárias, lineares e existem apenas em memória;
- movimento ainda é informado pelo cliente pelo componente visual existente;
- não há validação de colisão, mapa, reconexão ou restauração;
- não há entidade de gameplay no processo servidor;
- `character/player/player.tscn` não é usado nem alterado;
- o limite configurado de clientes não é capacidade validada;
- nenhum marco de 2, 10, 20, 50 ou 100 jogadores foi comprovado por esta etapa.
