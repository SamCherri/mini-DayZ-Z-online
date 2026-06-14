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

`world.tscn` é a cena principal configurada em `project.godot`. No estado
atual, ela contém somente um nó `World` do tipo `Node2D`. Não há mapa, ponto de
spawn ou jogador instanciado nessa cena.

### Jogador

A cena jogável identificada é `character/player/player.tscn`, cujo nó raiz
`Player` é um `CharacterBody2D` controlado por
`character/player/player.gd`.

Ainda não é seguro usar essa cena diretamente para jogadores remotos porque:

1. todas as instâncias consultam o mesmo input local;
2. a cena contém uma `Camera2D`;
3. o status usa o autoload global `PlayerStatus`;
4. inventário e detecção estão acoplados ao jogador completo;
5. `world.tscn` ainda não define um contêiner nem pontos de spawn.

Instanciar dois jogadores completos agora poderia fazer ambos responderem ao
mesmo teclado e compartilharem status. Por isso, a camada de rede apenas emite
`player_spawn_requested` e `player_despawn_requested`; a cena de mundo ainda
não responde a esses sinais.

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
acima.

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
4. Encerre o cliente e confirme que o host registra a desconexão.

Uma cena ou menu também pode chamar diretamente
`NetworkManager.create_host(7000, 8)` e
`NetworkManager.join_host("127.0.0.1", 7000)`, além de observar os sinais
`player_spawn_requested` e `player_despawn_requested`.

Para testar entre dois computadores na mesma rede, substitua `127.0.0.1` pelo
IP local do computador host e permita UDP na porta `7000` no firewall.

O resultado esperado nesta etapa é a sessão e os sinais funcionarem. Ainda não
é esperado ver dois personagens na tela. Também não é esperado que este fluxo
seja distribuído como forma de hospedagem do jogo.

## Próxima integração segura

Antes de spawn visual e movimento replicado:

1. adicionar ao mundo um nó `Players` e pontos de spawn;
2. separar input/câmera para existir somente no jogador com autoridade local;
3. substituir o status global por estado pertencente a cada jogador;
4. definir uma representação remota sem HUD e sem lógica de inventário local;
5. conectar os sinais do `NetworkManager` a um spawner;
6. anexar `PlayerSync` à representação multiplayer;
7. validar o fluxo em duas instâncias;
8. encerrar a fase de host local e iniciar o servidor dedicado/headless;
9. mover autoridade, sessão e estado do mundo para o processo de servidor;
10. implementar login, personagem e persistência;
11. introduzir área de interesse antes dos testes de maior escala.

Depois disso, a capacidade deve ser validada progressivamente em **2, 10, 20,
50 e 100 jogadores simultâneos**. O marco de 100 jogadores é uma meta futura,
dependente de medição e otimização; não é uma promessa baseada no smoke test
local.
