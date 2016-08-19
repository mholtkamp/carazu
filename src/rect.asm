	INCLUDE "include/constants.inc"
	INCLUDE "include/level.inc"
	INCLUDE "include/rect.inc"
	INCLUDE "include/globals.inc"

COLLIDED_LEFT      EQU $01
COLLIDED_RIGHT     EQU $02 
COLLIDED_UP        EQU $04
COLLIDED_DOWN      EQU $08

SECTION "UtilData", BSS

fRectX:
DS 2 
fRectY:
DS 2
RectX:
DS 1 
RectY:
DS 1 
RectWidth:
DS 1
RectHeight:
DS 1 

Rect2X:
DS 1 
Rect2Y:
DS 1 
Rect2Width:
DS 1 
Rect2Height:
DS 1 

fXDisp:
DS 2
fYDisp:
DS 2

CollisionThreshold:
DS 1

CollisionBitfield:
DS 1

IntRect:
DS 4 

Scratch:
DS 4




SECTION "MoveRect_Fixed", HOME 

; MoveRect_Fixed 
; input: 
;   hl = rect address
;   bc  = x-displacement component
;   de  = y-displacement component
;   a  = collision threshold
; output:
; 	 e = collision bitfield
;		 BIT_COLLIDED_LEFT  0
;		 BIT_COLLIDED_RIGHT 1 
;		 BIT_COLLIDED_UP    2
;		 BIT_COLLIDED_DOWN  3
MoveRect_Fixed::

	; Save data needed later on 
	; save the rect location for after the subroutine is finished
	
	ld [CollisionThreshold], a 
	
	; switch to correct rom bank 
	ld a, [MapBank]
	ld [ROM_BANK_WRITE_ADDR], a 
	
	push hl 
	ld a, [hl+]
	ld [fRectX], a 
	ld a, [hl+]
	ld [fRectX + 1], a 
	ld a, [hl+]
	ld [fRectY], a 
	ld a, [hl+]
	ld [fRectY + 1], a 
	ld a, [hl+]
	ld [RectWidth], a 
	ld a, [hl+]
	ld [RectHeight], a 

	ld a, b 
	ld [fXDisp], a
	ld a, c
	ld [fXDisp + 1], a 
	ld a, d  
	ld [fYDisp], a 
	ld a, e 
	ld [fYDisp + 1], a 
	
	; clear output
	ld a, 0
	ld [CollisionBitfield], a 
	
.move_x
	; check if there is any x displacement
	ld a, [fXDisp]	
	ld b, a 		   ; a = x-displacement high 
	ld a, [fXDisp + 1] ; a = x-displacement low 
	or b 			   ; any bits in either high or low?
	jp z, .move_y   ; not moving x, so move y 
	
	; Move the rect's x coord 
	ld a, [fRectX]
	ld b, a 		; b = fRectX high 
	ld a, [fRectX + 1]
	ld c, a 		; c = fRectX low 
	
	ld a, [fXDisp]
	ld h, a 		; h = fDispX high 
	ld a, [fXDisp + 1]
	ld l, a         ; l = fDispX low 
	
	add hl, bc		; a = rect.x + x-disp = new x position 
	ld c, h 		; c = integer part of new x-position 
	ld a, h 
	ld [fRectX], a 	; store integer part of new x-position 
	ld a, l 
	ld [fRectX + 1], a ;store fractional part of new x-position 
	
	; Offset the xposition used in collision to match BG scroll 
	ld a, [BGFocusPixelsX]
	add a, c 
	ld c, a 		; c = new rect x position (with scroll offset)
	
	; If moving right, then add rect.width to the x coord 
	ld a, [fXDisp]	; a = integer part of xdisp
	bit 7, a 		; is x-disp negative?
	jp nz, .use_x_pos
	ld a, [RectWidth]		; a = rect.width 
	sub 1 			; subtract 1 to get the last pixel on right 
	add a, c 		; c = rect.x + rect.width - 1
	ld c, a 		; set c to the x-pos being examined
	
.use_x_pos	
	
	; Retrieve the rect's y position (for indexing VRAM)
	ld a, [fRectY] 	; a = rect.y (integer) 
	ld b, a 
	ld a, [BGFocusPixelsY]
	add a, b 				; a = rect.y + pixelsY  
	
	call _MultMapWidth
	
	; Add the x tile index to get the specific map entry we need 
	; Divide by 8 to get x tile coord 
	ld b, 0
	srl c 
	srl c 
	srl c 
	add hl, bc
	ld a, c 				; save the x-tile offset for later 
	ld [Scratch + 2], a 
	ld a, [MapAddress]
	ld b, a 
	ld a, [MapAddress + 1]
	ld c, a 
	add hl, bc          

	; add origin index to get absolute map entry address 
	ld a, [MapOriginIndex]
	ld b, a 
	ld a, [MapOriginIndex + 1]
	ld c, a 
	add hl, bc 				; absolute tile addess in rom memory
	
	; set counter variable in d 
	ld a, [RectHeight]
	sub 1 
	ld d, a 
	
.loop0 
	ld a, [CollisionThreshold]
	ld b, a 
	
	ld a, [hl]		    ; Get the entry value
		
	; Compare the entry value with the collision threshold 
	; if the value is less than threshold, we need to handle collision 
	 
	cp b 
	jp c, .handle_collision_x	; hit a collision tile, go handle it 
	
	; check whether to do next loop 
	ld a, d 
	sub 8 				; decrement loop variable 
	jp c, .check_y_plus_height 
	ld d, a 			; save loop var 
	ld b, 0
	ld a, [MapWidth]
	ld c, a 
	add hl, bc  		; add MapWidth to hl to get next tile to check (1 row = MapWidth)
	jp .loop0
	
.check_y_plus_height
	;check the tile collision for point rect.y + rect.height 
	; this might do a redundant check 
	ld a, [RectHeight]
	sub 1 
	ld b, a 			; b = rect.height  - 1 
	ld a, [fRectY]		; a = rect.y (integer)

	add a, b 			; a = rect.y + rect.height - 1 
	ld b, a 
	ld a, [BGFocusPixelsY]
	add a, b 			; a = rect.y + rect.height - 1 + pixelsY  
	
	;mult by 4 to get tile index 
	call _MultMapWidth

	ld a, [Scratch + 2]		; retrieve that x-tile coord from earlier
	ld b, 0 
	ld c, a 			; bc = x-tile coord 

	add hl, bc 
	ld  b, h 
	ld  c, l   			; bc now has x+y tile offset 
	
	ld a, [MapAddress]
	ld h, a 
	ld a, [MapAddress + 1]
	ld l, a 
	add hl, bc 		
	
	; add origin index to get absolute map entry address 
	ld a, [MapOriginIndex]
	ld b, a 
	ld a, [MapOriginIndex + 1]
	ld c, a 
	add hl, bc 				; absolute tile addess in rom memory
	
	ld a, [CollisionThreshold]
	ld b, a
	ld a, [hl]			; a = map entry val 
	
	cp b 						; if entry is less than threshold 
	jp c, .handle_collision_x	; it's a collision tile so handle it 

	jp .move_y 					; no collision tile, so move in Y dir now 
	
.handle_collision_x
	
	ld a, [fXDisp]		; Get the original x disp (integer)
	bit 7, a 			; is x-disp negative 
	jp z, .resolve_move_right
	
.resolve_move_left 
	ld a, [CollisionBitfield]
	or COLLIDED_LEFT
	ld [CollisionBitfield], a 	; update output bitfield
	ld a, [fRectX]			; Get the rect.x coord (where it is colliding)
	ld b, a 
	ld a, [BGFocusPixelsX]
	ld d, a 
	add a, b 			; a = rect.x + focuspixelsX
	add a, 8			; add 8 to the rect x position (cancel out movement to left)
	and $f8  			; zero out lower 3 bits to snap it to the tile 
	sub d 				; subtract the pixels scroll 
	ld [fRectX], a
	ld a, 0 
	ld [fRectX + 1], a  ; zero-out fractional part 
	jp .move_y 			; now attempt moving in y direction 
	
.resolve_move_right
	ld a, [CollisionBitfield]
	or COLLIDED_RIGHT
	ld [CollisionBitfield], a 	; update output bitfield
	ld a, [RectWidth]
	sub 1 				
	ld b, a 			; b = rect.width - 1
	ld a, [fRectX]       ; a = rect.x (integer)

	add a, b 			; a = rect.width + rect.x 
	ld c, a 			; c = rect.width + rect.x 
	ld a, [BGFocusPixelsX]
	ld d, a 			; d = focuspixelsx
	add a, c 			; a = rect.width + rect.x + focuspixelsX 
	and $f8				; snap to the tile boundary
	sub 1 				; push back one pixel from the collided tile 
	sub b				; subtract result by rect.width to get the resolved x position 
	sub d 
	ld [fRectX], a 		; save the resolved x coord 
	ld a, 0 
	ld [fRectX + 1], a 	; zero out fractional part 
	
.move_y
	ld a, [fYDisp]   
	ld b, a 			; b = y-displacement (integer)
	ld a, [fYDisp + 1] 	; a = y-displacement (fractional)
	or b 				; is either integer or fractional part non-zero?
	jp z, .return	; no movement in y direction, so return. nothing else to do
	
	; Move the rect's y coord 
	ld a, [fRectY]
	ld b, a 		; b = rect.y (integer)
	ld a, [fRectY + 1]
	ld c, a 		; c = rect.y (fractional)
	
	ld a, [fYDisp]	
	ld h, a 		; h = ydisp (integer)
	ld a, [fYDisp + 1]
	ld l, a 		; l = ydisp (fractional)
	
	add hl, bc 		; get the new y position
	ld  c, h		; store integer part of new y pos in c  
	ld  a, h 		
	ld [fRectY], a   ; save that new y position in rect structure	
	ld  a, l 
	ld [fRectY + 1], a ;save fractional part of new pos in rect 
	
	; figure out if object is moving down or up 
	ld a, [fYDisp]
	bit 7, a   		; Check if y move dir is pos or neg 
	jp nz, .use_y_pos 
	ld a, [RectHeight]
	sub 1
	ld b, a 		; b = rect.height - 1
	ld a, c			; a = rect.y 
	add a, b 		; a = rect.y + rect.height - 1
	
	ld c, a			; c = rect.y + rect.height - 1 (coordinate of interest)
	
.use_y_pos
	
	; mask and multiply by 4 to get VRAM index 
	ld a, [BGFocusPixelsY]
	add a, c 
	call _MultMapWidth
	
	; prepare for looping collision check 
	ld a, [MapAddress]
	ld b, a 
	ld a, [MapAddress + 1]
	ld c, a 
	add hl, bc 			; hl = address of row to examine 
	
	; add origin index to get absolute map entry address 
	ld a, [MapOriginIndex]
	ld b, a 
	ld a, [MapOriginIndex + 1]
	ld c, a 
	add hl, bc 				; absolute tile addess in rom memory
	
	; save row address for later 
	ld a, h 
	ld [Scratch], a 
	ld a, l
	ld [Scratch + 1], a 
	
	ld a, [fRectX]		
	ld c, a 			; c = rect. x
	
	; Offset the xposition used in collision to match BG scroll 
	ld a, [BGFocusPixelsX]
	add a, c 
	ld c, a 		; c = new rect x position (with scroll offset)
	ld b, 0 			
	
	srl c 
	srl c
	srl c 				; divide rect.x by 8 to get x tile-coord (column num)
	add hl, bc 			; add x tile coord to hl to get address of tile under inspection
	
	; get rect width to determine how many times to loop 
	ld a, [RectWidth]
	sub 1 		
	ld d, a 		
	
.loop1 
	ld a, [CollisionThreshold]	
	ld b, a 					; b = collision threshold 
	ld a, [hl]					; get map entry value 
	
	cp b 						; value - threshold ?
	jp c, .handle_collision_y 	; the collision threshold is bigger than the map value. go handle collision 
	
	; prepare for next iteration of loop 
	ld a, d		; a = loop counter  
	sub 8 		; subtract 8 to see if we are past width of tile 
	jp c, .check_x_plus_width ; if counter is now < 0, go check the right-most point of rect 
	ld d, a 	; save loop counter value 	
	inc hl 		; set address to tile in next column 
	jp .loop1 
	
.check_x_plus_width
	ld a, [RectWidth]
	sub 1 
	ld b, a 		; b = rect.width -  1
	ld a, [fRectX]	; a = rect.x 
	add a, b 	; a = rect.x + rect.width - 1 
	ld b, a 	; b = rect.x + rect.width - 1 
	
	; Offset the xposition used in collision to match BG scroll 
	ld a, [BGFocusPixelsX]
	add a, b 
	
	srl a
	srl a
	srl a		; divide x coord by 8 to get tile coord
	ld b, 0 
	ld c, a 	; c = column offset 
	
	; get the first row's map entry address 
	ld a, [Scratch]
	ld h, a 
	ld a, [Scratch +  1]
	ld l, a 
	
	add hl, bc 	; find the tile address needing to be examined 
	
	ld a, [CollisionThreshold]
	ld b, a 	; b = threshold
	ld a, [hl] 	; get tile value 
	
	cp b 		; val - threshold ?
	jp c, .handle_collision_y
	jp .return
	
.handle_collision_y

	; figure out direction moving 
	ld a, [fYDisp]	; a = y-disp 
	bit 7,a 		; is the number negative?
	jp z, .resolve_move_down ;jump to the negative movement code 

.resolve_move_up
	ld a, [CollisionBitfield]
	or COLLIDED_UP
	ld [CollisionBitfield], a 	; update output bitfield
	ld a, [fRectY]		; a = rect.y 
	ld b, a 
	ld a, [BGFocusPixelsY]
	ld c, a 
	add a, b 
	add a, 8 		; move down 1 tile 
	and $f8			; snap to the new tile 
	sub c 			; subtract pixelsY
	ld [fRectY], a 	; save rectified position 
	ld a, 0 
	ld [fRectY + 1], a ;zero out fractional part 
	jp .return
	
.resolve_move_down
	ld a, [CollisionBitfield]
	or COLLIDED_DOWN
	ld [CollisionBitfield], a 	; update output bitfield
	ld a, [RectHeight]
	sub 1 
	ld b, a 			; b = rect.height - 1 
	ld a, [fRectY] 		; a = rect.y 	
	add a, b 		; a = rect.y + rect.height - 1 (position of interest)
	ld c, a 
	ld a, [BGFocusPixelsY]
	ld d, a 		; d = pixelsY 
	add a, c 		; a =  rect.y + rect.height - 1 + pixelsY 
	
	and $f8			; snap to the collision tile 
	sub 1 			; move up one pixel (to be in a non-colliding tile)
	sub b			; subtract height - 1 
	sub d 			; subtract pixelsY to get resolved y-coord 
	ld [fRectY], a 	; save new y coord 
	ld a, 0 
	ld [fRectY + 1], a ;zero-out fractional component
	
.return 	
	;Final step is to save rect data to actual address 
	pop hl 			; hl = rect address 
	ld a, [fRectX]
	ld [hl+], a 	; store rect.x 
	ld a, [fRectX + 1]
	ld [hl+], a 
	ld a, [fRectY]	
	ld [hl+], a 	; store rect.y 
	ld a, [fRectY + 1]
	ld [hl+], a 
	ld a, [RectWidth]
	ld [hl+], a 	; store rect.width 
	ld a, [RectHeight]
	ld [hl+], a 	; store rect.height 
	
	; set output register 
	ld a, [CollisionBitfield]
	
	ret 
	
; CheckRectGrounded
; input:
;   hl - rect 	
;    a - collision threshold 
; output:
;	a - 1 if grounded, 0 otherwise 
CheckRectGrounded_Fixed::

	; save collision threshold
	ld [CollisionThreshold], a 
	
	; switch to correct rom bank 
	ld a, [MapBank]
	ld [ROM_BANK_WRITE_ADDR], a 
	
	; save rect data 
	ld a, [hl+]
	ld [RectX], a 
	inc hl 
	ld a, [hl+]
	ld [RectY], a 
	inc hl 
	ld a, [hl+]
	ld [RectWidth], a 
	ld a, [hl]
	ld [RectHeight], a 
	
	; First duty is to find the tile row we need to examine
	; so get y coord and divide by 8, then mult by 32 
	ld a, [RectY]
	ld b, a 
	ld a, [RectHeight]
	add a, b 				; a = y-pixel coord to examine (do not sub height by 1 as we need to get the pixel just below the rect)
	ld b, a 
	ld a, [BGFocusPixelsY]
	add a, b 

	call _MultMapWidth
	
	ld a, [MapAddress]
	ld b, a 
	ld a, [MapAddress + 1]
	ld c, a 
	add hl, bc 					; hl = row address 
	
	; add origin index to get absolute map entry address 
	ld a, [MapOriginIndex]
	ld b, a 
	ld a, [MapOriginIndex + 1]
	ld c, a 
	add hl, bc 				
	
	; find the end tile x tile-coords
	ld a, [RectX]
	ld c, a 
	ld a, [RectWidth]
	sub 1				
	add a, c 			
	ld c, a			    ; c = end pixel coords
	ld a, [BGFocusPixelsX]
	add a, c 
	ld c, a 
	srl c 
	srl c 
	srl c 				; c = end x tile coord
	
	; find first tile coords 
	ld a, [RectX]
	ld b, a 			; b = start pixel coords
	ld a, [BGFocusPixelsX]
	add a, b 
	ld b, a 
	srl b 
	srl b 
	srl b 				; b = start x tile coord
	
	ld a, c 
	sub b 				
	add a, 1 
	ld d, a 			; d = number of times to loop ((end tile - start tile) + 1)
	
	ld c, b 
	ld b, 0 			; bc = start x-tile coord 
	
	add hl, bc 			; hl = starting tile address in vram map 0 
	
	; load the collision threshold for loop 
	ld a, [CollisionThreshold]
	ld b, a 
	
.loop 

	ld a, [hl] 
	cp b 			; is the tile a collision tile 
	jp nc, .continue
	
	; tile value is under collision threshold so set a to 1 (grounded)
	; and return 
	ld a, 1 
	ret
	
.continue 
	dec d 
	jp z, .return_not_grounded 
	
	; still more tiles to check so increment tile address
	; and continue the loop 
	inc hl 
	jp .loop 
	
.return_not_grounded
	ld a, 0 
	ret 


SECTION "UtilData", BSS

SpriteFlip: DS 1  
SpriteIndex: DS 1 
SpritePattern: DS 1 
SpriteCharWidth: DS 1 
SpriteCharHeight: DS 1 
RectOffsetX: DS 1 
RectOffsetY: DS 1 
OAMAddress: DS 2 
RectAddress: DS 2 


SECTION "UpdateOAMFromRect_Fixed", HOME 
; UpdateOAMFromRect_2x2
;   hl = [Rect Address]  
;	b = sprite tile pattern index 
;   c = oam index 
;   d = Rect Offset X
;   e = Rect Offset Y
;   a = flip x 
UpdateOAMFromRect_2x2::

	; save params 
	ld [SpriteFlip], a 		
	
	ld a, d 
	ld [RectOffsetX], a 
	ld a, e 
	ld [RectOffsetY], a 
	
	ld a, b 
	ld [SpritePattern], a 
	ld a, c 
	ld [SpriteIndex], a 
	
	ld a, [hl+]
	ld [RectX], a 
	inc hl 
	ld a, [hl]
	ld [RectY], a		; Rect width / height not needed 
	
	; Now to actually begin the subroutine. Use a nested loop to iterate 
	; through sprite objs, starting with top left obj.
	
	; Get the starting OAM address
	ld hl, LocalOAM 

	ld a, [SpriteIndex]
	ld c, a 
	sla c 
	sla c 			; multiply by 4 to get OAM address offset 
	ld b, 0 
	
	add hl, bc 			; hl = OAM address of first OBJ to edit (upper-left tile)
	
	ld a, [RectOffsetY]
	ld c, a 
	ld a, [RectY] 
	sub c 
	add a, 16 			; add 16 to get the sprite y coordinates (x = 8, y = 16: top left pixel on screen)
	ld c, a 			; c = obj y-coordinate  
	ld [Scratch], a 	; save the top most obj y-coordinate
	
	ld a, [RectOffsetX]
	ld b, a 
	ld a, [RectX]
	sub b 
	add a, 8 			; get obj x-coordinate 
	ld b, a 			; b = obj x-coordinate 
	
	
	; figure out which loop to run based on flip values 
	ld a, [SpriteFlip]
	cp 1
	jp z, .flip_x 
	jp .no_flip 
	
	
.no_flip 

	; Get patten index for first sprite 
	; no flip = start from first pattern
	ld a, [SpritePattern]
	ld d, a 
	
	; top-left 
	ld a, c 
	ld [hl+], a 		; save y coord 
	ld a, b 
	ld [hl+], a 		; save x coord 
	ld a, d 
	ld [hl+], a 		; save pattern 
	ld a, 0 
	ld [hl+], a 		; no flip 
	
	inc d 
	
	; bottom-left 
	ld a, c 
	add a, 8 
	ld [hl+], a 		
	ld a, b 
	ld [hl+], a 
	ld a, d 
	ld [hl+], a 
	ld a, 0 
	ld [hl+], a 	
	
	inc d  
	
	; top-right 
	ld a, c 
	ld [hl+], a 
	ld a, b 
	add a, 8 
	ld [hl+], a 
	ld a, d
	ld [hl+], a 
	ld a, 0 
	ld [hl+], a 
	
	inc d 
	
	; bottom-right 
	ld a, c 
	add a, 8 
	ld [hl+], a 
	ld a, b 
	add a, 8 
	ld [hl+], a 
	ld a, d 
	ld [hl+], a 
	ld a, 0 
	ld [hl+], a 
	
	ret 
	
	
.flip_x 
	; Get patten index for first sprite 
	; no flip = start from first pattern
	ld a, [SpritePattern]
	ld d, a 
	
	; top-left 
	ld a, c 
	ld [hl+], a 		; save y coord 
	ld a, b 
	ld [hl+], a 		; save x coord 
	ld a, d 
	add a, 2 
	ld [hl+], a 		; save pattern 
	ld a, $20 
	ld [hl+], a 		; no flip 
	
	; bottom-left 
	ld a, c 
	add a, 8 
	ld [hl+], a 		
	ld a, b 
	ld [hl+], a 
	ld a, d 
	add a, 3 
	ld [hl+], a 
	ld a, $20 
	ld [hl+], a 	

	; top-right 
	ld a, c 
	ld [hl+], a 
	ld a, b 
	add a, 8 
	ld [hl+], a 
	ld a, d
	ld [hl+], a 
	ld a, $20 
	ld [hl+], a 
	
	; bottom-right 
	ld a, c 
	add a, 8 
	ld [hl+], a 
	ld a, b 
	add a, 8 
	ld [hl+], a 
	ld a, d 
	inc a 
	ld [hl+], a 
	ld a, $20 
	ld [hl+], a 
	
	ret 
	
;	a = y-block 	
; a/b/h/l are overwritten 
_MultMapWidth::
	ld b, a 
	and $f8 
	ld h, b 
	ld l, a 
	
	ld a, [MapWidth]
	
	bit 5, a 
	jp nz, .mult_32
	bit 6, a 
	jp nz, .mult_64
	bit 7, a 
	jp nz, .mult_128
	; else treat map as 256 width (max width)
	jp nz, .mult_256
	
.mult_32 
	;shift left 2 
	srl h 
	srl h 
	srl h 
	srl h 
	srl h 
	srl h 
	sla l 
	sla l 
	ret 
	
.mult_64 
	;shift left 3  
	srl h 
	srl h 
	srl h 
	srl h 
	srl h 
	sla l 
	sla l 
	sla l 
	ret 
	
.mult_128 
	;shift left 4  
	srl h 
	srl h 
	srl h 
	srl h 
	sla l  
	sla l 
	sla l 
	sla l 
	ret 
	
.mult_256 
	; shift left 5 
	srl h 
	srl h 
	srl h 
	sla l  
	sla l  
	sla l 
	sla l 
	sla l 
	ret 
	
; hl = rect address 
Rect_CheckSpecials::

	; switch to correct rom bank 
	ld a, [MapBank]
	ld [ROM_BANK_WRITE_ADDR], a 

	; Save rect data 
	ld a, [hl+]
	ld [fRectX], a 
	ld a, [hl+]
	ld [fRectX + 1], a 
	ld a, [hl+]
	ld [fRectY], a 
	ld a, [hl+]
	ld [fRectY + 1], a 
	ld a, [hl+]
	ld [RectWidth], a 
	ld a, [hl+]
	ld [RectHeight], a 

	; Find tile in rom 
	; First duty is to find the tile row we need to examine
	; so get y coord and divide by 8, then mult by map width 
	ld a, [fRectY]
	ld b, a 
	ld a, [BGFocusPixelsY]
	add a, b 

	call _MultMapWidth
	
	ld a, [MapAddress]
	ld b, a 
	ld a, [MapAddress + 1]
	ld c, a 
	add hl, bc 					; hl = row address 

	; add origin index to get absolute map entry address 
	ld a, [MapOriginIndex]
	ld b, a 
	ld a, [MapOriginIndex + 1]
	ld c, a 
	add hl, bc 			

	; find the number of times to loop in vertical direction 
	; find the end y tile coords 
	ld a, [fRectY]
	ld c, a 
	ld a, [RectHeight]
	sub 1 
	add a, c 
	ld c, a 			; c = end pixel coords 
	ld a, [BGFocusPixelsY]
	add a, c 
	ld c, a 
	srl c 
	srl c 
	srl c 				; c = end y tile coords 
	
	; find the start y tile coords 
	ld a, [fRectY]
	ld b, a 			; b = start pixel coords
	ld a, [BGFocusPixelsY]
	add a, b 
	ld b, a 
	srl b 
	srl b 
	srl b 				; b = start y tile coord
	
	ld a, c 
	sub b 				
	add a, 1 
	ld e, a 			; e = number of times to loop per column ((end tile - start tile) + 1)
	
	; find the end tile x tile-coords
	ld a, [fRectX]
	ld c, a 
	ld a, [RectWidth]
	sub 1				
	add a, c 			
	ld c, a			    ; c = end pixel coords
	ld a, [BGFocusPixelsX]
	add a, c 
	ld c, a 
	srl c 
	srl c 
	srl c 				; c = end x tile coord
	
	; find first tile coords 
	ld a, [fRectX]
	ld b, a 			; b = start pixel coords
	ld a, [BGFocusPixelsX]
	add a, b 
	ld b, a 
	srl b 
	srl b 
	srl b 				; b = start x tile coord
	
	ld a, c 
	sub b 				
	add a, 1 
	ld d, a 			; d = number of times to loop per row ((end tile - start tile) + 1)
	ld [Scratch], a 	; Scratch = horizontal loop count 
	
	ld c, b 
	ld b, 0 			; bc = start x-tile coord 
	
	add hl, bc 			; hl = starting tile address in vram map 0 \
	
	ld b, 0 			; b will be the return special tile bitfield 
	
.loop 

	ld a, [hl+] 
	
	; Check for each special tile 
	cp SPECIAL_TILE_SPIKE_UP
	jp z, .set_spike
	cp SPECIAL_TILE_SPIKE_DOWN
	jp z, .set_spike 
	
	cp SPECIAL_TILE_SPRING_UP_1
	jp z, .set_spring_up
	cp SPECIAL_TILE_SPRING_UP_2
	jp z, .set_spring_up 
	
	cp SPECIAL_TILE_SPRING_RIGHT_1
	jp z, .set_spring_right 
	cp SPECIAL_TILE_SPRING_RIGHT_2
	jp z, .set_spring_right 
	
	cp SPECIAL_TILE_DOOR_2  
	jp z, .set_door 
	
	cp SPECIAL_TILE_SECRET_DOOR_2
	jp z, .set_secret_door 
	
	jp .continue 
	
.set_spike
	set BIT_SPIKE, b 
	jp .continue 
	
.set_spring_up 
	set BIT_SPRING_UP, b 
	jp .continue 

.set_spring_right
	set BIT_SPRING_RIGHT, b 
	jp .continue 
	
.set_door 
	set BIT_DOOR, b 
	jp .continue 
	
.set_secret_door
	set BIT_SECRET_DOOR, b 
	jp .continue
	
.continue 
	dec d 			; lower horizontal counter 
	jp nz, .loop 
	
	dec e 
	ret z			; return if finished checking all tiles 
	
	; prepare for next row loop 
	ld a, [Scratch]
	ld d, a 		; reset horizontal counter 
	
	ld a, l 
	sub d 
	ld l, a 
	ld a, h 
	sbc 0 
	ld h, a 		; subtract tile pointer by horizontal count to reset to first x tile 
	
	ld a, [MapWidth]
	ld c, a 
	ld a, l 
	add a, c 
	ld l, a 
	ld a, h 
	adc a, 0 
	ld h, a 		; add the map width to get the next row
	
	jp .loop 
	
	
; hl = rect 1 
; de = rect 2 
; ret: a = 1 if overlapping. 0 otherwise 
RectOverlapsRect_Int:

	ld a, [hl+]
	ld [RectX], a 
	ld a, [hl+]
	ld [RectY], a 
	ld a, [hl+]
	ld [RectWidth], a 
	ld a, [hl+]
	ld [RectHeight], a 
	
	ld a, [de]
	ld [Rect2X], a 
	inc de 
	ld a, [de]
	ld [Rect2Y], a 
	inc de 
	ld a, [de]
	ld [Rect2Width], a 
	inc de 
	ld a, [de]
	ld [Rect2Height], a 
	
	; x > x2 + width2 
	ld a, [RectX]
	ld c, a 
	
	ld a, [Rect2Width]
	sub 1 
	ld b, a 
	ld a, [Rect2X]
	add a, b 	; a = x2 + (width2 - 1) 
	cp c 		
	jp c, .return_false
	
	; x + width < x2 
	ld a, [Rect2X]
	ld c, a 
	
	ld a, [RectWidth] 
	sub 1 
	ld b, a 
	ld a, [RectX]
	add a, b 	; a = x + (width - 1)
	cp c
	jp c, .return_false
	
	; y > y2 + width2 
	ld a, [RectY]
	ld c, a 
	
	ld a, [Rect2Height]
	sub 1 
	ld b, a 
	ld a, [Rect2Y]
	add a, b 	; a = y2 + (height2 - 1) 
	cp c 		
	jp c, .return_false
	
	; y + height < y2 
	ld a, [Rect2Y]
	ld c, a 
	
	ld a, [RectHeight] 
	sub 1 
	ld b, a 
	ld a, [RectY]
	add a, b 	; a = y + (height - 1)
	cp c
	jp c, .return_false
	
.return_true 
	ld a, 1 
	ret 
	
.return_false 
	ld a, 0 
	ret 
	
; RectOverlapsRect_Fixed
; hl = rect1 
; de = rect2
; ret: a = 1 if overlap. 0 otherwise 
RectOverlapsRect_Fixed

	ld a, [hl+]
	ld [RectX], a 
	inc hl 
	ld a, [hl+]
	ld [RectY], a 
	inc hl 
	ld a, [hl+]
	sub 1 
	ld [RectWidth], a 
	ld a, [hl+]
	sub 1 
	ld [RectHeight], a 
	
	ld a, [de]
	ld [Rect2X], a 
	inc de 
	inc de 
	ld a, [de]
	ld [Rect2Y], a 
	inc de 
	inc de 
	ld a, [de]
	sub 1 
	ld [Rect2Width], a 
	inc de 
	ld a, [de]
	sub 1 
	ld [Rect2Height], a 
	
	; x > x2 + width2 
	ld a, [RectX]
	ld c, a 
	
	ld a, [Rect2Width]
	ld b, a 
	ld a, [Rect2X]
	add a, b 	; a = x2 + (width2 - 1) 
	cp c 		
	jp c, .return_false
	
	; x + width < x2 
	ld a, [Rect2X]
	ld c, a 
	
	ld a, [RectWidth] 
	ld b, a 
	ld a, [RectX]
	add a, b 	; a = x + (width - 1)
	cp c
	jp c, .return_false
	
	; y > y2 + width2 
	ld a, [RectY]
	ld c, a 
	
	ld a, [Rect2Height]
	ld b, a 
	ld a, [Rect2Y]
	add a, b 	; a = y2 + (height2 - 1) 
	cp c 		
	jp c, .return_false
	
	; y + height < y2 
	ld a, [Rect2Y]
	ld c, a 
	
	ld a, [RectHeight] 
	ld b, a 
	ld a, [RectY]
	add a, b 	; a = y + (height - 1)
	cp c
	jp c, .return_false
	
.return_true 
	ld a, 1 
	ret 
	
.return_false 
	ld a, 0 
	ret 

	
RectOverlapsRect_Int_Fixed:
	ld a, [de]
	ld [IntRect], a 
	inc de 
	inc de 
	ld a, [de]
	ld [IntRect+1], a 
	inc de 
	inc de 
	ld a, [de]
	ld [IntRect+2],a 
	inc de 
	ld a, [de]
	ld [IntRect+3], a 
	ld de, IntRect 		; hl already set from caller 
	call RectOverlapsRect_Int
	; a holds overlap result.
	ret 