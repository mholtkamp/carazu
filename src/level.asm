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

MapWidthShift:
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


MapAddress:
DS 2

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
	ld h, Level0MapWidthShift
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
	
	call _Level_LoadBorders
	
	ret 
	
.load_1 

	ret 
	

; _Level_LoadAttributes
;  b = map width 
;  c = map height
;  d = map origin X
;  e = map origin Y
;  h = map width shift
_Level_LoadAttributes0::

	ld a, b 
	ld [MapWidth], a 			; save map width 
	ld a, c 
	ld [MapHeight], a 			; save map height 
	
	ld a, d 
	ld [MapOriginX], a 			; save origin x-coord 
	ld a, e 
	ld [MapOriginY], a 			; save origin y-coord 
	
	ld a, h
	ld [MapWidthShift], a 		; save map width shift 
	
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
	; save map address 
	ld a, h
	ld [MapAddress], a 
	ld a, l 
	ld [MapAddress + 1], a 
	
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
	

_Level_LoadBorders::
	call _Level_LoadLeft
	call _Level_LoadRight
	call _Level_LoadTop
	call _Level_LoadBottom 
	ret
	
_Level_LoadLeft::
	; Find VRAM address first 
	ld a, [BGFocusY]
	sub 1 
	jp nc, .get_y_addr 
	add a, 32  
.get_y_addr 
	ld b, a 			; b = y block num
	
	ld h, b  			; prepare to mult the y coord by 32 
	ld l, b 
	
	srl h 
	srl h 
	srl h 
	
	sla l 
	sla l 
	sla l 
	sla l 
	sla l

	ld de, MAP_0
	add hl, de 
	
	ld a, [BGFocusX]
	sub 1 
	jp nc, .get_x_addr 
	add a, 32 
.get_x_addr
	ld e, a 
	ld d, 0 
	
	add hl, de 		; hl = absolute vram address of 
	
	push hl
	
	ld a, [MapOriginIndex]
	ld h, a 
	ld a, [MapOriginIndex + 1]
	ld l, a 
	
	; subtract the map width to get upper row 
	ld a, [MapWidth]
	ld e, a 
	ld a, l 
	sub e 
	ld l, a 
	ld a, h
	sbc a, 0 
	ld h, a 
	
	; subtract 1 to get the left column 
	ld de, $ffff 
	add hl, de  
	
	; add start address of rom map 
	ld a, [MapAddress]
	ld d, a 
	ld a, [MapAddress + 1]
	ld e, a  
	add hl, de 			; hl = absolute rom address of first tile to stream
	
	pop de 				; de = restored absolute vram address of first tile to write 
	
	ld a, 20  			; 18 tiles in column + 2 for diagonal tiles 
	ld [Scratch], a 	; scratch holds counter 
	
	ld a, [MapWidth]
	ld c, a 
	ld b, 0 			; load map width in bc 
	
.loop 
	ld a, [hl]
	ld [de], a 
	
	; increment addresses 
	add hl, bc 			; rom map pointing at next row now 
	
	ld a, e 
	add a, 32 
	ld e, a 
	ld a, d 
	adc a, 0 
	ld d, a 			; vram pointer is pointing at next row now 
	
	; check if vram map pointer is still in MAP_0
	cp $9C				; a holds high byte of vram address. 9C is start of MAP_1 
	jp c, .dec_counter
	
	; fix vram pointer 
	sub 4 
	ld d, a 
	
.dec_counter

	ld a, [Scratch]
	dec a 
	ld [Scratch], a
	jp nz, .loop
	ret 
	
	
_Level_LoadRight::
	ret
_Level_LoadTop::
	ret 
_Level_LoadBottom::
	ret 


