# Roadmap — Mini DayZ Z Online RP

## Fase 0 — Preparação do repositório

- [x] Criar README do projeto.
- [x] Registrar atribuição e aviso de projeto de fã.
- [x] Definir roadmap inicial.
- [x] Definir arquitetura multiplayer.
- [ ] Importar a base Godot de referência.
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
- [ ] Criar build Android offline.

## Fase 2 — Multiplayer mínimo

- [ ] Criar pasta `multiplayer/`.
- [ ] Criar `NetworkManager.gd`.
- [ ] Criar fluxo host/client para testes.
- [ ] Sincronizar entrada e saída de jogadores.
- [ ] Sincronizar posição básica.
- [ ] Sincronizar animação básica.
- [ ] Criar spawn points.
- [ ] Testar 2 jogadores em LAN.

## Fase 3 — Servidor dedicado

- [ ] Criar projeto/cena de servidor headless.
- [ ] Servidor deve controlar posição, vida e inventário crítico.
- [ ] Cliente não deve decidir dano, loot raro ou teleportes.
- [ ] Criar logs de conexão.
- [ ] Criar limite inicial de jogadores por sala.
- [ ] Criar reinício seguro da sessão.

## Fase 4 — RP básico

- [ ] Criar criação de personagem com nome e sobrenome.
- [ ] Criar chat local.
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

## Fase 5 — Persistência

- [ ] Criar ID único de personagem.
- [ ] Salvar posição.
- [ ] Salvar inventário.
- [ ] Salvar status.
- [ ] Salvar profissão/facção.
- [ ] Criar banco local inicial para testes.
- [ ] Planejar banco online: SQLite/PostgreSQL/Supabase/Firebase.

## Fase 6 — Android online

- [ ] Ajustar interface para celular.
- [ ] Criar botões touch.
- [ ] Testar tela pequena.
- [ ] Testar rede móvel instável.
- [ ] Reduzir consumo de internet.
- [ ] Criar APK de teste.
- [ ] Criar checklist de bugs antes de release.

## Fase 7 — Identidade própria

- [ ] Definir nome final do jogo.
- [ ] Trocar logo.
- [ ] Trocar sprites sensíveis.
- [ ] Trocar sons e músicas.
- [ ] Criar lore própria.
- [ ] Criar mapa próprio.
- [ ] Revisar avisos legais.

## Prioridade imediata

1. Importar a base Godot.
2. Fazer rodar offline.
3. Criar `NetworkManager.gd`.
4. Testar dois jogadores em LAN.
5. Só depois avançar para servidor online real.

> A importação continua pendente porque o ambiente de execução retornou HTTP
> 403 ao acessar o GitHub. Consulte
> [`IMPORT_VALIDATION.md`](IMPORT_VALIDATION.md) antes de prosseguir.
