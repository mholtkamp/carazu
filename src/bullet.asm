INCLUDE "include/bullet.inc"
INCLUDE "include/constants.inc"
INCLUDE "include/player.inc"
INCLUDE "include/rect.inc"
INCLUDE "include/globals.inc"
INCLUDE "include/enemy.inc"
INCLUDE "include/sound.inc"
INCLUDE "tiles/bullet_tiles.inc"

BULLET_ENEMY_RECT_OFFSET_X EQU 1 
BULLET_ENEMY_RECT_OFFSET_Y EQU 1
BULLET_ENEMY_WIDTH EQU 5 
BULLET_ENEMY_HEIGHT EQU 5 
BULLET_PLAYER_WIDTH EQU 5
BULLET_PLAYER_HEIGHT EQU 5 

DEACTIVATION_RANGE_MIN EQU  192 
DEACTIVATION_RANGE_MAX EQU  224 

BULLET_ENEMY_OBJ_FLAGS EQU $10 
BULLET_PLAYER_OBJ_FLAGS EQU $00

BULLET_PALETTE_COUNTER_MAX EQU 8
BASS_CANNON_MAX_COUNT EQU 18 

	SECTION "BulletVars", BSS 
	
Bullets:
EnemyBullets:
EnemyBullet0:
DS BULLET_DATA_SIZE
EnemyBullet1:
DS BULLET_DATA_SIZE
EnemyBullet2:
DS BULLET_DATA_SIZE
EnemyBullet3:
DS BULLET_DATA_SIZE
EnemyBullet4:
DS BULLET_DATA_SIZE

PlayerBullet:
DS BULLET_DATA_SIZE

FireParamX:
DS 1 
FireParamY:
DS 1 
FireParamXVel:
DS 2 
FireParamYVel:
DS 2 
FireParamGravityX:
DS 1 
FireParamGravityY:
DS 1 

BulletPalette:
DS 1 
BulletPaletteCounter:
DS 1 

BassCounter:
DS 1 

	SECTION "BulletProcs", HOME 
	
	
ResetBullets::

	ld a, 0
	ld b, BULLET_DATA_SIZE * (MAX_BULLETS_ENEMY + MAX_BULLETS_PLAYER)	
	ld hl, Bullets 
	
.loop 
	ld [hl+], a 
	dec b 
	jp nz, .loop 

	; initialize obj1 palette for enemy bullets 
	ld a, %11100100
	ld [BulletPalette], a 
	
	; Set rect locations to -8,-16 so the graphics are offscreen 
	ld a, -8 
	ld [EnemyBullet0 + 1], a 
	ld [EnemyBullet1 + 1], a 
	ld [EnemyBullet2 + 1], a 
	ld [EnemyBullet3 + 1], a 
	ld [EnemyBullet4 + 1], a 
	ld [PlayerBullet + 1], a 
	ld a, -16 
	ld [EnemyBullet0 + 3], a 
	ld [EnemyBullet1 + 3], a 
	ld [EnemyBullet2 + 3], a 
	ld [EnemyBullet3 + 3], a 
	ld [EnemyBullet4 + 3], a 
	ld [PlayerBullet + 3], a 
	
	ret 
	
LoadBulletGraphics::

	; First, load in bullet sprite tiles (player bullet + enemy bullet sprite)
	ld hl, BulletTiles
	ld de, TILE_BANK_0 + BULLET_PLAYER_TILE*16 
	ld b, 16*2 
	
.loop 
	ld a, [hl+]
	ld [de], a 
	inc de 
	
	dec b 
	jp nz, .loop 
		
	; Second, initialize the local oam
	ld hl, LocalOAM + BULLET_OBJ_INDEX*4
	
	; EnemyBullet0 
	ld a, 0 
	ld [hl+], a 
	ld [hl+], a 
	ld a, BULLET_ENEMY_TILE
	ld [hl+], a 
	ld a, BULLET_ENEMY_OBJ_FLAGS
	ld [hl+], a 
	; EnemyBullet1 
	ld a, 0 
	ld [hl+], a 
	ld [hl+], a 
	ld a, BULLET_ENEMY_TILE
	ld [hl+], a 
	ld a, BULLET_ENEMY_OBJ_FLAGS
	ld [hl+], a 
	; EnemyBullet2 
	ld a, 0 
	ld [hl+], a 
	ld [hl+], a 
	ld a, BULLET_ENEMY_TILE
	ld [hl+], a 
	ld a, BULLET_ENEMY_OBJ_FLAGS
	ld [hl+], a 
	; EnemyBullet3 
	ld a, 0 
	ld [hl+], a 
	ld [hl+], a 
	ld a, BULLET_ENEMY_TILE
	ld [hl+], a 
	ld a, BULLET_ENEMY_OBJ_FLAGS
	ld [hl+], a 
	; EnemyBullet4 
	ld a, 0 
	ld [hl+], a 
	ld [hl+], a 
	ld a, BULLET_ENEMY_TILE
	ld [hl+], a 
	ld a, BULLET_ENEMY_OBJ_FLAGS
	ld [hl+], a 
	; PlayerBullet
	ld a, 0 
	ld [hl+], a 
	ld [hl+], a 
	ld a, BULLET_PLAYER_TILE
	ld [hl+], a 
	ld a, BULLET_PLAYER_OBJ_FLAGS
	ld [hl+], a 

	ret 
	
	
UpdateBullets::
	
	call Bullet_UpdateEnemy0
	call Bullet_UpdateEnemy1
	call Bullet_UpdateEnemy2
	call Bullet_UpdateEnemy3
	call Bullet_UpdateEnemy4
	call Bullet_UpdatePlayer
	
	call UpdateBulletSprites
	
	ld a, [BulletPaletteCounter]
	inc a 
	ld [BulletPaletteCounter], a 
	cp BULLET_PALETTE_COUNTER_MAX
	ret nz
	
	ld a, 0 
	ld [BulletPaletteCounter], a 
	
	; Update obp1 for flashy effect 
	ld a, [BulletPalette]
	rlca 
	rlca 
	ld [BulletPalette], a 
	ld [rOBP1], a 

	ret 
	
; Pass by shared bss memory 
; Param0 = FireParamX
; Param1 = FireParamY
; Param2 = FireParamXVel
; Param3 = FireParamYVel
; Param4 = FireParamGravityX 
; Param5 = FireParamGravityY
FireEnemyBullet::

	; Iterate through bullets and find an inactive bullet 
	ld hl, EnemyBullet0
	ld a, [hl]
	cp 0 
	jp z, .fire
	
	ld hl, EnemyBullet1
	ld a, [hl]
	cp 0 
	jp z, .fire
	
	ld hl, EnemyBullet2
	ld a, [hl]
	cp 0 
	jp z, .fire
	
	ld hl, EnemyBullet3
	ld a, [hl]
	cp 0 
	jp z, .fire

	ld hl, EnemyBullet4
	ld a, [hl]
	cp 0 
	jp z, .fire
	
	ret		; return, all bullets are active. can't fire 
	
.fire
	ld a, 1 
	ld [hl+], a 	; Mark bullet as active 
	
	ld a, [FireParamX]
	ld [hl+], a 
	ld a, 0 
	ld [hl+], a 		; set starting x position
	
	ld a, [FireParamY]
	ld [hl+], a 
	ld a, 0 
	ld [hl+], a 		; set starting y position 
	
	ld a, BULLET_ENEMY_WIDTH
	ld [hl+], a 		; set bullet width (constant)
	ld a, BULLET_ENEMY_HEIGHT
	ld [hl+], a 		; set bullet height (constant)
	
	ld a, [FireParamXVel]
	ld [hl+], a 
	ld a, [FireParamXVel+1]
	ld [hl+], a 
	
	ld a, [FireParamYVel]
	ld [hl+], a 
	ld a, [FireParamYVel+1]
	ld [hl+], a 
	
	ld a, [FireParamGravityX]
	ld [hl+], a 
	ld a, [FireParamGravityY]
	ld [hl+], a 
	
	; Bullet is all set now, and will be updated / rendered in the Update proc
	; But consider adding code below to update the graphics for the current frame.
	; Probably not worth it
	ret 
	
	
; Pass by shared bss memory 
; Param0 = FireParamX
; Param1 = FireParamY
; Param2 = FireParamXVel
; Param3 = FireParamYVel
; Param4 = FireParamGravityX 
; Param5 = FireParamGravityY
FirePlayerBullet::

	; Iterate through bullets and find an inactive bullet 
	ld hl, PlayerBullet
	ld a, [hl]
	cp 0
	jp z, .fire 
	
	ret		; player already has an active bullet
		
.fire
	
	ld a, 1 
	ld [hl+], a 	; Mark bullet as active 
	
	ld a, [FireParamX]
	ld [hl+], a 
	ld a, 0 
	ld [hl+], a 		; set starting x position
	
	ld a, [FireParamY]
	ld [hl+], a 
	ld a, 0 
	ld [hl+], a 		; set starting y position 
	
	ld a, BULLET_PLAYER_WIDTH
	ld [hl+], a 		; set bullet width (constant)
	ld a, BULLET_PLAYER_HEIGHT
	ld [hl+], a 		; set bullet height (constant)
	
	ld a, [FireParamXVel]
	ld [hl+], a 
	ld a, [FireParamXVel+1]
	ld [hl+], a 
	
	ld a, [FireParamYVel]
	ld [hl+], a 
	ld a, [FireParamYVel+1]
	ld [hl+], a 
	
	ld a, [FireParamGravityX]
	ld [hl+], a 
	ld a, [FireParamGravityY]
	ld [hl+], a 
	
	ld a, 0 
	ld [BassCounter], a 		; Reset the bass counter 
	
	; Bullet is all set now, and will be updated / rendered in the Update proc
	; But consider adding code below to update the graphics for the current frame.
	; Probably not worth it
	
	; Play Fire Sound 
	ld a, $29
	ld b, $80
	ld c, $f8
	ld de, 1000
	ld h, $40 
	call PlaySound_1
	
	ret 
	
; hl = bullet struct 
Bullet_UpdateEnemy0:
	ld a, [EnemyBullet0]
	cp 0 
	ret z 		; return if inactive 
	
	ld a, [EnemyBullet0 + 11]	; get grav x 
	ld c, a 					
	ld b, 0						; bc = x gravity 
	ld a, [EnemyBullet0 + 7]
	ld h, a 
	ld a, [EnemyBullet0 + 8]
	ld l, a 					; hl = x velocity 
	add hl, bc 
	ld a, h 
	ld [EnemyBullet0 + 7], a 
	ld a, l 
	ld [EnemyBullet0 + 8], a 	; save new x vel 
	
	ld a, [EnemyBullet0 + 1]
	ld b, a 
	ld a, [EnemyBullet0 + 2]
	ld c, a 					; get x pos 
	add hl, bc 
	ld a, h 
	ld [EnemyBullet0 + 1], a 
	ld a, l 
	ld [EnemyBullet0 + 2], a 	; save new x pos 
	
	ld a, [EnemyBullet0 + 12]	; get grav y 
	ld c, a 					
	ld b, 0						; bc = y gravity 
	ld a, [EnemyBullet0 + 9]
	ld h, a 
	ld a, [EnemyBullet0 + 10]
	ld l, a 					; hl = y velocity 
	add hl, bc 
	ld a, h 
	ld [EnemyBullet0 + 9], a 
	ld a, l 
	ld [EnemyBullet0 + 10], a 	; save new y vel 
	
	ld a, [EnemyBullet0 + 3]
	ld b, a 
	ld a, [EnemyBullet0 + 4]
	ld c, a 					; get y pos 
	add hl, bc 
	ld a, h 
	ld [EnemyBullet0 + 3], a 
	ld a, l 
	ld [EnemyBullet0 + 4], a 	; save new y pos 
	
	ld hl, PlayerRect 
	ld de, EnemyBullet0 + 1 
	call RectOverlapsRect_Fixed
	cp 0
	jp z, .check_deactivation
	
	ld a, [EnemyBullet0 + 1]		; get x 
	add a, BULLET_ENEMY_WIDTH/2 	; get center x coord 
	call Player_Damage 				; attempt to damage player 
	ld hl, EnemyBullet0
	ld b, 0 						; EnemyBullet0 index 
	call Bullet_Deactivate			; deactivate it
	jp .return 
	
.check_deactivation
	ld a, [EnemyBullet0 + 1]
	cp DEACTIVATION_RANGE_MIN
	jp c, .check_y_deactivation 
	cp DEACTIVATION_RANGE_MAX
	jp nc, .check_y_deactivation 
	jp .deactivate
	
.check_y_deactivation
	ld a, [EnemyBullet0 + 3]
	cp DEACTIVATION_RANGE_MIN
	jp c, .return 
	cp DEACTIVATION_RANGE_MAX
	jp nc, .return 
	;jp .deactivate
	
.deactivate
	ld hl, EnemyBullet0
	ld b, 0 
	call Bullet_Deactivate
	; jp .return 

.return
	ret 
	
; hl = bullet struct 
Bullet_UpdateEnemy1:
	ld a, [EnemyBullet1]
	cp 0 
	ret z 		; return if inactive 
	
	ld a, [EnemyBullet1 + 11]	; get grav x 
	ld c, a 					
	ld b, 0						; bc = x gravity 
	ld a, [EnemyBullet1 + 7]
	ld h, a 
	ld a, [EnemyBullet1 + 8]
	ld l, a 					; hl = x velocity 
	add hl, bc 
	ld a, h 
	ld [EnemyBullet1 + 7], a 
	ld a, l 
	ld [EnemyBullet1 + 8], a 	; save new x vel 
	
	ld a, [EnemyBullet1 + 1]
	ld b, a 
	ld a, [EnemyBullet1 + 2]
	ld c, a 					; get x pos 
	add hl, bc 
	ld a, h 
	ld [EnemyBullet1 + 1], a 
	ld a, l 
	ld [EnemyBullet1 + 2], a 	; save new x pos 
	
	ld a, [EnemyBullet1 + 12]	; get grav y 
	ld c, a 					
	ld b, 0						; bc = y gravity 
	ld a, [EnemyBullet1 + 9]
	ld h, a 
	ld a, [EnemyBullet1 + 10]
	ld l, a 					; hl = y velocity 
	add hl, bc 
	ld a, h 
	ld [EnemyBullet1 + 9], a 
	ld a, l 
	ld [EnemyBullet1 + 10], a 	; save new y vel 
	
	ld a, [EnemyBullet1 + 3]
	ld b, a 
	ld a, [EnemyBullet1 + 4]
	ld c, a 					; get y pos 
	add hl, bc 
	ld a, h 
	ld [EnemyBullet1 + 3], a 
	ld a, l 
	ld [EnemyBullet1 + 4], a 	; save new y pos 
	
	ld hl, PlayerRect 
	ld de, EnemyBullet1 + 1 
	call RectOverlapsRect_Fixed
	cp 0
	jp z, .check_deactivation
	
	ld a, [EnemyBullet1 + 1]		; get x 
	add a, BULLET_ENEMY_WIDTH/2 	; get center x coord 
	call Player_Damage 				; attempt to damage player 
	ld hl, EnemyBullet1
	ld b, 1 						; EnemyBullet1 index 
	call Bullet_Deactivate			; deactivate it
	jp .return 
	
.check_deactivation
	ld a, [EnemyBullet1 + 1]
	cp DEACTIVATION_RANGE_MIN
	jp c, .check_y_deactivation 
	cp DEACTIVATION_RANGE_MAX
	jp nc, .check_y_deactivation 
	jp .deactivate
	
.check_y_deactivation
	ld a, [EnemyBullet1 + 3]
	cp DEACTIVATION_RANGE_MIN
	jp c, .return 
	cp DEACTIVATION_RANGE_MAX
	jp nc, .return 
	;jp .deactivate
	
.deactivate
	ld hl, EnemyBullet1
	ld b, 1 
	call Bullet_Deactivate
	; jp .return 

.return
	ret 
	
; hl = bullet struct 
Bullet_UpdateEnemy2:
	ld a, [EnemyBullet2]
	cp 0 
	ret z 		; return if inactive 
	
	ld a, [EnemyBullet2 + 11]	; get grav x 
	ld c, a 					
	ld b, 0						; bc = x gravity 
	ld a, [EnemyBullet2 + 7]
	ld h, a 
	ld a, [EnemyBullet2 + 8]
	ld l, a 					; hl = x velocity 
	add hl, bc 
	ld a, h 
	ld [EnemyBullet2 + 7], a 
	ld a, l 
	ld [EnemyBullet2 + 8], a 	; save new x vel 
	
	ld a, [EnemyBullet2 + 1]
	ld b, a 
	ld a, [EnemyBullet2 + 2]
	ld c, a 					; get x pos 
	add hl, bc 
	ld a, h 
	ld [EnemyBullet2 + 1], a 
	ld a, l 
	ld [EnemyBullet2 + 2], a 	; save new x pos 
	
	ld a, [EnemyBullet2 + 12]	; get grav y 
	ld c, a 					
	ld b, 0						; bc = y gravity 
	ld a, [EnemyBullet2 + 9]
	ld h, a 
	ld a, [EnemyBullet2 + 10]
	ld l, a 					; hl = y velocity 
	add hl, bc 
	ld a, h 
	ld [EnemyBullet2 + 9], a 
	ld a, l 
	ld [EnemyBullet2 + 10], a 	; save new y vel 
	
	ld a, [EnemyBullet2 + 3]
	ld b, a 
	ld a, [EnemyBullet2 + 4]
	ld c, a 					; get y pos 
	add hl, bc 
	ld a, h 
	ld [EnemyBullet2 + 3], a 
	ld a, l 
	ld [EnemyBullet2 + 4], a 	; save new y pos 
	
	ld hl, PlayerRect 
	ld de, EnemyBullet2 + 1 
	call RectOverlapsRect_Fixed
	cp 0
	jp z, .check_deactivation
	
	ld a, [EnemyBullet2 + 1]		; get x 
	add a, BULLET_ENEMY_WIDTH/2 	; get center x coord 
	call Player_Damage 				; attempt to damage player 
	ld hl, EnemyBullet2
	ld b, 2 						; EnemyBullet2 index 
	call Bullet_Deactivate			; deactivate it
	jp .return 
	
.check_deactivation
	ld a, [EnemyBullet2 + 1]
	cp DEACTIVATION_RANGE_MIN
	jp c, .check_y_deactivation 
	cp DEACTIVATION_RANGE_MAX
	jp nc, .check_y_deactivation 
	jp .deactivate
	
.check_y_deactivation
	ld a, [EnemyBullet2 + 3]
	cp DEACTIVATION_RANGE_MIN
	jp c, .return 
	cp DEACTIVATION_RANGE_MAX
	jp nc, .return 
	;jp .deactivate
	
.deactivate
	ld hl, EnemyBullet2
	ld b, 2 
	call Bullet_Deactivate
	; jp .return 

.return
	ret 
	
; hl = bullet struct 
Bullet_UpdateEnemy3:
	ld a, [EnemyBullet3]
	cp 0 
	ret z 		; return if inactive 
	
	ld a, [EnemyBullet3 + 11]	; get grav x 
	ld c, a 					
	ld b, 0						; bc = x gravity 
	ld a, [EnemyBullet3 + 7]
	ld h, a 
	ld a, [EnemyBullet3 + 8]
	ld l, a 					; hl = x velocity 
	add hl, bc 
	ld a, h 
	ld [EnemyBullet3 + 7], a 
	ld a, l 
	ld [EnemyBullet3 + 8], a 	; save new x vel 
	
	ld a, [EnemyBullet3 + 1]
	ld b, a 
	ld a, [EnemyBullet3 + 2]
	ld c, a 					; get x pos 
	add hl, bc 
	ld a, h 
	ld [EnemyBullet3 + 1], a 
	ld a, l 
	ld [EnemyBullet3 + 2], a 	; save new x pos 
	
	ld a, [EnemyBullet3 + 12]	; get grav y 
	ld c, a 					
	ld b, 0						; bc = y gravity 
	ld a, [EnemyBullet3 + 9]
	ld h, a 
	ld a, [EnemyBullet3 + 10]
	ld l, a 					; hl = y velocity 
	add hl, bc 
	ld a, h 
	ld [EnemyBullet3 + 9], a 
	ld a, l 
	ld [EnemyBullet3 + 10], a 	; save new y vel 
	
	ld a, [EnemyBullet3 + 3]
	ld b, a 
	ld a, [EnemyBullet3 + 4]
	ld c, a 					; get y pos 
	add hl, bc 
	ld a, h 
	ld [EnemyBullet3 + 3], a 
	ld a, l 
	ld [EnemyBullet3 + 4], a 	; save new y pos 
	
	ld hl, PlayerRect 
	ld de, EnemyBullet3 + 1 
	call RectOverlapsRect_Fixed
	cp 0
	jp z, .check_deactivation
	
	ld a, [EnemyBullet3 + 1]		; get x 
	add a, BULLET_ENEMY_WIDTH/2 	; get center x coord 
	call Player_Damage 				; attempt to damage player 
	ld hl, EnemyBullet3
	ld b, 3 						; EnemyBullet3 index 
	call Bullet_Deactivate			; deactivate it
	jp .return 
	
.check_deactivation
	ld a, [EnemyBullet3 + 1]
	cp DEACTIVATION_RANGE_MIN
	jp c, .check_y_deactivation 
	cp DEACTIVATION_RANGE_MAX
	jp nc, .check_y_deactivation 
	jp .deactivate
	
.check_y_deactivation
	ld a, [EnemyBullet3 + 3]
	cp DEACTIVATION_RANGE_MIN
	jp c, .return 
	cp DEACTIVATION_RANGE_MAX
	jp nc, .return 
	;jp .deactivate
	
.deactivate
	ld hl, EnemyBullet3
	ld b, 3
	call Bullet_Deactivate
	; jp .return 

.return
	ret 
	
; hl = bullet struct 
Bullet_UpdateEnemy4:
	ld a, [EnemyBullet4]
	cp 0 
	ret z 		; return if inactive 
	
	ld a, [EnemyBullet4 + 11]	; get grav x 
	ld c, a 					
	ld b, 0						; bc = x gravity 
	ld a, [EnemyBullet4 + 7]
	ld h, a 
	ld a, [EnemyBullet4 + 8]
	ld l, a 					; hl = x velocity 
	add hl, bc 
	ld a, h 
	ld [EnemyBullet4 + 7], a 
	ld a, l 
	ld [EnemyBullet4 + 8], a 	; save new x vel 
	
	ld a, [EnemyBullet4 + 1]
	ld b, a 
	ld a, [EnemyBullet4 + 2]
	ld c, a 					; get x pos 
	add hl, bc 
	ld a, h 
	ld [EnemyBullet4 + 1], a 
	ld a, l 
	ld [EnemyBullet4 + 2], a 	; save new x pos 
	
	ld a, [EnemyBullet4 + 12]	; get grav y 
	ld c, a 					
	ld b, 0						; bc = y gravity 
	ld a, [EnemyBullet4 + 9]
	ld h, a 
	ld a, [EnemyBullet4 + 10]
	ld l, a 					; hl = y velocity 
	add hl, bc 
	ld a, h 
	ld [EnemyBullet4 + 9], a 
	ld a, l 
	ld [EnemyBullet4 + 10], a 	; save new y vel 
	
	ld a, [EnemyBullet4 + 3]
	ld b, a 
	ld a, [EnemyBullet4 + 4]
	ld c, a 					; get y pos 
	add hl, bc 
	ld a, h 
	ld [EnemyBullet4 + 3], a 
	ld a, l 
	ld [EnemyBullet4 + 4], a 	; save new y pos 
	
	ld hl, PlayerRect 
	ld de, EnemyBullet4 + 1 
	call RectOverlapsRect_Fixed
	cp 0
	jp z, .check_deactivation
	
	ld a, [EnemyBullet4 + 1]		; get x 
	add a, BULLET_ENEMY_WIDTH/2 	; get center x coord 
	call Player_Damage 				; attempt to damage player 
	ld hl, EnemyBullet4
	ld b, 4 						; EnemyBullet4 index 
	call Bullet_Deactivate			; deactivate it
	jp .return 
	
.check_deactivation
	ld a, [EnemyBullet4 + 1]
	cp DEACTIVATION_RANGE_MIN
	jp c, .check_y_deactivation 
	cp DEACTIVATION_RANGE_MAX
	jp nc, .check_y_deactivation 
	jp .deactivate
	
.check_y_deactivation
	ld a, [EnemyBullet4 + 3]
	cp DEACTIVATION_RANGE_MIN
	jp c, .return 
	cp DEACTIVATION_RANGE_MAX
	jp nc, .return 
	;jp .deactivate
	
.deactivate
	ld hl, EnemyBullet4
	ld b, 4 
	call Bullet_Deactivate
	; jp .return 

.return
	ret 
	
; hl = bullet struct 
Bullet_UpdatePlayer:
	ld a, [PlayerBullet]
	cp 0 
	ret z 		; return if inactive 
	
	ld a, [PlayerBullet + 11]	; get grav x 
	ld c, a 					
	ld b, 0						; bc = x gravity 
	ld a, [PlayerBullet + 7]
	ld h, a 
	ld a, [PlayerBullet + 8]
	ld l, a 					; hl = x velocity 
	add hl, bc 
	ld a, h 
	ld [PlayerBullet + 7], a 
	ld a, l 
	ld [PlayerBullet + 8], a 	; save new x vel 
	
	ld a, [PlayerBullet + 1]
	ld b, a 
	ld a, [PlayerBullet + 2]
	ld c, a 					; get x pos 
	add hl, bc 
	ld a, h 
	ld [PlayerBullet + 1], a 
	ld a, l 
	ld [PlayerBullet + 2], a 	; save new x pos 
	
	ld a, [PlayerBullet + 12]	; get grav y 
	ld c, a 					
	ld b, 0						; bc = y gravity 
	ld a, [PlayerBullet + 9]
	ld h, a 
	ld a, [PlayerBullet + 10]
	ld l, a 					; hl = y velocity 
	add hl, bc 
	ld a, h 
	ld [PlayerBullet + 9], a 
	ld a, l 
	ld [PlayerBullet + 10], a 	; save new y vel 
	
	ld a, [PlayerBullet + 3]
	ld b, a 
	ld a, [PlayerBullet + 4]
	ld c, a 					; get y pos 
	add hl, bc 
	ld a, h 
	ld [PlayerBullet + 3], a 
	ld a, l 
	ld [PlayerBullet + 4], a 	; save new y pos 
	
	ld a, [BassCounter]
	inc a 
	ld [BassCounter], a 		; inc counter 
	cp BASS_CANNON_MAX_COUNT
	jp z, .deactivate
	
	
	ld a, [Enemy0]
	cp 0 
	jp z, .enemy1
	
	ld hl, PlayerBullet+1
	ld de, Enemy0+2 
	call RectOverlapsRect_Fixed
	cp 0 
	jp z, .enemy1 
	
	ld hl, Enemy0
	ld b, ENEMY_OBJ_INDEX + 0
	jp .enemy_contact 
	
	
.enemy1 
	ld a, [Enemy1]
	cp 0 
	jp z, .enemy2
	
	ld hl, PlayerBullet+1
	ld de, Enemy1+2 
	call RectOverlapsRect_Fixed
	cp 0 
	jp z, .enemy2 
	
	ld hl, Enemy1
	ld b, ENEMY_OBJ_INDEX + 4
	jp .enemy_contact 
	
.enemy2 
	ld a, [Enemy2]
	cp 0 
	jp z, .enemy3
	
	ld hl, PlayerBullet+1
	ld de, Enemy2+2 
	call RectOverlapsRect_Fixed
	cp 0 
	jp z, .enemy3 
	
	ld hl, Enemy2
	ld b, ENEMY_OBJ_INDEX + 8
	jp .enemy_contact 
	
.enemy3 
	ld a, [Enemy3]
	cp 0 
	jp z, .enemy4
	
	ld hl, PlayerBullet+1
	ld de, Enemy3+2 
	call RectOverlapsRect_Fixed
	cp 0 
	jp z, .enemy4 
	
	ld hl, Enemy3
	ld b, ENEMY_OBJ_INDEX + 12
	jp .enemy_contact 
	
.enemy4 
	ld a, [Enemy4]
	cp 0 
	jp z, .check_deactivation
	
	ld hl, PlayerBullet+1
	ld de, Enemy4+2 
	call RectOverlapsRect_Fixed
	cp 0 
	jp z, .check_deactivation 
	
	ld hl, Enemy4
	ld b, ENEMY_OBJ_INDEX + 16 
	jp .enemy_contact 
	
.check_deactivation
	ld a, [PlayerBullet + 1]
	cp DEACTIVATION_RANGE_MIN
	jp c, .check_y_deactivation 
	cp DEACTIVATION_RANGE_MAX
	jp nc, .check_y_deactivation 
	jp .deactivate
	
.check_y_deactivation
	ld a, [PlayerBullet + 3]
	cp DEACTIVATION_RANGE_MIN
	jp c, .return 
	cp DEACTIVATION_RANGE_MAX
	jp nc, .return 
	jp .deactivate
	
.enemy_contact
	; hl should point to enemy struct 
	ld a, [hl]
	cp ENEMY_SHOOTER 
	jp z, .deactivate
	cp ENEMY_PLATFORM
	jp z, .deactivate
	cp ENEMY_SPIKE
	jp z, .spike 
	
.kill
	; kill the enemy
	; hl should contain enemy struct pointer 
	;  b should contain enemy index 
	ld c, 0 
	call Enemy_Kill 
	call SpawnStars_Bass
	jp .deactivate
	
.spike 
	push hl 
	ld de, 11 
	add hl, de 
	ld a, [hl]
	and SPIKE_FLAG_BLACK 
	pop hl 
	
	jp z, .kill 
	;jp .deactivate
	
.deactivate
	ld hl, PlayerBullet
	ld b, 5 
	call Bullet_Deactivate
	; jp .return 

.return
	ret 
	
; hl = bullet struct addr 
; b = bullet index 
Bullet_Deactivate::

	ld a, 0 
	ld [hl+], a 	; set active flag to 0
	ld a, -8 
	ld [hl+], a 
	inc hl 
	ld a, -16 
	ld [hl], a 
	
	ret 
	
UpdateBulletSprites::

	ld hl, LocalOAM + BULLET_OBJ_INDEX*4 
	ld a, [EnemyBullet0 + 3]
	add a, 16 - BULLET_ENEMY_RECT_OFFSET_Y
	ld [hl+], a 
	ld a, [EnemyBullet0 + 1]
	add a, 8 - BULLET_ENEMY_RECT_OFFSET_X
	ld [hl+], a 
	inc hl 
	inc hl 
	ld a, [EnemyBullet1 + 3]
	add a, 16 - BULLET_ENEMY_RECT_OFFSET_Y
	ld [hl+], a 
	ld a, [EnemyBullet1 + 1]
	add a, 8 - BULLET_ENEMY_RECT_OFFSET_X
	ld [hl+], a 
	inc hl 
	inc hl 
	ld a, [EnemyBullet2 + 3]
	add a, 16 - BULLET_ENEMY_RECT_OFFSET_Y
	ld [hl+], a 
	ld a, [EnemyBullet2 + 1]
	add a, 8 - BULLET_ENEMY_RECT_OFFSET_X 
	ld [hl+], a 
	inc hl 
	inc hl 
	ld a, [EnemyBullet3 + 3]
	add a, 16 - BULLET_ENEMY_RECT_OFFSET_Y
	ld [hl+], a 
	ld a, [EnemyBullet3 + 1]
	add a, 8 - BULLET_ENEMY_RECT_OFFSET_X 
	ld [hl+], a 
	inc hl 
	inc hl 
	ld a, [EnemyBullet4 + 3]
	add a, 16 - BULLET_ENEMY_RECT_OFFSET_Y
	ld [hl+], a 
	ld a, [EnemyBullet4 + 1]
	add a, 8 - BULLET_ENEMY_RECT_OFFSET_X 
	ld [hl+], a 
	inc hl 
	inc hl 
	ld a, [PlayerBullet + 3]
	add a, 16 
	ld [hl+], a 
	ld a, [PlayerBullet + 1]
	add a, 8 
	ld [hl+], a 
	inc hl 
	inc hl 
	ret 

; d = shiftx 
; e = shifty 
ScrollBullets::
	
	ld a, [EnemyBullet0]
	cp 0
	jp z, .bullet1
	ld hl, EnemyBullet0 + 1
	ld a, [hl]
	add a, d 
	ld [hl+], a 
	inc hl 
	ld a, [hl]
	add a, e 
	ld [hl], a 
	
.bullet1	
	ld a, [EnemyBullet1]
	cp 0
	jp z, .bullet2
	ld hl, EnemyBullet1 + 1
	ld a, [hl]
	add a, d 
	ld [hl+], a 
	inc hl 
	ld a, [hl]
	add a, e 
	ld [hl], a 
	
.bullet2	
	ld a, [EnemyBullet2]
	cp 0
	jp z, .bullet3
	ld hl, EnemyBullet2 + 1
	ld a, [hl]
	add a, d 
	ld [hl+], a 
	inc hl 
	ld a, [hl]
	add a, e 
	ld [hl], a 
	
.bullet3	
	ld a, [EnemyBullet3]
	cp 0
	jp z, .bullet4
	ld hl, EnemyBullet3 + 1
	ld a, [hl]
	add a, d 
	ld [hl+], a 
	inc hl 
	ld a, [hl]
	add a, e 
	ld [hl], a 
	
.bullet4	
	ld a, [EnemyBullet4]
	cp 0
	jp z, .bullet5
	ld hl, EnemyBullet4 + 1
	ld a, [hl]
	add a, d 
	ld [hl+], a 
	inc hl 
	ld a, [hl]
	add a, e 
	ld [hl], a 
	
.bullet5 
	ld a, [PlayerBullet]
	cp 0
	ret z 
	ld hl, PlayerBullet + 1
	ld a, [hl]
	add a, d 
	ld [hl+], a 
	inc hl 
	ld a, [hl]
	add a, e 
	ld [hl], a 
	
	ret
	