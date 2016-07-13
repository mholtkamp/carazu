INCLUDE "include/level.inc"
INCLUDE "include/player.inc"
INCLUDE "include/constants.inc"

; Level includes 
INCLUDE "levels/level0.inc"

; Tile Set includes
INCLUDE "tiles/bg_tiles_0.inc"

	SECTION "LevelData", BSS 
	
; Public 

BGScrollX:
DS 1 

BGScrollY:
DS 1

LevelColThresh:
DS 1 

LevelNum:
DS 1 

; Private
Scratch:
DS 1

	SECTION "LevelCode", HOME 
	
Level_Initialize::

	ld a, 0 
	ld [BGScrollX], a 
	ld [BGScrollY], a 
	ld [LevelNum], a 
	
	ret 
	
	
Level_Load:: 

	ld a, [LevelNum]
	sla a 
	sla a 			; mult by four to get jump table offset 
	ld c, a 
	ld b, 0 		; bc = jump table offset 
	
	ld hl, .jump_table
	add hl, bc 		; hl = address to jump 
	
	jp [hl]
	
.jump_table 
	jp .load_0
	nop 
	jp .load_1 
	nop 
	
	ret 
	
.load_0 
	ld a, Level0MapWidth
	ld hl, Level0Map
	ld bc, Level0Start 
	call _Level_LoadMap
	
	ld a, Level0TileSet
	call _Level_LoadTileSet
	
	ld b, Level0SpawnX
	ld c, Level0SpawnY 
	call Player_SetPosition
	
	ret 
	
.load_1 

	ret 
	

; _Level_LoadMap 
;  a = map width (blocks)
; bc = map start (block)
; hl = map data address 
_Level_LoadMap::

	ld [Scratch], a 			; save map width 

	ld  de, MAP_0 
	add hl, bc 
	
	ld b, VRAM_MAP_WIDTH		; 24 tiles wide
	ld c, VRAM_MAP_HEIGHT		; 24 tiles high
	
.loop 
	
	; copy map entry 
	ld a, [hl+]
	ld [de], a 
	inc de 
	
	dec b 
	jp nz, .loop 
	
	; move onto next row 
	ld b, VRAM_MAP_WIDTH 	; reset x counter
	
	; Get next row in ROM
	ld a, [Scratch]			; load the map width 
	sub b 					; subtract vram width to get next block offset
	push de 
	ld e, a 
	ld d, 0 
	add hl, de 				; add block offset
	pop de 
	
	; Get next row in VRAM 
	push hl 
	ld h, 0 
	ld l, 32 - VRAM_MAP_WIDTH			; 32 is size of row in vram. hl = offset to next row in vram 
	add hl, de 
	ld d, h  
	ld e, l
	pop hl 
	
	dec c 
	jp nz, .loop 
	
	ret 
	
_Level_LoadTileSet::

	sla a 
	sla a 		; multiply by 4 to get jump offset
	ld b, 0 
	ld c, a 
	
	ld hl, .jump_table 
	add hl, bc 
	
	jp [hl]
	
.jump_table
	jp .load_0 
	nop 
	
	
.load_0
	ld a, BGTiles0ColThresh
	ld [LevelColThresh], a 
	
	ld de, TILE_BANK_1
	ld hl, BGTiles0
	ld bc, BGTiles0Size
	jp .copy 
	
	
.copy 
	ld a, [hl+]
	ld [de], a 
	inc de 
	
	dec bc 
	ld a, b 
	or c 
	jp nz, .copy
	ret 