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

Quando um peer conecta, `server/ServerMain.gd` registra somente a conexão. Após
o handshake descrito em
[`DEDICATED_SESSION_PROTOCOL.md`](DEDICATED_SESSION_PROTOCOL.md), o servidor:

1. registra em memória uma posição temporária;
2. envia ao novo cliente os peers que já possuem sessão aceita;
3. anuncia o novo peer aos clientes com sessão aceita;
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

## Smoke test automatizado de runtime

Na raiz do repositório, com o executável `godot` 4.6 disponível no `PATH`,
execute:

```bash
./scripts/smoke_test_dedicated_spawn.sh
```

Quando executado com sucesso, o script inicia o servidor dedicado na porta UDP
`7000`, conecta dois clientes headless, encerra o primeiro cliente e verifica
automaticamente:

- inicialização do servidor;
- duas conexões registradas pelo servidor;
- duas sessões temporárias aceitas;
- eventos de spawn recebidos pelos dois clientes;
- desconexão do primeiro cliente;
- evento de despawn recebido pelo cliente restante.

Uma falha de conexão, ausência de mensagem esperada ou encerramento inesperado
faz o comando terminar com código diferente de zero. Os logs completos são
gravados por padrão em `artifacts/godot-smoke-test/`:

```text
server.log
client-1.log
client-2.log
```

Para usar outro caminho do executável, porta, diretório ou limite de espera:

```bash
GODOT_BIN=/caminho/para/godot PORT=7001 \
LOG_DIR=/tmp/godot-smoke TIMEOUT_SECONDS=30 \
./scripts/smoke_test_dedicated_spawn.sh
```

O workflow `.github/workflows/godot-smoke-test.yml` baixa a versão oficial
Godot 4.6 para Linux, importa o projeto em modo headless, executa o mesmo script
em cada pull request e publica os três logs como artefato, inclusive quando o
teste falha. A cena principal e os autoloads críticos de inicialização usam
caminhos `res://` explícitos no `project.godot`, evitando depender de um cache
local para resolver UIDs em runners limpos.

### Como interpretar os logs

- `ServerMain: servidor dedicado iniciado`: a porta ENet foi aberta;
- `ServerMain: peer ... conectado`: um cliente alcançou o servidor;
- `SessionProtocol: sessão aceita`: o handshake temporário foi aceito;
- `ServerMain: sessão criada`: o servidor registrou a sessão em memória;
- `SpawnProtocol: evento de spawn recebido`: o cliente recebeu uma autorização
  de representação visual enviada pelo servidor;
- `ServerMain: peer ... desconectado`: o servidor percebeu a saída;
- `SpawnProtocol: evento de despawn recebido`: o cliente restante recebeu a
  remoção autorizada.

## Limitações

- quando o workflow passa, o CI headless valida processos, rede local e
  mensagens; ele não inspeciona pixels nem comprova visualmente que o avatar
  foi desenhado;
- o teste usa dois clientes no mesmo runner e não representa internet pública,
  Android, latência real ou teste de carga;
- posições são temporárias, lineares e existem apenas em memória;
- o movimento básico agora usa o protocolo autoritativo inicial documentado em
  [`DEDICATED_MOVEMENT_PROTOCOL.md`](DEDICATED_MOVEMENT_PROTOCOL.md);
- não há validação de colisão, mapa, reconexão ou restauração;
- não há entidade de gameplay no processo servidor;
- `character/player/player.tscn` não é usado nem alterado;
- o limite configurado de clientes não é capacidade validada;
- nenhum marco de 2, 10, 20, 50 ou 100 jogadores foi comprovado por esta etapa.
