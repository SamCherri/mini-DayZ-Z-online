# Auditoria de assets — MVP offline Android

## Objetivo e limites

Esta auditoria cobre somente o protótipo interno em `debug/`. Nenhum asset foi
criado, alterado ou obtido externamente. O MVP não carrega CSVs, não reutiliza
scripts de gameplay definitivo e não depende de servidor, login ou multiplayer.

## Assets encontrados e usados agora

| Categoria | Assets confirmados | Uso no MVP |
| --- | --- | --- |
| Player | `asset/images/character/player_skin/player_skin_def_1.png`, `player_base-sheet0.png`, mãos e retrato | `player_skin_def_1.png` como spritesheet estático (4 x 11); círculo antigo apenas como fallback |
| Zumbis | `zed_normal_skin1..8.png`, `zed_fast_skin1..3.png`, `zed_tank_skin.png`, `zed_screamer.png`, skins army e olhos | normal, fast e tank como frames estáticos; marcador vermelho apenas como fallback |
| Terreno | `ground_tilemap.png`, `ground_enviroment_tilemap.png`, `tilemap_forest.png`, `tilemap_bunker.png` | catálogo e diagnóstico; o fundo usa paleta procedural segura porque os arquivos são atlas, não tiles independentes |
| Vegetação | `tree_leaves_1..4.png`, `tree_pine_1..2.png`, `berry_bush.png`, `tree_block.png` | quatro variações reais distribuídas em mais de 20 posições |
| Construções | casas urbanas, casas de vila, igreja, posto, hospital, polícia, galpão e supermercado | casa, posto, galpão e hospital como sprites decorativos |
| Objetos | carros, barricadas, cercas, lixeiras, banco, bloco de areia e bomba d'água | carro e barricada no cenário |
| Loot | `environment/bunker/bunker_lootbox.png`, baús de construções e `spawn_loot_point-sheet0.png` | três caixas interativas com mudança visual temporária |
| UI touch | attack, interact, inventory, switch, dpad field/stick, pad button e pad stick | dpad, knob, ataque e inventário aplicados aos controles existentes |

## Disponíveis para uma etapa posterior

- Composição de personagem com base, pele, mãos, roupas e equipamento.
- Animações completas do player e dos tipos de zumbi.
- TileMap real com seleção correta das células dos atlas de terreno.
- Interiores, portas, cercas com colisão e variações de construções.
- Retrato, slots, itens e demais elementos da interface original.
- Sons já existentes para passos, ambiente, interação e zumbis.

Esses itens exigem conhecer os frames, offsets, camadas e regras do gameplay
original. Foram evitados nesta PR para manter o MVP pequeno e isolado.

## Assets deliberadamente não usados

- `player_base-sheet0.png` tem apenas 2 x 2 pixels e faz parte da composição do
  personagem; isolado não produz um personagem reconhecível.
- Os atlas `ground_tilemap.png`, `ground_enviroment_tilemap.png`,
  `tilemap_forest.png` e `tilemap_bunker.png` não são aplicados diretamente como
  uma imagem gigante para evitar exibir o atlas inteiro ou depender de um
  `TileSet` de produção.
- Cenas e scripts do player, zumbis, inventário, loot e mapa definitivos não são
  instanciados. Isso evita dependências de autoloads, CSVs, rede e regras ainda
  fora do escopo do APK offline.
- Assets de olhos, mãos e interiores não são sobrepostos sem os metadados de
  animação corretos.

## Estratégia de fallback

`OfflineMvpAssetCatalog.gd` valida cada caminho com `ResourceLoader.exists()`.
Quando um recurso não pode ser carregado, registra
`[OfflineMvpAssetCatalog] fallback visual` e o respectivo nó desenha a forma
debug anterior. Assim, um asset ausente não impede o boot da cena.
