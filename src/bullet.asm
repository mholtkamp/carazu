INCLUDE "include/bullet.inc"
INCLUDE "include/constants.inc"
INCLUDE "include/player.inc"
INCLUDE "tiles/bullet_tiles.inc"

BULLET_ENEMY_RECT_OFFSET_X EQU 1 
BULLET_ENEMY_RECT_OFFSET_Y EQU 1
BULLET_ENEMY_WIDTH EQU 5 
BULLET_ENEMY_HEIGHT EQU 5 

DEACTIVATION_RANGE_MIN EQU  192 
DEACTIVATION_RANGE_MAX EQU  224 

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

	SECTION "BulletProcs", HOME 
	
	
ResetBullets::

	ld a, 0
	ld b, BULLET_DATA_SIZE * (MAX_BULLETS_ENEMY + MAX_BULLETS_PLAYER)	
	ld hl, Bullets 
	
.loop 
	ld [hl+], a 
	dec b 
	jp nz, .loop 

	ret 
	
LoadBulletGraphics::

	ld hl, BulletTiles
	ld de, TILE_BANK_0 + BULLET_PLAYER_TILE*16 
	ld b, 16*2 
	
.loop 
	ld a, [hl+]
	ld [de], a 
	inc de 
	
	dec b 
	jp nz, .loop 

	ret 
	
	
; Pass by shared bss memory 
; Param0 = FireParamX
; Param1 = FireParamY
; Param2 = FireParamXVel
; Param3 = FireParamYVel
; Param4 = FireParamGravity 
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
	
	ld a, [FireParamGravity]
	ld [hl+], a 
	ld a, [FireParamGravity+1]
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
; Param4 = FireParamGravity 
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
	jp c, .return 
	cp DEACTIVATION_RANGE_MAX
	jp nc, .return 
	
.deactivate
	ld hl, EnemyBullet0
	ld b, 0 
	call Bullet_Deactivate
	; jp .return 

.return
	ret 