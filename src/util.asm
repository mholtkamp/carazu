INCLUDE "include/util.inc"
INCLUDE "include/constants.inc"

	SECTION "UtilVariables", BSS 
	
MapWidth:
DS 1
MapHeight:
DS 1 
Scratch:
DS 2 
	
	
	
	SECTION "UtilProcedures", HOME 
	
; hl = ROM tile address
; b  = 0: Sprite Tiles   1: BG Tiles 2: Shared 
; c  = Number of tiles to load 
; d  = rom bank 
; e  = tile index offset in vram 
LoadTiles::

	; Switch to the correct ROM bank first.
	ld a, d 
	ld [ROM_BANK_WRITE_ADDR], a 
	
	; Find the VRAM address based on tile index offset and sprite/tile 
	; multiply the index offset by 16 (aka shift left 4)
	; this swap method is simpler. probably faster than doing 8 shifts too.
	ld a, e
	swap a 
	and $0f
	ld d, a 
	ld a, e 
	swap a 
	and $f0 
	ld e, a 		; de = address offset 
	
	push hl 			; save rom address. need hl for an add 
	
	ld a, b 
	cp 0 
	jp z, .use_sprite_tile_address
	cp 1
	jr z, .use_bg_tile_address
	ld hl, TILE_BANK_SHARED
	jr .get_final_vram_addr
.use_bg_tile_address 
	ld hl, TILE_BANK_1
	jp .get_final_vram_addr 
.use_sprite_tile_address
	ld hl, TILE_BANK_0
.get_final_vram_addr
	add hl, de 
	ld d, h 
	ld e, l 
	pop hl 		; restore rom address 
	
	; source and destination are both known, now find the number of bytes
	; needed to be transfered. if speed was important, then maybe writing out
	; 16 invididual ld instructions per tile would be faster, but this proc
	; is meant to be called when the lcd is disabled, so speed isn't really important.
	ld a, c 
	swap a 
	and $0f 
	ld b, a 
	ld a, c 
	swap a
	and $f0 
	ld c, a 		; multiply numtiles by 16 to get num bytes (16 bytes per tile)
	
.loop
	ld a, [hl+]
	ld [de], a 
	inc de 
	dec bc 
	ld a, b 
	or c 
	jp nz, .loop 
	
	ret 
	
; LoadMap
; push0 = map width, map height 
; b = x tile offset (in vram)
; c = y tile offset (in vram)
; d = ROM bank 
; e = 0: Load into BG map, 1: Load into window map
; hl = rom map address 
LoadMap::

	; switch to proper rom bank 
	ld a, d 
	ld [ROM_BANK_WRITE_ADDR], a 
	
	; next step is to figure out starting vram address 
	ld a, e 
	cp 0 
	jp .use_bg_map
	ld de, MAP_1
	jp .get_vram_addr
.use_bg_map
	ld de, MAP_0
.get_vram_addr
	
	push hl 		; save rom map address 
	ld h, 0 
	ld l, b
	add hl, de		; add x offset contribution to dest address  
	
	ld b, c 
	sla c 
	sla c 
	sla c
	sla c 
	sla c 
	sra b 
	sra b 
	sra b
	add hl, bc 		; add y offset contribution to dest address 
	
	pop de 			; restore source address  (but put it in de now)
	
	; save return address 
	pop bc 
	ld a, b 
	ld [Scratch], a 
	ld a, c 
	ld [Scratch+1], a 
	
	pop bc 			; get param push0: width and height for counting 
	ld a, b 
	ld [MapWidth], a 
	ld a, c 
	ld [MapHeight], a 
.loop
	ld a, [de]
	ld [hl+], a 
	inc de 
	
	dec b
	jp nz, .loop 
	
	ld a, [MapWidth]
	ld b, a 			; reset bc counter 
	ld a, l 
	sub b 
	ld l, a 
	ld a, h 
	sbc 0 
	ld h, a 			; hl = hl - MapWidth 
	
	ld a, l 
	add a, 32 
	ld l, a 
	ld a, h 
	adc a, 0 
	ld h, a 			; hl = hl + 32. now pointing at next row 
	
	dec c 
	jp nz, .loop 
	
	ld a, [Scratch]
	ld b, a 
	ld a, [Scratch + 1]
	ld c, a 
	push bc 
	ret 
	

; hl = null-terminated text string 
; b = x tile pos 
; c = y tile pos 
; d = 0: BG, 1: Window 
WriteText::
	ld a, d 
	cp 0
	jp z, .write_to_bg
	ld de, MAP_1 
	jp .get_vram_addr
.write_to_bg
	ld de, MAP_0 
	
.get_vram_addr
	push hl 		; save string addr 
	ld h, 0 
	ld l, b
	add hl, de		; add x offset contribution to dest address  
	
	ld b, c 
	sla c 
	sla c 
	sla c
	sla c 
	sla c 
	sra b 
	sra b 
	sra b
	add hl, bc 		; add y offset contribution to dest address 
	
	pop de 			; restore string address 
	
	
.loop 
	ld a, [de]
	cp 0 
	ret z 
	
	add a, 32 			; map entry =  ascii val - ' ' + 64 
	add a, -128			; offset from negative start of full font 
	ld [hl+], a 
	inc de 
	jp .loop 
	
	
; b = vram map number. 0 = MAP_0     1 = MAP_1
ClearMap::

	ld a, b 
	cp 0 
	jp z, .map0
	ld hl, MAP_1 
	jp .clear 
.map0 
	ld hl, MAP_0 
.clear 
	ld bc, 32*32
	
.loop 
	ld a, 0 
	ld [hl+], a 
	dec bc 
	
	ld a, b 
	or c 
	jp nz, .loop 
	
	ret 
