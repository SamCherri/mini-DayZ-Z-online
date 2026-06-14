# Validação offline da base Godot

Data da validação: 14 de junho de 2026.

## Escopo

Esta validação cobre somente a abertura, a importação e a tentativa de
inicialização offline da base Godot importada pela PR #3. Nenhum recurso de
multiplayer, sistema RP, asset ou elemento de identidade visual foi alterado.

## Configuração confirmada

- O arquivo `project.godot` usa `config_version=5`.
- A versão declarada em `config/features` é Godot 4.6 com o renderizador
  `Forward Plus`.
- A cena `world.tscn` existe e contém um nó raiz `World` do tipo `Node2D`.
- O projeto importado não possuía `application/run/main_scene`.
- `world.tscn` foi configurada como cena principal pelo UID
  `uid://b3rbvu3iaughq`.

## Tentativas realizadas

1. A instalação local foi verificada com `command -v godot` e
   `command -v godot4`. Nenhum executável Godot está instalado na imagem.
2. Foi tentada a consulta da versão oficial `4.6-stable` pela API de releases
   do Godot no GitHub para obter um binário compatível.
3. A consulta externa retornou HTTP 403, portanto não foi possível instalar o
   editor, importar os recursos nem iniciar a janela do jogo neste ambiente.

## Erros e limitações encontrados

### Corrigido

- **Cena principal ausente:** executar o projeto pelo editor não tinha uma
  cena inicial definida. A configuração agora aponta para `world.tscn`.
- **Caminho de textura com capitalização incorreta:** o recurso
  `pipe_wrench.tres` apontava para `pipe_Wrench.png`, que não existe em
  sistemas de arquivos sensíveis a maiúsculas. O caminho agora corresponde ao
  arquivo real `pipe_wrench.png`; o asset em si não foi alterado.

### Pendente por limitação do ambiente

- **Godot indisponível:** não há binário `godot` ou `godot4` instalado.
- **Download bloqueado:** o acesso à API de releases do GitHub respondeu HTTP
  403.
- Como consequência, a importação real dos assets, a validação dos scripts
  pelo parser do Godot e a execução offline não puderam ser concluídas nesta
  imagem.

A verificação estática confirmou que, após a correção acima, todos os caminhos
`res://` declarados nos arquivos `.tscn` e `.tres` apontam para arquivos
existentes. Não foi identificado nem ocultado outro erro de execução: erros
internos que dependam do parser ou do runtime só poderão ser enumerados depois
que o Godot 4.6 conseguir importar e iniciar a cena.

## Como concluir a validação em uma máquina com Godot 4.6

Na raiz do repositório, execute:

```bash
godot --editor --path .
```

Espere a importação terminar e confirme que `world.tscn` abre no editor.
Depois, teste a inicialização offline:

```bash
godot --path .
```

Para uma verificação sem janela, útil em CI:

```bash
godot --headless --path . --editor --quit
godot --headless --path . --quit-after 10
```

Se o executável da instalação se chamar `godot4`, substitua `godot` por
`godot4` nos comandos.
