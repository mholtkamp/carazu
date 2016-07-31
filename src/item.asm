INCLUDE "include/item.inc"
INCLUDE "include/globals.inc"
INCLUDE "include/constants.inc"
INCLUDE "include/util.inc"
INCLUDE "include/level.inc"

INCLUDE "tiles/item_tiles.inc"



ITEM_DATA_SIZE EQU 8
ITEM_INACTIVE EQU 0 
ITEM_ACTIVE EQU 1 

; Item Type
;   Type: 1 byte 
;      X: 1 byte 
;      Y: 1 byte 
; Active: 1 byte 
;  RectX: 1 byte 
;  RectY: 1 byte 
;  RectW: 1 byte 
;  RectH: 1 byte 


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

TileRect:
DS 4 
PixelRect:
DS 4  
CurItem:
DS 2 
CurItemNum:
DS 1

TileX:
DS 1 
TileY:
DS 1 

CurRectX:
DS 1 
CurRectY:
DS 1 

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
	inc de 
	inc de 
	inc de 
	inc de 
	inc de 		; These 5 extra inc des are needed to point to next item struct. item list only contains TYPE,X,Y and nothing else.
	
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

	ld hl, Items 
	ld a, 0 
	ld [CurItemNum], a 
	
.loop 
	ld a, h 
	ld [CurItem], a 
	ld a, l 
	ld [CurItem+1], a 		; save current item being examined
	
	ld a, [hl+]
	ld d, a 	; d = type 
	cp ITEM_NONE
	jp z, .continue_none

	ld a, [hl+]
	ld [TileRect], a 
	ld a, [hl+]
	ld [TileRect+1], a 
	ld a, [hl+]
	ld e, a 	; e = active
	ld a, [hl+]
	ld [PixelRect], a 
	ld a, [hl+]
	ld [PixelRect+1], a 
	ld a, [hl+]
	ld [PixelRect+2], a 
	ld a, [hl+]
	ld [PixelRect+3], a 
	
	; determine tile rect width/height based on item number 
	ld a, d 
	cp ITEM_SECRET_1
	jp nc, .large_dim
	ld a, 1 
	ld [TileRect+2], a 
	ld [TileRect+3], a 
	jp .check_active
.large_dim
	ld a, 2 
	ld [TileRect+2], a 
	ld [TileRect+3], a 
	
.check_active 
	ld a, e 
	cp ITEM_ACTIVE
	jp z, .update_active_item
	jp .update_inactive_item
	
.update_active_item
	push hl
	
	; (1), check if item is outside the screen rect. if so call Item_Deactivate and continue
	ld hl, TileRect
	ld de, ScreenRect
	call RectOverlapsRect_Int

	cp 1
	jp z, .check_player_overlap

	ld a, [CurItem]
	ld h, a 
	ld a, [CurItem+1]
	ld l, a 				; hl = cur item 
	ld a, [CurItem]
	ld e, a 
	call Item_Deactivate 
	jp .update_active_item_end 	; no need to check pixel overlap 

.check_player_overlap
	; (2) if still in screen rec, check if item overlaps player rect. If so call Item_Consume 
	ld hl, PixelRect
	ld de, PlayerRect 
	call RectOverlapsRect_Int
	cp 1 
	jp nz, .update_active_item_end 
	
	ld a, [CurItem]
	ld h, a 
	ld a, [CurItem+1]
	ld l, a 
	call Item_Consume
	
.update_active_item_end
	ld a, [CurItem]
	ld h, a 
	ld a, [CurItem+1]
	ld l, a 
	ld a, [CurItemNum]
	ld e, a 
	call Item_SyncOBJs
	
	pop hl 				; restore the item struct pointer 
	jp .continue

.update_inactive_item
	push hl 
	; (1) check if item inside screen rect. if so, call Item_Activate
	ld hl, TileRect
	ld de, ScreenRect
	call RectOverlapsRect_Int
	cp 1
	jp nz, .update_inactive_item_end 
	
	ld a, [CurItem]
	ld h, a 
	ld a, [CurItem+1]
	ld l, a 
	call Item_Activate

.update_inactive_item_end 
	ld a, [CurItem]
	ld h, a 
	ld a, [CurItem+1]
	ld l, a 
	ld a, [CurItemNum]
	ld e, a 
	call Item_SyncOBJs
	
	pop hl 
	jp .continue 

.continue_none 
	inc hl 
	inc hl 		
	inc hl 
	inc hl 
	inc hl 
	inc hl 
	inc hl ; increment pointer to point at next item struct 
.continue 
	ld a, [CurItemNum]
	inc a 
	ld [CurItemNum], a 	; save new item num for next loop. 
	cp MAX_ITEMS		; check if we already iterated through every item 
	jp nz, .loop  
	
	ret 
	
Item_Activate::
	ld b, [hl]		; B RESERVED FOR ITEM TYPE 
	inc hl 	; now points at tile x
	ld a, [hl]
	ld [TileX], a 
	inc hl  ; now points at tile y 
	ld a, [hl]
	ld [TileY], a 
	inc hl  ; now points at active 
	ld a, ITEM_ACTIVE
	ld [hl], a 
	inc hl ; now points at (pixel) RectX
	
	; Find the x/y coordinates of the item rect 
	ld a, [MapOriginX]
	ld d, a 
	ld a, [TileX]
	sub d 			; a = tilex - originx 
	sla a 
	sla a 
	sla a 			; a = (tilex - originx)*8
	ld d, a 
	ld a, [BGFocusPixelsX]
	add a, d 		; add the pixel offset. a = rectx 
	ld [hl+], a 	; save rectx
	
	ld a, [MapOriginY]
	ld d, a 
	ld a, [TileY]
	sub d 
	sla a 
	sla a
	sla a 
	ld d, a 
	ld a, [BGFocusPixelsY]
	add a, d 
	ld [hl+], a 	; save recty 
	
	; Determine rect width/height of item based on item type 
	ld a, b 
	cp ITEM_SECRET_1
	jp nc, .big_item 
	ld a, 8
	ld [hl+], a 
	ld [hl+], a 
	ret
	
.big_item 
	ld a, 16 
	ld [hl+], a 
	ld [hl+], a 
	ret 

; hl = item pointer
; e = item num 
Item_Deactivate::
	; First, mark item as inactive 
	ld b, [hl] ; b = item type  
	inc hl 	; now points at x 
	inc hl 	; now points at y 
	inc hl  ; now points at active 
	ld a, ITEM_INACTIVE
	ld [hl], a 	; save item as inactive 
	
	; Second, depending on item type (and therefore size)
	; disable all associated objs by setting them to 0,0
	sla e 
	sla e 	; mult item number by 4 to get oam offset 
	ld d, 0 
	ld hl, LocalOAM + ITEM_OBJ_INDEX*4
	add hl, de 	; hl = obj y coord of interest 
	
	ld a, b 	; a = item type 
	cp ITEM_SECRET_1
	jp nc, .disable_objs_big_item
	; disable the single obj for a small item 
	ld a, 0 
	ld [hl+], a 	; obj y = 0
	ld [hl+], a 	; obj x = 0 
	ret 
	
.disable_objs_big_item
	; disable 4 objs for a big item 
	ld a, 0 
	ld [hl+], a 	; obj1 y = 0
	ld [hl+], a 	; obj1 x = 0 
	inc hl 
	inc hl 			; inc pointer to next obj 
	ld [hl+], a 	; obj2 y = 0
	ld [hl+], a 	; obj2 x = 0 
	inc hl 
	inc hl 			; inc pointer to next obj 
	ld [hl+], a 	; obj3 y = 0
	ld [hl+], a 	; obj3 x = 0 
	inc hl 
	inc hl 			; inc pointer to next obj 
	ld [hl+], a 	; obj4 y = 0
	ld [hl+], a 	; obj4 x = 0 
	inc hl 
	inc hl 			; inc pointer to next obj 
	ret 
	
Item_Consume::

	ret

; hl = item 
;  e = item num 
Item_SyncOBJs::

	; Sync objs with item rectx/recty if active
	ld a, [hl+]		; a = item type 
	ld b, a 		; B RESERVED FOR ITEM TYPE 
	cp ITEM_NONE 
	ret z
	
	inc hl 
	inc hl 
	ld a, [hl+]		; a = active 
	cp ITEM_INACTIVE
	ret z
	
	ld a, [hl+]
	ld [CurRectX], a 
	ld a, [hl+]
	ld [CurRectY], a 
	
	sla e
	sla e 		; mult item num by 4 to get obj offset 
	ld d, 0 
	
	; Item is active, so update objs 
	ld hl, LocalOAM + ITEM_OBJ_INDEX*4
	add hl, de 
	
	ld a, b 
	cp ITEM_SECRET_1
	jp nc, .big_item
	ld a, [CurRectY]
	add a, 16 	; add 16 y offset to sprite 
	ld [hl+], a 
	ld a, [CurRectX]
	add a, 8 	; add 8 x offset to sprite 
	ld [hl+], a 
	ret 
	
.big_item
	; obj 1 
	ld a, [CurRectY]
	add a, 16 	; add 16 y offset to sprite 
	ld [hl+], a 
	ld a, [CurRectX]
	add a, 8 	; add 8 x offset to sprite 
	ld [hl+], a 
	inc hl 
	inc hl 
	; obj 2 
	ld a, [CurRectY]
	add a, 24 	
	ld [hl+], a 
	ld a, [CurRectX]
	add a, 8 	
	ld [hl+], a 
	inc hl 
	inc hl 
	; obj 3 
	ld a, [CurRectY]
	add a, 16 	
	ld [hl+], a 
	ld a, [CurRectX]
	add a, 16 	
	ld [hl+], a 
	inc hl 
	inc hl 
	ld a, [CurRectY]
	add a, 24 	
	ld [hl+], a 
	ld a, [CurRectX]
	add a, 16 	
	ld [hl+], a 
	inc hl 
	inc hl 
	ret
	