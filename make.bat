if not exist "obj/" mkdir obj
if not exist "rom/" mkdir rom

rgbasm -oobj/main.obj src/main.asm
rgbasm -oobj/rect.obj src/rect.asm
rgbasm -oobj/font.obj src/font.asm
rgbasm -oobj/input.obj src/input.asm 
rgbasm -oobj/player.obj src/player.asm 
rgbasm -oobj/level.obj src/level.asm
rgbasm -oobj/sound.obj src/sound.asm 
rgbasm -oobj/music.obj src/music.asm 
rgbasm -oobj/menu.obj src/menu.asm 
rgbasm -oobj/util.obj src/util.asm
rgbasm -oobj/stats.obj src/stats.asm
rgbasm -oobj/item.obj src/item.asm 
rgbasm -oobj/enemy.obj src/enemy.asm 

rgbasm -oobj/special_tiles.obj tiles/special_tiles.asm
rgbasm -oobj/item_tiles.obj tiles/item_tiles.asm
rgbasm -oobj/enemy_tiles.obj tiles/enemy_tiles.asm 
rgbasm -oobj/bg_tiles_0.obj tiles/bg_tiles_0.asm
rgbasm -oobj/player_sprite_tiles.obj tiles/player_sprite_tiles.asm

rgbasm -oobj/level_items.obj levels/level_items.asm
rgbasm -oobj/level_enemies.obj levels/level_enemies.asm
rgbasm -oobj/level0.obj levels/level0.asm
rgbasm -oobj/level1.obj levels/level1.asm
rgbasm -oobj/level2.obj levels/level2.asm
rgbasm -oobj/level3.obj levels/level3.asm

rgbasm -oobj/song0.obj music/song0.asm 

xlink -mrom/carazu.map -nrom/carazu.sym carazu.link
rgbfix -v -p rom/carazu.gb