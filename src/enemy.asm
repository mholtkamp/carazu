INCLUDE "include/enemy.inc"
INCLUDE "include/constants.inc"
INCLUDE "include/util.inc"
INCLUDE "include/rect.inc"
INCLUDE "include/level.inc"
INCLUDE "include/globals.inc"
INCLUDE "include/player.inc"
INCLUDE "include/bullet.inc"
INCLUDE "tiles/enemy_tiles.inc"

SLIME_X_OFFSET EQU 2
SLIME_Y_OFFSET EQU 4
SLIME_WIDTH EQU 12 
SLIME_HEIGHT EQU 12
SLIME_MOVE_SPEED EQU $00C0
SLIME_GRAVITY EQU $0030

BIRDY_X_OFFSET EQU 1
BIRDY_Y_OFFSET EQU 4
BIRDY_WIDTH EQU 14
BIRDY_HEIGHT EQU 10 
BIRDY_Y_JITTER_SPEED EQU $0010
BIRDY_BOMB_INTERVAL EQU 75
BIRDY_BOMB_XVEL EQU $0000 
BIRDY_BOMB_YVEL EQU $0100
BIRDY_BOMB_GRAV_X EQU $00
BIRDY_BOMB_GRAV_Y EQU $06

SHOOTER_X_OFFSET EQU 0 
SHOOTER_Y_OFFSET EQU 0 
SHOOTER_WIDTH EQU 16 
SHOOTER_HEIGHT EQU 16 
SHOOTER_BULLET_GRAV EQU $18

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
EnemyPrevY:
DS 1 

EnemyYVel:
DS 2 

EnemyRectOffsetX:
DS 1 
EnemyRectOffsetY:
DS 1 

SlimeScratch: 
LeftBound:
DS 1 
RightBound:
DS 1 
EnemyXVel:
DS 1 
SlimeJumpVel:
DS 1 
SlimeFlags:
DS 1 
YOffset:
DS 1 
CurDirection:
DS 1 
AnimCounter:
DS 1 

BirdyVerticalDistance:
DS 1 
BirdyFlags:
DS 1 
BulletCounter:
DS 1 

ShooterBulletXVel:
DS 1 
ShooterBulletYVel:
DS 1 
ShooterBulletInterval:
DS 1 
ShooterFlags:
DS 1 


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
	ld hl, LocalOAM + STARS_OBJ_INDEX*4 
	ld [hl+], a 	; disable star1 sprite 
	ld [hl+], a 	; disable star2 sprite 
	inc hl 
	inc hl 
	ld [hl+], a 
	ld [hl+], a 	;disable star2 sprite
	
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
	ld [de], a 		; param0 = left boundary 
	inc de 			
	ld a, [hl+]
	ld [de], a 		; param1 = right boundary
	inc de 
	ld a, [hl+]		
	ld [de], a 		; param2 = xvel 
	inc de 			
	ld a, [hl+]
	ld [de], a 		; param3 = yvel 
	inc de 			
	ld a, [hl+]
	ld [de], a 		; param4 = option flags 
	inc de 			
	jp .loop
	
.load_birdy
	ld a, [hl+]
	ld [de], a 		; param0 = left boundary 
	inc de 			
	ld a, [hl+]
	ld [de], a 		; param1 = right boundary
	inc de 
	ld a, [hl+]		
	ld [de], a 		; param2 = xvel 
	inc de 			
	ld a, [hl+]
	ld [de], a 		; param3 = vertical distance 
	inc de 			
	ld a, [hl+]
	ld [de], a 		; param4 = option flags 
	inc de 			
	jp .loop 
	
.load_shooter
	ld a, [hl+]
	ld [de], a 		; param0 = bullet xvel 
	inc de 	
	ld a, [hl+]
	ld [de], a 		; param1 = bullet yvel 
	inc de 	
	ld a, [hl+]
	ld [de], a 		; param2 = bullet fire interval 
	inc de 	
	ld a, [hl+]
	ld [de], a 		; param3 = option flags 
	inc de
	inc de 			; no param4 
	
.load_spike
	ld a, [hl+]
	ld [de], a 		; param0 = left/top boundary 
	inc de 	
	ld a, [hl+]
	ld [de], a 		; param1 = right/bottom boundary 
	inc de 	
	ld a, [hl+]
	ld [de], a 		; param2 = speed 
	inc de 	
	ld a, [hl+]
	ld [de], a 		; param3 = option flags 
	inc de 	
	inc de 			; no param4 

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
	add a, 23 					; screen rect width = 24 
	cp d 
	jp z, .check_y_bounds 
	ld a, [ScreenRect+1]
	cp e
	jp z, .check_x_bounds 
	add a, 23 					; screen rect height = 24 
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
	ld a, [hl+]
	ld [de], a 				; save the xvel 
	inc de 					
	ld a, [hl+]
	ld [de], a 				; save the jump vel  (yvel)
	inc de 
	ld a, [hl+]
	ld [de], a 				; save the option flags 
	inc de 
	ld a, 0 
	ld [de], a 				; save cur direction as 0 (left)
	inc de 			
	ld [de], a				; set anim counter to 0  
	inc de 
	ld a, 0
	ld [de], a 				; set y vel (int)
	inc de 
	ld [de], a 				; set y vel (fract)
	inc de 
	ld [de], a 				; set y offset to 0 
	ld b, SLIME_X_OFFSET
	ld c, SLIME_Y_OFFSET
	jp .apply_rect_offset 
	
.birdy 
	ld a, BIRDY_WIDTH
	ld [de], a 
	inc de 
	ld a, BIRDY_HEIGHT 
	ld [de], a 
	inc de 
	ld a, [hl+]
	ld [de], a 				; save left tile boundary
	inc de 
	ld a, [hl+]
	ld [de], a 				; save right tile boundary 
	inc de 
	ld a, [hl+]
	ld [de], a 				; save the xvel 
	inc de 		
	ld a, [hl+]
	ld [de], a				; save vertical distance  
	inc de
	ld a, [hl+]
	ld [de], a 				; save the options flag 
	inc de 
	ld a, 0 
	ld [de], a 				; init cur direction 
	inc de 
	ld [de], a 				; init anim counter 
	inc de 
	ld [de], a 				; init bullet counter to 0 
	inc de 
	ld [de], a 				; init y offset to 0
	ld b, BIRDY_X_OFFSET
	ld c, BIRDY_Y_OFFSET
	jp .apply_rect_offset

.shooter 
	ld a, SHOOTER_WIDTH
	ld [de], a
	inc de 
	ld a, SHOOTER_HEIGHT 
	ld [de], a 
	inc de 
	ld a, [hl+]
	ld [de], a				; save bullet xvel 
	inc de 
	ld a, [hl+]
	ld [de], a				; save bullet yvel  
	inc de
	ld a, [hl+]
	ld [de], a 				; save bullet interval 
	inc de 
	ld a, [hl+]
	ld [de], a				; save flags  
	inc de 
	ld a, 0 
	ld [de], a 				; init anim counter 
	inc de 
	ld [de], a				; init bullet counter 
	ld b, SHOOTER_X_OFFSET
	ld c, SHOOTER_Y_OFFSET 
	jp .apply_rect_offset
	
.spike 

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
	inc hl 
	ld a, [hl+]
	ld [EnemyX], a
	ld a, [hl+]
	ld [EnemyX+1], a 
	ld a, [hl+]
	ld [EnemyY], a 
	ld [EnemyPrevY], a 
	ld a, [hl+]
	ld [EnemyY+1], a 
	ld a, [hl+]
	ld [EnemyWidth], a 
	ld a, [hl+]
	ld [EnemyHeight], a 
	
	ld a, [EnemyType]
	cp ENEMY_NONE 
	jp z, .return 
	
	; would a jump table be faster? With only 4 enemies probably not 
	cp ENEMY_SLIME
	jp z, .slime 
	cp ENEMY_BIRDY
	jp z, .birdy 
	cp ENEMY_SHOOTER 
	jp z, .shooter 
	cp ENEMY_SPIKE 
	jp z, .spike 
	
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
	
	; enemy overlaps player. If a spike, or shooter instantly damage player 
	ld a, [EnemyType]
	cp ENEMY_SPIKE
	jp z, .damage_player 
	cp ENEMY_SHOOTER 
	jp z, .generic_check_recall
	
.check_damage_cond
	; Not a spike, so check the relative y position of the player 
	ld a, [PlayerPrevYLow]
	ld b, a 			; b = player bottom y pos 
	dec b 				; give player a 1 pixel advantage 
	
	ld a, [EnemyPrevY]		; compare with enemy prev y 
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
	ld a, [EnemyStruct+1]
	add a, 8 
	ld l, a 
	ld a, [EnemyStruct]
	adc a, 0 
	ld h, a 			; load enemy struct pointer and offset into scratch region 
	
	; Load slime behavior config 
	ld a, [hl+]
	ld [LeftBound], a 		; left tile 
	ld a, [hl+]
	ld [RightBound], a 	; right tile 
	ld a, [hl+]
	ld [EnemyXVel], a 			; xvel 
	ld a, [hl+]
	ld [SlimeJumpVel], a 		; jump vel
	ld a, [hl+]
	ld [SlimeFlags], a			; flags  

	; Load slime variables
	ld a, [hl+]
	ld [CurDirection], a 		; cur direction 
	ld a, [hl]
	ld [AnimCounter], a 		; anim counter 
	inc a
	ld [hl+], a 				; inc anim counter 
	ld a, [hl+]
	ld [EnemyYVel], a 			; get y vel (int)
	ld a, [hl+]
	ld [EnemyYVel+1], a 		; get y vel (fraction)
	ld a, [hl+]
	ld [YOffset], a 			; y offset 

	call Enemy_MoveWithBounds
	
.slime_jump
	ld a, [SlimeFlags]
	and SLIME_FLAG_JUMP
	jp z, .slime_finish 	; not a jumping slime, so just go to finish 
	ld a, [EnemyYVel]
	ld d, a 
	ld a, [EnemyYVel+1]
	ld e, a 
	ld hl, SLIME_GRAVITY
	add hl, de 				; get new y velocity 
	ld a, h 
	cpl 
	inc a 
	ld b, a 
	ld a, [YOffset]
	add a, b 
	bit 7, a 
	jp nz, .slime_reset_jump
	ld [YOffset], a 
	ld a, [EnemyY]
	add a, h 
	ld [EnemyY], a 
	ld a, h 
	ld [EnemyYVel], a 
	ld a, l 
	ld [EnemyYVel+1], a 
	jp .slime_finish
.slime_reset_jump 
	ld a, [YOffset]
	ld b, a 
	ld a, [EnemyY]
	add a, b 
	ld [EnemyY], a 
	ld a, 0 
	ld [YOffset], a
	ld a, [SlimeJumpVel]
	ld l, a 
	ld h, $ff
	sla l 
	rl h 
	sla l
	rl h 
	sla l 
	rl h 
	ld a, h 
	ld [EnemyYVel], a
	ld a, l 
	ld [EnemyYVel+1], a 	
	
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
	ld a, [EnemyY]
	ld [hl+], a 
	ld a, [EnemyY+1]
	ld [hl+], a 
	ld bc, 7 
	add hl, bc 
	ld a, [CurDirection]
	ld [hl+], a 
	ld [EnemyFlip], a 
	inc hl 
	ld a, [EnemyYVel]
	ld [hl+], a 
	ld a, [EnemyYVel+1]
	ld [hl+], a 
	ld a, [YOffset]
	ld [hl+], a 
	
	ld a, [AnimCounter]		; get anim counter 
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
	ld a, [EnemyStruct+1]
	add a, 8 
	ld l, a 
	ld a, [EnemyStruct]
	adc a, 0 
	ld h, a 			; load enemy struct pointer and offset into scratch region 
	
	; Load birdy behavior config 
	ld a, [hl+]
	ld [LeftBound], a 
	ld a, [hl+]
	ld [RightBound], a 
	ld a, [hl+]
	ld [EnemyXVel], a 
	ld a, [hl+]
	ld [BirdyVerticalDistance], a 
	ld a, [hl+]
	ld [BirdyFlags], a

	; Load birdy variables 
	ld a, [hl+]
	ld [CurDirection], a 
	ld a, [hl]
	ld [AnimCounter], a 
	inc a 
	ld [hl+], a 
	ld a, [hl+]
	ld [BulletCounter], a 
	ld a, [hl+]
	ld [YOffset], a 
	
	ld a, [BirdyFlags]
	and BIRDY_FLAG_ONE_WAY
	jp nz, .birdy_one_way
	call Enemy_MoveWithBounds
	jp .birdy_zig_zag 
	
.birdy_one_way
	ld a, [EnemyX]
	ld h, a 
	ld a, [EnemyX+1]
	ld l, a 
	
	ld a, [EnemyXVel]
	ld e, a 
	bit 7, e 
	jp nz, .birdy_one_way_neg_vel
	ld d, 0 
	ld a, 1 
	ld [CurDirection], a 
	jp .birdy_one_way_add_vel
.birdy_one_way_neg_vel
	ld d, $ff
	ld a, 0 
	ld [CurDirection], a 
.birdy_one_way_add_vel
	sla e 
	rl d 
	sla e 
	rl d 
	sla e 
	rl d 
	add hl, de 
	ld a, h 
	ld [EnemyX], a 
	ld a, l 
	ld [EnemyX+1], a 
	jp .birdy_zig_zag
	
.birdy_zig_zag
	ld a, [BirdyFlags]
	and BIRDY_FLAG_ZIG_ZAG 
	jp z, .birdy_finish
	ld a, [YOffset]
	bit 7, a 		; bit 7 stores moving direction 
	jp nz, .birdy_zig_zag_up
	inc a 
	ld b, a 
	ld a, [EnemyY]
	inc a 
	ld [EnemyY], a 
	ld a, [BirdyVerticalDistance]
	cp b 
	jp z, .birdy_zig_zag_go_up
	ld a, b 		
	ld [YOffset] , a ;going down still, dont set bit 7. save y offset 
	jp .birdy_bomb
.birdy_zig_zag_go_up 
	ld a, b 
	set 7, a 
	ld [YOffset], a 
	jp .birdy_bomb
.birdy_zig_zag_up
	res 7, a 
	dec a 
	ld b, a 
	ld a, [EnemyY]
	dec a 
	ld [EnemyY], a 
	ld a, b
	cp 0 
	jp z, .birdy_zig_zag_go_down 
	ld a, b 		
	set 7, a 
	ld [YOffset] , a ;going up still, set bit 7. save y offset 
	jp .birdy_bomb
.birdy_zig_zag_go_down 
	ld a, b 
	ld [YOffset], a 	; going down now, dont set bit 7 
	jp .birdy_bomb

.birdy_bomb 
	ld a, [BirdyFlags]
	and BIRDY_FLAG_BOMB 
	jp z, .birdy_finish
	
	ld a, [BulletCounter]
	cp 0 
	jp z, .birdy_fire_bullet 
	dec a 
	ld [BulletCounter], a 
	jp .birdy_finish
.birdy_fire_bullet 
	ld a, BIRDY_BOMB_INTERVAL
	ld [BulletCounter], a 		; reset counter 
	ld a, [EnemyX]
	add a, BIRDY_WIDTH/2 
	ld [FireParamX], a 
	ld a, [EnemyY]
	add a, BIRDY_HEIGHT/2 
	ld [FireParamY], a 
	ld a, 0
	ld [FireParamXVel], a 
	ld [FireParamXVel+1], a 
	ld a, BIRDY_BOMB_YVEL >> 8 
	ld [FireParamYVel], a 
	ld a, BIRDY_BOMB_YVEL & $00ff 
	ld [FireParamYVel+1], a 
	ld a, BIRDY_BOMB_GRAV_X
	ld [FireParamGravityX], a 
	ld a, BIRDY_BOMB_GRAV_Y
	ld [FireParamGravityY], a 
	call FireEnemyBullet
	; jp .birdy_finish 

	
.birdy_finish 
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
	ld a, [EnemyY]
	ld [hl+], a 
	ld a, [EnemyY+1]
	ld [hl+], a 
	ld bc, 7 
	add hl, bc 
	ld a, [CurDirection]
	ld [hl+], a 
	ld [EnemyFlip], a 
	inc hl 
	ld a, [BulletCounter]
	ld [hl+], a 
	ld a, [YOffset]
	ld [hl+], a 
	
	ld a, [AnimCounter]		; get anim counter 
	and $10 
	srl a 
	srl a 
	ld b, a 
	ld a, ENEMY_TILE_BIRDY
	add a, b
	ld [EnemySpritePattern], a 
	ld a, BIRDY_X_OFFSET
	ld [EnemyRectOffsetX],a 
	ld a, BIRDY_Y_OFFSET
	ld [EnemyRectOffsetY], a 
	call .generic
	jp .return 
	
	
.shooter 
	ld a, [EnemyStruct+1]
	add a, 8 
	ld l, a 
	ld a, [EnemyStruct]
	adc a, 0 
	ld h, a 			; load enemy struct pointer and offset into scratch region 
	
	; Load shooter behavior config 
	ld a, [hl+]
	ld [ShooterBulletXVel], a 		; bullet xvel 
	ld a, [hl+]
	ld [ShooterBulletYVel], a 		; bullet yvel 
	ld a, [hl+]
	ld [ShooterBulletInterval], a 	; bullet interval 
	ld a, [hl+]
	ld [ShooterFlags], a 			; option flags
	
	; Load shooter variables
	ld a, [hl]
	ld [AnimCounter], a 		; anim counter 
	inc a
	ld [hl+], a 				; inc anim counter 
	ld a, [hl+]
	ld [BulletCounter], a 		; get y vel (int)

	; Check if the shooter should launch a new bullet 
	ld a, [ShooterBulletInterval]
	ld b, a 
	ld a, [BulletCounter]
	inc a 
	ld [BulletCounter], a 
	cp b 	; does the bullet counter == bullet interval?
	jp nz, .shooter_finish 
	ld a, 0 
	ld [BulletCounter], a 		; reset bullet counter 
	
	; Prepare to fire bullet, setup the wram params for FireEnemyBullet
	ld a, [EnemyX]
	add a, SHOOTER_WIDTH/2 
	ld [FireParamX], a 
	ld a, [EnemyY]
	add a, SHOOTER_HEIGHT/2 
	ld [FireParamY], a 
	ld a, [ShooterBulletXVel]
	bit 7, a 
	jp nz, .shooter_neg_bullet_xvel
	ld h, 0 
	jp .shooter_xvel 
.shooter_neg_bullet_xvel
	ld h, $ff 
.shooter_xvel
	ld l, a 
	sla l 
	rl h 
	sla l 
	rl h 
	sla l 
	rl h 
	ld a, h 
	ld [FireParamXVel], a 
	ld a, l 
	ld [FireParamXVel + 1], a 
	ld a, [ShooterBulletYVel]
	bit 7, a 
	jp nz, .shooter_neg_bullet_yvel
	ld h, 0 
	jp .shooter_yvel 
.shooter_neg_bullet_yvel
	ld h, $ff 
.shooter_yvel
	ld l, a 
	sla l 
	rl h 
	sla l 
	rl h 
	sla l 
	rl h 
	ld a, h 
	ld [FireParamYVel], a 
	ld a, l 
	ld [FireParamYVel + 1], a 
	ld a, 0
	ld [FireParamGravityX], a 		; Never any x grav for shooter 
	
	ld a, [ShooterFlags]
	and SHOOTER_FLAG_APPLY_GRAVITY
	cp 0 
	jp z, .shooter_no_y_grav
	ld a, SHOOTER_BULLET_GRAV
	ld [FireParamGravityY], a 
	jp .shooter_call_fire
	
.shooter_no_y_grav
	ld a, 0 
	ld [FireParamGravityY], a 
	;jp .shooter_call_fire 
	
.shooter_call_fire
	call FireEnemyBullet
	; jp .shooter_finish

.shooter_finish 
	ld a, [EnemyStruct]
	ld h, a 
	ld a, [EnemyStruct+1]
	ld l, a 
	ld bc, 13 
	add hl, bc 
	
	ld a, [AnimCounter]		; get anim counter 
	and $38 
	srl a 
	ld b, a 
	bit 4, b 
	jp nz, .shooter_reverse_anim
	ld a, ENEMY_TILE_SHOOTER
	add a, b 
	ld [EnemySpritePattern],  a 
	jp .shooter_finish_for_real
.shooter_reverse_anim
	ld a, b 
	and $0f 		; chop off bit 4 
	ld b, a 
	ld a, ENEMY_TILE_SHOOTER + 12		; load last tile index 
	sub b 								; subtract instead of add to get looping animation 
	ld [EnemySpritePattern], a 
	; jp .shooter_finish_for_real
	
.shooter_finish_for_real

	ld a, SHOOTER_X_OFFSET
	ld [EnemyRectOffsetX],a 
	ld a, SHOOTER_Y_OFFSET
	ld [EnemyRectOffsetY], a 

	ld a, [BulletCounter]
	ld [hl], a 				; save bullet counter. hl should be pointing it from beginning of .shooter_finish 
	
	call .generic
	jp .return 


.spike 
	
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
	
	
Enemy_MoveWithBounds

	ld a, [CurDirection]		; get cur dir 
	cp 0 
	jp z, .move_left 
	ld a, [EnemyXVel]
	ld e, a 
	ld d, 0 
	sla e 
	rl d 
	sla e 
	rl d 
	sla e 
	rl d 					; speed is offset by 3 shifts 
	jp .move 
.move_left
	ld a, [EnemyXVel]
	cpl 
	ld e, a 
	ld d, $ff 
	sla e 
	rl d 
	sla e 
	rl d 
	sla e 
	rl d 
	inc de 
.move 
	ld a, [EnemyX]
	ld h, a 
	ld a, [EnemyX+1]
	ld l, a 
	add hl, de 			; get new enemy position 
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
	ld a, [EnemyWidth]
	dec a 
	ld c, a 
	ld a, b 
	add a, c 
	ld d, a 
	
	cp RECALL_RANGE_MAX
	jp nc, .shift_arith
	srl b 
	srl b 
	srl b
	srl d 
	srl d 
	srl d 
	jp .add_bias
.shift_arith
	sra b 
	sra b 
	sra b 
	sra d 
	sra d 
	sra d 
.add_bias
	ld a, 32 		; use tile bias for positive compare 
	add a, b 			; b = cur tile 
	ld b, a 
	ld a, 32 
	add a, d 
	ld d, a 
	
	; check left boundary 
	ld a, [MapOriginX]
	ld c, a 
	ld a, [LeftBound]
	sub c 					; a = relative left 
	sub 1 					; move boundary one tile over when going left
	add a, 32 				; bias by 32 for positive compare 
	cp b
	jp nc, .set_dir_right
	
	; check right boundary 
	ld a, [RightBound]
	sub c 
	inc a 
	add a, 32 
	cp d 
	jp c, .set_dir_left
	ret
	
.set_dir_right
	ld a, 1 
	ld [CurDirection], a 
	ret
.set_dir_left 
	ld a, 0 
	ld [CurDirection], a 
	ret 