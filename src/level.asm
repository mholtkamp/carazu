INCLUDE "include/level.inc"
INCLUDE "include/player.inc"
INCLUDE "include/constants.inc"
INCLUDE "include/globals.inc"
INCLUDE "include/item.inc"
INCLUDE "include/enemy.inc"

; Level includes 
INCLUDE "levels/level_items.inc"
INCLUDE "levels/level_enemies.inc"
INCLUDE "levels/level0.inc"
INCLUDE "levels/level1.inc"
INCLUDE "levels/level2.inc"
INCLUDE "levels/level3.inc"

; Tile Set includes
INCLUDE "tiles/special_tiles.inc"
INCLUDE "tiles/bg_tiles_0.inc"

CameraAnchorLeft EQU 64 
CameraAnchorRight EQU 80
CameraAnchorTop EQU 64
CameraAnchorBottom EQU 80 

	SECTION "LevelData", BSS 
	
; Public 

BGScrollX:
DS 1 

BGScrollY:
DS 1

BGScrollXPrev:
DS 1 

BGScrollYPrev:
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

BGFocusPixelsX: 
DS 1 
BGFocusPixelsY:
DS 1 

MapOriginIndex:
DS 2 
MapOriginIndexPlus:
DS 2 


MapAddress:
DS 2

MapStreamDir:
DS 1 

ScreenRect:
DS 4 

MapBank:
DS 1 

; Private
LoadFlags:
DS 1 

LastLoad:
DS 1 

Scratch:
DS 1 



	SECTION "LevelCode", HOME 
	
Level_Initialize::

	ld a, 0 
	ld [BGScrollX], a 
	ld [BGScrollY], a 
	ld [BGScrollXPrev], a 
	ld [BGScrollYPrev], a 
	ld [BGFocusPixelsX], a 
	ld [BGFocusPixelsY], a 
	ld [LoadFlags], a 
	ld [LastLoad], a 
	ld [MapStreamDir], a 
	ld [MapBank], a 
	
	ret 
	
Level_Reset::
	ld a, 0 
	ld [BGScrollX], a 
	ld [BGScrollY], a 
	ld [BGScrollXPrev], a 
	ld [BGScrollYPrev], a 
	ld [BGFocusPixelsX], a 
	ld [BGFocusPixelsY], a 
	ld [BGFocusX], a 
	ld [BGFocusY], a 
	ld [LoadFlags], a 
	ld [LastLoad], a 
	ld [MapStreamDir], a 
	ld [MapBank], a 
	
	ret 
	
Level_Load:: 

	call Level_Reset 
	call Reset_Items
	call ResetEnemies
	call ResetEnemyList
	
	; Load special tiles 
	ld bc, TILE_BANK_1 + 16*SPECIAL_TILES_INDEX
	ld hl, SpecialTiles
	ld de, NUM_SPECIAL_TILES*16 ; 64 characters, 16 bytes each

.loop_special
	ld a, [hl+]
	ld [bc], a 
	inc bc 
	dec de 
	ld a, d 
	or e 
	jp nz, .loop_special
	
	; Load the level 
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
	jp .load_2
	nop 
	jp .load_3 
	nop 
	
	ret 
	
.load_0 
	ld b, Level0MapWidth
	ld c, Level0MapHeight
	ld d, Level0MapOriginX 
	ld e, Level0MapOriginY
	ld h, Level0MapBank
	call _Level_LoadAttributes0
	
	ld de, Level0MapOriginIndex
	ld hl, Level0MapOriginIndex + Level0MapWidth * VRAM_MAP_HEIGHT
	call _Level_LoadAttributes1
	
	ld a, Level0TileSet
	call _Level_LoadTileSet
	
	ld hl, Level0Map
	call _Level_LoadMap
	
	ld hl, Level0Items
	call Load_Items
	
	ld hl, Level0Enemies
	call LoadEnemyList
	
	ld b, Level0SpawnX
	ld c, Level0SpawnY 
	call Player_SetPositionFromTiles
	jp .return 
	
.load_1 
	ld b, Level1MapWidth
	ld c, Level1MapHeight
	ld d, Level1MapOriginX 
	ld e, Level1MapOriginY
	ld h, Level1MapBank
	call _Level_LoadAttributes0
	
	ld de, Level1MapOriginIndex
	ld hl, Level1MapOriginIndex + Level1MapWidth * VRAM_MAP_HEIGHT
	call _Level_LoadAttributes1
	
	ld a, Level1TileSet
	call _Level_LoadTileSet
	
	ld hl, Level1Map
	call _Level_LoadMap
	
	ld hl, Level1Items
	call Load_Items
	
	ld hl, Level1Enemies
	call LoadEnemyList
	
	ld b, Level1SpawnX
	ld c, Level1SpawnY 
	call Player_SetPositionFromTiles
	jp .return 
	
.load_2
	ld b, Level2MapWidth
	ld c, Level2MapHeight
	ld d, Level2MapOriginX 
	ld e, Level2MapOriginY
	ld h, Level2MapBank
	call _Level_LoadAttributes0
	
	ld de, Level2MapOriginIndex
	ld hl, Level2MapOriginIndex + Level2MapWidth * VRAM_MAP_HEIGHT
	call _Level_LoadAttributes1
	
	ld a, Level2TileSet
	call _Level_LoadTileSet
	
	ld hl, Level2Map
	call _Level_LoadMap
	
	ld hl, Level2Items
	call Load_Items
	
	ld hl, Level2Enemies
	call LoadEnemyList
	
	ld b, Level2SpawnX
	ld c, Level2SpawnY 
	call Player_SetPositionFromTiles
	jp .return 
	
.load_3
	ld b, Level3MapWidth
	ld c, Level3MapHeight
	ld d, Level3MapOriginX 
	ld e, Level3MapOriginY
	ld h, Level3MapBank
	call _Level_LoadAttributes0
	
	ld de, Level3MapOriginIndex
	ld hl, Level3MapOriginIndex + Level3MapWidth * VRAM_MAP_HEIGHT
	call _Level_LoadAttributes1
	
	ld a, Level3TileSet
	call _Level_LoadTileSet
	
	ld hl, Level3Map
	call _Level_LoadMap
	
	ld hl, Level3Items
	call Load_Items
	
	ld hl, Level3Enemies
	call LoadEnemyList
	
	ld b, Level3SpawnX
	ld c, Level3SpawnY 
	call Player_SetPositionFromTiles
	jp .return 

	
.return
	call Player_UpdateLocalOAM
	call _Level_LoadBorders
	call _Level_CalcScreenRect
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
	ld [MapBank], a 			; save map bank 
	
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
	ld [MapOriginIndexPlus], a 
	ld a, l 
	ld [MapOriginIndexPlus + 1], a
	
	ret 
	
; _Level_LoadMap 
; hl = map data address (beginning of entire map)
_Level_LoadMap::
	; switch to proper rom bank 
	ld a, [MapBank]
	ld [ROM_BANK_WRITE_ADDR], a 
	
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
	ld a, BGTiles0Bank
	ld [ROM_BANK_WRITE_ADDR], a 
	
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
	ld a, [MapBank]
	ld [ROM_BANK_WRITE_ADDR], a 
	
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
	add a, 20			; 20 = screen width in blocks 
	cp 32
	jp c, .get_x_addr 
	sub 32 
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
	
	; add 20 to get right column  
	ld de, 20
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
	
	
_Level_LoadTop::
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
	
	ld a, 22  			; 20 tiles in row + 2 for diagonal tiles 
	ld [Scratch], a 	; scratch holds counter 
	
.loop 
	ld a, [hl+]
	ld [de], a 
	inc de 
	
	ld a, e 
	and $1f 
	; check if vram map pointer is still in MAP_0
	jp nz, .dec_counter
	
	; fix vram pointer 
	ld a, e 
	sub 32 
	ld e, a 
	ld a, d 
	sbc 0 
	ld d, a 
	
.dec_counter

	ld a, [Scratch]
	dec a 
	ld [Scratch], a
	jp nz, .loop
	ret 
	
	
_Level_LoadBottom::	
	; Find VRAM address first 
	ld a, [BGFocusY]
	add a, 18			; 18 = height of screen 
	cp 32 
	jp c, .get_y_addr 
	sub 32  
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
	
	; MapOriginIndexPlus stores maporiginindex + mapwidth*18 
	ld a, [MapOriginIndexPlus]
	ld h, a 
	ld a, [MapOriginIndexPlus + 1]
	ld l, a 
	
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
	
	ld a, 22  			; 20 tiles in row + 2 for diagonal tiles 
	ld [Scratch], a 	; scratch holds counter 
	
.loop 
	ld a, [hl+]
	ld [de], a 
	inc de 
	
	ld a, e 
	and $1f 
	; check if vram map pointer is still in MAP_0
	jp nz, .dec_counter
	
	; fix vram pointer 
	ld a, e 
	sub 32 
	ld e, a 
	ld a, d 
	sbc 0 
	ld d, a 
	
.dec_counter

	ld a, [Scratch]
	dec a 
	ld [Scratch], a
	jp nz, .loop
	ret 

Level_Update::
	call _Level_Scroll
	call _Level_SetMapStream 
	call _Level_CalcScreenRect
	
	ret 
	
_Level_Scroll::
	
	; Record prev scroll 
	ld a, [BGScrollX]
	ld [BGScrollXPrev], a 
	ld a, [BGScrollY]
	ld [BGScrollYPrev], a 
	
	; Check Left Camera Anchor 
.check_x_anchors
	ld a, [PlayerRect]
	cp CameraAnchorLeft 
	jp c, .attempt_left 
	cp CameraAnchorRight+1
	jp nc, .attempt_right
	
.check_y_anchors 
	ld a, [PlayerRect + 2]
	cp CameraAnchorTop
	jp c, .attempt_top 
	cp CameraAnchorBottom 
	jp nc, .attempt_bottom 
	
.return  	; Do not change this .return label. the code BELOW jumps here 
	; Before returning, update the player rect position in case scroll changed 
	ld a, [BGScrollX]
	ld b, a 
	ld a, [BGScrollXPrev]
	sub b 
	ld d, a 				; d = x shift 
	ld b, a 
	ld a, [PlayerRect]
	add a, b 
	ld [PlayerRect], a 			; Update shifted X posititon
	
	ld a, [BGScrollY]
	ld b, a 
	ld a, [BGScrollYPrev]
	sub b 
	ld e, a 				; e = y shift 
	ld b, a 
	ld a, [PlayerRect + 2]
	add a, b 
	ld [PlayerRect + 2], a 
	ld a, [PlayerPrevYLow]
	add a, b 
	ld [PlayerPrevYLow], a 
	
	; d = xshift 
	; e = yshift
	call Scroll_Items
	call ScrollEnemies

	ret 
	
.attempt_left 
	ld b, a 		; b = player x coord 
	ld a, CameraAnchorLeft
	sub b 
	cp MAX_SPEED+1
	jp c, .attempt_left_sub_pixels
	ld a, MAX_SPEED 		; cap the amount of pixels we can scroll 
.attempt_left_sub_pixels 
	ld b, a					; b = number of pixels to scroll 
	ld a, [BGFocusPixelsX]
	sub b 
	jp c, .attempt_left_change_focus 
	ld [BGFocusPixelsX], a 		; no change in focus, load the new PixelsX and BGScrollX
	ld a, [BGScrollX]
	sub b 
	ld [BGScrollX], a 
	jp .check_y_anchors 
.attempt_left_change_focus
	add a, 8 					; reset the FocusPixelsX back into 0-7 range 
	ld c, a 					; c = new FocusPixelsX (possibly)
	ld a, [MapOriginX]
	cp 0 
	jp nz, .attempt_left_exe_change_focus 
	ld a, [BGFocusPixelsX]
	ld b, a 
	ld a, [BGScrollX]
	sub b 						; sub tract the prev pixels to push camera to leftmost of map 
	ld [BGScrollX], a 
	ld a, 0 
	ld [BGFocusPixelsX], a 		; load pixelsX with 0 because map is at leftmost side 	
	jp .check_y_anchors
.attempt_left_exe_change_focus
	; Origin and Focus can be shifted left since OriginX isnt 0 (yet)
	sub 1 			; shift focus left 
	ld [MapOriginX], a 			; save shifted MapOriginX 
	
	; Focus is shifting, set load flag 
	ld a, [LoadFlags]
	or LOAD_LEFT 
	ld [LoadFlags], a 
	
	ld a, [MapOriginIndex + 1]
	sub 1 
	ld [MapOriginIndex + 1], a 
	ld a, [MapOriginIndex]
	sbc 0 
	ld [MapOriginIndex], a 

	ld a, [MapOriginIndexPlus + 1]
	sub 1 
	ld [MapOriginIndexPlus + 1], a 
	ld a, [MapOriginIndexPlus]
	sbc 0 
	ld [MapOriginIndexPlus], a 
	
	ld a, c 
	ld [BGFocusPixelsX], a 		; save the new BGFocusPixelsX 
	ld a, [BGFocusX]
	sub 1 
	and $1f 					; keep focus in range 0 - 31 
	ld [BGFocusX], a 			; save the new BGFocusX 
	ld a, [BGScrollX]
	sub b 
	ld [BGScrollX], a			; shift scroll x val over (b should contain pixels moved left ) 
	jp .check_y_anchors 
	
.attempt_right 
	ld b, a 		; b = player x coord 
	
	ld a, [MapWidth]
	sub 20					; 21 = screen width in tiles  
	ld c, a 
	ld a, [MapOriginX]
	cp c 
	jp z, .check_y_anchors		; origin is as far right as it can go. do not move anything
	
	ld a, CameraAnchorRight
	ld c, a 
	ld a, b 
	sub c 					; a = number of pixels moved to right  
	cp MAX_SPEED+1
	jp c, .attempt_right_sub_pixels
	ld a, MAX_SPEED 		; cap the amount of pixels we can scroll 
.attempt_right_sub_pixels 
	ld b, a					; b = number of pixels to scroll 
	ld a, [BGFocusPixelsX]
	add a, b 
	cp 8
	jp nc, .attempt_right_change_focus 
	ld [BGFocusPixelsX], a 		; no change in focus, load the new PixelsX and BGScrollX
	ld a, [BGScrollX]
	add a, b 
	ld [BGScrollX], a 
	jp .check_y_anchors 
.attempt_right_change_focus
	sub 8 					; reset the FocusPixelsX back into 0-7 range 
	ld c, a 					; c = new FocusPixelsX (possibly)
	ld a, [MapWidth]
	sub 20					; 20 = screen width in tiles   
	ld d, a 				
	ld a, [MapOriginX] 
	cp d 
	jp nz, .attempt_right_exe_change_focus 
	jp .check_y_anchors
.attempt_right_exe_change_focus
	
	; Origin and Focus can be shifted right since OriginX isnt 0 (yet)
	add a, 1 					; shift focus right 
	ld [MapOriginX], a 			; save shifted MapOriginX 
	
	; Focus is shifting, set load flag 
	ld a, [LoadFlags]
	or LOAD_RIGHT
	ld [LoadFlags], a 
	
	ld a, [MapOriginIndex + 1]
	add a, 1 
	ld [MapOriginIndex + 1], a 
	ld a, [MapOriginIndex]
	adc a, 0 
	ld [MapOriginIndex], a 

	ld a, [MapOriginIndexPlus + 1]
	add a, 1 
	ld [MapOriginIndexPlus + 1], a 
	ld a, [MapOriginIndexPlus]
	adc a, 0  
	ld [MapOriginIndexPlus], a 
	
	ld a, [BGFocusX]
	add a, 1 
	and $1f 					; keep focus in range 0 - 31 
	ld [BGFocusX], a 			; save the new BGFocusX 
	
	; check if maporigin x is as far right as it can go 
	ld a, [MapOriginX]
	cp d 
	jp nz, .attempt_right_not_rightmost
	ld a, [BGFocusPixelsX]	; get previous pixelsX 
	ld c, a 
	ld a, 8 
	sub c 					
	ld c, a 				; c = # of pixels to scroll bgscrollx
	ld a, 0  
	ld [BGFocusPixelsX], a 	; focus x will be 0 on far right 
	ld a, [BGScrollX]
	add a, c 
	ld [BGScrollX], a 
	jp .check_y_anchors
.attempt_right_not_rightmost 
	ld a, c 
	ld [BGFocusPixelsX], a 		; save the new BGFocusPixelsX 

	ld a, [BGScrollX]
	add b 
	ld [BGScrollX], a			; shift scroll x val over (b should contain pixels moved right ) 
	jp .check_y_anchors 
	
.attempt_top
	ld b, a 		; b = player y coord 
	ld a, CameraAnchorTop
	sub b 
	cp MAX_SPEED+1
	jp c, .attempt_top_sub_pixels
	ld a, MAX_SPEED 		; cap the amount of pixels we can scroll 
.attempt_top_sub_pixels 
	ld b, a					; b = number of pixels to scroll 
	ld a, [BGFocusPixelsY]
	sub b 
	jp c, .attempt_top_change_focus 
	ld [BGFocusPixelsY], a 		; no change in focus, load the new PixelsY and BGScrollY
	ld a, [BGScrollY]
	sub b 
	ld [BGScrollY], a 
	jp .return 
.attempt_top_change_focus
	add a, 8 					; reset the FocusPixelsY back into 0-7 range 
	ld c, a 					; c = new FocusPixelsY (possibly)
	ld a, [MapOriginY]
	cp 0 
	jp nz, .attempt_top_exe_change_focus 
	ld a, [BGFocusPixelsY]
	ld b, a 
	ld a, [BGScrollY]
	sub b 						; sub tract the prev pixels to push camera to topmost of map 
	ld [BGScrollY], a 
	ld a, 0 
	ld [BGFocusPixelsY], a 		; load pixelsY with 0 because map is at topmost side 	
	jp .return
.attempt_top_exe_change_focus
	; Origin and Focus can be shifted up since OriginY isnt 0 (yet)
	sub 1 			; shift focus up 
	ld [MapOriginY], a 			; save shifted MapOriginX 
	
	; Focus is shifting, set load flag 
	ld a, [LoadFlags]
	or LOAD_TOP
	ld [LoadFlags], a 
	
	; to shift map up, subtract map width 
	ld a, [MapWidth]
	ld d, a 
	
	ld a, [MapOriginIndex + 1]
	sub d 
	ld [MapOriginIndex + 1], a 
	ld a, [MapOriginIndex]
	sbc 0 
	ld [MapOriginIndex], a 

	ld a, [MapOriginIndexPlus + 1]
	sub d 
	ld [MapOriginIndexPlus + 1], a 
	ld a, [MapOriginIndexPlus]
	sbc 0 
	ld [MapOriginIndexPlus], a 
	
	ld a, c 
	ld [BGFocusPixelsY], a 		; save the new BGFocusPixelsY 
	ld a, [BGFocusY]
	sub 1 
	and $1f 					; keep focus in range 0 - 31 
	ld [BGFocusY], a 			; save the new BGFocusX 
	ld a, [BGScrollY]
	sub b 
	ld [BGScrollY], a			; shift scroll x val over (b should contain pixels moved top ) 
	jp .return 
	
.attempt_bottom 
	ld b, a 		; b = player y coord 
	
	ld a, [MapHeight]
	sub 18					; 18 = screen height in tiles  
	ld c, a 				; c =  map height 
	ld a, [MapOriginY]
	cp c 
	jp z, .return		; origin is as far bottom  as it can go. do not move anything
	
	ld a, CameraAnchorBottom
	ld c, a 				; c = camera anchor bottom 
	ld a, b 				
	sub c 					; a = number of pixels moved to down   
	cp MAX_SPEED+1
	jp c, .attempt_bottom_sub_pixels
	ld a, MAX_SPEED 		; cap the amount of pixels we can scroll 
.attempt_bottom_sub_pixels 
	ld b, a					; b = number of pixels to scroll 
	ld a, [BGFocusPixelsY]
	add a, b 
	cp 8
	jp nc, .attempt_bottom_change_focus 
	ld [BGFocusPixelsY], a 		; no change in focus, load the new PixelsY and BGScrollY
	ld a, [BGScrollY]
	add a, b 
	ld [BGScrollY], a 
	jp .return  
.attempt_bottom_change_focus
	sub 8 					; reset the FocusPixelsY back into 0-7 range 
	ld c, a 					; c = new FocusPixelsY (possibly)
	ld a, [MapHeight]
	sub 18					; 18 = screen height in tiles   
	ld d, a 				
	ld a, [MapOriginY] 
	cp d 
	jp nz, .attempt_bottom_exe_change_focus 
	jp .return 
.attempt_bottom_exe_change_focus
	; Origin and Focus can be shifted down since OriginY isnt 0 (yet)
	add a, 1 					; shift focus down 
	ld [MapOriginY], a 			; save shifted MapOriginY
	
	; Focus is shifting, set load flag 
	ld a, [LoadFlags]
	or LOAD_BOTTOM
	ld [LoadFlags], a 
	
	; to shift map up, subtract map width 
	ld a, [MapWidth]
	ld e, a 
	
	ld a, [MapOriginIndex + 1]
	add a, e 
	ld [MapOriginIndex + 1], a 
	ld a, [MapOriginIndex]
	adc a, 0 
	ld [MapOriginIndex], a 

	ld a, [MapOriginIndexPlus + 1]
	add a, e 
	ld [MapOriginIndexPlus + 1], a 
	ld a, [MapOriginIndexPlus]
	adc a, 0  
	ld [MapOriginIndexPlus], a 
	
	ld a, [BGFocusY]
	add a, 1 
	and $1f 					; keep focus in range 0 - 31 
	ld [BGFocusY], a 			; save the new BGFocusY 
	
	; check if maporigin y is as far bottom as it can go 
	ld a, [MapOriginY]
	cp d 
	jp nz, .attempt_bottom_not_bottommost
	ld a, [BGFocusPixelsY]	; get previous pixelsY
	ld c, a 
	ld a, 8 
	sub c 					
	ld c, a 				; c = # of pixels to scroll bgscrollY
	ld a, 0  
	ld [BGFocusPixelsY], a 	; focuspixels y will be 0 on far bottom 
	ld a, [BGScrollY]
	add a, c 
	ld [BGScrollY], a 
	jp .return 
.attempt_bottom_not_bottommost 
	ld a, c 
	ld [BGFocusPixelsY], a 		; save the new BGFocusPixelsY 

	ld a, [BGScrollY]
	add b 
	ld [BGScrollY], a			; shift scroll x val over (b should contain pixels moved bottom ) 
	jp .return 
	
_Level_SetMapStream::
	ld a, [LoadFlags]
	ld b, a 			; b = load flags 
	
	bit LOAD_LEFT_BIT, a 
	jp nz, .set_left 
	bit LOAD_RIGHT_BIT, a 
	jp nz, .set_right 
	
.check_y_loads
	bit LOAD_TOP_BIT, a 
	jp nz, .set_top 
	bit LOAD_BOTTOM_BIT, a 
	jp nz, .set_bottom
	
	ld a, 0					; no streaming
	ld [MapStreamDir], a 
	ld [LastLoad], a 
	
	ret 
	
.set_left 
	and $0C			; bit 2 and 3 are the y load flags 
	jp z, .set_left_exe 
	ld a, [LastLoad]
	cp LAST_LOAD_X
	jp z, .check_y_loads
.set_left_exe 
	ld a, LOAD_LEFT 
	ld [MapStreamDir], a 
	ld a, b
	and ~LOAD_LEFT 
	ld [LoadFlags], a 
	ld a, LAST_LOAD_X 
	ld [LastLoad], a 
	
	ret 
	
.set_right 
	and $0C			; bit 2 and 3 are the y load flags 
	jp z, .set_right_exe 
	ld a, [LastLoad]
	cp LAST_LOAD_X
	jp z, .check_y_loads
.set_right_exe 
	ld a, LOAD_RIGHT
	ld [MapStreamDir], a 
	ld a, b
	and ~LOAD_RIGHT 
	ld [LoadFlags], a 
	ld a, LAST_LOAD_X 
	ld [LastLoad], a 
	ret 
	
.set_top 
	ld a, LOAD_TOP
	ld [MapStreamDir], a 
	ld a, b
	and ~LOAD_TOP 
	ld [LoadFlags], a 
	ld a, LAST_LOAD_Y 
	ld [LastLoad], a
	ret 
	
.set_bottom
	ld a, LOAD_BOTTOM  
	ld [MapStreamDir], a 
	ld a, b
	and ~LOAD_BOTTOM 
	ld [LoadFlags], a 
	ld a, LAST_LOAD_Y 
	ld [LastLoad], a
	ret 
	
	
_Level_CalcScreenRect::

	ld a, [MapOriginX]
	sub 2 
	jp nc, .save_screen_x
	ld a, 0 
.save_screen_x
	ld [ScreenRect], a 
	
	ld a, [MapOriginY]
	sub 2
	jp nc, .save_screen_y
	ld a, 0 
.save_screen_y
	ld [ScreenRect+1], a 
	
.save_width 
	ld a, 24 
	ld [ScreenRect + 2], a 	; this should never overflow since levels can only be 128 tiles wide
	
.save_height 
	ld a, 24 
	ld [ScreenRect + 3], a 	; this should also never overflow when added to y val for same reason ^ 

	ret 