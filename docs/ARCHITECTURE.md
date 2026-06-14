# Arquitetura — RP Multiplayer Godot Android

## Visão geral

O projeto deve ser tratado como um jogo Godot 2D survival com multiplayer
online e foco em RP. O produto-alvo é um **APK Android cliente** conectado pela
internet a um **servidor dedicado**, e não uma sessão hospedada por um jogador
na rede local.

A arquitetura alvo é **cliente-servidor autoritativa**:

```text
APK Android 1  ┐
APK Android 2  ├──> Servidor dedicado autoritativo ───> Banco de dados
APK Android N  ┘               │
                               └──> Estado do mundo e área de interesse
```

O cliente mostra o jogo, recebe input do jogador e renderiza o mundo. O
servidor valida as ações importantes, mantém o estado válido da sessão e envia
a cada cliente somente as atualizações relevantes para sua área de interesse.

O ENet/host local atual é somente um **smoke test de fundação**. Ele serve para
validar conexão, desconexão e contratos básicos entre duas instâncias, mas não
define hospedagem, segurança, persistência ou escala do produto final. Consulte
[`ONLINE_SERVER_ARCHITECTURE.md`](ONLINE_SERVER_ARCHITECTURE.md) para a
arquitetura online detalhada.

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

A persistência de produção deve ficar atrás do servidor dedicado. O APK nunca
deve acessar o banco diretamente nem ser a fonte de verdade para inventário,
posição, status ou propriedade de itens.

### 6. Sincronização por área de interesse

O servidor não deve transmitir todo o mundo para todos os jogadores. Ele deve:

- dividir o mapa em células, setores ou outra estrutura espacial;
- identificar jogadores, zumbis, loot e eventos próximos de cada cliente;
- enviar entrada e saída de entidades da área de interesse;
- usar frequências diferentes conforme distância e importância;
- limitar mensagens globais aos sistemas que realmente exigem alcance global.

Essa separação é necessária para reduzir tráfego, processamento e quantidade de
entidades mantidas por cada APK, especialmente nos marcos de 20, 50 e 100
jogadores.

## Rede

### Smoke test inicial

Usar a camada nativa de multiplayer do Godot para teste LAN/local.

Objetivo limitado desse teste:

- 2 jogadores conectados.
- Spawn separado.
- Posição sincronizada.
- Chat local funcionando.

Esse host não é o servidor do produto e não deve acumular persistência ou
regras definitivas. O resultado esperado é somente reduzir riscos técnicos
antes da separação entre APK cliente e processo headless.

### Arquitetura online

Depois do smoke test, o caminho obrigatório é um servidor dedicado acessível
pela internet:

- processo Godot headless ou serviço de servidor compatível em Linux;
- implantação em VPS, máquina virtual ou contêiner;
- endpoint estável e configuração segura de portas;
- regras autoritativas executadas no servidor;
- PostgreSQL para contas, personagens e dados persistentes;
- métricas, logs, backup e recuperação;
- APK configurado como cliente, sem opção de ser o host de produção.

SQLite pode ser usado somente em protótipos isolados ou testes automatizados.
Ele não é a escolha alvo para a persistência compartilhada do servidor online.

## Escala progressiva

A meta futura é suportar até **100 jogadores simultâneos**, mas ela não deve ser
tratada como capacidade garantida antes de testes. A evolução será validada em:

1. **2 jogadores:** conexão, autoridade, spawn e sincronização básica;
2. **10 jogadores:** sessão online inicial, login, personagem e estabilidade;
3. **20 jogadores:** área de interesse, entidades e tráfego de rede;
4. **50 jogadores:** carga do servidor, banco, observabilidade e recuperação;
5. **100 jogadores:** otimização, teste prolongado e validação da meta futura.

Cada limite só deve avançar quando o anterior estiver estável, mensurado e sem
falhas críticas de duplicação, perda de dados ou autoridade.

## Persistência online inicial

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

O esquema definitivo deve separar conta, personagem, inventário e demais
domínios em estruturas consistentes. O exemplo acima representa apenas os dados
mínimos que precisam ser considerados, não uma tabela única recomendada para
produção.

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
