;****************************************************************************************************************************************************
;*	Blank Simple Source File
;*
;****************************************************************************************************************************************************
;*
;*
;****************************************************************************************************************************************************

;****************************************************************************************************************************************************
;*	Includes
;****************************************************************************************************************************************************
	; system includes

	; project includes
	INCLUDE "tiles/bg_tiles.inc"
	INCLUDE "tiles/sprite_tiles.inc"
	INCLUDE "maps/bg_map.inc"
	
	INCLUDE "include/rect.inc"
	INCLUDE "include/font.inc"
	
;****************************************************************************************************************************************************
;*	user data (constants)
;****************************************************************************************************************************************************

;****************************************************************************************************************************************************
;*	equates
;****************************************************************************************************************************************************
rLY EQU $ff44
rLCDC EQU $ff40
rBGP EQU $ff47
rOBP0 EQU $ff48
rP1 EQU $ff00
Tiles0 EQU $9000
Tiles1 EQU $8000

BUTTON_START EQU $8 
BUTTON_SELECT EQU $4 
BUTTON_B EQU $2 
BUTTON_A EQU $1 
BUTTON_DOWN EQU $80 
BUTTON_UP EQU $40 
BUTTON_LEFT EQU $20 
BUTTON_RIGHT EQU $10 

PLAYER_HORI_SPEED EQU $0100;$00C0
GRAVITY EQU $0010
JUMP_SPEED EQU $FD80
COLLISION_TILE_CAP EQU 8 

PLAYER_ANIM_AIR_PATTERN EQU 8 
PLAYER_ANIM_IDLE_PATTERN EQU 12 
PLAYER_ANIM_WALK0_PATTERN EQU 0
PLAYER_ANIM_WALK1_PATTERN EQU 4 


;****************************************************************************************************************************************************
;*	BSS variables
;****************************************************************************************************************************************************
	SECTION "Variables", BSS[$C000]

PlayerRect:
DS 6 

FrameCounter:
DS	1 

GraphicTileIndex:
DS	1

GraphicTileDir:
DS	1 

InputsHeld:
DS	1 

InputsDown:
DS 	1 

fYVelocity:
DS 2 

PlayerGrounded
DS 1 

Scratch:
DS 8

FlipPlayerX:
DS 1 

WalkAnimCounter:
DS 1 

PlayerSpritePattern:
DS 1 

LYValue:
DS 2   

LocalOAM:
DS 160 


;****************************************************************************************************************************************************
;*	cartridge header
;****************************************************************************************************************************************************

	SECTION	"Org $00",HOME[$00]
RST_00:	
	jp	$100

	SECTION	"Org $08",HOME[$08]
RST_08:	
	jp	$100

	SECTION	"Org $10",HOME[$10]
RST_10:
	jp	$100

	SECTION	"Org $18",HOME[$18]
RST_18:
	jp	$100

	SECTION	"Org $20",HOME[$20]
RST_20:
	jp	$100

	SECTION	"Org $28",HOME[$28]
RST_28:
	jp	$100

	SECTION	"Org $30",HOME[$30]
RST_30:
	jp	$100

	SECTION	"Org $38",HOME[$38]
RST_38:
	jp	$100

	SECTION	"V-Blank IRQ Vector",HOME[$40]
VBL_VECT:
	reti
	
	SECTION	"LCD IRQ Vector",HOME[$48]
LCD_VECT:
	reti

	SECTION	"Timer IRQ Vector",HOME[$50]
TIMER_VECT:
	reti

	SECTION	"Serial IRQ Vector",HOME[$58]
SERIAL_VECT:
	reti

	SECTION	"Joypad IRQ Vector",HOME[$60]
JOYPAD_VECT:
	reti
	
	SECTION	"Start",HOME[$100]
	nop
	jp	Start

	; $0104-$0133 (Nintendo logo - do _not_ modify the logo data here or the GB will not run the program)
	DB	$CE,$ED,$66,$66,$CC,$0D,$00,$0B,$03,$73,$00,$83,$00,$0C,$00,$0D
	DB	$00,$08,$11,$1F,$88,$89,$00,$0E,$DC,$CC,$6E,$E6,$DD,$DD,$D9,$99
	DB	$BB,$BB,$67,$63,$6E,$0E,$EC,$CC,$DD,$DC,$99,$9F,$BB,$B9,$33,$3E

	; $0134-$013E (Game title - up to 11 upper case ASCII characters; pad with $00)
	DB	"ALPHA",0,0,0,0,0,0
		;0123456789A

	; $013F-$0142 (Product code - 4 ASCII characters, assigned by Nintendo, just leave blank)
	DB	"    "
		;0123

	; $0143 (Color GameBoy compatibility code)
	DB	$00	; $00 - DMG 
			; $80 - DMG/GBC
			; $C0 - GBC Only cartridge

	; $0144 (High-nibble of license code - normally $00 if $014B != $33)
	DB	$00

	; $0145 (Low-nibble of license code - normally $00 if $014B != $33)
	DB	$00

	; $0146 (GameBoy/Super GameBoy indicator)
	DB	$00	; $00 - GameBoy

	; $0147 (Cartridge type - all Color GameBoy cartridges are at least $19)
	DB	$19	; $19 - ROM + MBC5

	; $0148 (ROM size)
	DB	$01	; $01 - 512Kbit = 64Kbyte = 4 banks

	; $0149 (RAM size)
	DB	$00	; $00 - None

	; $014A (Destination code)
	DB	$00	; $01 - All others
			; $00 - Japan

	; $014B (Licensee code - this _must_ be $33)
	DB	$33	; $33 - Check $0144/$0145 for Licensee code.

	; $014C (Mask ROM version - handled by RGBFIX)
	DB	$00

	; $014D (Complement check - handled by RGBFIX)
	DB	$00

	; $014E-$014F (Cartridge checksum - handled by RGBFIX)
	DW	$00

;****************************************************************************************************************************************************

;****************************************************************************************************************************************************
;*	Program Start
;****************************************************************************************************************************************************

	SECTION "Program Start",HOME[$0150]
Start::
	di ;disable interrupts
	ld sp, $ffff ; setting stack pointer to the fast-ram area.
	
	call WAIT_VBLANK ; wait until we are in the vblank region of the screen refresh
	
	ld a, 0  ; zero-out the a register
	ldh [rLCDC], a ;turn off LCD
	
	call CLEAR_MAP
	call CLEAR_OAM
	call LOAD_BG_TILES
	call LOAD_MAP
	call LOAD_SPRITE_TILES
	call LoadFont_Full
	
	ld a, %11100100 ;load normal palette of colors
	ldh [rBGP], a
	ldh [rOBP0], a 
	
	ld a, %10000011 ; turn on LCD, OBJ, BG
	ld [rLCDC], a
	
	; Initialize framecounter to 0
	ld hl, FrameCounter
	ld a, 0
	ld [hl], a 
	
	; Initialize graphic tile index to 0
	ld hl, GraphicTileIndex
	ld a, 0 
	ld [hl], a 
	
	; Initialize graphic tile dir to 0 
	ld hl, GraphicTileDir
	ld a, 0 
	ld [hl], a 
	
	; Initialize flip player
	ld a, 0 
	ld [FlipPlayerX], a 
	
	; Initialize Player Rect
	ld hl, PlayerRect
	ld [hl], 8 					; x (integer)
	ld hl, PlayerRect + 1 
	ld [hl], 0 					; x (fractional)
	ld hl, PlayerRect + 2 
	ld [hl], 128				; y (integer)
	ld hl, PlayerRect + 3
	ld [hl], 0 					; y (fractional)
	ld hl, PlayerRect + 4 
	ld [hl], 8 					; width 
	ld hl, PlayerRect + 5 
	ld [hl], 12 				; height 
	
	; Initialize Player variables 
	ld hl, fYVelocity			
	ld [hl], 0 					; (integer)
	ld hl, fYVelocity + 1 
	ld [hl], 0 					; (fraction)
	
	ld hl, PlayerGrounded
	ld [hl], 0
	
	
	
	ld hl, 0 
	
Main_Game_Loop::
	call UPDATE_INPUTS
	call UPDATE_PLAYER
	call UPDATE_LOCAL_OAM
	call RECORD_LY
	
	call WAIT_VBLANK
	nop
	nop
	
	; Update animated tiles
	ld hl, FrameCounter           ; Get framcount pointer
	ld a, [hl]                    ; get counter value from internal RAM
	inc a                         ; increase the count
	ld [hl], a                    ; save the frame count
    and $0F                       ; mask away only the 3 LSB 
	cp 4                          ; is the value 4?
	jp nz, SkipUpdateGraphicTiles  ; call the function
	call UPDATE_GRAPHIC_TILE_INDEX     ; Update the graphic tiles
	call UPDATE_GRAPHIC_TILES
SkipUpdateGraphicTiles::
	call TRANSFER_OAM 
	call DRAW_LY

	jp Main_Game_Loop
	
	
;***************************************************************
;* Subroutines
;***************************************************************

	SECTION "Support Routines", HOME
	
WAIT_VBLANK::
	ldh a, [rLY]     ;load the y position of current scanline
	cp $8F           ; is the scanline equal to 143? 
	jr nz, WAIT_VBLANK ; if not equal, keep looping
.almost_vblank
	ldh a, [rLY]     ; loop until 144, then we are in VBLANK
	cp $90
	jr nz, .almost_vblank
	ret              ; we are now in the VBLANK interval, so return
	
CLEAR_OAM::
	; First clear actual OAM 
	ld hl, $fe00 ;load address of OAM
	ld de, $0001 ;amount to add to HL after loads 
	ld b, 40     ; 40 sprites to clear
.loop_0 
	ld [hl], 0 
	add hl, de
	ld [hl], 0 
	add hl, de
    ld [hl], 0 
	add hl, de
	ld [hl], 0 
	add hl, de
	dec b 
	ld a, b 
	cp 0
	jr nz, .loop_0
	
	; Next, clear local OAM 
	ld hl, LocalOAM ;load address of OAM
	ld de, $0001 ;amount to add to HL after loads 
	ld b, 40     ; 40 sprites to clear
.loop_1 
	ld [hl], 0 
	add hl, de
	ld [hl], 0 
	add hl, de
    ld [hl], 0 
	add hl, de
	ld [hl], 0 
	add hl, de
	dec b 
	ld a, b 
	cp 0
	jr nz, .loop_1
	
	ret
	
CLEAR_MAP::
	ret
	
LOAD_BG_TILES::
	ld hl, AlphaBgTiles ; address of tile data
	ld de, Tiles0       ; address of tile memory in VRAM
	ld c, 34            ; 34 tiles to load 

.loop_all_tiles
	ld b, 16			; 16 bytes to load
	
.loop_single_tile
	ld a, [hl] 			; load the src tile data into a
	ld [de], a			; store the tile data into dst
	inc hl
	inc de
	dec b
	ld a, b
	cp 0
	jr nz, .loop_single_tile
	
	dec c               ; decrement tile counter
	ld a, c				; transfer to accumulator
	cp 0				; if 0 then we are doing transferring tiles
	jr nz, .loop_all_tiles  ; if not zero, work on transferring next tile
	
	ret
	
LOAD_MAP::
	ld hl, BgMap                     ; address of map data on ROM
	ld de, $9800                     ; first map data in VRAM
	ld bc, BgMapHeight * BgMapWidth   ; 32*32 iterations

.loop
	ld a, [hl]
	ld [de], a 
	inc hl
	inc de
	dec bc
	ld a, b
	cp 0
	jr nz, .loop
	ld a, c
	cp 0
	jr nz, .loop
	ret
	
LOAD_SPRITE_TILES::
	ld hl, SpriteTiles
	ld de, $8000 
	ld bc, 16 * 16  ; 1 sprite tile to load (16 bytes per tile)
.loop 
	ld a, [hl+]
	ld [de], a 
	inc de
	dec bc 
	ld a, b 
	or c 
	jr nz, .loop
	ret 

UPDATE_GRAPHIC_TILE_INDEX::
	ld hl, GraphicTileDir
	ld a, [hl] 
	cp 0 
	jp z, .uf
	
.ub                           ; Reverse dir
	ld hl, GraphicTileIndex
	ld a, [hl]
	cp 0
	jr nz, .ub_dec
	inc a
	ld [hl], a
	ld hl, GraphicTileDir
	ld [hl], 0
	ret

.ub_dec
	dec a 
	ld [hl], a
	ret

.uf
	ld hl, GraphicTileIndex
	ld a, [hl]
	cp 2 
	jr nz, .uf_inc
	dec a 
	ld [hl], a 
	ld hl, GraphicTileDir 
	ld [hl], 1 
	ret
	
.uf_inc
	inc a 
	ld [hl], a 
	ret 
	
UPDATE_GRAPHIC_TILES::
	ld hl, GraphicTileIndex
	ld a, [hl]
	ld hl, AlphaBgTiles + $A0
	sla a 
	sla a
	sla a
	sla a
	ld c, a 
	ld b, 0 
	add hl, bc 
	ld de, $9080
	ld b, 16
.loop 
	ld a, [hl]
	ld [de], a 
	inc hl
	inc de
	dec b
	jp nz, .loop 
	ret

UPDATE_INPUTS::
	ld a, $20       ; Get D-Pad input first 
	ld [rP1], a   ; select D-Pad buttons
	ld a, [rP1]   
	ld a, [rP1]   ; get values twice to make sure proper results are returned
	cpl 
	and $0f         ; only need bottom 4 bits
	swap a
	ld b, a 
	ld a, $10       ; prepare to query for buttons 
	ld [rP1], a 
	ld a, [rP1]     ; read many times to make sure proper results are retrieved
	ld a, [rP1]
	ld a, [rP1]
	ld a, [rP1]
	ld a, [rP1]
	ld a, [rP1]
	cpl 
	and $0f 
	or b            ; combine buttons and d-pad to one byte
	ld [InputsHeld], a ; store held buttons in memory
	ld a, $30          ; reset (?) joypad. aka do not request what inputs are down
	ld [rP1], a 
	ret
	
UPDATE_PLAYER::
	
	; prepare params for MoveRect_Integer function 
	ld bc, $0000 
	ld de, $0000  
	
.check_left	
	ld a, [InputsHeld]
	and BUTTON_LEFT
	jp z, .check_right 
	ld bc, $0 - PLAYER_HORI_SPEED
	ld a, %00000010 
	ld [FlipPlayerX], a 
	jp .check_grounded 
	
.check_right 
	ld a, [InputsHeld]
	and BUTTON_RIGHT
	jp z, .check_grounded 
	ld a, 0 
	ld [FlipPlayerX], a 
	ld bc, PLAYER_HORI_SPEED 

.check_grounded	
	ld a, [PlayerGrounded]
	cp 0 
	jp z, .apply_gravity
	
	; player is marked as grounded, but check if grounded 
	; in case the player has moved off a platform 
	ld hl, PlayerRect
	ld a, COLLISION_TILE_CAP
	push bc
	push de 
	call CheckRectGrounded_Fixed
	pop de 
	pop bc 
	
	cp 1 
	jp z, .check_jump 
	ld [PlayerGrounded], a 				; save player as not grounded 
	jp .apply_gravity

.check_jump
	ld a, [InputsHeld]					; player is not grounded, so check for jump
	and BUTTON_A
	jp z, .update_player_animation 			; y-vel is already zeroed so go to move call 
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
	ld hl, GRAVITY
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
	jp .move_player_rect
	
.set_anim_air 
	ld a, PLAYER_ANIM_AIR_PATTERN
	ld [PlayerSpritePattern], a 		; set anim pattern air 
	jp .move_player_rect
.set_anim_idle
	ld a, PLAYER_ANIM_IDLE_PATTERN
	ld [PlayerSpritePattern], a 		; set anim pattern idle 
	jp .move_player_rect
.set_anim_walk1
	ld a, PLAYER_ANIM_WALK1_PATTERN 
	ld [PlayerSpritePattern], a 		; set anim pattern walk1 
	;goto .move_player_rect


.move_player_rect
	ld a, 8
	ld hl, PlayerRect
	call MoveRect_Fixed
	bit BIT_COLLIDED_DOWN, a 
	jp z, .check_hit_up 
	
	; player hit something moving down, mark as grounded 
	ld a, 1 
	ld [PlayerGrounded], a 			; player collided downward so load grounded = 1 
	
	; player collided with something moving down, zero y velocity
	ld a, 0 
	ld [fYVelocity], a 
	ld [fYVelocity + 1], a 
	jp .return
	
.check_hit_up
	bit BIT_COLLIDED_UP, a 
	jp z, .return 
	
	; player collided with something moving up, zero y velocity
	ld a, 0 
	ld [fYVelocity], a 
	ld [fYVelocity + 1], a 
	
.return
	ret
	
UPDATE_LOCAL_OAM::

	; Update player OAM 
	ld hl, PlayerRect			
	push hl 					; param0 = rect address 
	ld hl, LocalOAM				
	push hl 					; param1 = oam address 
	ld b, 4 
	ld c, 4 
	push bc 					; param2 = rect offset x / y 
	ld b, 2  
	ld c, 2  
	push bc 					; param3 = sprite char width/height 
	ld a, [PlayerSpritePattern]
	ld b, a  
	ld c, 0 
	push bc 					; param4 = sprite pattern, sprite OBJ index 
	ld b, 0 
	ld a, [FlipPlayerX]
	ld c, a  
	push bc 					; param5 = 0, flip flags 
	call UpdateOAMFromRect_Fixed
	ret 
	
RECORD_LY::

	; save value of LY 
	ld a, [rLY]
	ld b, a 
	and $0f
	cp $0a 		; check if its a hex character 
	jp c, .set_digit1_tile
	add a, 7 		; add 7 to point to hex chars A-F  
.set_digit1_tile
	add a, FontPatternStart + 16 
	ld [LYValue + 1], a 
	
	ld a, b 		; grab ly value again 
	and $f0 
	swap a 
	cp $0a 
	jp c, .set_digit16_tile 
	add a, 7 
.set_digit16_tile
	add a, FontPatternStart + 16 
	ld [LYValue], a 
	
	ret 
	
	
TRANSFER_OAM::
	; TODO: Replace this with proper sprite DMA 
	; Transfer Player data (4 OBJ sprites)
	
	ld a, 4 		; player is 4 obj sprites
	; TODO: add number of active sprites to this value
	ld b, a 		; e = loop counter. quit loop when == 0 
	
	ld hl, LocalOAM
	ld de, $fe00 
	
.loop
	push bc 		 ; save counter 
	ld bc, $0001	 ; use instead of inc operations because of OAM bug 
	
	ld a, [hl]
	ld [de], a       ; byte 1
	add hl, bc 
	push hl 
	;ld hl, de 
	ld h, d
	ld l, e 
	add hl, bc 
	;ld de, hl
	ld d, h 
	ld e, l 
	pop hl 
	
	ld a, [hl]
	ld [de], a       ; byte 2 
	add hl, bc
	push hl 
	;ld hl, de 
	ld h, d
	ld l, e 
	add hl, bc 
	;ld de, hl
	ld d, h 
	ld e, l 
	pop hl 
	
	ld a, [hl]
	ld [de], a       ; byte 3 
	add hl, bc
	push hl 
	;ld hl, de 
	ld h, d
	ld l, e 
	add hl, bc 
	;ld de, hl
	ld d, h 
	ld e, l 
	pop hl 
	
	ld a, [hl]
	ld [de], a       ; byte 4 
	add hl, bc
	push hl 
	;ld hl, de 
	ld h, d
	ld l, e 
	add hl, bc 
	;ld de, hl
	ld d, h 
	ld e, l 
	pop hl 
	
	pop bc 		; restore counter 
	ld a, b
	sub 1 
	ld b, a 	; save that counter 
	cp 0 
	jp nz, .loop	; counter isnt zero yet. more data to transter 
	
	ret

DRAW_LY::
	ld hl, $9831 
	ld a, [LYValue]
	ld [hl+], a 
	ld a, [LYValue + 1]
	ld [hl], a 
	ret 

;*** End Of File ***