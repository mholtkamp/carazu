INCLUDE "include/splash.inc"
INCLUDE "include/globals.inc"
INCLUDE "include/input.inc"
INCLUDE "include/stats.inc"
INCLUDE "include/constants.inc"
INCLUDE "include/util.inc"
INCLUDE "tiles/item_tiles.inc"

SPLASH_WINDOW_X_POS EQU 7 
SPLASH_WINDOW_Y_POS EQU 0 

HEADER_Y EQU 3 
ITEM_Y EQU 7 
ITEM_X EQU 9
FOOTER_Y EQU 13

SECRET1_SHARED_TILE_INDEX EQU $84 
SECRET2_SHARED_TILE_INDEX EQU $88
SECRET3_SHARED_TILE_INDEX EQU $8C
FERMATA_SHARED_TILE_INDEX EQU $90 
BASS_SHARED_TILE_INDEX EQU $94
ALLEGRO_SHARED_TILE_INDEX EQU $98 

	SECTION "SplashVars", BSS 
	
SplashType:
DS 1 

	SECTION "SplashData", DATA, BANK[1]
	
FermataHeaderText0:
DB "FERMATA RUNE", 0 
FermataFooterText0:
DB "PRESS A IN MID-AIR", 0
FermataFooterText1:
DB "TO DOUBLE JUMP", 0 

BassHeaderText0:
DB "BASS RUNE", 0 
BassFooterText0:
DB "PRESS B TO FIRE", 0 
BassFooterText1:
DB "THE BASS CANNON", 0 

AllegroHeaderText0:
DB "ALLEGRO RUNE", 0 
AllegroFooterText0:
DB "MOVE SPEED BONUS", 0 


	
	SECTION "SplashProcs", HOME 
	
Splash_Update::

	ld a, [InputsHeld]
	and BUTTON_START 
	ret z 
	
	; Player hit start, so set state back to game state 
	ld a, STATE_GAME 
	ld [GameState], a 
	
	; Manually switch to game state to continue and not reload level (as call SwitchGame would do)
	call WaitVBLANK_Flag
	
	; disable lcd 
	ld hl, rLCDC 
	res 7 ,[hl]		; turn of lcd 
	
	ld b, 1 
	call ClearMap
	
	; Enable sprites 
	ld hl, rLCDC 
	set 1, [hl]
	
	; Reset the stats HUD
	call Stats_Show
	
	; Re-enable lcd 
	ld hl, rLCDC 
	set 7, [hl]		; turn on lcd 
	
	ret 
	
	
Splash_Load

	; clear window 
	ld b, 1 
	call ClearMap 
	
	; Set window x/y
	ld a, SPLASH_WINDOW_Y_POS
	ld [rWY], a 
	ld a, SPLASH_WINDOW_X_POS 
	ld [rWX], a 
	
	; Load special tiles in shared tile bank 
	ld hl, ItemTiles 
	ld b, 2 
	ld c, 32 
	ld d, ItemTilesBank 
	ld e, 0
	call LoadTiles 
	
	; Disable sprites 
	ld hl, rLCDC 
	res 1, [hl]
	
	; Switch to proper rom bank to load string data 
	ld a, 1 
	ld [ROM_BANK_WRITE_ADDR], a 
	
	ld a, [SplashType]
	cp SPLASH_FERMATA 
	jp z, .fermata 
	cp SPLASH_BASS
	jp z, .bass 
	cp SPLASH_ALLEGRO 
	jp z, .allegro 
	
	jp .return 
	
.fermata 
	ld b, 4
	ld c, HEADER_Y 
	ld d, 1 
	ld hl, FermataHeaderText0
	call WriteText 
	
	ld b, 1
	ld c, FOOTER_Y 
	ld d, 1 
	ld hl, FermataFooterText0
	call WriteText
	
	ld b, 3 
	ld c, FOOTER_Y + 1  
	ld d, 1 
	ld hl, FermataFooterText1
	call WriteText
	
	ld a, FERMATA_SHARED_TILE_INDEX
	jp .item_tiles 
	
.bass 
	ld b, 6
	ld c, HEADER_Y
	ld d, 1 
	ld hl, BassHeaderText0
	call WriteText
	
	ld b, 3
	ld c, FOOTER_Y 
	ld d, 1 
	ld hl, BassFooterText0
	call WriteText
	
	ld b, 3
	ld c, FOOTER_Y + 1 
	ld d, 1 
	ld hl, BassFooterText1
	call WriteText
	
	ld a, BASS_SHARED_TILE_INDEX
	jp .item_tiles

.allegro 

	ld b, 4
	ld c, HEADER_Y
	ld d, 1 
	ld hl, AllegroHeaderText0
	call WriteText
	
	ld b, 2
	ld c, FOOTER_Y 
	ld d, 1 
	ld hl, AllegroFooterText0
	call WriteText
	
	ld a, ALLEGRO_SHARED_TILE_INDEX
	jp .item_tiles
	
.item_tiles
	; a should equal tile index in shared tile data 
	ld [ITEM_X + ITEM_Y*32 + MAP_1], a 
	inc a 
	ld [ITEM_X + ITEM_Y*32 + MAP_1 + 32], a 
	inc a 
	ld [ITEM_X + ITEM_Y*32 + MAP_1 + 1], a 
	inc a 
	ld [ITEM_X + ITEM_Y*32 + MAP_1 + 32 + 1], a 
	
	;jp .return 
	
.return 
	ret 