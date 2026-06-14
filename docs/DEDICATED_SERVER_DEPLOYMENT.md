# Execução operacional do servidor dedicado

## Escopo desta etapa

Esta etapa prepara a primeira forma padronizada de executar o servidor
dedicado do Mini DayZ Z Online RP fora do APK, em um computador Linux ou em
uma futura VPS. Ela **não faz implantação automática**, não provisiona uma
VPS e não publica um servidor na internet.

Os scripts somente organizam os comandos Godot e suas variáveis de ambiente.
O servidor atual continua sendo a fundação técnica em memória: ainda não há
login real, banco de dados, persistência, personagem final nem capacidade
validada para 100 jogadores.

## Pré-requisitos

- Godot 4.6 disponível no `PATH`, normalmente pelo comando `godot`;
- repositório completo na máquina;
- terminal aberto na raiz do repositório;
- porta escolhida disponível.

O arquivo [`.env.example`](../.env.example) documenta valores de exemplo, mas
os scripts leem variáveis do ambiente do processo. Eles não exigem um arquivo
`.env` em produção.

## Iniciar o servidor localmente

Na raiz do repositório:

```bash
./scripts/run_dedicated_server.sh
```

O padrão usa `godot`, porta UDP `7000` e limite de 8 clientes. Para alterar os
valores apenas nessa execução:

```bash
GODOT_BIN=/usr/local/bin/godot PORT=7001 MAX_CLIENTS=16 \
  ./scripts/run_dedicated_server.sh
```

O runner valida a existência do Godot, a faixa da porta e o limite positivo
de clientes. Também prepara o diretório local `logs/`. Os logs do processo
continuam visíveis no terminal e, em um serviço systemd, podem ser consultados
pelo journal do sistema.

O limite configurado não comprova capacidade. O valor padrão de 8 é apenas um
parâmetro operacional inicial, não uma promessa de escala.

## Iniciar um cliente dedicado

Com o servidor em execução, abra outro terminal na raiz do repositório:

```bash
./scripts/run_dedicated_client.sh
```

Para personalizar o destino e os dados temporários:

```bash
SERVER_ADDRESS=127.0.0.1 PORT=7000 \
SESSION_NAME=SessionOne FIRST_NAME=Client LAST_NAME=One \
  ./scripts/run_dedicated_client.sh
```

`SESSION_NAME`, `FIRST_NAME` e `LAST_NAME` pertencem somente aos protocolos
temporários atuais. Eles não representam cadastro, autenticação ou personagem
persistente.

## Porta e firewall

O ENet usado pelo projeto precisa da porta escolhida em **UDP**. Em uma futura
VPS, será necessário liberar, por exemplo, `7000/udp` tanto no firewall do
Linux quanto nas regras de rede do provedor. Não é necessário publicar essa
porta para testes feitos inteiramente em `127.0.0.1`.

Evite liberar portas sem antes configurar acesso administrativo seguro,
atualizações do sistema e regras mínimas de firewall. Essa preparação será
tratada em uma etapa posterior de implantação real.

## Modos dedicados

- `--dedicated-server` inicia `server/server_main.tscn` em modo headless. Esse
  processo aceita conexões e mantém o estado temporário autorizado pelo
  servidor, sem interface, câmera ou controle de jogador.
- `--dedicated-client` identifica o fluxo cliente conectado ao servidor
  dedicado. O cliente solicita sessão e personagem temporários e aguarda a
  autorização do servidor antes de criar o avatar visual.

Esses modos não devem ser confundidos com o fluxo legado `--host`, mantido
somente para testes técnicos locais.

## Exemplo de serviço systemd

O arquivo
[`deploy/systemd/minidayz-dedicated.service.example`](../deploy/systemd/minidayz-dedicated.service.example)
é uma referência segura, sem dados reais de usuário. Antes de uso futuro, um
administrador deverá:

1. instalar o projeto em `/opt/minidayz-online`;
2. instalar o Godot no caminho configurado;
3. criar um usuário de serviço sem privilégios;
4. copiar e adaptar o exemplo para `/etc/systemd/system/`;
5. liberar a porta UDP escolhida;
6. habilitar e iniciar o serviço com `systemctl`.

O exemplo não é instalado nem ativado automaticamente por esta mudança.

## Limitações mantidas

- nenhum APK Android é gerado nesta etapa;
- nenhuma VPS real é criada ou configurada;
- nenhum servidor público fica online;
- não há cadastro ou login real;
- não há PostgreSQL ou outro banco de dados;
- sessão, personagem e posição não persistem após reiniciar o processo;
- inventário, dano, status, zumbis e loot não foram adicionados ao servidor;
- a meta futura de 100 jogadores não foi implementada nem validada.

Uma VPS real, observabilidade, desligamento gracioso, recuperação, segurança,
persistência e testes de carga serão etapas posteriores e separadas.

## Importação no CI

Antes do smoke test, o GitHub Actions executa
`scripts/import_godot_project.sh`. O script guarda a saída completa em
`artifacts/godot-import/import.log` e preserva o código real retornado pelo
Godot.

Em alguns ambientes Linux headless, o Godot pode exibir `[ DONE ] reimport` e
depois abortar durante o encerramento com uma falha nativa, como
`double free or corruption`. Nessa situação específica, o cache já terminou
de ser gerado e o workflow continua com um aviso. Se o marcador de conclusão
não estiver no log, a etapa falha com o código retornado pelo Godot.

Essa tolerância não considera o projeto automaticamente válido. O smoke test
runtime de servidor e dois clientes continua sendo a validação final de que o
cache importado pode ser usado. Tanto o log de importação quanto os logs do
runtime são publicados como artifacts do workflow.
