# Validação da importação da base Godot

Data da auditoria: 14 de junho de 2026.

## Resultado atual

A base Godot ainda não foi copiada para este repositório. O acesso direto ao
repositório público `011eh/minidayz` e ao arquivo ZIP do branch `master`
retornou HTTP 403 neste ambiente. Para evitar uma importação parcial ou sem
proveniência verificável, nenhum arquivo de jogo foi criado manualmente.

Um arquivo local chamado `Mini DayZ rpg.zip` foi auditado e removido. O pacote
continha uma aplicação Construct/Cordova (`c2runtime.js`, `cordova.js`,
`data.js` e uma pasta extensa de imagens), não a árvore Godot pública esperada.
Ele não foi extraído nem usado como fonte porque a licença e a origem de seus
recursos não estavam demonstradas.

## Informações confirmadas na fonte pública

- **Engine:** Godot 4.
- **Versão declarada:** Godot 4.6, conforme `config/features` no
  `project.godot` público consultado em 14 de junho de 2026.
- **Formato do projeto:** `config_version=5`.
- **Cena de mundo encontrada:** `world.tscn`, cujo nó raiz é `World`
  (`Node2D`).
- **Cena principal configurada:** não confirmada. O `project.godot` consultado
  não apresenta `run/main_scene`; portanto, `world.tscn` é a candidata evidente,
  mas não deve ser registrada como cena principal sem validar a árvore completa
  no editor.
- **Licença do repositório de referência:** Apache License 2.0.

## Teste offline

Não foi possível abrir ou executar o jogo:

1. os arquivos da base Godot não puderam ser baixados por causa do HTTP 403;
2. não há executável `godot`, `godot4` ou `godot3` instalado neste ambiente;
3. sem a árvore completa, não é seguro inventar dependências ou ajustar UIDs.

Logo, ainda não foi validado se o personagem aparece, se o movimento funciona
ou se existem erros de importação de recursos.

## Procedimento seguro para continuar

Em uma máquina com acesso ao GitHub:

```bash
git clone https://github.com/011eh/minidayz.git /tmp/minidayz
rsync -a --exclude=.git /tmp/minidayz/ ./
```

Antes de criar o próximo commit:

1. comparar o `LICENSE` importado com a Apache-2.0;
2. preservar `README.md` e avisos de projeto de fã deste repositório;
3. registrar o commit exato da fonte em `ATTRIBUTION.md`;
4. abrir o projeto com Godot 4.6;
5. selecionar `world.tscn` apenas se o editor pedir uma cena principal;
6. executar `godot --path . --editor --quit` para importar recursos;
7. executar `godot --path . --headless --quit-after 10` para verificar erros
   básicos, quando a cena principal estiver configurada.

## Limites desta etapa

- Nenhum multiplayer foi implementado.
- Nenhuma identidade visual foi alterada.
- Nenhum APK foi usado como fonte.
- Nenhum recurso de origem incerta foi reaproveitado.
