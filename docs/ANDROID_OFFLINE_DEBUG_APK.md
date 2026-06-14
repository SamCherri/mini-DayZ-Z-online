# APK Android offline debug para teste interno

## Escopo

Este APK existe somente para **teste privado e interno em celulares Android**.
Ele não é uma release pública. A build usa a cena de boot temporária
`res://debug/AndroidBootDebug.tscn` para abrir a cena jogável
`res://debug/OfflineMvpWorld.tscn`, sem login, servidor, banco de dados ou
multiplayer real.

Esta trilha é paralela à evolução online. Ela não altera, substitui nem valida
o servidor dedicado, os protocolos multiplayer ou o mapa final.

## Limitações importantes

- não está pronto para publicação na Play Store;
- não comprova que o multiplayer online funciona;
- não usa servidor, login, banco de dados ou persistência;
- mapa, player, status, loot, interação e zumbis são temporários;
- pode conter nome, ícone e outros assets temporários que precisam ser
  revisados antes de uma publicação.

O APK é assinado com uma chave de desenvolvimento gerada pelo GitHub Actions.
Essa assinatura serve apenas para instalação interna e não deve ser usada em
uma futura versão pública.

## Gerar o APK no GitHub Actions

1. Abra o repositório no GitHub e entre na aba **Actions**.
2. Selecione o workflow **Android offline debug APK**.
3. Use **Run workflow**, escolha a branch e confirme.
4. Aguarde a execução ficar verde.
5. Baixe o artifact **minidayz-offline-debug-apk**.

O workflow baixa o Godot 4.6 e os templates Android, importa o projeto com
`scripts/import_godot_project.sh`, configura o editor com
`scripts/configure_android_export_settings.sh`, ativa o boot temporário com
`scripts/prepare_offline_debug_boot.sh` e exporta
`minidayz-offline-debug.apk`.

## Boot temporário e cena carregada

O `project.godot` versionado continua apontando para `res://world.tscn`.
Somente antes da exportação do APK offline, no runner descartável, o workflow
troca a main scene para `res://debug/AndroidBootDebug.tscn`. Isso não altera a
execução normal no editor nem os workflows online.

Ao abrir o APK, a tela permanece parada e mostra:

- **MiniDayZ Offline Debug**;
- **MVP Offline Android**;
- **Pronto para carregar o MVP offline**;
- versão do Godot e plataforma;
- botão grande **Carregar mundo**.

Não há transição automática. Ao tocar em **Carregar mundo**, o boot carrega
`res://debug/OfflineMvpWorld.tscn`, sem depender do conteúdo visual atual de
`world.tscn`. O painel técnico passa a informar:

- **MVP OFFLINE carregado**;
- nome e classe do root;
- player ativo;
- câmera ativa;
- touch ativo;
- quantidade de objetos criados;
- quantidade de zumbis fake criados.

O marcador central grande fica oculto por padrão depois do carregamento. O
botão **Ocultar debug** esconde o pequeno painel técnico sem remover o mapa,
HUD, player, câmera ou controles.

## MVP offline temporário

`res://debug/OfflineMvpWorld.tscn` é um mundo `Node2D` temporário de 3000 x
3000 pixels. Seu script desenha proceduralmente fundo verde, grade, estradas,
clareira, abrigo, árvores e pedras, evitando dependência de assets finais.

O MVP contém:

- `res://debug/OfflineDebugPlayer.tscn`, player verde identificado como
  **PLAYER DEBUG**, nascido no centro do mapa;
- movimento pelas ações `move_left`, `move_right`, `move_up` e `move_down`;
- `Camera2D` filha do player, com zoom para celular, suavização e limites;
- HUD com vida, fome e sede fictícias;
- textos **MVP OFFLINE ANDROID** e **Sem servidor / Sem login**;
- três caixas fake que mostram **Interagiu com caixa** quando a ação é usada
  perto delas;
- três zumbis geométricos fake, com movimento lento, aviso de proximidade e
  redução apenas da vida fictícia;
- joystick virtual, botão **Ação**, botão **Inventário** e feedback visual.

O joystick converte toque e arrasto nas ações de movimento usadas no PC. O
botão **Ação** usa `attack` quando disponível e `interact` como alternativa.
O botão **Inventário** usa `toggle_inventory` e mostra **Inventário debug**.

O `res://world.tscn` original permanece disponível para diagnóstico e evolução
futura. Ele não foi substituído. O mapa procedural existe apenas para validar
Android, touch, câmera, renderização e um ciclo mínimo de exploração antes da
integração do gameplay final.

## Roteiro de teste no celular

1. Abra o APK e confirme que a tela inicial permanece aguardando.
2. Toque em **Carregar mundo**.
3. Confirme **MVP OFFLINE carregado** e os estados no painel.
4. Confirme terreno, grade, estradas, árvores, pedras, caixas e zumbis.
5. Confirme **PLAYER DEBUG**, joystick, **Ação** e **Inventário**.
6. Arraste o joystick e verifique movimento e acompanhamento da câmera.
7. Aproxime-se de uma caixa, toque em **Ação** e confirme
   **Interagiu com caixa**.
8. Toque em **Inventário** e confirme **Inventário debug**.
9. Aproxime-se de um zumbi e confirme o aviso e a vida fictícia reduzida.
10. Toque em **Ocultar debug** e teste com o painel técnico escondido.

Se a tela ficar cinza ou algum elemento não aparecer, tire um print com o
painel aberto e, se possível, capture `adb logcat`. Os logs usam os prefixos
`[AndroidBootDebug]`, `[OfflineMvpWorld]` e `[MobileDebugControls]`.

## Baixar e instalar no celular

1. Na execução concluída do workflow, role até **Artifacts**.
2. Baixe **minidayz-offline-debug-apk**.
3. Extraia `minidayz-offline-debug.apk`.
4. Toque no APK e permita temporariamente a instalação pelo navegador ou
   gerenciador de arquivos.

Se uma versão anterior tiver assinatura diferente, pode ser necessário
desinstalá-la. Artifacts expiram conforme a política do GitHub; execute o
workflow novamente quando necessário.
