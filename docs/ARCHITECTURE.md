# Arquitetura — RP Multiplayer Godot Android

## Visão geral

O projeto deve ser tratado como um jogo Godot 2D survival com multiplayer online e foco em RP.

A arquitetura recomendada é **cliente-servidor autoritativa**:

```text
Android Client 1  ┐
Android Client 2  ├──> Dedicated Server ───> Database
Android Client 3  ┘
```

O cliente mostra o jogo, recebe input do jogador e renderiza o mundo. O servidor valida as ações importantes e distribui o estado para os outros jogadores.

## Por que servidor autoritativo?

Em jogo RP online, confiar totalmente no cliente facilita:

- Teleporte/trapaça de posição.
- Duplicação de item.
- Dano falso.
- Loot infinito.
- Manipulação de status.
- Spawn indevido.

Por isso, o servidor deve controlar ou validar:

- Posição final do jogador.
- Vida, dano e morte.
- Inventário e loot importante.
- Spawn de zumbis.
- Chat e comandos.
- Profissões/facções.
- Salvamento do personagem.

## Camadas planejadas

### 1. Cliente Android

Responsável por:

- Tela inicial.
- Login simples.
- Criação de personagem.
- Input mobile.
- Renderização do mapa.
- HUD.
- Chat.
- Predição básica de movimento.

### 2. NetworkManager

Arquivo planejado:

```text
multiplayer/NetworkManager.gd
```

Responsável por:

- Conectar ao servidor.
- Receber ID do jogador.
- Enviar input.
- Receber snapshots do mundo.
- Criar/remover jogadores remotos.
- Tratar desconexões.

### 3. PlayerSync

Arquivo planejado:

```text
multiplayer/PlayerSync.gd
```

Responsável por:

- Sincronizar posição.
- Sincronizar animações.
- Interpolar movimento remoto.
- Reduzir tremedeira/lag visual.

### 4. ServerCore

Arquivos planejados:

```text
server/ServerMain.gd
server/SessionManager.gd
server/PlayerAuthority.gd
server/WorldState.gd
```

Responsável por:

- Aceitar conexões.
- Criar sessão.
- Validar jogadores.
- Controlar spawn.
- Controlar estado do mundo.
- Enviar atualizações para clientes.

### 5. Persistence

Arquivos planejados:

```text
server/Persistence.gd
server/schema.sql
```

Responsável por salvar:

- Conta/personagem.
- Posição.
- Inventário.
- Status.
- Profissão/facção.
- Último login.

## Rede

### Primeira etapa

Usar a camada nativa de multiplayer do Godot para teste LAN/local.

Objetivo inicial:

- 2 jogadores conectados.
- Spawn separado.
- Posição sincronizada.
- Chat local funcionando.

### Etapa online

Depois do teste LAN, evoluir para servidor dedicado.

Opções futuras:

- Godot headless server.
- Servidor VPS Linux.
- Docker.
- Banco PostgreSQL ou SQLite inicial.

## Persistência inicial

Para MVP, começar simples:

```text
player_id
character_name
position_x
position_y
health
blood
hunger
thirst
stamina
inventory_json
faction
job
last_seen
```

## Sistemas RP principais

### Personagem

- Nome e sobrenome obrigatórios.
- Validação de nome RP.
- Aparência básica.
- Spawn inicial em zona segura.

### Chat

Comandos iniciais:

```text
/me    ação do personagem
/do    descrição de cena
/try   tentativa com resultado
/pm    mensagem privada
/radio rádio de facção/profissão
/ooc   fora do personagem
```

### Facções/famílias

MVP:

- Nome da família.
- Cargo do membro.
- Rádio interno.
- Base/área segura.

### Profissões

MVP:

- Médico.
- Mecânico.
- Policial/militar RP, caso o servidor permita.
- Caminhoneiro/entregador.
- Comerciante.

## Checklist técnico antes do APK online

- [ ] Sem crash ao desconectar.
- [ ] Sem duplicação de item ao relogar.
- [ ] Sem teleporte livre pelo cliente.
- [ ] Chat com limite anti-spam.
- [ ] Nome RP validado.
- [ ] Servidor salva personagem.
- [ ] APK conecta em IP externo.
- [ ] Teste com internet móvel.
- [ ] Teste com Wi-Fi instável.
