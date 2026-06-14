# APK Android offline debug para teste interno

## Escopo

Este APK existe somente para **teste privado e interno em celulares Android**.
Ele abre a cena principal offline atual, `res://world.tscn`, sem iniciar uma
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
projeto com `scripts/import_godot_project.sh`, gera
`minidayz-offline-debug.apk` e publica o artifact
`minidayz-offline-debug-apk`.

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
