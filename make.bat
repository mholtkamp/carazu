rgbasm -oobj/main.obj src/main.asm
rgbasm -oobj/rect.obj src/rect.asm
rgbasm -oobj/font.obj src/font.asm
rgbasm -oobj/input.obj src/input.asm 
rgbasm -oobj/player.obj src/player.asm 
rgbasm -oobj/level.obj src/level.asm

rgbasm -oobj/bg_tiles_0.obj tiles/bg_tiles_0.asm
rgbasm -oobj/sprite_tiles.obj tiles/sprite_tiles.asm

rgbasm -oobj/level0.obj levels/level0.asm

xlink -mrom/carazu.map -nrom/carazu.sym carazu.link
rgbfix -v -p rom/carazu.gb