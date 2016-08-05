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
SLIME_MOVE_SPEED EQU $0100

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

EnemyScratch: 
DS 12
EnemyPatternIndex:
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
	jp .return 
	cp ENEMY_SLIME
	jp .load_slime
	cp ENEMY_BIRDY
	jp .load_birdy 
	cp ENEMY_SHOOTER
	jp .load_shooter 
	cp ENEMY_SPIKE 
	jp .load_spike
	cp ENEMY_JUMP_SLIME
	jp .load_jump_slime
	cp ENEMY_BOMB_BIRDY
	jp .load_bomb_birdy 
	cp ENEMY_PARA_SHOOTER
	jp .load_para_shooter 
	cp ENEMY_BLACK_SPIKE
	jp .load_black_spike
	cp ENEMY_ZIG_BIRDY
	jp .load_zig_birdy 
	
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
	ld hl, Enemy0 + 1 
	ld a, [hl]
	add a, d 
	ld [hl+], a 
	inc hl 
	ld a, [hl]
	add a, e 
	ld [hl], a 

	; Enemy1 
	ld hl, Enemy1 + 1 
	ld a, [hl]
	add a, d 
	ld [hl+], a 
	inc hl 
	ld a, [hl]
	add a, e 
	ld [hl], a 
	
	; Enemy2 
	ld hl, Enemy2 + 1 
	ld a, [hl]
	add a, d 
	ld [hl+], a 
	inc hl 
	ld a, [hl]
	add a, e 
	ld [hl], a 
	
	; Enemy3
	ld hl, Enemy3 + 1 
	ld a, [hl]
	add a, d 
	ld [hl+], a 
	inc hl 
	ld a, [hl]
	add a, e 
	ld [hl], a 
	
	; Enemy4
	ld hl, Enemy4 + 1 
	ld a, [hl]
	add a, d 
	ld [hl+], a 
	inc hl 
	ld a, [hl]
	add a, e 
	ld [hl], a 

	ret 
	
UpdateEnemies::
	
	; Update each enemy struct first 
	; Originally, had this as loop, but unwrapping it for minor performance increase 
	ld hl, Enemy0 
	ld b, ENEMY_OBJ_INDEX*4 
	call Enemy_Update
	
	ld hl, Enemy1 
	ld b, (ENEMY_OBJ_INDEX+4)*4
	call Enemy_Update
	
	ld hl, Enemy2 
	ld b, (ENEMY_OBJ_INDEX+8)*4
	call Enemy_Update
	
	ld hl, Enemy3 
	ld b, (ENEMY_OBJ_INDEX+12)*4
	call Enemy_Update
	
	ld hl, Enemy4 
	ld b, (ENEMY_OBJ_INDEX+16)*4
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
	jp z, .continue 
	
	ld a, [hl+]
	ld [EnemyTileRect], a 		; tile x 
	ld a, [hl+]
	ld [EnemyTileRect+1], a 	; tile y 
	ld de, ScreenRect
	call RectOverlapsRect_Int
	
	cp 1 
	jp nz, .continue		; no rect overlap so do not attempt spawning  
	
	dec hl 
	dec hl 
	dec hl 			; dec three times to point to beginning of enemy list entry 
	
	push bc
	call Enemy_Spawn
	pop bc  
	
.continue 
	pop hl 	; get current enemy entry 
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
	add a, b  			; offset by focus scroll value 
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
	add a, b  			; offset by focus scroll value 
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
	jp .return 
	
	; would a jump table be faster? Yea probably
	cp ENEMY_SLIME
	jp .slime 
	cp ENEMY_BIRDY
	jp .birdy 
	cp ENEMY_SHOOTER 
	jp .shooter 
	cp ENEMY_SPIKE 
	jp .spike 
	cp ENEMY_JUMP_SLIME
	jp .jump_slime
	cp ENEMY_BOMB_BIRDY
	jp .bomb_birdy
	cp ENEMY_PARA_SHOOTER
	jp .para_shooter
	cp ENEMY_BLACK_SPIKE
	jp .black_spike 
	cp ENEMY_ZIG_BIRDY
	jp .zig_birdy
	
	
	; Unknown enemy type... that's a problem
	jp .return 
	

	; This .generic label is actually a proc, so use call, not jp 
	; returns a = 1 if enemy is still alive, 0 if enemy was killed 
	; input: [EnemyPatternIndex] = pattern index 
	; input: [FlipOBJs]			 = flip on x axis?
.generic 
	; check if overlapping the player 
	inc hl 		; hl now pointing at enemy rect 
	push hl 	; save this pointer to enemy rect 
	ld de, PlayerRect 
	call RectOverlapsRect_Fixed
	pop hl 		; restore enemy rect pointer 
	
	cp 0
	jp z, .generic_update_objs
	
	; enemy overlaps player. If a spike, instantly injure player 
	ld a, [EnemyType]
	cp ENEMY_SPIKE
	jp z, .damage_player 
	cp ENEMY_BLACK_SPIKE
	jp z, .damage_player 
	
	; Not a spike, so check the relative y position of the player 
	ld a, [PlayerRect+2]
	ld b, a 				
	ld a, PLAYER_HEIGHT - 1
	add a, b 
	ld b, a 			; b = player bottom y pos 
	inc hl 
	inc hl 
	ld a, [hl+]			; inc hl twice to point at y coord and get it. (hl should have been pointing at enemy struct's rect)
	ld c, a 
	inc hl 
	inc hl 
	ld a, [hl]			; get height 
	srl a 				; shift right to divide by 2 
	add a, c 			; a = enemy_y + enemy_height/2
	
	; if the enemy pos is higher than the player pos, damage the player 
	cp b 
	jp nc, .damage_player
	
	; Well, the player was higher than enemy, so now we need to kill this enemy :(
	ld a, [EnemyStruct]
	ld h, a 
	ld a, [EnemyStruct+1]
	ld l, a 
	ld a, [OBJOffset]
	ld b, a 
	call Enemy_Kill 
	ld a, 0 
	ret 
	
	
.damage_player
	; call Player_Damage 
	jp .generic_update_objs


.generic_update_objs
	ld a, [EnemyStruct]
	ld h, a 
	ld a, [EnemyStruct+1]
	ld l, a 
	inc hl 
	inc hl 		
	push hl 	; param 
	ld hl, LocalOAM
	ld a, [OBJOffset]
	ld c, a 
	ld b, 0 
	add hl, bc 
	push hl 	;
	
	
	
	ld a, 1 
	ret 
	
.slime 
	 
	; Slimey updates 
	ld a, [EnemyStruct]
	ld h, a 
	ld a, [EnemyStruct+1]
	ld l, a 
	
	; Get x pos 
	ld a, [hl+]
	ld [EnemyX], a
	ld a, [hl+]
	ld [EnemyX+1], a 
	
	; Get Scratch 
	ld a, l 
	add a, 6 
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
	jp .slime_move_left 
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
	sub c 			; subtract scroll offset 
	srl a 
	srl a 
	srl a 
	add a, 32 		; use tile bias 
	ld b, a 			; b = cur tile 
	
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
	sub 1 
	add a, 32 
	cp b 
	jp c, .slime_set_dir_left
	
.slime_set_dir_right
	ld a, 1 
	ld [EnemyScratch+2], a 
	jp .slime_finish
.slime_set_dir_left 
	ld a, 0 
	ld [EnemyScratch+2], a 
	
.slime_finish
	ld a, [EnemyScratch+3]		; get anim counter 
	and $04 
	ld b, a 
	ld a, ENEMY_TILE_SLIME 
	add a, b
	ld c, a 
    
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
	
Enemy_Kill::

	ret 
	
	
Enemy_Recall::

	ret 