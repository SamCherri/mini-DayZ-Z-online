# APK Android offline debug para teste interno

## Escopo

Este APK existe somente para **teste privado e interno em celulares Android**.
Ele não é uma release pública. A build usa a cena de boot temporária
`res://debug/AndroidBootDebug.tscn` para validar visualmente a abertura de
`res://world.tscn`, sem login, servidor, banco de dados ou multiplayer real.

Esta trilha de build é paralela à evolução online do projeto. Ela não altera,
substitui nem valida o servidor dedicado.

## Limitações importantes

- não é uma release pública;
- não está pronto para publicação na Play Store;
- não comprova que o multiplayer online funciona;
- não usa o servidor dedicado;
- não possui login real;
- não possui banco de dados;
- não adiciona persistência, gameplay online ou novos sistemas;
- usa um player, uma câmera, marcadores e controles touch temporários de debug;
- pode conter nome, ícone, sprites, sons e outros assets temporários que
  precisam ser revisados e substituídos antes de qualquer publicação.

O arquivo é assinado com uma chave de desenvolvimento gerada pelo GitHub
Actions. Essa assinatura serve apenas para instalar a build debug em aparelhos
de teste e não deve ser usada para uma futura versão pública.

## Gerar o APK no GitHub Actions

1. Abra o repositório no GitHub.
2. Toque ou clique na aba **Actions**.
3. Selecione o workflow **Android offline debug APK**.
4. Use **Run workflow**, escolha a branch desejada e confirme em
   **Run workflow**.
5. Aguarde a execução ficar verde.

O workflow baixa o Godot 4.6 e seus templates de exportação Android, importa o
projeto com `scripts/import_godot_project.sh`, grava a configuração Android do
editor diretamente com `scripts/configure_android_export_settings.sh`, ativa
o boot temporário com `scripts/prepare_offline_debug_boot.sh`, gera
`minidayz-offline-debug.apk` e publica o artifact `minidayz-offline-debug-apk`.

## Boot temporário de diagnóstico

O `project.godot` versionado continua apontando para `res://world.tscn`.
Somente depois da importação e imediatamente antes da exportação do APK offline,
o workflow cria um backup do arquivo no diretório temporário do runner e troca
a main scene para `res://debug/AndroidBootDebug.tscn`. Como o runner do GitHub
Actions é descartável, essa alteração não afeta o editor, a execução no PC ou
os outros workflows.

Ao abrir o APK, a tela escura mostra imediatamente:

- **MiniDayZ Offline Debug**;
- **MVP Offline Android**;
- **Pronto para carregar world.tscn**;
- **Toque em Carregar mundo**;
- a versão do Godot, a plataforma e a identificação da build;
- o botão grande **Carregar mundo**.

A tela fica parada até o toque manual em **Carregar mundo**. Não há timer,
carregamento por frame nem transição automática. Depois do toque, o botão é
desabilitado e a tela mostra **Carregando world.tscn**. Se o recurso não puder
ser carregado ou instanciado, a mensagem **Erro ao carregar world.tscn**
permanece visível e o botão é reabilitado para uma nova tentativa.

Quando o carregamento funciona, o boot adiciona o mundo à árvore e mantém um
overlay persistente no canto superior esquerdo. Ele informa:

- **DEBUG APK: world carregado**;
- nome e classe do root do mundo;
- quantidade de filhos diretos;
- se a `Camera2D` foi encontrada ou criada;
- se o player/marcador temporário foi criado;
- se os controles touch estão ativos.

O botão **Ocultar debug** remove o painel e o marcador central para liberar a
visualização da jogabilidade. Esse comando não remove o player, a câmera nem os
controles touch.

## MVP offline temporário

O APK inclui componentes exclusivos da trilha de diagnóstico:

- `res://debug/OfflineDebugPlayer.tscn`: player verde temporário, identificado
  como **PLAYER DEBUG**, que nasce na origem e usa as ações `move_left`,
  `move_right`, `move_up` e `move_down`;
- uma `Camera2D` ativa, criada quando o mundo não oferece uma câmera ativa e
  posicionada para acompanhar o player debug;
- marcador de origem dentro do mundo e marcador de tela
  **MARCADOR DEBUG VISÍVEL / MVP OFFLINE**;
- `res://debug/MobileDebugControls.tscn`: joystick virtual, botão **Ação**,
  botão **Inventário** e indicador **DEBUG TOUCH ENABLED**.

O joystick converte toque e arrasto nas mesmas ações de movimento já usadas no
PC. O botão **Ação** usa `attack` quando essa ação existe e recorre a `interact`
como alternativa. O botão **Inventário** usa `toggle_inventory`. Esses
componentes não substituem nem alteram o player, inventário ou gameplay
definitivos; servem apenas para validar renderização, entrada touch, câmera e
movimento no Android antes da implementação móvel final.

Durante a execução do APK, o log do aplicativo (por exemplo, via `adb logcat`)
registra as etapas com o prefixo `[AndroidBootDebug]`: início do boot, tentativa
de load, load, instanciação, adição à árvore e eventual erro com o caminho do
recurso.

Esse boot é estritamente diagnóstico. Ele não modifica servidor dedicado,
protocolos multiplayer, login, banco, inventário, zumbis, loot, status, player
ou assets finais.

## Roteiro de teste no celular

1. Abra o APK e confirme que **MiniDayZ Offline Debug** permanece na tela.
2. Toque em **Carregar mundo**.
3. Confirme que o overlay mostra **DEBUG APK: world carregado** e os estados de
   câmera, player e touch.
4. Confirme que aparecem o marcador central, **PLAYER DEBUG**, o joystick e os
   botões **Ação** e **Inventário**.
5. Toque em **Ocultar debug** para liberar o centro da tela.
6. Arraste o joystick e confirme que o player se move e a câmera o acompanha.
7. Pressione **Ação** e **Inventário** e observe a mensagem no canto superior
   direito e, se estiver usando `adb logcat`, os registros correspondentes.
8. Se a tela continuar cinza ou algum elemento não aparecer, tire um print com
   o overlay aberto. O texto do overlay ajuda a identificar exatamente qual
   etapa falhou.

Essa configuração não carrega o projeto nem executa um script GDScript. O
script shell valida o Android SDK, o Java e a chave debug e então cria
`${HOME}/.config/godot/editor_settings-4.tres` no runner.

Durante a importação, o CI salva o log original e uma cópia normalizada, sem
carriage returns e códigos ANSI, no artifact `godot-android-import-logs`.
Crashes nativos ocorridos depois dos marcadores seguros
`[ DONE ] reimport` ou `[ DONE ] loading_editor_layout` são tolerados. Se o
Godot falhar antes de alcançar um desses marcadores, o workflow continua
bloqueado para não exportar um projeto cuja importação esteja incompleta.

## Baixar o artifact no celular

1. No navegador do celular, entre na mesma conta do GitHub que tem acesso ao
   repositório.
2. Abra **Actions** e toque na execução concluída do workflow
   **Android offline debug APK**.
3. Role até a seção **Artifacts**.
4. Toque em **minidayz-offline-debug-apk** para baixar o arquivo compactado.
5. Abra o arquivo `.zip`, extraia `minidayz-offline-debug.apk` e toque no APK
   para iniciar a instalação.

O Android pode pedir autorização para instalar aplicativos vindos do navegador
ou do gerenciador de arquivos. Ative essa permissão somente para essa
instalação privada e desative-a depois, se desejar. Se uma versão anterior com
assinatura diferente estiver instalada, pode ser necessário desinstalá-la
antes.

Artifacts do GitHub Actions expiram conforme a política configurada no
repositório. Se o download não estiver mais disponível, execute novamente o
workflow manual.
