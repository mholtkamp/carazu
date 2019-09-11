
SRC=\
  src/main.asm \
  src/rect.asm \
  src/font.asm \
  src/input.asm \
  src/player.asm \
  src/level.asm \
  src/sound.asm \
  src/music.asm \
  src/menu.asm \
  src/util.asm \
  src/stats.asm \
  src/item.asm \
  src/enemy.asm \
  src/bullet.asm \
  src/splash.asm \
  tiles/special_tiles.asm \
  tiles/item_tiles.asm \
  tiles/enemy_tiles.asm \
  tiles/bullet_tiles.asm \
  tiles/bg_tiles_0.asm \
  tiles/bg_tiles_1.asm \
  tiles/bg_tiles_2.asm \
  tiles/player_sprite_tiles.asm \
  levels/level_items.asm \
  levels/level_enemies.asm \
  levels/level_maps.asm \
  levels/level_properties.asm \
  music/song0.asm

OBJECTS=$(addprefix obj/,$(SRC:.asm=.obj))
TARGET=rom/carazu.gb

all: ${TARGET}

.PHONY: clean
clean:
	rm -rfv obj rom

obj/%.obj: %.asm
	mkdir -p obj obj/src obj/tiles obj/levels obj/music
	rgbasm -o$@ $^

${TARGET}: ${OBJECTS}
	mkdir -p rom
	rgblink -o${TARGET} -mrom/carazu.map -nrom/carazu.sym ${OBJECTS}
	rgbfix -v rom/carazu.gb # -p

