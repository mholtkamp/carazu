INCLUDE "include/stats.inc"
INCLUDE "include/player.inc"
INCLUDE "include/font.inc"
INCLUDE "include/constants.inc"
INCLUDE "include/level.inc"
INCLUDE "include/globals.inc"
INCLUDE "include/util.inc"

STATS_WINDOW_Y_POS EQU 136 
STATS_WINDOW_X_POS EQU WINDOW_X_OFFSET
BUBBLE_TILE_INDEX EQU (SPECIAL_TILES_INDEX + 10)
HEART_TILE_INDEX EQU (SPECIAL_TILES_INDEX + 11) 

FINALE_WINDOW_X_POS EQU 7 
FINALE_WINDOW_Y_POS EQU 0 

	SECTION "StatsVariables", BSS 

; Run Stats 
PlayerHearts:
DS 1 
PlayerBubbles: 
DS 1 
HasFermata:
DS 1 
HasBass:
DS 1 
HasAllegro:
DS 1 
PlayTime: 
DS 2 

; Record Stats 
RecordTime:
DS 2 
RecordBubbles:
DS 1 

; Secret Stats
Secret1:
DS 1 
Secret2:
DS 1 
Secret3:
DS 1 

; Debug Stats  
DebugLY:
DS 1 

; New Record Flags 
NewRecBubbles:
DS 1 
NewRecTime:
DS 1 

; Stat Bar Window Data 
HeartEntries:
DS 3
BubbleEntries
DS 2 

DebugLYEntries:
DS 2

TickTimer:
DS 1 

SaveSignature EQU $A000
SaveLevel EQU $A004
SaveHearts EQU $A005
SaveBubbles EQU $A006
SaveFermata EQU $A007
SaveBass EQU $A008
SaveAllegro EQU $A009
SaveTime EQU $A00A
SaveRecordTime EQU $A00C 
SaveRecordBubbles EQU $A00E
SaveSecret1 EQU $A00F
SaveSecret2 EQU $A010
SaveSecret3 EQU $A011

	SECTION "StatsVars", DATA, BANK[1]

StringTheEnd:
DB "THE END", 0 

StringCredit0:
DB "CREATED BY", 0 
StringCredit1:
DB "MARTIN HOLTKAMP", 0

StringBubbles:
DB "BUBBLES: ", 0 
StringTime:
DB "TIME: ", 0 

StringNewRec:
DB "NEW RECORD!!", 0  



	SECTION "StatsProcs", HOME 
	
Stats_ResetRun::
	; Should be called when starting a new game
	ld a, 0
	ld [LevelNum], a 
	ld a, MAX_HEARTS 
	ld [PlayerHearts], a 
	ld a, 0 
	ld [PlayerBubbles], a 
	ld [PlayTime], a 
	ld [PlayTime+1], a 
	ld [HasFermata], a 
	ld [HasBass], a 
	ld [HasAllegro], a 
	ld [TickTimer], a 
	
	ld a, 0 
	ld [DebugLY], a 

	ret 
	
; return: a = 1 if valid save found. 0 otherwise 
Stats_LoadFromSave::
	ld a, RAM_ENABLE
	ld [RAM_ENABLE_WRITE_ADDR], a
	ld a, 0 
	ld [RAM_BANK_WRITE_ADDR], a 

	; Check save signature for a valid saved game 
	; If the check fails, it means it's the first time running
	; this game (well, never saved a game before.)
	ld a, [SaveSignature]
	cp "N"
	jp nz, .return_false 
	ld a, [SaveSignature+1]
	cp "I"
	jp nz, .return_false 
	ld a, [SaveSignature+2]
	cp "M"
	jp nz, .return_false
	ld a, [SaveSignature+3]
	cp "U"
	jp nz, .return_false 
	
	; load run 
	ld a, [SaveLevel]
	ld [LevelNum], a
	ld a, [SaveHearts]
	ld [PlayerHearts], a 
	ld a, [SaveBubbles]
	ld [PlayerBubbles], a 
	ld a, [SaveFermata]
	ld [HasFermata], a 
	ld a, [SaveBass]
	ld [HasBass], a 
	ld a, [SaveAllegro]
	ld [HasAllegro], a 
	ld a, [SaveTime]
	ld [PlayTime], a 
	ld a, [SaveTime+1]
	ld [PlayTime+1], a 
	
	; load records 
	ld a, [SaveRecordTime]
	ld [RecordTime], a 
	ld a, [SaveRecordTime+1]
	ld [RecordTime+1], a 
	ld a, [SaveRecordBubbles]
	ld [RecordBubbles], a 
	
	; load secrets 
	ld a, [SaveSecret1]
	ld [Secret1], a 
	ld a, [SaveSecret2]
	ld [Secret2], a 
	ld a, [SaveSecret3]
	ld [Secret3], a 
	
	ld a, 0 
	ld [TickTimer], a 
	
	; save loaded successfully, ret 
	ld a, RAM_DISABLE
	ld [RAM_ENABLE_WRITE_ADDR], a
	ld a, 1 
	ret 
	
.return_false
	ld a, RAM_DISABLE
	ld [RAM_ENABLE_WRITE_ADDR], a
	ld a, 0 
	ret
	
Stats_InitNoSave
	; load internal ram values, 
	ld a, -1 
	ld [LevelNum], a 
	ld a, MAX_HEARTS
	ld [PlayerHearts], a 
	ld a, 0 
	ld [PlayerBubbles], a 
	ld [HasFermata], a 
	ld [HasBass], a 
	ld [HasAllegro], a 
	ld [PlayTime], a 
	ld [PlayTime+1], a 
	ld [RecordBubbles], a 
	ld [Secret1], a 
	ld [Secret2], a 
	ld [Secret3], a 
	ld a, $ff
	ld [RecordTime], a 
	ld [RecordTime+1], a 
	ld a, 0 
	ld [TickTimer], a 
	
	call Stats_SaveRun
	call Stats_SaveDefaultRecords
	call Stats_SaveSecrets
	ret 
	
Stats_SaveRun::
	ld a, RAM_ENABLE
	ld [RAM_ENABLE_WRITE_ADDR], a
	ld a, 0 
	ld [RAM_BANK_WRITE_ADDR], a 
	
	; Place signature at start of cart ram 
	ld a, "N"
	ld [SaveSignature], a 
	ld a, "I"
	ld [SaveSignature+1], a 
	ld a, "M"
	ld [SaveSignature+2], a 
	ld a, "U"
	ld [SaveSignature+3], a 
	
	; Current run stats 
	ld a, [LevelNum]
	ld [SaveLevel], a 
	ld a, [PlayerHearts]
	ld [SaveHearts], a 
	ld a, [PlayerBubbles]
	ld [SaveBubbles], a 
	ld a, [HasFermata]
	ld [SaveFermata], a 
	ld a, [HasBass]
	ld [SaveBass], a 
	ld a, [HasAllegro]
	ld [SaveAllegro], a 
	ld a, [PlayTime]
	ld [SaveTime], a 
	ld a, [PlayTime+1]
	ld [SaveTime+1], a 
	
	ld a, RAM_DISABLE
	ld [RAM_ENABLE_WRITE_ADDR], a
	
	ret 
	
Stats_SaveRecords::
	ld a, RAM_ENABLE
	ld [RAM_ENABLE_WRITE_ADDR], a
	ld a, 0 
	ld [RAM_BANK_WRITE_ADDR], a 
	
	ld a, [RecordTime]
	ld b, a 
	ld a, [PlayTime]
	cp b 
	jp c, .save_time
	jp z, .comp_lower_byte
	jp .check_bubbles
.comp_lower_byte
	ld a, [RecordTime+1]
	ld b, a 
	ld a, [PlayTime+1]
	cp b 
	jp c, .save_time 
	jp .check_bubbles 
	
.save_time
	; first save the value in internal ram 
	ld a, [PlayTime]
	ld [RecordTime], a 
	ld a, [PlayTime+1]
	ld [RecordTime+1], a 
	
	; save on cart ram 
	ld a, [RecordTime]
	ld [SaveRecordTime], a 
	ld a, [RecordTime+1]
	ld [SaveRecordTime+1], a 
	
	ld a, 1 
	ld [NewRecTime], a 
	
.check_bubbles 
	ld a, [PlayerBubbles]
	ld b, a 
	ld a, [RecordBubbles]
	cp b 
	jp c, .save_bubbles
	jp .return  
	
.save_bubbles
	; save on internal ram 
	ld a, [PlayerBubbles]
	ld [RecordBubbles],a 
	
	; save on cart ram 
	ld [SaveRecordBubbles], a 
	
	ld a, 1 
	ld [NewRecBubbles], a 
	
	jp .return  
	
.return 
	ld a, RAM_DISABLE
	ld [RAM_ENABLE_WRITE_ADDR], a
	ret 
	
Stats_SaveSecrets::
	ld a, RAM_ENABLE
	ld [RAM_ENABLE_WRITE_ADDR], a
	ld a, 0 
	ld [RAM_BANK_WRITE_ADDR], a 
	
	ld a, [Secret1]
	ld [SaveSecret1], a 
	ld a, [Secret2]
	ld [SaveSecret2], a 
	ld a, [Secret3]
	ld [SaveSecret3], a 
	
	ld a, RAM_DISABLE
	ld [RAM_ENABLE_WRITE_ADDR], a
	ret 
	
Stats_SaveDefaultRecords::
	ld a, RAM_ENABLE
	ld [RAM_ENABLE_WRITE_ADDR], a
	ld a, 0 
	ld [RAM_BANK_WRITE_ADDR], a 
	
	ld a, $ff 
	ld [SaveRecordTime], a 
	ld [SaveRecordTime+1], a 
	ld a, 0
	ld [SaveRecordBubbles], a 
	
	ld a, RAM_DISABLE
	ld [RAM_ENABLE_WRITE_ADDR], a
	ret 
	
Stats_LoadGraphics::
	call Font_LoadNumbers
	
	; Clear first row of window map 
	ld a, BLANK_TILE_INDEX
	ld hl, MAP_1 
	ld b, 20 	; 20 = number of tiles in row 
	
.loop 
	ld [hl+], a 
	dec b 
	jp nz, .loop 

	; Put the bubble map entry in because that will never change 
	ld a, BUBBLE_TILE_INDEX
	ld [MAP_1 + BUBBLE_ENTRY_X], a 
	
	ret 
	
Stats_IncrementTimer
	
	ld a, [TickTimer]
	inc a 
	ld [TickTimer], a 
	cp 60 
	jp nz, .return 
	
	ld a, 0 
	ld [TickTimer], a ; Reset tick timer 
	
	ld a, [PlayTime]
	ld h, a 
	ld a, [PlayTime+1]
	ld l, a 
	inc hl 
	ld a, h 
	ld [PlayTime], a 
	ld a, l 
	ld [PlayTime+1], a 
	
.return 
	ret 
	
Stats_Update::
	; Zero out all entry values
	ld a, 0 
	ld hl, HeartEntries
	ld [hl+], a 
	ld [hl+], a 
	ld [hl+], a 
	ld hl, BubbleEntries
	ld [hl+], a 
	ld [hl+], a
	ld [hl+], a 
	
	; Determine which hearts to draw 
	ld hl, HeartEntries
	ld a, [PlayerHearts]
	cp 3 
	jp nc, .fill3hearts
	cp 2
	jp nc, .fill2hearts
	cp 1 
	jp nc, .fill1heart
	jp .update_bubbles 
	
	
	
.fill3hearts
	ld a, HEART_TILE_INDEX
	ld [hl+], a 
.fill2hearts
	ld a, HEART_TILE_INDEX
	ld [hl+], a 
.fill1heart
	ld a, HEART_TILE_INDEX
	ld [hl+], a

	
.update_bubbles
	ld hl, BubbleEntries
	ld a, [PlayerBubbles]
	ld c, a 
	
	ld a, c 
	and $f0 
	swap a 
	ld d, a 
	ld a, NUMBER_TILES_INDEX
	add a, d 
	ld [hl+], a 	; load sec most sig digit 
	
	ld a, c 
	and $0f 
	ld d, a 
	ld a, NUMBER_TILES_INDEX
	add a, d 
	ld [hl], a 		; load least sig digit 
	
.check_death
	ld a, [PlayerHearts]
	cp 0 
	jp nz, .update_debug_ly
	ld a, 2 
	ld [PlayerHearts], a 
	
	ld a, RAM_ENABLE
	ld [RAM_ENABLE_WRITE_ADDR], a
	ld a, 0 
	ld [RAM_BANK_WRITE_ADDR], a 
	
	; Get the last saved bubble count 
	ld a, [SaveBubbles]
	ld [PlayerBubbles], a 
	
	ld a, RAM_DISABLE
	ld [RAM_ENABLE_WRITE_ADDR], a
	
	ld a, STATE_DEATH 
	ld [GameState], a 
	ld a, DEATH_STATE_COUNTER_MAX
	ld [DeathStateCounter], a 
	; load death state palettes 
	ld a, %00011011
	ld [rBGP], a 
	ld a, %00000000
	ld [rOBP0], a 
	; jp .update_debug_ly
	
.update_debug_ly
	ld hl, DebugLYEntries
	ld a, [DebugLY]
	ld c, a 
	
	ld a, c 
	and $f0 
	swap a 
	ld d, a 
	ld a, NUMBER_TILES_INDEX
	add a, d 
	ld [hl+], a 	; load sec most sig digit 
	
	ld a, c 
	and $0f 
	ld d, a 
	ld a, NUMBER_TILES_INDEX
	add a, d 
	ld [hl], a 		; load least sig digit 
	
	ret 
	
	
Stats_Hide::
	ld hl, rLCDC
	res 5, [hl]	
	ret 
	
Stats_Show::

	; Set window x/y
	ld a, STATS_WINDOW_Y_POS
	ld [rWY], a 
	ld a, STATS_WINDOW_X_POS 
	ld [rWX], a 
	
	; Put the bubble map entry in because that will never change 
	ld a, BUBBLE_TILE_INDEX
	ld [MAP_1 + BUBBLE_ENTRY_X], a 
	
	; Enable window in lcdc 
	ld hl, rLCDC
	set 6, [hl]
	set 5, [hl]
	
	ret 
	
Stats_RecordLY:
	ld a, [rLY]
	ld b, a 
	ld a, [DebugLY]
	cp b 
	jp c, .record_new_ly
	ret 
.record_new_ly
	ld a, b 
	ld [DebugLY], a 
	ret 

; Call this when switching states to save any new records and to
; also set the window data for the finale state
Stats_LoadFinale::

	ld a, 0 
	ld [NewRecBubbles], a 
	ld [NewRecTime], a 		; init these bss vars as 0 for no new record 
	
	call Stats_SaveRecords
	
	; clear window 
	ld b, 1 
	call ClearMap 
	
	ld a, 1 
	ld [ROM_BANK_WRITE_ADDR], a 
	
	; "The End" 
	ld b, 6
	ld c, 2 
	ld d, 1 
	ld hl, StringTheEnd
	call WriteText 
	
	; "Bubbles: " 
	ld b, 2
	ld c, 6 
	ld d, 1 
	ld hl, StringBubbles
	call WriteText 
	
	; "Time: "
	ld b, 2
	ld c, 9 
	ld d, 1 
	ld hl, StringTime
	call WriteText 
	
	; "Created by"
	ld b, 1
	ld c, 14
	ld d, 1 
	ld hl, StringCredit0
	call WriteText 
	
	; "Martin Holtkamp"
	ld b, 4 
	ld c, 16 
	ld d, 1 
	ld hl, StringCredit1
	call WriteText 
	
	; Write Bubbles 
	ld a, [PlayerBubbles]
	and $f0 
	swap a 
	ld d, a 
	ld a, NUMBER_TILES_INDEX
	add a, d 
	ld [$9CCB], a 
	
	ld a, [PlayerBubbles]
	and $0f
	ld d, a 
	ld a, NUMBER_TILES_INDEX
	add a, d 
	ld [$9CCC], a 
	
	; Write Time 
	ld a, [PlayTime]
	and $f0 
	swap a 
	ld d, a 
	ld a, NUMBER_TILES_INDEX
	add a, d 
	ld [$9D28], a 
	ld a, [PlayTime]
	and $0f  
	ld d, a 
	ld a, NUMBER_TILES_INDEX
	add a, d 
	ld [$9D29], a 
	ld a, [PlayTime+1]
	and $f0 
	swap a 
	ld d, a 
	ld a, NUMBER_TILES_INDEX
	add a, d 
	ld [$9D2A], a 
	ld a, [PlayTime+1]
	and $0f  
	ld d, a 
	ld a, NUMBER_TILES_INDEX
	add a, d 
	ld [$9D2B], a 
	
	; Set window x/y
	ld a, FINALE_WINDOW_Y_POS
	ld [rWY], a 
	ld a, FINALE_WINDOW_X_POS 
	ld [rWX], a 
	
	; Disable sprites 
	ld hl, rLCDC 
	res 1, [hl]
	
	ret 