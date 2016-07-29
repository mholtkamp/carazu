INCLUDE "include/stats.inc"
INCLUDE "include/player.inc"
INCLUDE "include/font.inc"
INCLUDE "include/constants.inc"


STATS_WINDOW_Y_POS EQU 136 
STATS_WINDOW_X_POS EQU WINDOW_X_OFFSET
BUBBLE_TILE_INDEX EQU (SPECIAL_TILES_INDEX + 10)
HEART_TILE_INDEX EQU (SPECIAL_TILES_INDEX + 11) 
	SECTION "StatsVariables", BSS 

PlayerHearts:
DS 1 
PlayerBubbles: 
DS 1 

HeartEntries:
DS 3
BubbleEntries
DS 2 


	SECTION "StatsProcs", HOME 
	
Stats_Reset::
	; Should be called when starting a new game
	ld a, MAX_HEARTS 
	ld [PlayerHearts], a 
	ld a, 0 
	ld [PlayerBubbles], a 

	ret 
	
Stats_LoadFromSave::

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
	
	; Enable window in lcdc 
	ld hl, rLCDC
	set 6, [hl]
	set 5, [hl]
	
	ret 
