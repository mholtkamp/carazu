INCLUDE "include/menu.inc"
INCLUDE "include/font.inc"
INCLUDE "include/util.inc"
INCLUDE "include/globals.inc"
INCLUDE "include/input.inc"
INCLUDE "include/constants.inc"
INCLUDE "include/level.inc"
INCLUDE "include/stats.inc"

	SECTION "MenuVars", BSS 
	
MENU_OPTION_NEW_GAME EQU 0 
MENU_OPTION_CONTINUE EQU 1 
	
MenuCursor:
DS 1 


	SECTION "MenuGraphics", HOME 
	
MenuBGMapWidth  EQU 20
MenuBGMapHeight EQU 18
MenuBGMapBank   EQU 0

MenuTilesBank EQU 0
MenuBGTileCount EQU 24 
MenuSpriteTileCount EQU 1 

Str_NewGame:
DB "NEW GAME",0

Str_Continue:
DB "CONTINUE",0

MenuBGMap::
DB $17,$17,$17,$17,$17,$17,$17,$17,$17,$17
DB $17,$17,$17,$17,$17,$17,$17,$17,$17,$17
DB $17,$17,$17,$17,$17,$17,$17,$17,$17,$17
DB $17,$17,$17,$17,$17,$17,$17,$17,$17,$17
DB $17,$17,$17,$17,$17,$17,$17,$17,$17,$17
DB $17,$17,$17,$17,$17,$17,$17,$17,$17,$17
DB $17,$17,$17,$17,$17,$17,$17,$17,$17,$17
DB $17,$17,$17,$17,$17,$17,$17,$17,$17,$17
DB $17,$17,$17,$17,$00,$02,$04,$06,$08,$0A
DB $04,$06,$0C,$0E,$10,$12,$17,$17,$17,$17
DB $17,$17,$17,$17,$01,$03,$05,$07,$09,$0B
DB $05,$07,$0D,$0F,$11,$13,$17,$17,$17,$17
DB $17,$17,$17,$17,$17,$17,$17,$17,$17,$17
DB $17,$17,$17,$17,$17,$17,$17,$17,$17,$17
DB $17,$17,$17,$17,$17,$17,$17,$17,$17,$17
DB $17,$17,$17,$17,$17,$17,$17,$17,$17,$17
DB $17,$17,$17,$17,$17,$17,$17,$17,$17,$17
DB $17,$17,$17,$17,$17,$17,$17,$17,$17,$17
DB $17,$17,$17,$17,$17,$17,$17,$17,$17,$17
DB $17,$17,$17,$17,$17,$17,$17,$17,$17,$17
DB $17,$17,$17,$17,$17,$17,$17,$17,$17,$17
DB $17,$17,$17,$17,$17,$17,$17,$17,$17,$17
DB $17,$17,$17,$17,$17,$17,$17,$17,$17,$17
DB $17,$17,$17,$17,$17,$17,$17,$17,$17,$17
DB $17,$17,$17,$17,$17,$17,$17,$17,$17,$17
DB $17,$17,$17,$17,$17,$17,$17,$17,$17,$17
DB $17,$17,$17,$17,$17,$17,$17,$17,$17,$17
DB $17,$17,$17,$17,$17,$17,$17,$17,$17,$17
DB $17,$17,$17,$17,$17,$17,$17,$17,$17,$17
DB $17,$17,$17,$17,$17,$17,$17,$17,$17,$17
DB $17,$17,$17,$17,$17,$17,$17,$17,$17,$17
DB $17,$17,$17,$17,$17,$17,$17,$17,$17,$17
DB $17,$17,$17,$17,$17,$17,$17,$17,$17,$17
DB $17,$17,$17,$17,$17,$17,$17,$17,$17,$17
DB $17,$17,$17,$17,$17,$17,$17,$17,$17,$17
DB $17,$17,$17,$17,$17,$17,$17,$17,$17,$17

MenuBGTiles::
DB $03,$03,$1F,$1C,$3F,$30,$7F,$60
DB $7F,$43,$7C,$44,$78,$48,$78,$48
DB $78,$48,$78,$48,$7C,$44,$7F,$43
DB $7F,$60,$3F,$30,$1F,$18,$0F,$0F
DB $E0,$E0,$F8,$38,$FC,$0C,$FE,$06
DB $FE,$E2,$3E,$3E,$00,$00,$00,$00
DB $00,$00,$00,$00,$3E,$3E,$FE,$E2
DB $FE,$02,$FE,$06,$FC,$1C,$F0,$F0
DB $00,$00,$00,$00,$01,$01,$01,$01
DB $03,$02,$03,$02,$07,$04,$07,$04
DB $0F,$08,$0F,$09,$0F,$09,$1F,$10
DB $1F,$13,$3E,$22,$3E,$22,$3E,$3E
DB $00,$00,$80,$80,$C0,$40,$C0,$40
DB $E0,$20,$E0,$20,$F0,$10,$F0,$90
DB $F8,$88,$78,$48,$F8,$C8,$FC,$04
DB $FC,$E4,$3E,$22,$3E,$22,$3E,$3E
DB $00,$00,$3F,$3F,$3F,$20,$3F,$20
DB $3F,$23,$3E,$22,$3F,$23,$3F,$20
DB $3F,$20,$3F,$20,$3F,$20,$3F,$20
DB $3F,$23,$3E,$22,$3E,$22,$3E,$3E
DB $00,$00,$F0,$F0,$F8,$08,$FC,$04
DB $FC,$C4,$7C,$44,$FC,$C4,$FC,$04
DB $F8,$08,$F0,$70,$E0,$20,$F0,$10
DB $F8,$08,$FC,$84,$7C,$44,$3C,$3C
DB $00,$00,$3F,$3F,$3F,$20,$3F,$20
DB $3F,$3F,$00,$00,$00,$00,$01,$01
DB $03,$02,$07,$04,$0F,$08,$1F,$11
DB $3F,$23,$3F,$20,$3F,$20,$3F,$3F
DB $00,$00,$FC,$FC,$FC,$04,$FC,$04
DB $FC,$C4,$7C,$44,$F8,$88,$F0,$10
DB $E0,$20,$C0,$40,$80,$80,$00,$00
DB $FC,$FC,$FC,$04,$FC,$04,$FC,$FC
DB $00,$00,$3C,$3C,$3C,$24,$3C,$24
DB $3C,$24,$3C,$24,$3C,$24,$3C,$24
DB $3C,$24,$3C,$24,$3C,$24,$3E,$22
DB $3F,$21,$1F,$10,$0F,$08,$07,$07
DB $00,$00,$1E,$1E,$1E,$12,$1E,$12
DB $1E,$12,$1E,$12,$1E,$12,$1E,$12
DB $1E,$12,$1E,$12,$1E,$12,$3E,$22
DB $FE,$C2,$FC,$04,$F8,$08,$F0,$F0
DB $00,$04,$00,$06,$00,$07,$00,$04
DB $00,$3C,$38,$44,$38,$44,$00,$38
DB $00,$3C,$3C,$42,$72,$8D,$76,$89
DB $66,$99,$66,$99,$3C,$42,$00,$3C
DB $70,$70,$78,$48,$7C,$44,$7E,$42
DB $7C,$44,$78,$48,$70,$70,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00

MenuSpriteTiles::
DB $70,$70,$78,$48,$7C,$44,$7E,$42
DB $7C,$44,$78,$48,$70,$70,$00,$00

	SECTION "MenuProcedures", HOME 
	
Menu_UpdateCursorSprite::
	ld a, [MenuCursor]
	cp 0 
	jp z, .cursor_0
	cp 1
	jp z, .cursor_1
	
.cursor_0 
	ld a, 96
	ld [LocalOAM], a 
	ld a, 46 
	ld [LocalOAM+1], a 
	ld a, 0 
	ld [LocalOAM+2], a
	ld a, $00
	ld [LocalOAM+3], a 
	ret 
	
.cursor_1 
	ld a, 112
	ld [LocalOAM], a 
	ld a, 46 
	ld [LocalOAM+1], a 
	ld a, 0 
	ld [LocalOAM+2], a
	ld a, $00
	ld [LocalOAM+3], a 
	ret 
	
Menu_Load::

	; Reset cursor position
	ld a, [LevelNum]
	cp -1
	jp z, .set_cursor_0
	ld a, 1 
	ld [MenuCursor], a 
	jp .load_tiles
.set_cursor_0
	ld a, 0
	ld [MenuCursor], a 
	
.load_tiles 
	ld hl, MenuSpriteTiles
	ld b, 0 	; load sprite tiles 
	ld c,	MenuSpriteTileCount
	ld d, 0 	; Home bank
	ld e, 0 	; tile index 
	call LoadTiles
	
	ld hl, MenuBGTiles
	ld b, 1 	; load bg tiles 
	ld c, MenuBGTileCount 
	ld d, 0 	; Home bank 
	ld e, 0 	; tile index 
	call LoadTiles 
	
	call Font_LoadFull 

	ld b, MenuBGMapWidth
	ld c, MenuBGMapHeight
	push bc 
	ld hl, MenuBGMap 
	ld b, 0 	; x offset 
	ld c, 0     ; y offset 
	ld d, 0 	; rom bank 0 
	ld e, 0 	; BG map, not window 
	call LoadMap

	ld hl, Str_NewGame
	ld b, 6		; x coord
	ld c, 10	; y coord  
	ld d, 0       ; BG 
	call WriteText
	
	ld hl, Str_Continue
	ld b, 6
	ld c, 12 
	ld d, 0 
	call WriteText
	
	ret
	
Menu_Update::

; Handle input 
.check_up
	ld a, [InputsPrev]
	and BUTTON_UP
	cpl 
	ld b, a 
	ld a, [InputsHeld]
	and BUTTON_UP 
	and b 
	jp z, .check_down
	ld a, 0 
	ld [MenuCursor], a 
	
.check_down
	ld a, [InputsPrev]
	and BUTTON_DOWN 
	cpl 
	ld b, a 
	ld a, [InputsHeld]
	and BUTTON_DOWN 
	and b 
	jp z, .check_a 
	ld a, 1 
	ld [MenuCursor], a 
	
.check_a
	ld a, [InputsHeld]
	and BUTTON_A 
	jp z, .update_obj
	ld a, [MenuCursor]
	cp MENU_OPTION_NEW_GAME
	jp z, .new_game
	cp MENU_OPTION_CONTINUE
	jp z, .continue
	
.update_obj
	call Menu_UpdateCursorSprite
	ret 

.new_game
	ld a, 0 
	ld [LevelNum], a 	; set level to 0 since it is a new game 
	
	call Stats_ResetRun	; reset the stat bss variables, as this is a new game.
	
	ld b, STATE_GAME 
	call SwitchState
	ret 
	
.continue 
	ld a, [LevelNum]
	cp -1 
	jp z, .update_obj		; level is -1, means no saved run 
	
	ld b, STATE_GAME
	call SwitchState
	ret 