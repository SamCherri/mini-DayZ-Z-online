# Plano do servidor dedicado

## Decisão desta etapa

`server/ServerMain.gd` ainda não foi criado porque `world.tscn` não possui
mundo jogável, jogadores, spawner ou ciclo de sessão. Um servidor funcional
agora seria apenas um segundo ponto de entrada ENet, sem conseguir controlar o
estado real do jogo, e poderia transmitir uma falsa impressão de autoridade.

O teste local inicial usa `NetworkManager.create_host()`. Isso permite validar
conexão e desconexão sem afirmar que já existe um servidor autoritativo.

## Pré-requisitos para `ServerMain.gd`

1. Cena de servidor/headless com ciclo de vida definido.
2. Contêiner de jogadores e pontos de spawn no mundo.
3. Separação entre jogador local, jogador remoto e estado por sessão.
4. Protocolo inicial de mensagens e validação de movimento.
5. Política para reconexão, timeout e limite de jogadores.
6. Logs de conexão e encerramento seguro.

## Responsabilidades futuras

O servidor dedicado deverá:

- iniciar ENet sem interface gráfica;
- manter a lista de sessões e jogadores;
- escolher e validar posições de spawn;
- validar movimento antes de replicá-lo;
- remover jogadores desconectados;
- futuramente assumir autoridade sobre vida, dano, loot, inventário e zumbis.

Esses sistemas críticos não fazem parte desta fundação.
