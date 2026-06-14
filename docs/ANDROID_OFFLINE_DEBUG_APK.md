# APK Android offline debug para teste interno

## Escopo

Este APK existe somente para **teste privado e interno em celulares Android**.
Ele usa uma cena de boot temporária, `res://debug/AndroidBootDebug.tscn`, para
diagnosticar visualmente a abertura de `res://world.tscn`, sem iniciar uma
conexão automática e sem exigir o argumento `--dedicated-client`.

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
- o estado atual do boot;
- a versão do Godot, a plataforma e a identificação da build;
- o botão **Carregar mundo**, que também permite repetir a tentativa após erro.

A cena tenta carregar `res://world.tscn` automaticamente depois de aguardar um
frame. Se o recurso não puder ser carregado ou instanciado, a mensagem
**Erro ao carregar world.tscn** permanece visível e o aplicativo não fecha
silenciosamente. Se o carregamento funcionar, o mundo é adicionado à árvore e
um pequeno selo **DEBUG APK: world carregado** permanece no canto superior.
Assim, uma tela vazia com o selo indica que o mundo existe na árvore, mas está
invisível; sem o selo, a própria tela informa a etapa ou o erro alcançado.

Durante a execução do APK, o log do aplicativo (por exemplo, via `adb logcat`)
registra as etapas com o prefixo `[AndroidBootDebug]`: início do boot, tentativa
de load, load, instanciação, adição à árvore e eventual erro com o caminho do
recurso.

Esse boot é estritamente diagnóstico. Ele não modifica servidor dedicado,
protocolos multiplayer, login, banco, inventário, zumbis, loot, status, player
ou assets finais.

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
