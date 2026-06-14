# Fundação do servidor dedicado/headless

## Objetivo desta etapa

Esta é a primeira estrutura executável do servidor dedicado do Mini DayZ Z
Online RP. Ela inicia um processo Godot sem interface gráfica, abre uma porta
ENet, mantém em memória uma lista simples dos peers conectados e distribui o
protocolo visual inicial descrito em
[`DEDICATED_SPAWN_PROTOCOL.md`](DEDICATED_SPAWN_PROTOCOL.md).

Esta fundação não substitui as etapas futuras de servidor autoritativo. Ela não
instancia `player.tscn`, não executa regras de gameplay e não acessa banco de
dados.

## Como iniciar o servidor

É necessário usar Godot 4.6. Na raiz do repositório, execute:

```bash
godot --headless --path . server/server_main.tscn -- --dedicated-server
```

O servidor usa a porta UDP `7000` e aceita até 8 clientes por padrão. Para
escolher outros valores:

```bash
godot --headless --path . server/server_main.tscn -- \
  --dedicated-server --port 7001 --max-clients 16
```

Os argumentos colocados depois de `--` são encaminhados ao script do servidor.
O marcador `--dedicated-server` também impede que o autoload
`multiplayer/NetworkManager.gd` conecte seus sinais de host/cliente local.
Assim, somente `ServerMain.gd` registra conexões e desconexões no processo
dedicado. A cena do servidor encerra com erro se esse marcador não for
informado.

Ao iniciar corretamente, o terminal exibe uma mensagem semelhante a:

```text
ServerMain: servidor dedicado iniciado na porta 7000 (máximo de 8 clientes).
```

Se a porta estiver ocupada ou não puder ser aberta, o processo registra
`ServerMain: erro ao abrir a porta ...` e encerra com o código de erro recebido
do Godot.

Em uma VPS ou contêiner, a porta escolhida precisa ser liberada como **UDP** no
firewall e na configuração de rede do provedor.

## Como conectar um cliente

Com o servidor local executando na porta padrão, abra outro terminal na raiz do
repositório e execute:

```bash
godot --path . -- --connect 127.0.0.1
```

Esse comando usa a fundação cliente existente em
`multiplayer/NetworkManager.gd`. Para um servidor em outra máquina, substitua
`127.0.0.1` pelo IP ou domínio alcançável do servidor.

Para conectar a uma porta customizada, informe `--port` depois do endereço:

```bash
godot --path . -- --connect 127.0.0.1 --port 7000
godot --path . -- --connect meu-servidor.com --port 7001
```

O endereço padrão continua sendo `127.0.0.1` nas chamadas internas do
`NetworkManager`, e a porta padrão continua sendo `7000`. Se `--port` não for
informado, o cliente usa `7000`. Se o argumento estiver sem valor, não for um
número inteiro ou estiver fora da faixa válida de `1` a `65535`, o cliente
registra um aviso e usa `7000` com segurança.

O valor usado no cliente deve ser igual à porta escolhida ao iniciar o
servidor. Em acesso pela internet, use o IP público ou domínio do servidor e
confirme que essa porta está liberada como **UDP**.

Quando um cliente entra ou sai, o terminal do servidor registra o ID do peer e
o total atual de conexões:

```text
ServerMain: peer 2 conectado. Total conectado: 1.
ServerMain: peer 2 desconectado. Total conectado: 0.
```

A conexão, sozinha, não cria mais o avatar. O cliente deve concluir a sessão
temporária descrita em
[`DEDICATED_SESSION_PROTOCOL.md`](DEDICATED_SESSION_PROTOCOL.md) e o personagem
descrito em
[`DEDICATED_CHARACTER_PROTOCOL.md`](DEDICATED_CHARACTER_PROTOCOL.md) antes de
receber spawn e enviar movimento aceito pelo servidor.

## Limitações atuais

- a lista de peers existe somente em memória e é perdida ao reiniciar;
- há somente sessão temporária em memória; não há autenticação, conta, sessão
  persistente ou reconexão;
- há somente criação de personagem RP temporário em memória; não há seleção,
  carregamento ou personagem persistente;
- `character/player/player.tscn` não é instanciado;
- o spawn entregue é somente um evento visual temporário autorizado pelo
  servidor, sem entidade final de personagem;
- há somente movimento temporário por intenção e snapshots, sem colisão de
  mapa; inventário, dano, status, zumbis e loot continuam fora do servidor;
- não há banco de dados nem acesso a PostgreSQL;
- não há autoridade completa de gameplay, snapshots avançados ou área de
  interesse;
- não há implantação online, métricas ou recuperação automática;
- o limite padrão de 8 clientes é apenas configuração inicial, não capacidade
  validada;
- a meta futura de 100 jogadores não foi entregue nem testada.

O jogo offline continua usando a cena principal definida em `project.godot`.
A cena do servidor só é carregada quando informada explicitamente no comando,
evitando alterar o fluxo atual do cliente.

## Próximos passos

### Autenticação

1. criar um gerenciador de sessões separado da conexão ENet;
2. definir mensagens de login com validação feita no servidor;
3. proteger credenciais com hash apropriado e limites contra abuso;
4. recusar ações de gameplay antes de uma sessão autenticada.

### Personagem

1. associar personagens à conta autenticada;
2. validar nome e seleção no servidor;
3. criar uma representação própria para servidor, sem câmera, HUD ou input;
4. evoluir o protocolo visual inicial para autorizar personagem e movimento;
5. tratar desconexão e reconexão sem duplicar entidades.

### Persistência

1. criar uma camada de persistência acessível somente pelo servidor;
2. integrar PostgreSQL por configuração do ambiente de implantação;
3. adicionar migrações e transações para dados críticos;
4. salvar personagem e posição antes de inventário e demais sistemas;
5. definir backup, restauração, logs e desligamento gracioso.

Esses passos devem ser implementados em mudanças pequenas e testados primeiro
com poucos clientes. Os marcos de 2, 10, 20, 50 e 100 jogadores continuam
dependentes de medições reais de estabilidade e carga.
