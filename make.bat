rgbasm -oobj/main.obj src/main.asm
rgbasm -oobj/rect.obj src/rect.asm
rgbasm -oobj/font.obj src/font.asm

rgbasm -oobj/bg_tiles.obj tiles/bg_tiles.asm
rgbasm -oobj/sprite_tiles.obj tiles/sprite_tiles.asm

rgbasm -oobj/bg_map.obj maps/bg_map.asm

xlink -mrom/carazu.map -nrom/carazu.sym carazu.link
rgbfix -v -p rom/carazu.gb