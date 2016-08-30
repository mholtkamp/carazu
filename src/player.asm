; Includes
INCLUDE "include/constants.inc"
INCLUDE "include/globals.inc"
INCLUDE "include/rect.inc"
INCLUDE "include/input.inc"
INCLUDE "include/player.inc"
INCLUDE "include/level.inc"
INCLUDE "include/sound.inc"
INCLUDE "include/util.inc"
INCLUDE "include/stats.inc"
INCLUDE "include/bullet.inc"
INCLUDE "include/music.inc"
INCLUDE "tiles/player_sprite_tiles.inc"

; Constants
PLAYER_HORI_SPEED EQU $0100
GRAVITY EQU $0020
GRAVITY_HOLD EQU $0010
GRAVITY_SPRUNG EQU $0020
JUMP_SPEED EQU $FD80
PLAYER_HORI_ACCEL EQU $0010
PLAYER_MAX_HORI_SPEED EQU $0100 
PLAYER_MIN_HORI_SPEED EQU ($0 - PLAYER_MAX_HORI_SPEED)
PLAYER_MAX_VERT_SPEED EQU $0300 
PLAYER_MIN_VERT_SPEED EQU ($0 - PLAYER_MAX_VERT_SPEED)

PLAYER_MAX_HORI_SPEED_ALLEGRO EQU $0180
PLAYER_MIN_HORI_SPEED_ALLEGRO EQU (0 - PLAYER_MAX_HORI_SPEED_ALLEGRO)

PLAYER_ANIM_AIR_PATTERN EQU 8 
PLAYER_ANIM_IDLE_PATTERN EQU 12 
PLAYER_ANIM_WALK0_PATTERN EQU 0
PLAYER_ANIM_WALK1_PATTERN EQU 4 

JUMP_PRESS_WINDOW EQU 5 

SPRING_UP_SPEED EQU $0 - $0500 
SPRING_DOWN_SPEED EQU $0300 
SPRING_RIGHT_SPEED EQU $0500 
SPRING_LEFT_SPEED EQU $0 - $0500

PLAYER_SPRUNG_UP EQU 1
PLAYER_BOUNCE_SPEED EQU $0 - $0280
PLAYER_DAMAGE_COUNTER_MAX EQU 60
PLAYER_DAMAGE_XVEL EQU $0240

FERMATA_COUNTER_MAX EQU 10
FERMATA_DASH_SPEED EQU $0300

FERMATA_PULSE_COUNTER_MAX EQU 6

	SECTION "PlayerData", BSS 

PlayerRect:
DS 6 

fYVelocity:
DS 2 
fXVelocity:
DS 2 

PlayerGrounded:
DS 1 

PlayerFlipX
DS 1 

WalkAnimCounter:
DS 1 

PlayerSpritePattern:
DS 1 

LastADown:
DS 1 

PlayerSprung:
DS 1 

PlayerPrevYLow:
DS 1 

PlayerDamaged:
DS 1 

PlayerDamagedCounter:
DS 1 

PlayerOnPlatform:
DS 1 

FermataCharge:
DS 1 

FermataPulseCounter:
DS 1 

FermataPulseX:
DS 1 
FermataPulseY:
DS 1 

	SECTION "PlayerCode", HOME 

Player_Initialize::

	ld a, 8
	ld [PlayerRect], a 					; x (integer)
	ld a, 0
	ld [PlayerRect + 1], a 				; x (fractional)
	ld a, 128				
	ld [PlayerRect + 2], a 				; y (integer)
	ld a, 0 
	ld [PlayerRect + 3], a 				; y (fractional)
	ld a, PLAYER_WIDTH
	ld [PlayerRect + 4], a 				; width 
	ld a, PLAYER_HEIGHT 
	ld [PlayerRect + 5], a 				; height

	ld a, 0 
	ld [fYVelocity], a 			; (integer)
	ld [fYVelocity + 1], a 
	ld [fXVelocity], a 			; (integer)
	ld [fXVelocity + 1], a 
	
	ld a, 0 
	ld [PlayerGrounded], a 
	
	ld a, 0 
	ld [PlayerFlipX], a 
	
	ld a, 0 
	ld [WalkAnimCounter], a 
	
	ld a, PLAYER_ANIM_IDLE_PATTERN
	ld [PlayerSpritePattern], a 
	
	ld a, 0 
	ld [LastADown], a 
	
	ld a, 0
	ld [PlayerSprung], a 
	ld [PlayerPrevYLow], a 
	ld [PlayerDamaged], a 
	ld [PlayerDamagedCounter], a 
	ld [PlayerOnPlatform], a 
	ld [FermataPulseCounter], a 
	
	ld a, 1 
	ld [FermataCharge], a 
	ret 
	

Player_Update::
	
	; save the previous player-y coord for enemy jump detection 
	ld a, [PlayerRect+2]
	add a, PLAYER_HEIGHT - 1 
	ld [PlayerPrevYLow], a 
	
	; if damaged, handle accordingly 
	ld a, [PlayerDamaged]
	cp 1 
	jp nz, .prepare_move
	
	ld a, [PlayerDamagedCounter]
	dec a
	ld [PlayerDamagedCounter], a 
	jp nz, .prepare_move
	ld a, 0 
	ld [PlayerDamaged], a 
	
.prepare_move 
	; prepare params for MoveRect_Integer function 
	ld bc, $0000 
	ld de, $0000  
	
	; Record time since last A down 
	ld a, [InputsHeld]					
	and BUTTON_A
	ld h, a 
	ld a, [InputsPrev]
	cpl 
	and h 
	jp z, .inc_a_down_counter 
	ld a, 0 
	ld [LastADown], a 
	jp .check_fermata_activation
.inc_a_down_counter
	ld a, [LastADown]
	inc a 
	ld [LastADown], a 
	cp 0 
	jp nz, .check_fermata_activation 
	ld a, $ff 
	ld [LastADown], a 	; cap counter at 255 
	
.check_fermata_activation
	ld a, [HasFermata]
	cp 0 
	jp z, .check_bass 
	
	ld a, [PlayerGrounded]
	cp 1
	jp z, .check_bass
	
	ld a, [FermataCharge]
	cp 0 
	jp z, .check_bass
	
	ld a, [InputsHeld]
	and BUTTON_A 
	ld b, a 
	ld a, [InputsPrev]
	and BUTTON_A 
	cpl 
	and b 
	jp z, .check_bass
	
	; All conditions met to start fermata dash 
	ld a, 0 
	ld [FermataCharge], a 		; deplete charge 
	
	; Player is gonna jump, so in case he was on a platform, clear that flag 
	ld a, 0 
	ld [PlayerOnPlatform], a 
	
	; Adjust veloctiy
	ld hl, JUMP_SPEED
	ld d, h
	ld e, l 							; set yvel param for move rect subroutine call 
	ld a, h
	ld [fYVelocity], a 
	ld a, l 
	ld [fYVelocity + 1], a 				; set the y velocity to the jump velocity 
	ld a, 0 
	ld [PlayerGrounded], a 				; set grounded to 0 so player cant jump again
	
	; set pulse counter for visual effect. and init pulse location 
	ld a, FERMATA_PULSE_COUNTER_MAX
	ld [FermataPulseCounter], a 
	ld a, [PlayerRect]
	ld [FermataPulseX], a 
	ld a, [PlayerRect+2]
	add a, PLAYER_HEIGHT 
	ld [FermataPulseY], a 
	; jp .check_bass

.check_bass
	ld a, [HasBass]
	cp 0 
	jp z, .check_allegro
	
	ld a, [InputsHeld]
	and BUTTON_B 
	ld b, a 
	ld a, [InputsPrev]
	cpl 
	and b 
	jp z, .check_allegro 
	
	; If player has bass rune, then just try to fire the bass cannon
	ld a, [PlayerRect]
	add a, (PLAYER_WIDTH/2) + 2 
	ld [FireParamX], a 
	ld a, [PlayerRect+2]
	add a, (PLAYER_HEIGHT/3)
	ld [FireParamY], a 
	
	ld a, [PlayerFlipX]
	cp 0 
	jp z, .bass_pos_xvel
	ld a, (0 - BASS_CANNON_SPEED) >> 8
	ld [FireParamXVel], a 
	ld a, (0 - BASS_CANNON_SPEED) & $00ff
	ld [FireParamXVel+1], a 
	jp .bass_yvel
.bass_pos_xvel
	ld a, BASS_CANNON_SPEED >> 8 
	ld [FireParamXVel], a 
	ld a, BASS_CANNON_SPEED & $00ff
	ld [FireParamXVel+1], a 
.bass_yvel
	ld a, 0 
	ld [FireParamYVel], a 
	ld [FireParamYVel+1], a
	ld [FireParamGravityX], a 
	ld [FireParamGravityY], a 
	call FirePlayerBullet
	;jp .check_allegro
	
.check_allegro

	ld a, [HasAllegro]
	cp 1 
	jp z, .check_left_allegro
	; jp .check_left 
	
.check_left			
	ld a, [InputsHeld]
	and BUTTON_LEFT
	jp z, .check_right
	ld a, [fXVelocity]
	ld h, a 
	ld a, [fXVelocity + 1]
	ld l, a 
	bit 7, h 
	jp z, .check_left_add_input_vel
	
	;if xvel is less than PLAYER_MIN_HORI_SPEED, don't do anything!
	ld a, h 
	cp (PLAYER_MIN_HORI_SPEED & $ff00) >> 8  
	jp c, .apply_drag 		; higher byte is already above max. do nothing 
	jp nz, .check_left_add_input_vel 
	ld a, l
	cp (PLAYER_MIN_HORI_SPEED & $00ff) 
	jp c, .apply_drag 		; lower byte is above max low byte and high bytes are equal. do nothing 
	
.check_left_add_input_vel
	ld bc, $0 - PLAYER_HORI_ACCEL
	add hl, bc 		; subtract hori accel
	;limit speed 
	bit 7, h
	jp z, .check_left_save
	ld a, h 
	cp (PLAYER_MIN_HORI_SPEED & $ff00) >> 8 
	jp c, .check_left_limit
	jp nz, .check_left_save
	ld a, l 
	cp (PLAYER_MIN_HORI_SPEED & $00ff)
	jp nc, .check_left_save 
.check_left_limit
	ld hl, PLAYER_MIN_HORI_SPEED
.check_left_save
	ld b, h 
	ld c, l 		; bc = new hori speed 
	ld a, b
	ld [fXVelocity], a 
	ld a, c 
	ld [fXVelocity + 1], a ; save new x velocity 
	ld a, 1
	ld [PlayerFlipX], a 
	jp .check_grounded
	
.check_right 
	ld a, [InputsHeld]
	and BUTTON_RIGHT
	jp z, .apply_drag 
	ld a, [fXVelocity]
	ld h, a 
	ld a, [fXVelocity + 1]
	ld l, a 
	bit 7, h 
	jp nz, .check_right_add_input_vel	
	
	;if xvel is greater than MAX_HORI_SPEED, don't do anything!
	ld a, (PLAYER_MAX_HORI_SPEED & $ff00) >> 8 
	cp h 
	jp c, .apply_drag 		; higher byte is already above max. do nothing 
	jp nz, .check_right_add_input_vel 
	ld a, (PLAYER_MAX_HORI_SPEED & $00ff)
	cp l 
	jp c, .apply_drag 		; lower byte is above max low byte and high bytes are equal. do nothing 
	
.check_right_add_input_vel
	ld bc, PLAYER_HORI_ACCEL
	add hl, bc 		; bc = new hori speed 
	;limit speed 
	bit 7, h
	jp nz, .check_right_save
	ld a, (PLAYER_MAX_HORI_SPEED & $ff00) >> 8 
	cp h 
	jp c, .check_right_limit
	jp nz, .check_right_save
	ld a, (PLAYER_MAX_HORI_SPEED & $00ff)
	cp l 
	jp nc, .check_right_save 
.check_right_limit
	ld hl, PLAYER_MAX_HORI_SPEED
.check_right_save
	ld b, h 
	ld c, l 		; bc = new hori speed 
	ld a, b
	ld [fXVelocity], a 
	ld a, c 
	ld [fXVelocity + 1], a ; save new x velocity 
	ld a, 0 
	ld [PlayerFlipX], a 
	jp .check_grounded
	
	
; TODO: Consider the duplicated code here
.check_left_allegro	
	ld a, [InputsHeld]
	and BUTTON_LEFT
	jp z, .check_right_allegro
	ld a, [fXVelocity]
	ld h, a 
	ld a, [fXVelocity + 1]
	ld l, a 
	bit 7, h 
	jp z, .check_left_allegro_add_input_vel
	
	;if xvel is less than PLAYER_MIN_HORI_SPEED_ALLEGRO, don't do anything!
	ld a, h 
	cp (PLAYER_MIN_HORI_SPEED_ALLEGRO & $ff00) >> 8  
	jp c, .apply_drag 		; higher byte is already above max. do nothing 
	jp nz, .check_left_allegro_add_input_vel 
	ld a, l
	cp (PLAYER_MIN_HORI_SPEED_ALLEGRO & $00ff) 
	jp c, .apply_drag 		; lower byte is above max low byte and high bytes are equal. do nothing 
	
.check_left_allegro_add_input_vel
	ld bc, $0 - PLAYER_HORI_ACCEL
	add hl, bc 		; subtract hori accel
	;limit speed 
	bit 7, h
	jp z, .check_left_allegro_save
	ld a, h 
	cp (PLAYER_MIN_HORI_SPEED_ALLEGRO & $ff00) >> 8 
	jp c, .check_left_allegro_limit
	jp nz, .check_left_allegro_save
	ld a, l 
	cp (PLAYER_MIN_HORI_SPEED_ALLEGRO & $00ff)
	jp nc, .check_left_allegro_save 
.check_left_allegro_limit
	ld hl, PLAYER_MIN_HORI_SPEED_ALLEGRO
.check_left_allegro_save
	ld b, h 
	ld c, l 		; bc = new hori speed 
	ld a, b
	ld [fXVelocity], a 
	ld a, c 
	ld [fXVelocity + 1], a ; save new x velocity 
	ld a, 1
	ld [PlayerFlipX], a 
	jp .check_grounded
	
.check_right_allegro
	ld a, [InputsHeld]
	and BUTTON_RIGHT
	jp z, .apply_drag 
	ld a, [fXVelocity]
	ld h, a 
	ld a, [fXVelocity + 1]
	ld l, a 
	bit 7, h 
	jp nz, .check_right_allegro_add_input_vel	
	
	;if xvel is greater than MAX_HORI_SPEED, don't do anything!
	ld a, (PLAYER_MAX_HORI_SPEED_ALLEGRO & $ff00) >> 8 
	cp h 
	jp c, .apply_drag 		; higher byte is already above max. do nothing 
	jp nz, .check_right_allegro_add_input_vel 
	ld a, (PLAYER_MAX_HORI_SPEED_ALLEGRO & $00ff)
	cp l 
	jp c, .apply_drag 		; lower byte is above max low byte and high bytes are equal. do nothing 
	
.check_right_allegro_add_input_vel
	ld bc, PLAYER_HORI_ACCEL
	add hl, bc 		; bc = new hori speed 
	;limit speed 
	bit 7, h
	jp nz, .check_right_allegro_save
	ld a, (PLAYER_MAX_HORI_SPEED_ALLEGRO & $ff00) >> 8 
	cp h 
	jp c, .check_right_allegro_limit
	jp nz, .check_right_allegro_save
	ld a, (PLAYER_MAX_HORI_SPEED_ALLEGRO & $00ff)
	cp l 
	jp nc, .check_right_allegro_save 
.check_right_allegro_limit
	ld hl, PLAYER_MAX_HORI_SPEED_ALLEGRO
.check_right_allegro_save
	ld b, h 
	ld c, l 		; bc = new hori speed 
	ld a, b
	ld [fXVelocity], a 
	ld a, c 
	ld [fXVelocity + 1], a ; save new x velocity 
	ld a, 0 
	ld [PlayerFlipX], a 
	jp .check_grounded
	
.apply_drag 
	ld a, [fXVelocity]
	ld b, a 
	ld a, [fXVelocity + 1]
	ld c, a 
	
	ld a, b 
	and $80 
	jp z, .apply_drag_right
	ld hl, PLAYER_HORI_ACCEL
	add hl, bc 
	bit 7, h
	jp z, .set_vel_0
	ld b, h 
	ld c, l 
	ld a, b
	ld [fXVelocity], a 
	ld a, c 
	ld [fXVelocity + 1], a ; save new x velocity 
	jp .check_grounded
.apply_drag_right 
	ld hl, 0 - PLAYER_HORI_ACCEL
	add hl, bc 
	bit 7, h
	jp nz, .set_vel_0
	ld b, h 
	ld c, l 
	ld a, b
	ld [fXVelocity], a 
	ld a, c 
	ld [fXVelocity + 1], a ; save new x velocity 
	jp .check_grounded 
.set_vel_0
	ld bc, 0 
	ld a, b
	ld [fXVelocity], a 
	ld a, c 
	ld [fXVelocity + 1], a ; save new x velocity 
	; jp .check_grounded
	
.check_grounded	
	ld a, [PlayerGrounded]
	cp 0 
	jp z, .apply_gravity
	
	ld a, [PlayerOnPlatform]
	cp 1 
	jp z, .on_platform		; if player is marked as on platform, go straight to check_jump. check if on platform still after moving. 
	
.rect_move
	; player is marked as grounded, but check if grounded 
	; in case the player has moved off a platform 
	ld hl, PlayerRect
	ld a, [LevelColThresh]
	push bc
	push de 
	call CheckRectGrounded_Fixed
	pop de 
	pop bc 
	
	cp 1 
	jp z, .check_jump 
	ld [PlayerGrounded], a 				; save player as not grounded 
	jp .apply_gravity
	
.on_platform
	ld a, 0
	ld [fYVelocity], a 
	ld [fYVelocity+1], a 
	; jp .check_jump

.check_jump
	ld a, [InputsHeld]					; player is not grounded, so check for jump
	and BUTTON_A
	jp z, .update_player_animation 			; y-vel is already zeroed so go to move call 
	ld a, [LastADown]
	cp JUMP_PRESS_WINDOW
	jp nc, .update_player_animation
	
	; Player is gonna jump, so in case he was on a platform, clear that flag 
	ld a, 0 
	ld [PlayerOnPlatform], a 
	
	; Adjust veloctiy
	ld hl, JUMP_SPEED
	ld d, h
	ld e, l 							; set yvel param for move rect subroutine call 
	ld a, h
	ld [fYVelocity], a 
	ld a, l 
	ld [fYVelocity + 1], a 				; set the y velocity to the jump velocity 
	ld a, 0 
	ld [PlayerGrounded], a 				; set grounded to 0 so player cant jump again
	jp .update_player_animation 
	
.apply_gravity
	ld a, [fYVelocity]
	ld d, a 
	ld a, [fYVelocity + 1]
	ld e, a 
	ld a, [InputsHeld]
	and BUTTON_A 
	jp z, .use_default_gravity
	ld a, [PlayerSprung]
	cp PLAYER_SPRUNG_UP
	jp z, .use_default_gravity
	ld hl, GRAVITY_HOLD
	jp .add_gravity
.use_default_gravity
	ld hl, GRAVITY
.add_gravity
	add hl, de 
	ld d, h
	ld e, l 							; set resulting yvel for move rect subroutine 
	ld a, h 			
	ld [fYVelocity], a 
	ld a, l 
	ld [fYVelocity + 1], a 		; save the resulting yvel for next frame 
	
.update_player_animation
	; do not disrupt any registers besides a and hl 
	; because they have already been set with parameters meant for 
	; the move player rect routine 
	ld a, [PlayerGrounded]
	cp 0 
	jp z, .set_anim_air
	ld a, b 
	or c 
	jp z, .set_anim_idle
	ld a, [WalkAnimCounter]
	inc a 
	ld [WalkAnimCounter], a 
	bit 3, a 
	jp z, .set_anim_walk1
	ld a, PLAYER_ANIM_WALK0_PATTERN
	ld [PlayerSpritePattern], a 		; set anim pattern walk0
	jp .clamp_velocity
	
.set_anim_air 
	ld a, PLAYER_ANIM_AIR_PATTERN
	ld [PlayerSpritePattern], a 		; set anim pattern air 
	jp .clamp_velocity
.set_anim_idle
	ld a, PLAYER_ANIM_IDLE_PATTERN
	ld [PlayerSpritePattern], a 		; set anim pattern idle 
	jp .clamp_velocity
.set_anim_walk1
	ld a, PLAYER_ANIM_WALK1_PATTERN 
	ld [PlayerSpritePattern], a 		; set anim pattern walk1 

.clamp_velocity
	ld a, d 
	and $80 
	jp nz, .clamp_vert_neg
	ld a, d 
	cp (PLAYER_MAX_VERT_SPEED >> 8)
	jp c, .move_player_rect 	; nothing to clamp, move rect 
	ld a, e 
	cp (PLAYER_MAX_VERT_SPEED & $00ff)
	jp c, .move_player_rect
	ld de, PLAYER_MAX_VERT_SPEED
	ld a, d 
	ld [fYVelocity], a 
	ld a, e 
	ld [fYVelocity + 1], a 	  ; save clamped yvel 
	jp .move_player_rect
.clamp_vert_neg
	ld a, [PlayerSprung]
	cp PLAYER_SPRUNG_UP
	jp z, .move_player_rect	  ; don't clamp when sprung upwards
	
	ld a, (PLAYER_MIN_VERT_SPEED >> 8)
	cp d
	jp c, .move_player_rect
	jp nz, .skip_low_byte_vert
	ld a, e 
	cp (PLAYER_MIN_VERT_SPEED & $00ff)
	jp nc, .move_player_rect
.skip_low_byte_vert
	ld de, PLAYER_MIN_VERT_SPEED
	ld a, d 
	ld [fYVelocity], a 
	ld a, e 
	ld [fYVelocity + 1], a 	  ; save clamped yvel 

.move_player_rect
	ld a, [LevelColThresh]
	ld hl, PlayerRect
	call MoveRect_Fixed
	ld b, a 
	bit BIT_COLLIDED_DOWN, a 
	jp z, .check_hit_up 
	
	; player hit something moving down, mark as grounded 
	ld a, 1 
	ld [PlayerGrounded], a 			; player collided downward so load grounded = 1 
	ld [FermataCharge], a 
	ld a, 0 
	ld [PlayerSprung], a 
	
	; player collided with something moving down, zero y velocity
	ld a, 0 
	ld [fYVelocity], a 
	ld [fYVelocity + 1], a 
	jp .check_hit_hori
	
.check_hit_up
	bit BIT_COLLIDED_UP, a 
	jp z, .check_hit_hori 
	
	; player collided with something moving up, zero y velocity
	ld a, 0 
	ld [fYVelocity], a 
	ld [fYVelocity + 1], a 
	
.check_hit_hori
	ld a, b 		; get the collision bitfield again 
	and BIT_COLLIDED_LEFT | BIT_COLLIDED_RIGHT 
	jp z, .check_specials 
	
	ld a, 0 
	ld [fXVelocity], a 
	ld [fXVelocity + 1], a 
	
.check_specials 
	ld hl, PlayerRect
	call Rect_CheckSpecials 
	bit BIT_SPIKE, b 
	jp nz, .resolve_spikes
	bit BIT_SPRING_UP, b 
	jp nz, .resolve_spring_up
	bit BIT_SPRING_RIGHT, b
	jp nz, .resolve_spring_right 
	bit BIT_SPRING_LEFT, b
	jp nz, .resolve_spring_left 
	bit BIT_SPRING_DOWN, b
	jp nz, .resolve_spring_down 
	bit BIT_DOOR, b 
	jp nz, .resolve_door 
	bit BIT_SECRET_DOOR, b 
	jp nz, .resolve_secret_door
	jp .return 
	
.resolve_spikes
	ld a, 0 
	ld [PlayerHearts], a 
	jp .return 
	
.resolve_spring_up
	ld a, (SPRING_UP_SPEED >> 8)
	ld [fYVelocity], a 
	ld a, (SPRING_UP_SPEED & $00ff)
	ld [fYVelocity + 1], a 
	ld a, 0 
	ld [PlayerGrounded], a 
	ld a, PLAYER_SPRUNG_UP 
	ld [PlayerSprung], a 
	jp .return 
	
.resolve_spring_down 
	ld a, (SPRING_DOWN_SPEED >> 8)
	ld [fYVelocity], a 
	ld a, (SPRING_DOWN_SPEED & $00ff)
	ld [fYVelocity + 1], a 
	ld a, 0 
	jp .return 
	
.resolve_spring_right 
	ld a, (SPRING_RIGHT_SPEED >> 8)
	ld [fXVelocity], a 
	ld a, (SPRING_RIGHT_SPEED & $00ff)
	ld [fXVelocity + 1], a 
	ld a, 0 
	jp .return 
	
.resolve_spring_left
	ld a, (SPRING_LEFT_SPEED >> 8)
	ld [fXVelocity], a 
	ld a, (SPRING_LEFT_SPEED & $00ff)
	ld [fXVelocity + 1], a 
	ld a, 0 
	jp .return 
	
.resolve_door 
	ld a, [InputsHeld]
	and BUTTON_UP
	jp z, .return
	ld a, [LevelNum]
	cp 22
	jp nc, .resolve_door_bonus
	inc a
	ld [LevelNum], a 
	ld b, STATE_GAME 
	call SwitchState
	jp .return 
.resolve_door_bonus 
	cp 22 
	jp nz, .resolve_door_bonus_w2
	ld a, 5 
	ld [LevelNum], a 
	ld b, STATE_GAME
	call SwitchState
	jp .return 
.resolve_door_bonus_w2
	cp 23 
	jp nz, .resolve_door_bonus_w3
	ld a, 12 
	ld [LevelNum], a 
	ld b, STATE_GAME
	call SwitchState
	jp .return 
.resolve_door_bonus_w3
	cp 24 
	jp nz, .return 
	ld a, 20 
	ld [LevelNum], a 
	ld b, STATE_GAME
	call SwitchState
	jp .return 
	
.resolve_secret_door 
	ld a, [InputsHeld]
	and BUTTON_UP 
	jp z, .return 
	
	ld a, [LevelNum]
	cp 21 
	jp nz, .resolve_secret_door_check1
	ld b, STATE_FINALE 
	call SwitchState

.resolve_secret_door_check1
	cp 5
	jp nz, .resolve_secret_door_check2
	ld a, 22
	ld [LevelNum], a 
	ld b, STATE_GAME 
	call SwitchState 
	jp .return 
	
.resolve_secret_door_check2 
	cp 12 
	jp nz, .resolve_secret_door_check3 
	ld a, 23 
	ld [LevelNum], a 
	ld b, STATE_GAME 
	call SwitchState
	jp .return 
	

.resolve_secret_door_check3
	cp 20 
	jp nz, .return 
	ld a, 24
	ld [LevelNum], a 
	ld b, STATE_GAME
	call SwitchState
	jp .return 

.return
	ret
	
Player_UpdateLocalOAM::

	; Update fermata pulse visual 
	ld a, [FermataPulseCounter]
	cp 0 
	jp z, .no_pulse 
	
	; Dec counter 
	dec a 
	ld [FermataPulseCounter], a 		; save new counter val 
	ld a, [FermataPulseY] 
	inc a 
	ld [FermataPulseY], a 
	
	ld hl, LocalOAM + PULSE_OBJ_INDEX*4
	add a, 16 
	ld [hl+], a 
	ld a, [FermataPulseX]
	add a, 8 
	ld [hl+], a 
	ld a, ITEM_TILE_FERMATA_PULSE 
	ld [hl+], a 
	ld a, 0 
	ld [hl+], a 
	jp .update_player_oam
	
.no_pulse 
	ld a, 0 
	ld hl, LocalOAM + PULSE_OBJ_INDEX*4 
	ld [hl+], a 
	ld [hl+], a 
	;jp .update_player_oam

	
	
	
.update_player_oam
	; Update player OAM 
	ld hl, PlayerRect			
	ld a, [PlayerSpritePattern]
	ld b, a 					
	ld c, 0 					; oam index = 0 
	ld d, 4						; rect x offseet =  4 
	ld e, 4 					; rect y offset  = 4 
	ld a, [PlayerFlipX]
	call UpdateOAMFromRect_2x2
	
	ld a, [PlayerDamaged]
	cp 1 
	jp nz, .return 
	ld a, [PlayerDamagedCounter]
	bit 3, a 
	jp nz, .return 
	ld hl, LocalOAM + PLAYER_OBJ_INDEX*4
	ld a, 0 
	ld [hl+], a 		; disable player sprites 
	ld [hl+], a 
	inc hl 
	inc hl 
	ld [hl+], a 
	ld [hl+], a 
	inc hl 
	inc hl 
	ld [hl+], a 
	ld [hl+], a 
	inc hl 
	inc hl 
	ld [hl+], a 
	ld [hl+], a 
	inc hl 
	inc hl 
.return 
	ret 
	
Player_SetPositionFromTiles::
	ld a, [MapOriginX]
	ld d, a 
	ld a, b 
	sub d 
	sla a 
	sla a 
	sla a 
	ld [PlayerRect], a 
	
	ld a, [MapOriginY]
	ld d, a 
	ld a, c 
	sub d 
	sla a 
	sla a 
	sla a 
	ld [PlayerRect+2], a 

	ret 
	
Player_LoadGraphics::
	ld b, 0 			; load sprite tiles
	ld c, 16 			; player needs 16 sprite tiles 
	ld d, PlayerSpriteTilesBank		;rom bank 
	ld e, 0 			; player sprite tiles start from index 0
	ld hl, PlayerSpriteTiles 
	call LoadTiles 
	
	ret 
	
Player_Bounce::

	; Launch player slightly into air. This proc should be called 
	; when the player jumps on an enemy.
	ld a, 0 
	ld [PlayerGrounded], a 
	ld a, (PLAYER_BOUNCE_SPEED & $ff00) >> 8 
	ld [fYVelocity], a 
	ld a, (PLAYER_BOUNCE_SPEED & $00ff)
	ld [fYVelocity + 1], a 
	
	ret 
	
Player_Damage::

	ld b, a 	; store contact x coordinate 
	
	; Do nothing if player is already damaged 
	ld a, [PlayerDamaged]
	cp 1 
	jp z, .return 
	
	ld a, 1 
	ld [PlayerDamaged], a 			; set damaged flag for correct logic in player-update 
	ld a, PLAYER_DAMAGE_COUNTER_MAX
	ld [PlayerDamagedCounter], a 
	ld a, [PlayerHearts]
	dec a 
	ld [PlayerHearts], a 
	
	; Now set the players x velocity based on contact 
	ld a, [PlayerRect]
	add a, PLAYER_WIDTH/2 
	cp b 
	jp c, .push_left 
	
.push_right
	ld a, (PLAYER_DAMAGE_XVEL & $ff00) >> 8 
	ld [fXVelocity], a 
	ld a, (PLAYER_DAMAGE_XVEL & $00ff)
	ld [fXVelocity+1], a
	jp .return 
.push_left 
	ld a, ((0 - PLAYER_DAMAGE_XVEL) & $ff00) >> 8 
	ld [fXVelocity], a 
	ld a, ((0 - PLAYER_DAMAGE_XVEL) & $00ff)
	ld [fXVelocity+1], a
	; jp .return 
	
.return 
	; Play sound effect 
	ld b, $80
	ld c, $f8 
	ld d, $6a
	ld e, $40 
	call PlaySound_4
	
	ret 