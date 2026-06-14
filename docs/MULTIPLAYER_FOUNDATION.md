# Fundação multiplayer local — smoke test técnico

> **Este documento não descreve a arquitetura final do produto.** O host ENet
> local existe somente para validar a fundação de rede entre duas instâncias. O
> objetivo final é um APK Android conectado pela internet a um servidor
> dedicado e autoritativo, conforme
> [`ONLINE_SERVER_ARCHITECTURE.md`](ONLINE_SERVER_ARCHITECTURE.md).

## Escopo desta etapa

Esta etapa adiciona somente a fundação de rede ENet do Godot:

- criação de host local;
- conexão de cliente por endereço e porta;
- sinais de conexão e desconexão;
- pedidos de spawn e remoção de jogador;
- componente inicial de sincronização de posição e rotação.

Nenhum sistema de inventário, zumbis, dano, loot, status, chat RP, asset ou
identidade visual foi alterado.

Também não estão presentes nesta etapa:

- servidor dedicado/headless implantado online;
- autenticação e contas;
- personagens persistentes;
- banco de dados de produção;
- autoridade completa sobre gameplay;
- sincronização por área de interesse;
- capacidade validada além de duas instâncias.

Portanto, sucesso neste teste não significa que o multiplayer online esteja
pronto. Ele comprova apenas que os mecanismos mínimos de conexão podem ser
exercitados antes da arquitetura dedicada.

## Mapeamento atual

### Cena principal

`world.tscn` é a cena principal configurada em `project.godot`. Ela agora
contém o contêiner `Players`, dois pontos temporários em `SpawnPoints` e um
`WorldSpawner` que responde aos sinais de spawn/despawn somente no smoke test.

### Jogador

A cena jogável identificada é `character/player/player.tscn`, cujo nó raiz
`Player` é um `CharacterBody2D` controlado por
`character/player/player.gd`.

Ainda não é seguro usar essa cena diretamente para jogadores remotos porque:

1. todas as instâncias consultam o mesmo input local;
2. a cena contém uma `Camera2D`;
3. o status usa o autoload global `PlayerStatus`;
4. inventário e detecção estão acoplados ao jogador completo;
5. ela representa sistemas que ainda não possuem autoridade dedicada.

Instanciar dois jogadores completos agora poderia fazer ambos responderem ao
mesmo teclado e compartilharem status. Por isso, o smoke test usa
`multiplayer/simple_avatar.tscn`, uma representação independente e descartável.

## Arquivos criados

### `multiplayer/NetworkManager.gd`

Autoload inativo por padrão. Expõe:

- `create_host(port, max_clients)`;
- `join_host(address, port)`;
- `disconnect_from_session()`;
- estados `OFFLINE`, `HOSTING`, `CONNECTING` e `CONNECTED`;
- sinais de conexão, desconexão, falha e preparação de spawn.

Carregar o projeto offline não abre porta nem tenta conexão.

### `multiplayer/PlayerSync.gd`

Componente reutilizável que:

- recebe a autoridade multiplayer do jogador;
- envia posição e rotação em frequência configurável;
- interpola snapshots em instâncias remotas;
- não sincroniza inventário, status, dano ou animações.

O componente ainda não foi anexado a `player.tscn` pelos riscos descritos
acima. Em vez disso, ele foi anexado somente ao avatar simples.

### `multiplayer/SimpleAvatar.gd` e `simple_avatar.tscn`

Avatar visual temporário com um corpo geométrico, rótulo do peer, colisão e
movimento WASD básico apenas para a instância com autoridade. Ele não possui
câmera, HUD, inventário, `PlayerStatus`, zumbis, loot ou regras de gameplay.

### `multiplayer/WorldSpawner.gd`

Conecta `player_spawn_requested` e `player_despawn_requested` do
`NetworkManager`, distribui peers entre `Spawn1` e `Spawn2` e mantém os avatares
sob o nó `Players`. A cena dedicada `server/server_main.tscn` não carrega esse
spawner nem instancia qualquer avatar.

## Como testar host e cliente

É necessário Godot 4.6 e uma pequena cena temporária de teste ou um menu futuro
que chame o autoload. Para validar somente a conexão desta fundação, também é
possível usar os argumentos de linha de comando já preparados.

1. Inicie o host no primeiro terminal:

   ```bash
   godot --path . -- --host
   ```

2. Inicie o cliente no segundo terminal:

   ```bash
   godot --path . -- --connect 127.0.0.1
   ```

3. Confirme nos terminais mensagens como:

   - `NetworkManager: host local iniciado na porta 7000.`;
   - `NetworkManager: peer ... conectado.`;
   - `NetworkManager: peer ... desconectado.`.
4. Em cada janela, confirme dois quadrados identificados por peer:
   - azul para o avatar com autoridade local;
   - laranja para o avatar remoto.
5. Use WASD em cada janela para mover apenas o avatar local e observar a
   sincronização visual na outra instância.
6. Encerre o cliente e confirme que o host remove o avatar desconectado.

Uma cena ou menu também pode chamar diretamente
`NetworkManager.create_host(7000, 8)` e
`NetworkManager.join_host("127.0.0.1", 7000)`, além de observar os sinais
`player_spawn_requested` e `player_despawn_requested`.

Para testar entre dois computadores na mesma rede, substitua `127.0.0.1` pelo
IP local do computador host e permita UDP na porta `7000` no firewall.

O resultado esperado nesta etapa é visualizar dois avatares simples e validar
spawn, remoção, autoridade local e sincronização básica. Este fluxo não deve
ser distribuído como forma de hospedagem do jogo.

## Limitações do spawn visual

- é um smoke test host/client local, não spawn autorizado pelo servidor final;
- não usa `character/player/player.tscn` e não representa o personagem final;
- os pontos são fixos, temporários e distribuídos pela ordem de spawn;
- não há seleção, persistência, reconexão ou restauração de personagem;
- o movimento ainda é informado pelo cliente, sem validação autoritativa;
- não há mapa, animações de personagem, combate ou sistemas de sobrevivência;
- o servidor dedicado possui um protocolo visual inicial separado, mas ainda
  não mantém personagem ou gameplay autoritativo;
- este teste não valida APK, internet pública, escala ou 100 jogadores.

## Próxima integração segura

Depois deste spawn visual:

1. validar o fluxo em duas instâncias e registrar o resultado real;
2. mover autorização de spawn e estado do mundo para o processo dedicado;
3. fazer dois clientes receberem entidades autorizadas pelo servidor;
4. separar input/câmera do personagem final por autoridade;
5. substituir o status global por estado pertencente a cada jogador;
6. implementar login, seleção de personagem e persistência;
7. introduzir área de interesse antes dos testes de maior escala.

Depois disso, a capacidade deve ser validada progressivamente em **2, 10, 20,
50 e 100 jogadores simultâneos**. O marco de 100 jogadores é uma meta futura,
dependente de medição e otimização; não é uma promessa baseada no smoke test
local.
