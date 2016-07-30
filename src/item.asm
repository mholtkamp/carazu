INCLUDE "include/item.inc"
INCLUDE "include/globals.inc"
INCLUDE "include/constants.inc"
INCLUDE "include/util.inc"
INCLUDE "tiles/item_tiles.inc"


ITEM_DATA_SIZE EQU 3

; Item Type
; Type: 1 byte 
;    X: 1 byte 
;    Y: 1 byte 

	SECTION "ItemData", BSS 

Items:
Item0:
DS ITEM_DATA_SIZE
Item1:
DS ITEM_DATA_SIZE
Item2:
DS ITEM_DATA_SIZE
Item3:
DS ITEM_DATA_SIZE
Item4:
DS ITEM_DATA_SIZE
Item5:
DS ITEM_DATA_SIZE

Scratch:
DS 1 

	SECTION "ItemProcs", HOME 
	
Reset_Items::

	; Set all items to no item. clear x/y positions
	ld hl, Items 
	ld a, 0 			; 0 == ITEM_NONE btw 
	ld b, MAX_ITEMS * ITEM_DATA_SIZE
	
.loop0
	ld [hl+], a 
	dec b 
	jp nz, .loop0


	; Now reset all objs to off-screen coords 
	ld hl, LocalOAM + ITEM_OBJ_INDEX * 4
	ld b, MAX_ITEMS
	ld a, 0 
.loop1 
	ld [hl+], a 
	ld [hl+], a 
	inc hl 
	inc hl 
	
	dec b 
	jp nz, .loop1 
	
	ret 
	
; hl = pointer to item list 
Load_Items::
	; Sets the item type and x/y of all items for a level. 
	ld de, Items 	; initialize destination pointer 
	
	ld a, 0 
	ld [Scratch], a 	; [Scratch] = offset into oam 
	
.loop 
	ld a, [hl+]
	ld b, a 		; b = enemy type 
	
	; Check if done loading items 
	cp END_ITEM_LIST 
	ret z 
	
	; Save type 
	ld [de], a 
	inc de 
	; Save X
	ld [hl+], a 
	ld [de], a 
	inc de 
	; Save Y 
	ld [hl+], a 
	ld [de], a 
	inc de 
	
	; Get oam address to edit pattern number 
	push hl 	; save item list pointer 
	ld hl, LocalOAM + ITEM_OBJ_INDEX*4 + 2    ; +2 to get to pattern byte (3rd byte)
	ld a, [Scratch]
	cp MAX_ITEMS
	jp nc, .continue 		; obj counter is above max, dont do anything. 
	inc a 
	ld [Scratch], a 		; increment the counter 
	sla a 
	sla a 					; mult by 4 because each obj entry is 4 bytes 
	add a, l 
	ld l, a 
	ld a, h  
	adc a, 0
	ld h, a 				; hl = hl + a = first obj pattern to edit + 4*obj_counter = obj pattern byte to edit 
	
	; Load obj tile
	; NOTE: If the level has a rune or secret, then that should be the ONLY item in the level's item list 
	ld a, b 
	cp ITEM_HEART
	jp z, .obj_heart
	cp ITEM_BUBBLE 
	jp z, .obj_bubble 
	cp ITEM_SECRET_1
	jp z, .obj_secret_1 
	cp ITEM_SECRET_2 
	jp z, .obj_secret_2 
	cp ITEM_SECRET_3
	jp z, .obj_secret_3 
	cp ITEM_FERMATA_RUNE
	jp z, .obj_fermata_rune
	cp ITEM_BASS_RUNE
	jp z, .obj_bass_rune 
	cp ITEM_ALLEGRO_RUNE
	jp z, .obj_allegro_rune 
	
	; Item type unknown?
	jp .continue  
	
.obj_heart 
	ld a, ITEM_TILE_HEART
	ld [hl], a 
	jp .continue 
.obj_bubble 
	ld a, ITEM_TILE_BUBBLE 
	ld [hl], a 
	jp .continue 
.obj_secret_1 
	ld a, ITEM_TILE_SECRET_1
	jp .load_big_item
.obj_secret_2 
	ld a, ITEM_TILE_SECRET_2
	jp .load_big_item
.obj_secret_3 
	ld a, ITEM_TILE_SECRET_3
	jp .load_big_item
.obj_fermata_rune
	ld a, ITEM_TILE_FERMATA_RUNE
	jp .load_big_item
.obj_bass_rune
	ld a, ITEM_TILE_BASS_RUNE
	jp .load_big_item
.obj_allegro_rune
	ld a, ITEM_TILE_ALLEGRO_RUNE
	jp .load_big_item
	
	
.load_big_item
	ld [hl+], a 
	inc a 
	ld [hl+], a 
	inc a 
	ld [hl+], a 
	inc a 
	ld [hl], a 
	jp .continue 
	
.continue 
	pop hl 	; restore item list pointer 
	jp .loop 
	
	
Load_Item_Graphics::
	ld hl, ItemTiles
	ld b, 0 			; sprite tiles 
	ld c, 32    
	ld d, 0
	ld e, ITEM_TILES
	call LoadTiles
	ret 
	
Update_Items::

	; Check if any items 
	
	ret 
	
