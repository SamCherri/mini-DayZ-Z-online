# Etapas para concluir o game mode (TeleSoccer mobile-first por cenas)

Este plano divide a reta final em etapas pequenas, revisáveis e alinhadas com arquitetura limpa.

## Princípios fixos
- Reaproveitar o runtime legado e a identidade visual por cenas.
- Domínio sem dependência de frontend.
- Aplicação orquestra casos de uso, sem regra de negócio em infraestrutura/apresentação.
- Infraestrutura preparada para PostgreSQL/Prisma e deploy Railway via variáveis de plataforma.
- Evolução segura para multiplayer por turnos (contratos versionados e idempotência).

## Etapa 1 — Fechar contrato autoritativo cliente-servidor
**Objetivo:** sair de contrato local para contrato executável entre cliente e servidor.

**Entradas reaproveitadas:**
- `src/application/multiplayer/protocol/v1/messages.js`
- `src/application/multiplayer/message-mapper.js`
- `src/domain/multiplayer/turn-events.js`

**Entregáveis:**
- Especificação objetiva dos eventos/commands v1 (campos obrigatórios, erros e versionamento).
- Validação de envelope + payload por tipo de mensagem.
- Matriz de compatibilidade (cliente antigo x servidor novo).

**Critério de pronto:**
- Todo payload recebido/enviado passa por validação única.
- Nenhuma interpretação de protocolo fica no bridge legado.

## Etapa 2 — Servidor websocket autoritativo do turno
**Objetivo:** tornar o backend a fonte única da verdade do estado da partida.

**Entradas reaproveitadas:**
- `src/domain/multiplayer/turn-rules.js`
- `src/application/multiplayer/turn-orchestrator.js`
- `src/infrastructure/websocket/reliable-ws-transport.js` (conceitos de ack/retry)

**Entregáveis:**
- Processo servidor que recebe comandos, aplica regras de turno e publica eventos.
- Controle de ordem de comando por `matchId` e `turnNumber`.
- Idempotência por `messageId`.

**Critério de pronto:**
- Cliente não consegue impor estado local divergente do servidor.
- Reconexão recompõe estado canônico da sala.

## Etapa 3 — Persistência transacional de partida
**Objetivo:** garantir continuidade de sessão e histórico auditável.

**Entradas reaproveitadas:**
- `prisma/schema.prisma`
- `src/infrastructure/persistence/prisma-client.ts`
- `src/infrastructure/persistence/repositories/turn-event-repository.ts`

**Entregáveis:**
- Repositórios para sessão, turno, comandos e eventos com Prisma.
- Persistência transacional na confirmação do turno.
- Estratégia de recuperação de partida interrompida.

**Critério de pronto:**
- Reinício de processo não perde partida em andamento.
- Histórico de turno rastreável ponta a ponta.

## Etapa 4 — Loop RP de futebol por cenas
**Objetivo:** transformar fundação técnica em gameplay RP consistente.

**Entradas reaproveitadas:**
- `src/domain/rp/reputation.js`
- `src/domain/rp/interaction-scene.js`
- runtime visual de `legacy-shell/`

**Entregáveis:**
- Regras de progressão RP (reputação, escolhas e consequências por cena).
- Estados de cena sincronizados com turno (pré-jogo, jogada, intervalo, pós-jogo).
- Catálogo inicial de interações que alteram atributos do jogador/time.

**Critério de pronto:**
- Cada escolha de cena impacta estado de partida/reputação de forma determinística.
- Fluxo mantém identidade visual mobile-first por cenas.

## Etapa 5 — Adapter de apresentação desacoplado
**Objetivo:** manter frontend fino e previsível.

**Entradas reaproveitadas:**
- `legacy-shell/net-client.js`
- `src/application/multiplayer/session-client.js`
- `legacy-shell/index.html`

**Entregáveis:**
- Adapter explícito de apresentação para consumir eventos de aplicação.
- Remoção de decisões de regra de negócio do bridge legado.
- Tabela de mapeamento: evento de aplicação -> atualização visual por cena.

**Critério de pronto:**
- Frontend apenas renderiza estado/eventos.
- Mudanças de regra de jogo não exigem alteração no shell visual.

## Etapa 6 — Observabilidade e operação Railway
**Objetivo:** operar multiplayer com segurança em produção.

**Entradas reaproveitadas:**
- `src/infrastructure/observability/logger.js`
- `docs/operacao-multiplayer.md`

**Entregáveis:**
- Logs estruturados com `correlationId`, `matchId`, `playerId`.
- Métricas mínimas (latência turno, taxa de retry, timeout, reconexão).
- Runbook de incidentes atualizado para Railway.

**Critério de pronto:**
- Falhas de turno e reconexão identificáveis em minutos.
- Deploy não depende de `.env` local como premissa operacional.

## Etapa 7 — Hardening de qualidade
**Objetivo:** reduzir regressão antes de expansão de conteúdo.

**Entradas reaproveitadas:**
- `tests/domain-turn-rules.test.mjs`
- `tests/protocol-v1.test.mjs`

**Entregáveis:**
- Testes unitários adicionais de domínio (concorrência lógica e bordas).
- Testes de integração aplicação+infra (orquestração + persistência).
- Cenários de falha de rede (ACK perdido, retry, deduplicação).

**Critério de pronto:**
- Pipeline de testes cobre núcleo de turno/protocolo/persistência.
- Regressões críticas detectadas automaticamente.

## Etapa 8 — Conteúdo e fechamento do MVP
**Objetivo:** definir escopo “jogável e publicável” do modo RP.

**Entregáveis:**
- Pacote mínimo de cenas e progressão RP completo (início -> fim de ciclo).
- Balanceamento inicial de economia/reputação.
- Checklist de release (estabilidade, desempenho mobile e telemetria).

**Critério de pronto:**
- MVP completo com ciclo de jogo íntegro e observável.
- Base pronta para expansão contínua sem refatorações destrutivas.

---

## Ordem recomendada de execução
1. Etapa 1
2. Etapa 2
3. Etapa 3
4. Etapa 5
5. Etapa 4
6. Etapa 6
7. Etapa 7
8. Etapa 8

> Observação: Etapa 5 antes da 4 reduz retrabalho de UI e protege separação de camadas.
