# Protocolo de personagem RP temporário

## Objetivo

Esta etapa adiciona o primeiro personagem RP temporário ao servidor dedicado
do Mini DayZ Z Online RP. O personagem existe somente em memória enquanto o
processo do servidor está em execução e serve para validar a sequência:

1. conexão ENet;
2. sessão temporária aceita;
3. personagem temporário aceito;
4. spawn visual autorizado;
5. movimento autorizado.

Ele **não é o personagem final do jogo**. Esta implementação não instancia nem
altera `character/player/player.tscn`.

## Contrato compartilhado

`multiplayer/CharacterProtocol.gd` é um autoload compartilhado pelo cliente e
pelo servidor. Após a sessão ser aceita, o cliente chama:

```gdscript
request_temporary_character(first_name, last_name)
```

O cliente não envia `peer_id`. O servidor identifica o remetente real com
`multiplayer.get_remote_sender_id()`, valida nome e sobrenome e emite
`temporary_character_requested(peer_id, first_name, last_name)`.

O servidor responde somente ao peer remetente por um dos sinais:

- `temporary_character_accepted(peer_id, full_name)`;
- `temporary_character_rejected(reason)`.

## Validações

O servidor exige que:

- o peer esteja conectado;
- o peer já possua uma sessão temporária aceita;
- o peer ainda não possua personagem;
- nome e sobrenome não estejam vazios;
- cada parte tenha entre 3 e 16 caracteres;
- cada parte use somente letras ASCII (`A-Z` e `a-z`);
- números, espaços, símbolos e `_` não sejam aceitos.

As rejeições devolvem um motivo claro ao cliente. Estas regras são
deliberadamente simples e poderão evoluir quando existir conta, persistência,
moderação e uma política definitiva de nomes RP.

## Estado em memória

`server/ServerMain.gd` mantém:

```gdscript
characters[peer_id] = {
    "first_name": "...",
    "last_name": "...",
    "full_name": "...",
    "created_at": ...
}
```

Esse registro é perdido ao reiniciar o servidor. Ao desconectar, o peer, a
sessão, o personagem e a posição temporária são removidos.

## Dependência de spawn e movimento

A sessão aceita, sozinha, não gera mais spawn. A posição temporária só é
preparada quando o personagem é aceito. O servidor envia spawn e aceita
movimento somente quando o peer possui **sessão e personagem**.

O contrato de `SpawnProtocol.spawn_peer(peer_id, position)` foi mantido sem
nome nesta etapa para reduzir o risco da mudança. Por isso, o
`SimpleAvatar` continua exibindo o ID do peer. Exibir o nome RP sobre o avatar
fica para uma evolução futura do snapshot ou do protocolo visual.

## O que esta etapa não implementa

- cadastro ou login real;
- conta, senha, token ou recuperação de sessão;
- banco de dados ou PostgreSQL;
- persistência ou reconexão do personagem;
- inventário, status, skin ou aparência;
- personagem final ou `character/player/player.tscn`;
- zumbis, loot, dano, mapa final ou APK.

## Próximos passos para personagem persistente

1. implementar cadastro e login reais com credenciais protegidas;
2. criar identificadores persistentes de conta e personagem;
3. associar o personagem à conta autenticada;
4. definir regras definitivas e unicidade de nome RP;
5. criar uma camada de persistência acessível somente pelo servidor;
6. integrar PostgreSQL com migrações e transações;
7. persistir seleção, posição e aparência antes de inventário e status;
8. tratar reconexão sem duplicar sessão, personagem ou entidade.

Esses passos devem permanecer separados desta fundação temporária para que
segurança, persistência e gameplay possam ser revisados e testados
individualmente.
