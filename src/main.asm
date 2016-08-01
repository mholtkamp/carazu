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
	INCLUDE "include/rect.inc"
	INCLUDE "include/font.inc"
	INCLUDE "include/input.inc"
	INCLUDE "include/player.inc"
	INCLUDE "include/constants.inc"
	INCLUDE "include/globals.inc"
	INCLUDE "include/level.inc"
	INCLUDE "include/sound.inc"
	INCLUDE "include/music.inc"
	INCLUDE "include/menu.inc"
	INCLUDE "include/stats.inc"
	INCLUDE "include/item.inc"
	
;****************************************************************************************************************************************************
;*	user data (constants)
;****************************************************************************************************************************************************

;****************************************************************************************************************************************************
;*	equates
;****************************************************************************************************************************************************

HandleVBLInt EQU $ff80 


;****************************************************************************************************************************************************
;*	BSS variables
;****************************************************************************************************************************************************
	SECTION "Variables", BSS[$C000]

LocalOAM:
DS 160 

Scratch:
DS 8

LYValue:
DS 2   

VBLANK_Flag:
DS 1 

GameState:
DS 1 


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
	jp HandleVBLInt
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
	DB	"CARAZU",0,0,0,0,0
		;012345  6 7 8 9 A

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
	DB	$02	; $19 - ROM + MBC5

	; $0148 (ROM size)
	DB	$01	; $01 - 512Kbit = 64Kbyte = 4 banks

	; $0149 (RAM size)
	DB	$01	; $00 - None

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
	ld sp, $e000 ; setting stack pointer to the fast-ram area.
	
	call WaitVBLANK ; wait until we are in the vblank region of the screen refresh
	
	ld a, 0  ; zero-out the a register
	ldh [rLCDC], a ;turn off LCD
	
	; Initialize graphics
	call CLEAR_MAP
	call ClearOAM
	
	; Initialize Game State
	ld a, STATE_MENU
	ld [GameState], a 
	
	; Initialize sound
	call Initialize_Sound
	
	; Initialize BSS data
	call Player_Initialize
	call Level_Initialize 
	
	; Load Menu (don't use SwitchState because that waits for VBLANK)
	call Menu_Load
	
	; Load song 
	ld c, 0 
	call LoadSong
	
	ld a, %11100100 ;load normal palette of colors
	ldh [rBGP], a
	ldh [rOBP0], a 
	
	ld a, %10000011 ; turn on LCD, OBJ, BG
	ld [rLCDC], a

	
	; Copy the DMA subroutine into HRAM 
	call CopyVBLInt
	
	; Enable VBLANK interrupt 
	ld hl, $ffff
	set 0, [hl]
	
	ei 
	
	
Main_Game_Loop::
	call Input_Update
	
	ld a, [GameState]
	cp STATE_MENU 
	jp z, .menu 
	cp STATE_GAME
	jp z, .game 
	cp STATE_FINALE
	jp z, .finale 
	cp STATE_TRANSITION_OUT
	jp z, .trans_out
	cp STATE_TRANSITION_IN 
	jp z, .trans_in 
	cp STATE_PAUSE
	jp z, .pause 
	cp STATE_SPLASH
	jp z, .splash
	
	jp Main_Game_Loop	; should only get here in error (infinite loop will occur)
	
.menu 
	call Menu_Update
	call UpdateSong
	
	; Wait for VBLANK interval 
	call WaitVBLANK_Flag
	nop
	nop
	
	jp Main_Game_Loop
	
.game 
	; Game Logic Updates
	call Player_Update
	call Level_Update
	call Update_Items
	call Stats_Update 
	
	; Local OAM Updates 
	call Player_UpdateLocalOAM
	
	; Update music 
	call UpdateSong
	
	; Performance Measurement
	call Stats_RecordLY
	
	; switch to correct rom bank for vblank routine 
	ld a, [MapBank]
	ld [ROM_BANK_WRITE_ADDR], a 
	
	; Wait for VBLANK interval 
	call WaitVBLANK_Flag
	nop
	nop
	
	; Graphics
	
	; update scroll 
	ld a, [BGScrollX]
	ld [$ff43], a 
	ld a, [BGScrollY]
	ld [$ff42], a
	
	; Update stats window 
	ld hl, HeartEntries
	ld de, MAP_1 + HEART_ENTRY_X
	; heart 1 
	ld a, [hl+]
	ld [de], a 
	inc de 
	; heart 2 
	ld a, [hl+]
	ld [de], a 
	inc de 
	; heart 3 
	ld a, [hl]
	ld [de], a 

	ld hl, BubbleEntries 
	ld de, MAP_1 + BUBBLE_ENTRY_X+1 
	; bubble 1 
	ld a, [hl+]
	ld [de], a 
	inc de 
	; bubble 2 
	ld a, [hl]
	ld [de], a 
	
	ld hl, DebugLYEntries
	ld de, MAP_1 + DEBUG_LY_ENTRY_X
	; digit 1 
	ld a, [hl+]
	ld [de], a 
	inc de 
	; digit 2 
	ld a, [hl]
	ld [de], a 
	
	; stream new tiles 
	ld a, [MapStreamDir]
	cp LOAD_LEFT
	jp nz, .right
	call _Level_LoadLeft
	jp Main_Game_Loop
.right 
	cp LOAD_RIGHT
	jp nz, .top 
	call _Level_LoadRight
	jp Main_Game_Loop
.top 
	cp LOAD_TOP
	jp nz, .bottom 
	call _Level_LoadTop
	jp Main_Game_Loop
.bottom
	cp LOAD_BOTTOM
	jp nz, Main_Game_Loop
	call _Level_LoadBottom

	; draw performance counter if debugging
	;call DrawLY

	jp Main_Game_Loop
	
.finale
.trans_out 
.trans_in 
.pause 
.splash 
	jp Main_Game_Loop
	
WaitVBLANK_Flag::
	ld a, [VBLANK_Flag]
	cp 1 
	jr nz, WaitVBLANK_Flag
	ld a, 0 
	ld [VBLANK_Flag], a 	; clear flag 
	ret 
	
;***************************************************************
;* Subroutines
;***************************************************************

	SECTION "Support Routines", HOME
	
WaitVBLANK::
	ldh a, [rLY]     ;load the y position of current scanline
	cp $8F           ; is the scanline equal to 143? 
	jr nz, WaitVBLANK ; if not equal, keep looping
.almost_vblank
	ldh a, [rLY]     ; loop until 144, then we are in VBLANK
	cp $90
	jr nz, .almost_vblank
	ret              ; we are now in the VBLANK interval, so return
	
ClearOAM::
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

DrawLY::
	ld hl, $9831 
	ld a, [LYValue]
	ld [hl+], a 
	ld a, [LYValue + 1]
	ld [hl], a 
	ret 
	
CopyVBLInt::
	ld hl, HandleVBLInt_Code 
	ld de, $ff80 
	
.loop 
	ld a, [hl+]
	ld [de], a 
	inc de 
	ld a, h 
	cp HandleVBLInt_Code_End >> 8 
	jr nz, .loop 
	ld a, l 
	cp HandleVBLInt_Code_End & $00ff 
	jr nz, .loop 
	ret 
	
HandleVBLInt_Code::
	push af 
	
	ld a, 1 
	ld [VBLANK_Flag], a 		; set vblank flag 
	
	ld a, LocalOAM >> 8 
	ld [$ff46], a 
	ld a, $28 
	
.wait
	dec a 
	jr nz, .wait 
	pop af 
	reti 
	
HandleVBLInt_Code_End::
	nop 
	
; b = new state 
SwitchState::
	call WaitVBLANK_Flag
	ld hl, rLCDC 
	res 7 ,[hl]		; turn of lcd 
	
	ld a, b 
	cp STATE_MENU 
	jp z, .switch_menu
	cp STATE_GAME 
	jp z, .switch_game

.switch_menu 
	call Menu_Load
	ld c, 0 
	call LoadSong
	ld a, STATE_MENU
	ld [GameState], a 
	jp .return 
	
.switch_game
	call Player_LoadGraphics
	call Load_Item_Graphics
	call Level_Load 
	call Stats_LoadGraphics 
	call Stats_Show
	
	
	ld a, STATE_GAME 
	ld [GameState], a 
	jp .return 
	
.return 
	ld hl, rLCDC 
	set 7, [hl]		; turn on lcd 
	ret 

;*** End Of File ***