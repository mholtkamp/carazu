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

MapWidth:
DS 1 

MapHeight:
DS 1 

MapOriginX:
DS 1 
MapOriginY:
DS 1 

BGFocusX:
DS 1 
BGFocusY:
DS 1 

MapOriginIndex:
DS 2 
MapOriginPlus:
DS 2 




	SECTION "LevelCode", HOME 
	
Level_Initialize::

	ld a, 0 
	ld [BGScrollX], a 
	ld [BGScrollY], a 
	ld [LevelNum], a 
	
	ret 
	
Level_Reset::
	ld a, 0 
	ld [BGScrollX], a 
	ld [BGScrollY], a 
	ld [BGFocusX], a 
	ld [BGFocusY], a 
	ret 
	
Level_Load:: 

	call Level_Reset 
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
	ld b, Level0MapWidth
	ld c, Level0MapHeight
	ld d, Level0MapOriginX 
	ld e, Level0MapOriginY
	call _Level_LoadAttributes0
	
	ld de, Level0MapOriginIndex
	ld hl, Level0MapWidth * VRAM_MAP_HEIGHT
	call _Level_LoadAttributes1
	
	ld a, Level0TileSet
	call _Level_LoadTileSet
	
	ld hl, Level0Map
	call _Level_LoadMap
	
	ld b, Level0SpawnX
	ld c, Level0SpawnY 
	call Player_SetPosition
	
	;call _Level_LoadBorders
	
	ret 
	
.load_1 

	ret 
	

; _Level_LoadAttributes
;  b = map width 
;  c = map height
;  d = map origin X
;  e = map origin Y
_Level_LoadAttributes0::

	ld a, b 
	ld [MapWidth], a 			; save map width 
	ld a, c 
	ld [MapHeight], a 			; save map height 
	
	ld a, d 
	ld [MapOriginX], a 			; save origin x-coord 
	ld a, e 
	ld [MapOriginY], a 			; save origin y-coord 
	
	ret 
	
	
; _Level_LoadAttributes1
; de = origin index 
; hl = origin plus index (for loading bottom row)
_Level_LoadAttributes1::

	ld a, d
	ld [MapOriginIndex], a 
	ld a, e 
	ld [MapOriginIndex + 1], a 
	
	ld a, h 
	ld [MapOriginPlus], a 
	ld a, l 
	ld [MapOriginPlus + 1], a
	
	ret 
	
; _Level_LoadMap 
; hl = map data address (beginning of entire map)
_Level_LoadMap::
	ld a, [MapOriginIndex]
	ld d, a 
	ld a, [MapOriginIndex + 1]
	ld e, a 						; de = origin index, aka offset into ROM map
	
	add hl, de 						; hl = address in ROM of first map tile to transfer
	
	ld  de, MAP_0			 	;position map at top-left (focus 0,0) 
	
	ld b, VRAM_MAP_WIDTH		; 20 tiles wide
	ld c, VRAM_MAP_HEIGHT		; 18 tiles high
	
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
	ld a, [MapWidth]			; load the map width 
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
	