# Arquitetura do servidor online dedicado

## Objetivo

Este documento define a arquitetura alvo do Mini DayZ Z Online RP. O produto
final será distribuído como **APK Android cliente** e dependerá de um
**servidor dedicado online**, executado separadamente e disponível pela
internet.

O host ENet local documentado em
[`MULTIPLAYER_FOUNDATION.md`](MULTIPLAYER_FOUNDATION.md) é apenas um smoke test
inicial. Ele não é o modelo de hospedagem do produto, não deve guardar dados
definitivos e não comprova capacidade para muitos jogadores.

## Visão de alto nível

```text
┌──────────────────┐
│ APK Android      │
│ input, HUD, áudio│
│ e renderização   │
└────────┬─────────┘
         │ internet / protocolo de jogo
         ▼
┌──────────────────────────────────────┐
│ Servidor dedicado autoritativo       │
│ sessões, regras, mundo e replicação  │
└────────┬─────────────────────┬───────┘
         │                     │
         ▼                     ▼
┌──────────────────┐  ┌──────────────────────┐
│ PostgreSQL       │  │ Logs, métricas e     │
│ contas e         │  │ monitoramento        │
│ personagens      │  │ operacional          │
└──────────────────┘  └──────────────────────┘
```

## 1. APK Android como cliente

O APK é responsável por:

- coletar controles de toque e intenção do jogador;
- apresentar login, criação de personagem, HUD, chat e menus;
- renderizar mapa, personagens, zumbis, itens e efeitos recebidos;
- aplicar interpolação e, quando seguro, predição visual;
- enviar comandos e inputs, em vez de declarar resultados;
- tratar latência, perda temporária de conexão e reconexão.

O APK não deve:

- acessar o banco de dados diretamente;
- definir saldo, inventário, dano, vida ou posição final;
- criar loot ou personagens sem autorização;
- atuar como host do servidor de produção;
- receber o estado completo do mapa sem necessidade.

## 2. Servidor dedicado online

O servidor deve executar continuamente fora dos celulares, inicialmente como
um processo headless em Linux. Ele poderá ser implantado em VPS, máquina
virtual ou contêiner, desde que o ambiente permita portas de jogo, métricas,
logs, backups e reinícios controlados.

Responsabilidades:

- aceitar e encerrar conexões;
- autenticar contas e criar sessões;
- carregar e salvar personagens;
- manter o estado válido do mundo;
- processar inputs e aplicar regras;
- controlar spawn, vida, status, inventário, loot e zumbis;
- distribuir snapshots e eventos;
- detectar comandos inválidos, frequência abusiva e divergências;
- recuperar-se de desconexões e reinícios sem duplicar dados.

O servidor não deve depender da presença do primeiro jogador para existir. Uma
partida não pode terminar apenas porque um cliente Android fechou o aplicativo.

## 3. Autoridade e confiança

O cliente informa intenção; o servidor decide o resultado. Exemplos:

| Ação | Cliente envia | Servidor valida e decide |
| --- | --- | --- |
| Movimento | direção/input e sequência | velocidade, colisão e posição válida |
| Ataque | tentativa e alvo | alcance, cadência, acerto, dano e morte |
| Coleta | pedido sobre uma entidade | existência, distância e transferência |
| Inventário | pedido de mover/usar | propriedade, quantidade e efeito |
| Chat RP | texto e canal solicitado | alcance, permissão, limite e destinatários |
| Spawn | personagem selecionado | autorização, local e estado restaurado |

Essa regra reduz teleporte, dano falso, duplicação de itens e manipulação de
status. Validações importantes devem permanecer no servidor mesmo quando o
cliente possua previsão visual para melhorar a sensação de resposta.

## 4. Contas, personagens e banco de dados

O banco de produção recomendado é PostgreSQL, acessado somente por uma camada
de persistência do servidor.

Domínios mínimos:

- **conta:** identificador, credenciais protegidas, estado e datas de acesso;
- **personagem:** nome RP, aparência, posição e vínculo com a conta;
- **sobrevivência:** vida, sangue, fome, sede, stamina e doenças;
- **inventário:** itens, quantidades, estado e localização;
- **RP:** profissão, facção/família, permissões e progressão;
- **auditoria:** operações críticas úteis para investigar perda ou duplicação.

Senhas devem ser armazenadas com hash apropriado, nunca em texto puro. Escritas
que movem itens ou atualizam dados relacionados devem usar transações para
preservar integridade. Backups e migrações fazem parte da arquitetura, não são
uma etapa opcional posterior ao lançamento.

SQLite pode ser útil em testes locais isolados, mas não é a base alvo para
múltiplas sessões online compartilhando personagens.

## 5. Sincronização por área de interesse

Com muitos jogadores e entidades, transmitir o mundo inteiro para todos os
APKs desperdiça banda e processamento. O servidor deve manter uma **área de
interesse** para cada conexão.

Estratégia inicial:

1. dividir o mapa em células ou setores;
2. registrar em qual setor cada entidade está;
3. considerar o setor atual e vizinhos como área relevante;
4. avisar quando entidades entram ou saem dessa área;
5. enviar atualizações frequentes para entidades próximas;
6. reduzir frequência para entidades mais distantes quando ainda relevantes;
7. não replicar entidades sem impacto para aquele cliente.

Chat local, sons, combate, zumbis e loot podem usar distância ou setores.
Mensagens administrativas realmente globais seguem um canal separado. Os
limites e frequências deverão ser ajustados com métricas reais, não definidos
apenas por suposição.

## 6. Evolução progressiva de capacidade

**100 jogadores simultâneos é uma meta futura**, não uma capacidade já
entregue. A evolução planejada é:

### Marco 1 — 2 jogadores

- validar cliente Android/desktop de teste contra processo dedicado;
- confirmar autoridade de spawn e movimento;
- tratar conexão, desconexão e reconexão;
- medir a linha de base de tráfego e processamento.

### Marco 2 — 10 jogadores

- validar login e seleção de personagem;
- validar persistência sem perda ou duplicação;
- observar estabilidade de uma sessão online pequena;
- introduzir limites e logs contra abuso.

### Marco 3 — 20 jogadores

- ativar e medir área de interesse;
- validar zumbis, loot e chat por proximidade;
- ajustar frequência e tamanho de snapshots;
- testar internet móvel e condições de latência.

### Marco 4 — 50 jogadores

- executar testes automatizados de carga;
- medir CPU, memória, banda e banco;
- validar backup, reinício e recuperação;
- identificar gargalos antes de aumentar o limite.

### Marco 5 — 100 jogadores

- executar teste prolongado com carga representativa;
- otimizar os gargalos medidos;
- validar gameplay, persistência e observabilidade sob pico;
- liberar esse limite somente se os critérios de estabilidade forem atendidos.

Se um marco não estiver estável, o limite permanece no nível anterior. Caso um
único processo não suporte a meta, a evolução poderá incluir separação de
serviços ou múltiplas instâncias, mas isso deve ser decidido a partir de
métricas e não antecipado no MVP.

## 7. Implantação e operação

A primeira implantação online deve privilegiar simplicidade e diagnóstico:

- um servidor dedicado por ambiente;
- PostgreSQL gerenciado ou operado com backup;
- configurações fornecidas por variáveis do serviço de deploy;
- ambientes separados para desenvolvimento/teste e produção;
- logs estruturados de conexão, erro e operação crítica;
- métricas de jogadores conectados, latência, tráfego, CPU e memória;
- encerramento gracioso e salvamento antes de manutenção;
- controle de versão compatível entre APK e servidor.

O endereço do servidor não deve ficar espalhado em scripts. O cliente deve
recebê-lo por configuração de build ou mecanismo equivalente, permitindo trocar
o ambiente sem alterar regras de gameplay.

## 8. Sequência de implementação

1. concluir o smoke test ENet com duas instâncias;
2. criar o processo dedicado/headless;
3. mover sessão e autoridade básica para o servidor;
4. conectar clientes ao servidor por endereço externo;
5. implementar autenticação e personagem;
6. integrar PostgreSQL e persistência autoritativa;
7. integrar gameplay RP e entidades do mundo;
8. implementar área de interesse;
9. validar os marcos de 2, 10, 20, 50 e 100 jogadores;
10. consolidar o APK Android para testes e distribuição.

Essa sequência reaproveita o aprendizado do teste local, mas descarta a ideia
de LAN ou host de jogador como arquitetura final.
