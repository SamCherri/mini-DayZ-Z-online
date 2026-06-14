# Protocolo de sessão temporária do servidor dedicado

## Objetivo

Esta etapa adiciona o primeiro handshake de sessão ao servidor dedicado do
Mini DayZ Z Online RP. A sessão existe somente em memória enquanto o processo
do servidor está em execução e serve para impedir que uma conexão ENet receba
spawn ou envie movimento antes de ser identificada por um nome temporário
válido.

Ela **não é cadastro ou login real**. Não há senha, conta, personagem final,
token de autenticação ou banco de dados nesta camada.

## Contrato compartilhado

`multiplayer/SessionProtocol.gd` é registrado como autoload no cliente e no
servidor. O fluxo usa RPCs confiáveis:

1. depois de conectar, o cliente chama `request_session(display_name)`;
2. o RPC não aceita um `peer_id` escolhido pelo cliente;
3. o servidor identifica a conexão com
   `multiplayer.get_remote_sender_id()`;
4. o protocolo valida o nome e emite `session_requested(peer_id, display_name)`;
5. `server/ServerMain.gd` cria a sessão em memória;
6. o servidor responde com aceite ou rejeição somente ao peer remetente;
7. após o aceite, o servidor envia os eventos de spawn autorizados.

Os sinais compartilhados são:

- `session_requested(peer_id, display_name)`, usado pelo servidor;
- `session_accepted(peer_id, display_name)`, recebido pelo cliente;
- `session_rejected(reason)`, recebido pelo cliente.

## Validação temporária de nome

O nome:

- não pode ser vazio;
- deve ter entre 3 e 20 caracteres;
- aceita somente letras ASCII, números e `_`;
- tem espaços externos removidos antes da validação.

Essas regras são deliberadamente simples e servem apenas ao handshake técnico.
Elas não representam as futuras regras de nome e sobrenome RP.

Como o peer é obtido do remetente real do RPC, o cliente não escolhe para qual
peer criar uma sessão. A resposta de aceite também é recusada no cliente se
trouxer um ID diferente do ID local.

## Estado mantido pelo servidor

`server/ServerMain.gd` mantém dois registros separados:

```gdscript
connected_peers[peer_id] = {
    "connected_at": ...,
    "position": ... # adicionada somente após a sessão
}

sessions[peer_id] = {
    "display_name": "...",
    "created_at": ...
}
```

A conexão é registrada imediatamente, mas a posição e o spawn só são
preparados depois da sessão aceita. Ao desconectar, o servidor remove o peer e
a sessão. Como tudo está em memória, reiniciar o processo perde todos esses
dados.

## Dependência de spawn e movimento

O servidor dedicado passa a exigir uma sessão aceita:

- **spawn:** não acontece ao conectar; acontece após criar a sessão;
- **movimento:** inputs de peers sem sessão são ignorados;
- **snapshots:** são enviados somente aos peers com sessão;
- **despawn:** é enviado aos peers com sessão quando outro peer autenticado
  temporariamente desconecta.

O avatar continua sendo `multiplayer/simple_avatar.tscn`. Nenhuma entidade de
personagem final é criada no servidor.

## Uso no smoke test

O teste automatizado inicia os clientes assim:

```bash
godot --headless --path . -- \
  --connect 127.0.0.1 --port 7000 --test-name ClientOne --test-move

godot --headless --path . -- \
  --connect 127.0.0.1 --port 7000 --test-name ClientTwo
```

Se `--test-name` não for informado, o cliente usa temporariamente
`Guest<peer_id>`, por exemplo `Guest2`. Uma interface futura deverá substituir
essa escolha automática.

O CI aguarda primeiro:

- `SessionProtocol: sessão aceita`;
- `ServerMain: sessão criada`.

Somente depois valida spawn, movimento, desconexão e despawn.

### Inicialização isolada do inventário

O autoload `ItemActionTable` aponta para
`item/item_action_table_autoload.gd`. Essa fachada não carrega receitas,
classes de item ou texturas durante o boot. No cliente normal, a implementação
original é carregada sob demanda quando a interface chama uma operação real de
inventário ou crafting. No processo com `--dedicated-server`, essas operações
retornam valores vazios seguros porque o servidor deste marco não usa
inventário.

Essa separação não remove receitas nem muda o inventário do jogo. Ela apenas
impede que recursos de gameplay fora do escopo bloqueiem o smoke test de
sessão, spawn e movimento.

Os arquivos ocultos de munição `.22lr_ammo.png`, `.45_acp_ammo.png` e
`.357_ammo.png` foram verificados e estão versionados como PNGs válidos em
`asset/images/item/`. Os respectivos `.import` não são versionados porque o
`.gitignore` exclui arquivos gerados pelo Godot. Como nomes iniciados por ponto
podem exigir tratamento futuro na importação de assets, nenhuma imagem foi
substituída nesta correção; o isolamento lazy evita que elas sejam exigidas
pelo servidor dedicado atual.

## Limitações e próximos passos

Esta camada não oferece segurança de conta:

- não há cadastro;
- não há senha ou hash de senha;
- não há token ou expiração;
- não há recuperação ou retomada de sessão;
- não há nome RP completo ou unicidade global;
- não há personagem persistente;
- não há PostgreSQL ou qualquer outro banco;
- não há limite de tentativas, bloqueio por abuso ou observabilidade completa.

Os próximos passos devem permanecer separados e revisáveis:

1. criar cadastro e login reais com credenciais protegidas;
2. emitir sessões autenticadas com expiração e reconexão segura;
3. associar conta a um personagem selecionado;
4. validar nome e estado do personagem no servidor;
5. integrar PostgreSQL somente pela camada do servidor;
6. persistir posição e personagem antes de inventário e demais sistemas;
7. adicionar limites, auditoria e métricas contra abuso.

Até essas etapas existirem, `display_name` é apenas uma identificação
temporária para validar o fluxo de rede.
