# Roadmap — Mini DayZ Z Online RP

## Direção do produto

O produto final será um **APK Android cliente** de survival RP online,
conectado pela internet a um **servidor dedicado e autoritativo**. O fluxo
host/client ENet em localhost ou LAN é apenas um smoke test técnico inicial; ele
não é a experiência final, não substitui o servidor online e não deve receber
responsabilidades definitivas de persistência ou autoridade.

A meta futura é chegar a **100 jogadores simultâneos**, por evolução medida nos
limites de **2, 10, 20, 50 e 100 jogadores**. Cada marco depende da estabilidade
do anterior e de testes de carga, rede, banco e gameplay.

## Fase 0 — Preparação do repositório

- [x] Criar README do projeto.
- [x] Registrar atribuição e aviso de projeto de fã.
- [x] Definir roadmap inicial.
- [x] Definir arquitetura multiplayer.
- [x] Documentar a arquitetura alvo de servidor online dedicado.
- [x] Importar a base Godot de referência.
- [ ] Conferir licença e headers dos arquivos importados.
- [ ] Rodar o projeto localmente no Godot.
- [x] Auditar e rejeitar pacote Construct/Cordova de procedência incompatível.
- [x] Registrar a validação preliminar e os bloqueios do ambiente.

## Fase 1 — Base jogável offline

- [ ] Validar cena principal (`world.tscn` ou equivalente).
- [ ] Validar movimento do personagem.
- [ ] Validar câmera mobile/top-down.
- [ ] Validar zumbis básicos.
- [ ] Validar inventário e loot.
- [ ] Validar status: fome, sede, sangue, stamina e doença.
- [ ] Validar execução local para desenvolvimento, sem tratar o modo offline
  como produto final.
- [x] Criar workflow manual para APK offline debug interno.

## Fase 2 — Smoke test local de rede (2 jogadores)

- [x] Criar pasta `multiplayer/`.
- [x] Criar `NetworkManager.gd`.
- [x] Criar fluxo host/client ENet para testes.
- [x] Preparar sinais de entrada e saída de jogadores.
- [x] Criar spawn visual simples com avatar temporário para smoke test.
- [x] Criar spawn points temporários.
- [x] Automatizar no CI o runtime headless com servidor dedicado e dois clientes.
- [x] Implementar o movimento básico inicial autorizado pelo servidor dedicado.
- [ ] Validar visualmente a sincronização de posição básica em duas instâncias.
- [ ] Sincronizar animação básica.
- [ ] Testar duas instâncias em localhost ou LAN.
- [ ] Registrar resultados e limitações do teste.

**Saída da fase:** validar conexão, desconexão, spawn e contratos básicos. O
host local não será promovido a servidor de produção.

## Fase 3 — Servidor dedicado online/headless

- [x] Criar a estrutura inicial e a cena executável do servidor headless.
- [x] Permitir configurar endereço e porta do servidor por argumentos no cliente.
- [x] Criar o protocolo inicial de spawn/despawn visual autorizado pelo servidor.
- [x] Criar sessão temporária em memória antes de liberar spawn e movimento.
- [x] Criar personagem RP temporário em memória antes de liberar spawn e movimento.
- [x] Separar por `--dedicated-client` o cliente dedicado do smoke host/client
  local, sem spawn provisório antes de sessão e personagem.
- [x] Criar runner operacional e exemplo de serviço para executar o processo
  dedicado em Linux, sem implantar uma VPS.
- [ ] Confirmar no CI conexão, spawn, movimento, desconexão e despawn com dois clientes.
- [ ] Separar o processo servidor do APK cliente.
- [ ] Implantar uma primeira instância acessível pela internet.
- [ ] Fazer o servidor controlar posição, vida e inventário crítico.
- [ ] Impedir que o cliente decida dano, loot raro ou teleporte.
- [ ] Evoluir a sessão temporária para sessão autenticada, com logs e tratamento
  completo de reconexão.
- [ ] Criar reinício e recuperação seguros.
- [ ] Fazer dois clientes conectarem ao servidor externo, sem host de jogador.

## Fase 4 — Login, conta e personagem

- [x] Validar o primeiro protocolo de personagem temporário em memória, sem conta
  ou persistência.
- [ ] Criar cadastro e login de conta.
- [ ] Armazenar senha somente por hash seguro.
- [ ] Criar ID único de conta e personagem.
- [ ] Criar personagem com nome e sobrenome.
- [ ] Validar nome RP no servidor.
- [ ] Associar personagem à conta autenticada.
- [ ] Restaurar sessão e spawn após reconexão.

## Fase 5 — Persistência online

- [ ] Preparar banco PostgreSQL para o servidor dedicado.
- [ ] Separar dados de conta, personagem, inventário e progressão.
- [ ] Salvar posição, inventário e status pelo servidor.
- [ ] Salvar profissão, facção e último acesso.
- [ ] Proteger operações contra duplicação de itens.
- [ ] Criar migrações, backup e procedimento de recuperação.
- [ ] Garantir que o APK nunca acesse o banco diretamente.

SQLite pode apoiar testes isolados, mas não é a arquitetura alvo da
persistência compartilhada online.

## Fase 6 — Gameplay RP online inicial

- [ ] Criar chat local calculado por distância no servidor.
- [ ] Criar chat global administrativo.
- [ ] Criar comandos RP iniciais:
  - `/me`
  - `/do`
  - `/try`
  - `/pm`
  - `/radio`
- [ ] Criar sistema de profissões.
- [ ] Criar facções/famílias.
- [ ] Criar zonas seguras.
- [ ] Integrar zumbis, loot e inventário à autoridade do servidor.

## Fase 7 — Sincronização por área de interesse e escala

- [ ] Dividir o mapa em células, setores ou estrutura espacial equivalente.
- [ ] Enviar a cada cliente somente entidades e eventos relevantes.
- [ ] Definir frequências de atualização por distância e importância.
- [ ] Medir CPU, memória, banda, latência e consultas ao banco.
- [ ] Validar **2 jogadores** no servidor dedicado.
- [ ] Validar **10 jogadores** com login e personagem persistente.
- [ ] Validar **20 jogadores** com área de interesse ativa.
- [ ] Validar **50 jogadores** com observabilidade e teste de carga.
- [ ] Validar **100 jogadores** em teste prolongado como meta futura.

O número de vagas de produção nunca deve ser aumentado somente por estimativa.
Cada limite depende de métricas, estabilidade e ausência de falhas críticas.

## Fase 8 — APK Android conectado ao servidor

- [ ] Ajustar interface para celular.
- [ ] Criar botões touch.
- [ ] Testar telas e densidades diferentes.
- [ ] Configurar endereço seguro do servidor por ambiente de build/deploy.
- [ ] Testar internet móvel e Wi-Fi instável.
- [ ] Reduzir consumo de dados e bateria.
- [ ] Criar APK de teste conectado ao servidor dedicado.
- [ ] Criar checklist de bugs antes de release.

Esta documentação não autoriza gerar o APK nesta etapa atual; a build Android
vem depois que o fluxo online dedicado estiver funcional.

## Fase 9 — Identidade própria

- [ ] Definir nome final do jogo.
- [ ] Trocar logo.
- [ ] Trocar sprites sensíveis.
- [ ] Trocar sons e músicas.
- [ ] Criar lore própria.
- [ ] Criar mapa próprio.
- [ ] Revisar avisos legais.

## Prioridade imediata

1. Validar visualmente sessão, spawn e movimento dedicado com dois clientes.
2. Evoluir o movimento sem promover o host local a servidor de produção.
3. Separar e implantar o processo servidor fora do APK cliente.
4. Conectar clientes ao servidor dedicado pela internet.
5. Implementar cadastro/login real e personagem persistente.
6. Implementar persistência PostgreSQL protegida pelo servidor.
7. Implementar área de interesse.
8. Avançar pelos testes de 2, 10, 20, 50 e 100 jogadores.
9. Somente então consolidar o APK Android online para testes de release.
