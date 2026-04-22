# Preparação Inicial — Mod Roleplay para Mini DayZ

## 1) Diagnóstico rápido do pacote recebido

Arquivo analisado: `Mini DayZ rpg.zip` (o pedido mencionou RAR, mas o conteúdo entregue no repositório está em ZIP).

Resumo técnico do conteúdo:

- Total de arquivos: **2221**.
- Predominância de assets estáticos (`.png`, `.ogg`, `.m4a`).
- Base de runtime já exportada (Construct/Cordova), com destaque para:
  - `index.html`
  - `c2runtime.js`
  - `data.js`
  - `cordova.js`
  - `cordova-js-src/*`
  - XML de localização (`l_*.xml`)

Isso indica que a modificação inicial deve ser orientada a **engenharia reversa leve** e **organização de domínio**, evitando alterações diretas em massa no runtime ofuscado no começo.

---

## 2) Estratégia de preparação (fase 0)

### Objetivo
Preparar a base para evolução segura de um modo roleplay, sem quebrar o jogo atual e com caminho para multiplayer futuro.

### Princípios aplicados

- Separação por camadas: domínio, aplicação, infraestrutura, apresentação.
- Mudanças pequenas, revisáveis e com baixo risco.
- Reaproveitar regras existentes antes de substituir comportamento.
- Evitar lógica de negócio acoplada em interface/render.

### Entregáveis desta fase

1. Inventário automatizado do pacote para auditoria.
2. Diretriz de arquitetura para guiar próximos commits.
3. Checklist de extração de regras já existentes no jogo base.

---

## 3) Mapa técnico inicial para evolução

### 3.1 Núcleo legado (não tocar agressivamente agora)

- `c2runtime.js` / `data.js`: runtime e estado do jogo exportado.
- `images/*`, `media/*`: conteúdo visual e sonoro.

### 3.2 Nova camada incremental (alvo dos próximos passos)

Criar gradualmente uma estrutura paralela para o mod:

- `src/domain/` — entidades RP (personagem, facção, reputação, economia local, missões sociais).
- `src/application/` — casos de uso (entrar em cena, interagir, negociar, registrar ocorrências).
- `src/infrastructure/` — gateway de persistência e integração (preparado para PostgreSQL/Prisma no futuro).
- `src/presentation/` — adaptadores para UI/cenas sem regra de negócio embutida.

> Observação: este documento define direção. A criação física dessa estrutura pode ser feita em pequenos commits subsequentes.

---

## 4) Backlog de preparação imediata

1. Catalogar pontos de entrada e eventos principais em `index.html` e `data.js`.
2. Identificar variáveis de estado globais reutilizáveis para RP.
3. Definir contrato mínimo de domínio para:
   - personagem RP;
   - inventário social (itens não-combate);
   - sistema de reputação;
   - cenas de interação (hospital, mercado, delegacia, abrigo).
4. Planejar persistência externa (futuro):
   - modelagem Prisma;
   - PostgreSQL (Railway) via variáveis de ambiente de plataforma.

---

## 5) Reaproveitamento previsto

- Sistema de mapa/cenas, assets, inventário base e fluxo de navegação do jogo original.
- Interface e identidade visual existentes para manter sensação de “jogo por cenas”.

## 6) Itens potencialmente descartáveis (após validação)

- Trechos de lógica estritamente focados em sobrevivência/zumbis que conflitem com RP social.
- Assets duplicados ou não referenciados.

Nenhum descarte foi executado nesta fase.
