INCLUDE "include/enemy.inc"
INCLUDE "include/constants.inc"
INCLUDE "include/util.inc"
INCLUDE "include/rect.inc"
INCLUDE "include/level.inc"
INCLUDE "include/globals.inc"
INCLUDE "include/player.inc"
INCLUDE "tiles/enemy_tiles.inc"

SLIME_X_OFFSET EQU 2
SLIME_Y_OFFSET EQU 4
SLIME_WIDTH EQU 12 
SLIME_HEIGHT EQU 12
SLIME_MOVE_SPEED EQU $00C0

RECALL_RANGE_MIN EQU  192 
RECALL_RANGE_MAX EQU  224 

STAR_COUNTER_MAX EQU 12
STAR_SPEED EQU 2

	SECTION "EnemyVariables", BSS 
	
Enemies:												; 20 * 5 = 100 bytes
Enemy0:
DS ENEMY_DATA_SIZE
Enemy1:
DS ENEMY_DATA_SIZE
Enemy2:
DS ENEMY_DATA_SIZE
Enemy3:
DS ENEMY_DATA_SIZE
Enemy4:
DS ENEMY_DATA_SIZE

EnemyList:
DS ENEMY_ENTRY_DATA_SIZE * MAX_ENEMY_LIST_ENTRIES		; 8 * 20 = 160 bytes

EnemyTileRect:
DS 4 

EnemyType:
DS 1 
EnemyStruct:
DS 2 
OBJOffset:
DS 1 

EnemyRect:
EnemyX:
DS 2 
EnemyY:
DS 2 
EnemyWidth:
DS 1
EnemyHeight: 
DS 1 

EnemyRectOffsetX:
DS 1 
EnemyRectOffsetY:
DS 1 

EnemyScratch: 
DS 12
EnemySpritePattern:
DS 1 
EnemyFlip:
DS 1 

Star1X:
DS 1 
Star2X:
DS 1 
StarsY:
DS 1 
StarsCounter:
DS 1 
StarsActive:
DS 1 

	SECTION "EnemyProcedures", HOME 
	
LoadEnemyGraphics::

	ld b, 0			; load sprite tiles 
	ld c, 40		; tiles to load 
	ld d, EnemyTilesBank
	ld e, 16 
	ld hl, EnemyTiles
	call LoadTiles
	
	ret 
	
ResetEnemyList::

	ld a, 0 			; 0 = ENEMY_NONE btw
	ld b, MAX_ENEMY_LIST_ENTRIES
	ld hl, EnemyList
	
.loop
	ld [hl+], a 
	ld [hl+], a 
	ld [hl+], a 
	ld [hl+], a 
	ld [hl+], a 
	ld [hl+], a 
	ld [hl+], a
	ld [hl+], a 		; each enemy entry is 8 bytes long 

	dec b 
	jp nz, .loop 
	
	ret 
	
ResetEnemies::

	ld a, 0 
	ld [StarsActive], a		; set stars as inactive  
	
	ld a, 0 			; 0 = ENEMY_NONE 
	ld b, ENEMY_DATA_SIZE 
	ld c, MAX_ENEMIES 
	ld hl, Enemies
	
.loop 
	ld [hl+], a 
	
	dec b 
	jp nz, .loop 
	
	ld b, ENEMY_DATA_SIZE
	dec c 
	jp nz, .loop 
	
	; Clear enemy objs 
	ld hl, LocalOAM + ENEMY_OBJ_INDEX*4

	ld a, 0 
	ld b, 20  ; 20 =  5 enemies * 4 objs per enemy  
	
.obj_loop 
	ld [hl+], a 
	ld [hl+], a 
	inc hl 
	inc hl 
	
	dec b 
	jp nz, .obj_loop
	
	ret 
	

; hl = enemy list 
LoadEnemyList::
	; Switch to proper ROM bank 
	ld a, 1 
	ld [ROM_BANK_WRITE_ADDR], a 
	
	ld de, EnemyList 

.loop 
	ld a, [hl+]
	ld b, a 
	ld [de], a 		; store type
	inc de 
	ld a, [hl+]		
	ld [de], a 		; store x tile 
	inc de 
	ld a, [hl+]
	ld [de], a		; store y tile  
	inc de 
	
	ld a, b 
	
	cp END_ENEMY_LIST
	jp z, .return 
	cp ENEMY_SLIME
	jp z, .load_slime
	cp ENEMY_BIRDY
	jp z, .load_birdy 
	cp ENEMY_SHOOTER
	jp z, .load_shooter 
	cp ENEMY_SPIKE 
	jp z, .load_spike
	cp ENEMY_JUMP_SLIME
	jp z, .load_jump_slime
	cp ENEMY_BOMB_BIRDY
	jp z, .load_bomb_birdy 
	cp ENEMY_PARA_SHOOTER
	jp z, .load_para_shooter 
	cp ENEMY_BLACK_SPIKE
	jp z, .load_black_spike
	cp ENEMY_ZIG_BIRDY
	jp z, .load_zig_birdy 
	
	; Unknown enemy type encountered. Possibly because of mismatch between 
	; the number of params in list and the expected number of params 
	dec de 
	dec de 
	dec de 
	ld a, ENEMY_NONE 
	ld [de], a
	jp .return 
	
	
.load_slime 
	ld a, [hl+]
	ld [de], a 
	inc de 			; param0 = left boundary 
	ld a, [hl+]
	ld [de], a 
	inc de 			; param1 = right boundary
	inc de 			; no param2
	inc de 			; no param3 
	inc de 			; no param4
	jp .loop
	
.load_birdy
	ld a, [hl+]
	ld [de], a 		; param0 = 0: one-way , 1: two-way 
	inc de 			
	ld a, [hl+]
	ld [de], a 		; param1 = left tile boundary (if two way)
	inc de 	
	ld a, [hl+]
	ld [de], a		; param2 = right tile boundary (if two way) 
	inc de 
	inc de 			; no param3 
	inc de 			; no param4 
	jp .loop 
	
.load_shooter
	ld a, [hl+]
	ld [de], a 		; param0 = shot direction. refer to shooter equates 
	inc de 	
	inc de 			; no param1
	inc de			; no param2
	inc de 			; no param3
	inc de 			; no param4 
	
.load_spike
.load_jump_slime
.load_bomb_birdy
.load_para_shooter
.load_black_spike
.load_zig_birdy

.return 
	ret 
	
; d = shiftx 
; e = shifty 
ScrollEnemies::

	; Enemy0 
	ld hl, Enemy0 + 2
	ld a, [hl]
	add a, d 
	ld [hl+], a 
	inc hl 
	ld a, [hl]
	add a, e 
	ld [hl], a 

	; Enemy1 
	ld hl, Enemy1 + 2 
	ld a, [hl]
	add a, d 
	ld [hl+], a 
	inc hl 
	ld a, [hl]
	add a, e 
	ld [hl], a 
	
	; Enemy2 
	ld hl, Enemy2 + 2 
	ld a, [hl]
	add a, d 
	ld [hl+], a 
	inc hl 
	ld a, [hl]
	add a, e 
	ld [hl], a 
	
	; Enemy3
	ld hl, Enemy3 + 2 
	ld a, [hl]
	add a, d 
	ld [hl+], a 
	inc hl 
	ld a, [hl]
	add a, e 
	ld [hl], a 
	
	; Enemy4
	ld hl, Enemy4 + 2 
	ld a, [hl]
	add a, d 
	ld [hl+], a 
	inc hl 
	ld a, [hl]
	add a, e 
	ld [hl], a 

	; Stars 
	ld a, [Star1X]
	add a, d 
	ld [Star1X], a 
	ld a, [Star2X]
	add a, d 
	ld [Star2X], a 
	ld a, [StarsY]
	add a, e 
	ld [StarsY], a 
	
	ret 
	
UpdateEnemies::
	
	;Update Stars 
	call UpdateStars 
	
	; Update each enemy struct first 
	; Originally, had this as loop, but unwrapping it for minor performance increase 
	ld hl, Enemy0 
	ld b, ENEMY_OBJ_INDEX
	call Enemy_Update
	
	ld hl, Enemy1 
	ld b, ENEMY_OBJ_INDEX+4
	call Enemy_Update
	
	ld hl, Enemy2 
	ld b, ENEMY_OBJ_INDEX+8
	call Enemy_Update
	
	ld hl, Enemy3 
	ld b, ENEMY_OBJ_INDEX+12
	call Enemy_Update
	
	ld hl, Enemy4 
	ld b, ENEMY_OBJ_INDEX+16
	call Enemy_Update
	
	
	; Next, loop through enemy list 
	ld a, 2 
	ld [EnemyTileRect+2], a 
	ld [EnemyTileRect+3], a      ; width and height of all enemies is 2 
	
	
	ld hl, EnemyList
	ld b, MAX_ENEMY_LIST_ENTRIES
	
.list_loop
	push hl 
	ld a, [hl+]
	cp ENEMY_NONE 
	jp z, .continue_none
	
	ld a, [hl+]
	ld [EnemyTileRect], a 		; tile x 
	ld d, a 					; d = enemy x tile 
	ld a, [hl+]
	ld [EnemyTileRect+1], a 	; tile y 
	ld e, a 					; e = enemy y tile 
	pop hl 
	
	ld a, [ScreenRect]
	cp d 
	jp z, .check_y_bounds 
	add a, 21 					; screen rect width = 22 
	cp d 
	jp z, .check_y_bounds 
	ld a, [ScreenRect+1]
	cp e
	jp z, .check_x_bounds 
	add a, 21 					; screen rect height = 22 
	cp e 
	jp z, .check_x_bounds 

	jp .continue 		; not on the edge of the screen rect 

.check_y_bounds 
	ld a, [ScreenRect+1]
	add a, 23 
	cp e 
	jp c, .continue 
	
	sub 23 		; restore screenrect.y and set back 1 more tile 
	ld d, a 	; d not being used anymore (tile x)
	dec e		;push y coord downward one when checking upper edge of screen rect (because enemies are 2 by 2 tiles)
	ld a, e 
	cp d 
	jp c, .continue 
	jp .spawn 
	
.check_x_bounds 
	ld a, [ScreenRect]
	add a, 23 
	cp d 
	jp c, .continue 
	
	sub 23 		
	ld e, a 	
	dec d		
	ld a, d 
	cp e 
	jp c, .continue 
	;jp .spawn 
	
.spawn 
	push hl 
	push bc
	call Enemy_Spawn
	pop bc  
	; intentional fall through to continue_none
.continue_none 
	pop hl 
.continue 
	ld a, 8 
	add a, l 
	ld l, a 
	ld a, h 
	adc a, 0 
	ld h, a 	; add 8 to get next enemy entry 
	
	dec b 
	jp nz, .list_loop
	
	ret 
	
; b = list entry ID 
; hl = enemy entry address 
Enemy_Spawn::

	; Iterate through the current enemies. Check if...
	; (1) There is not an enemy with the same list entry identifier 
	; (2) There is an empty enemy slot.
	
	;Check IDs 
	ld a, [Enemy0 + 1]
	cp b
	jp z, .return 
	ld a, [Enemy1 + 1]
	cp b
	jp z, .return 
	ld a, [Enemy2 + 1]
	cp b
	jp z, .return 
	ld a, [Enemy3 + 1]
	cp b
	jp z, .return 
	ld a, [Enemy4 + 1]
	cp b
	jp z, .return 
	
	; Find first open slot 
	ld de, Enemy0
	ld a, [de]
	cp ENEMY_NONE
	jp z, .spawn 
	
	ld de, Enemy1 
	ld a, [de]
	cp ENEMY_NONE 
	jp z, .spawn 
	
	ld de, Enemy2
	ld a, [de]
	cp ENEMY_NONE 
	jp z, .spawn 
	
	ld de, Enemy3 
	ld a, [de]
	cp ENEMY_NONE 
	jp z, .spawn 
	
	ld de, Enemy4 
	ld a, [de]
	cp ENEMY_NONE 
	jp z, .spawn 
	
	jp .return 
	

.spawn 
	; hl = list entry 
	; de = enemy struct to use 
	ld a, d 
	ld [EnemyStruct], a 
	ld a, e 
	ld [EnemyStruct+1], a 			; save pointer for later
	
	ld a, [hl+]
	ld [de], a 		; store enemy type 
	inc de 
	ld [EnemyType], a 	; save enemy type for later 
	
	ld a, b 
	ld [de], a 		; store entry identifier 
	inc de 
	
	; from the tile x/y, convert to pixel coords for rect 
	ld a, [MapOriginX]
	ld b, a  
	ld a, [hl+]			; a = enemy tile x 
	sub b 				; a = tile x - origin x 
	sla a 
	sla a 
	sla a 				; multiply tile difference by 8 to get pixels 
	ld b, a 
	ld a, [BGFocusPixelsX]
	ld c, a 
	ld a, b 
	sub c  			; offset by focus scroll value 
	ld [de], a			; store RectX (int)
	inc de 
	ld a, 0 
	ld [de], a			; store RectX (fraction) 
	inc de 
	
	ld a, [MapOriginY]
	ld b, a  
	ld a, [hl+]			; a = enemy tile y 
	sub b 				; a = tile x - origin x 
	sla a 
	sla a 
	sla a 				; multiply tile difference by 8 to get pixels 
	ld b, a 
	ld a, [BGFocusPixelsY]
	ld c, a 
	ld a, b 
	sub c      			; offset by focus scroll value 
	ld [de], a			; store RectY (int)
	inc de 
	ld a, 0 
	ld [de], a			; store RectY (fraction) 
	inc de 
	
	; Now call enemy-type specific spawning code
	ld a, [EnemyType]
	cp ENEMY_SLIME
	jp z, .slime 
	cp ENEMY_BIRDY
	jp z, .birdy 
	cp ENEMY_SHOOTER
	jp z, .shooter 
	cp ENEMY_SPIKE
	jp z, .spike 
	cp ENEMY_JUMP_SLIME
	jp z, .jump_slime 
	cp ENEMY_BOMB_BIRDY
	jp z, .bomb_birdy 
	cp ENEMY_PARA_SHOOTER
	jp z, .para_shooter 
	cp ENEMY_BLACK_SPIKE
	jp z, .black_spike 
	cp ENEMY_ZIG_BIRDY 
	jp z, .zig_birdy 
	
.slime 
	ld a, SLIME_WIDTH
	ld [de], a
	inc de 
	ld a, SLIME_HEIGHT
	ld [de], a 
	inc de 
	ld a, [hl+]
	ld [de], a 				; save left tile boundary
	inc de 
	ld a, [hl+]
	ld [de], a 				; save right tile boundary 
	inc de 
	ld a, 0 
	ld [de], a				; set anim counter to 0  
	ld b, SLIME_X_OFFSET
	ld c, SLIME_Y_OFFSET
	jp .apply_rect_offset 
	
	


.birdy 
.shooter 
.spike 
.jump_slime
.bomb_birdy
.para_shooter 
.black_spike
.zig_birdy

jp .return 
	
	
	
.apply_rect_offset
	; b should be x offset 
	; c should be y offset 
	ld a, [EnemyStruct]
	ld h, a 
	ld a, [EnemyStruct + 1]
	ld l, a 
	inc hl 
	inc hl 
	ld a, [hl]
	add a, b 		; add x + x_offset 
	ld [hl+], a 	; store as new rect x 
	inc hl 
	ld a, [hl]
	add a, c 		; add y + y_offset
	ld [hl], a 		; store as new rect y 
	jp .return 
	
.return 
	ret 
	

; hl = enemy struct pointer 
;  b = first obj offset from LocalOAM
Enemy_Update::
	
	ld a, h 
	ld [EnemyStruct], a 
	ld a, l 
	ld [EnemyStruct+1], a 		; save start of enemy struct 
	
	ld a, b 
	ld [OBJOffset], a 			; save obj offset 
	
	ld a, [hl+]
	ld [EnemyType], a 
	cp ENEMY_NONE 
	jp z, .return 
	
	; would a jump table be faster? Yea probably
	cp ENEMY_SLIME
	jp z, .slime 
	cp ENEMY_BIRDY
	jp z, .birdy 
	cp ENEMY_SHOOTER 
	jp z, .shooter 
	cp ENEMY_SPIKE 
	jp z, .spike 
	cp ENEMY_JUMP_SLIME
	jp z, .jump_slime
	cp ENEMY_BOMB_BIRDY
	jp z, .bomb_birdy
	cp ENEMY_PARA_SHOOTER
	jp z, .para_shooter
	cp ENEMY_BLACK_SPIKE
	jp z, .black_spike 
	cp ENEMY_ZIG_BIRDY
	jp z, .zig_birdy
	
	
	; Unknown enemy type... that's a problem
	jp .return 
	

	; This .generic label is actually a proc, so use call, not jp 
	; returns a = 1 if enemy is still alive, 0 if enemy was killed 
	; input: [EnemySpritePattern] = pattern index 
	; input: [EnemyFlip]			 = flip on x axis?
.generic 
	; check if overlapping the player 
	ld a, [EnemyStruct]
	ld h, a 
	ld a, [EnemyStruct+1]
	ld l, a 
	inc hl 
	inc hl 
	push hl 	; save this pointer to enemy rect 
	ld de, PlayerRect 
	call RectOverlapsRect_Fixed
	pop hl 		; restore enemy rect pointer 
	
	cp 0
	jp z, .generic_check_recall
	
	; enemy overlaps player. If a spike, instantly injure player 
	ld a, [EnemyType]
	cp ENEMY_SPIKE
	jp z, .damage_player 
	cp ENEMY_BLACK_SPIKE
	jp z, .damage_player 
	
	; Not a spike, so check the relative y position of the player 
	ld a, [PlayerPrevYLow]
	ld b, a 			; b = player bottom y pos 
	
	inc hl 
	inc hl 
	ld a, [hl+]			; inc hl twice to point at y coord and get it. (hl should have been pointing at enemy struct's rect)
	ld c, a 
	
	ld a, b 
	
	; if the enemy pos is higher (lower y val) than the player pos, damage the player 
	cp c 
	jp nc, .damage_player
	
	; Well, the player was higher than enemy, so now we need to kill this enemy :(
	ld a, [EnemyStruct]
	ld h, a 
	ld a, [EnemyStruct+1]
	ld l, a 
	ld a, [OBJOffset]
	ld b, a 
	call Enemy_Kill 
	call SpawnStars
	ld a, 0 
	ret 
	
	
.damage_player
	ld a, [EnemyStruct]
	ld h, a 
	ld a, [EnemyStruct+1]
	ld l, a 
	inc hl 
	inc hl 
	ld a, [hl+]				
	ld b, a 
	inc hl 
	inc hl 
	inc hl 		; hl pointing at width 
	ld a, [hl]
	srl a 		; divide width by 2 
	add a, b 	; a = x coord of contact 
	call Player_Damage 
	jp .generic_check_recall


.generic_check_recall 
	; Check if the enemy is outside of the screen rect. If so, recall the enemy
	; Recall meaning, nullify enemy but do not purge from enemy list. So if the enemy
	; should be loaded in again, it will because the player has not killed it.
	ld a, [EnemyStruct]
	ld h, a 
	ld a, [EnemyStruct + 1]
	ld l, a 
	inc hl
	inc hl 			; hl pointing at enemy rect 
	ld a, [hl+]		; get x coord
	cp RECALL_RANGE_MIN
	jp c, .generic_check_recall_y		; less than min
	cp RECALL_RANGE_MAX 
	jp nc, .generic_check_recall_y		; more than max
	jp .generic_recall 
	
.generic_check_recall_y
	inc hl 
	ld a, [hl]
	cp RECALL_RANGE_MIN
	jp c, .generic_update_objs		; less than min
	cp RECALL_RANGE_MAX 
	jp nc, .generic_update_objs		; more than max
	jp .generic_recall 
	
.generic_recall 
	ld a, [EnemyStruct]
	ld h, a 
	ld a, [EnemyStruct+1]
	ld l, a 
	ld a, [OBJOffset]
	ld b, a 
	call Enemy_Recall
	ld a, 0 
	ret 

.generic_update_objs
	ld a, [EnemyStruct]
	ld h, a 
	ld a, [EnemyStruct+1]
	ld l, a 
	inc hl 
	inc hl 		; hl points at enemy rect 
	ld a, [EnemySpritePattern]
	ld b, a 
	ld a, [OBJOffset]
	ld c, a 
	ld a, [EnemyRectOffsetX]
	ld d, a 
	ld a, [EnemyRectOffsetY]
	ld e, a 
	ld a, [EnemyFlip]
	call UpdateOAMFromRect_2x2
	
	ld a, 1 
	ret 
	
.slime 
	 
	; Slimey updates 
	ld a, [EnemyStruct]
	ld h, a 
	ld a, [EnemyStruct+1]
	ld l, a 
	
	; Get x pos 
	inc hl 
	inc hl 
	ld a, [hl+]
	ld [EnemyX], a
	ld a, [hl+]
	ld [EnemyX+1], a 
	
	; Get Scratch 
	ld a, l 
	add a, 4 
	ld l, a 
	ld a, h 
	adc a, 0 
	ld h, a 		; position hl at scratch 
	
	ld a, [hl+]
	ld [EnemyScratch], a 		; left tile 
	ld a, [hl+]
	ld [EnemyScratch+1], a 		; right tile 
	ld a, [hl+]
	ld [EnemyScratch+2], a 		; cur direction 
	ld a, [hl]
	ld [EnemyScratch+3], a 		; anim counter 
	inc a
	ld [hl], a 					; inc anim counter 
	ld a, [EnemyScratch+2]		; get cur dir 
	cp 0 
	jp z, .slime_move_left 
	ld de, SLIME_MOVE_SPEED
	jp .slime_move 
.slime_move_left
	ld de, 0 - SLIME_MOVE_SPEED
.slime_move 
	ld a, [EnemyX]
	ld h, a 
	ld a, [EnemyX+1]
	ld l, a 
	add hl, de 			; get new slime position 
	ld a, l
	ld [EnemyX+1], a 	
	ld a, h 
	ld [EnemyX], a 		; store new x pos 
	
	; Check if tile is past left bounds or right bounds 
	ld b, a 
	ld a, [BGFocusPixelsX]
	ld c, a 
	ld a, b 
	add a, c 			; add scroll offset to get correct tile 
	ld b, a 
	add a, SLIME_WIDTH - 1 
	ld d, a 
	
	cp RECALL_RANGE_MAX
	jp nc, .slime_shift_arith
	srl b 
	srl b 
	srl b
	srl d 
	srl d 
	srl d 
	jp .slime_add_bias
.slime_shift_arith
	sra b 
	sra b 
	sra b 
	sra d 
	sra d 
	sra d 
.slime_add_bias
	ld a, 32 		; use tile bias for positive compare 
	add a, b 			; b = cur tile 
	ld b, a 
	ld a, 32 
	add a, d 
	ld d, a 
	
	; check left boundary 
	ld a, [MapOriginX]
	ld c, a 
	ld a, [EnemyScratch]
	sub c 					; a = relative left 
	sub 1 					; move boundary one tile over when going left
	add a, 32 				; bias by 32 for positive compare 
	cp b
	jp nc, .slime_set_dir_right
	
	; check right boundary 
	ld a, [EnemyScratch+1]
	sub c 
	inc a 
	add a, 32 
	cp d 
	jp c, .slime_set_dir_left
	jp .slime_finish 
	
.slime_set_dir_right
	ld a, 1 
	ld [EnemyScratch+2], a 
	jp .slime_finish
.slime_set_dir_left 
	ld a, 0 
	ld [EnemyScratch+2], a 
	
.slime_finish
	; save updated position
	ld a, [EnemyStruct]
	ld h, a 
	ld a, [EnemyStruct+1]
	ld l, a 
	inc hl 
	inc hl 
	ld a, [EnemyX]
	ld [hl+], a 
	ld a, [EnemyX+1]
	ld [hl+], a 
	ld bc, 6 
	add hl, bc 
	ld a, [EnemyScratch+2]
	ld [hl], a 
	ld [EnemyFlip], a 
	
	ld a, [EnemyScratch+3]		; get anim counter 
	and $10 
	srl a 
	srl a 
	ld b, a 
	ld a, ENEMY_TILE_SLIME 
	add a, b
	ld [EnemySpritePattern], a 
	ld a, SLIME_X_OFFSET
	ld [EnemyRectOffsetX],a 
	ld a, SLIME_Y_OFFSET
	ld [EnemyRectOffsetY], a 
	call .generic
	
	jp .return 


.birdy 
.shooter 
.spike 
.jump_slime
.bomb_birdy
.para_shooter
.black_spike
.zig_birdy
	
	
	
.return 
	ret 
	
; hl = enemy struct 
; b = obj index 
Enemy_Kill::
	inc hl
	ld a, [hl]
	dec hl 
	push hl 		; save enemy struct 
	ld hl, EnemyList 
	ld d, a 
	ld a, MAX_ENEMY_LIST_ENTRIES
	sub d 
	sla a 
	sla a 
	sla a 		; mult by 8 to get offset into EnemyList array 
	ld e, a 
	ld d, 0 
	add hl, de 
	ld a, ENEMY_NONE 
	ld [hl], a 	; clear the enemy entry 
	pop hl 			; restore enemy struct 
	call Enemy_Recall  	; to remove enemy from Enemies array and to hide sprites 
	call Player_Bounce
	ret 
	
	
; hl = enemy struct 
; b = obj index 
Enemy_Recall::
	; This will remove an enemy from Enemies array of structures 
	ld a, ENEMY_NONE 
	ld [hl+], a 			; clear the enemy type  
	ld a, 0 
	ld [hl], a 				; clear the enemy identifier
	
	; Reset objs 
	sla b 
	sla b 			; mult obj offset by 4 to get offset in bytes of LocalOAM
	ld c, b 
	ld b, 0 
	ld hl, LocalOAM
	add hl, bc 
	
	ld a, 0				; 0 will disable sprite  
	; disable obj0 
	ld [hl+], a 
	ld [hl+], a 
	inc hl
	inc hl 
	; disable obj1 
	ld [hl+], a 
	ld [hl+], a 
	inc hl
	inc hl 
	; disable obj2 
	ld [hl+], a 
	ld [hl+], a 
	inc hl
	inc hl
	; disable obj3 
	ld [hl+], a 
	ld [hl+], a 
	inc hl
	inc hl 
	
	ret 

	
SpawnStars::
	ld a, 1 
	ld [StarsActive], a 
	ld a, [PlayerRect]
	ld b,a
	ld [Star1X], a 
	ld [Star2X], a 
	ld a, [PlayerRect+2]
	add a, PLAYER_HEIGHT + 4
	ld c, a 
	ld [StarsY], a 
	ld a, STAR_COUNTER_MAX 
	ld [StarsCounter], a 
	
	; setup star obj attributes 
	ld hl, LocalOAM + STARS_OBJ_INDEX*4 
	ld de, LocalOAM + STARS_OBJ_INDEX*4 + 4 
	ld a, c 
	add a, 16 
	ld [hl+], a 
	ld [de], a 
	inc de 
	ld a, b 
	add a, 8 
	ld [hl+], a 
	ld [de], a 
	inc de 
	ld a, ITEM_TILE_STAR
	ld [hl+], a
	ld [de], a 
	inc de 
	ld a, 0 
	ld [hl], a 
	ld [de], a 
	
	ret 
	
UpdateStars::
	ld a, [StarsActive]
	cp 0 
	ret z 

	; stars are active so update 
	ld a, [StarsCounter]
	dec a 
	ld [StarsCounter], a 
	cp 0
	jp z, .deactivate_stars 
	
	; set y obj val 
	ld hl, LocalOAM + STARS_OBJ_INDEX*4
	ld a, [StarsY]
	add a, 16 
	ld [hl], a 
	ld hl, LocalOAM + STARS_OBJ_INDEX*4 + 4
	ld [hl], a 
	
	ld b, STAR_SPEED
	ld a, [Star1X]
	sub b 
	ld [Star1X], a 
	add a, 8 
	ld hl, LocalOAM + STARS_OBJ_INDEX*4 + 1 
	ld [hl], a 
	ld a, [Star2X]
	add a, b 
	ld [Star2X], a 
	add a, 8 
	ld hl, LocalOAM + STARS_OBJ_INDEX*4 + 4 + 1 
	ld [hl], a 

	ret 
	
.deactivate_stars
	; clear star flag 
	ld a, 0 
	ld [StarsActive], a 
	
	; disable star objs 
	ld a, 0 
	ld hl, LocalOAM + STARS_OBJ_INDEX*4
	ld [hl+], a 
	ld [hl+], a 
	inc hl 
	inc hl 
	ld [hl+], a 
	ld [hl+], a 
	ret 
	