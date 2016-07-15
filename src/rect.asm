	INCLUDE "include/constants.inc"
	INCLUDE "include/level.inc"

COLLIDED_LEFT      EQU $01
COLLIDED_RIGHT     EQU $02 
COLLIDED_UP        EQU $04
COLLIDED_DOWN      EQU $08

SECTION "UtilData", BSS

RectX:
DS 1 
RectY:
DS 1
RectWidth:
DS 1
RectHeight:
DS 1 

XDisp:
DS 1

YDisp:
DS 1

CollisionThreshold:
DS 1

CollisionBitfield:
DS 1

Scratch:
DS 4
 


SECTION "MoveRect_Integer", HOME

; MoveRect_Integer
; input:
;   hl = rect address
;   b  = x-displacement component
;   c  = y-displacement component
;   d  = collision threshold
; output:
; 	 e = collision bitfield
;		 BIT_COLLIDED_LEFT  0
;		 BIT_COLLIDED_RIGHT 1 
;		 BIT_COLLIDED_UP    2
;		 BIT_COLLIDED_DOWN  3
MoveRect_Integer::

	; Save data needed later on 
	; save the rect location for after the subroutine is finished
	push hl 
	ld a, [hl+]
	ld [RectX], a 
	ld a, [hl+]
	ld [RectY], a 
	ld a, [hl+]
	ld [RectWidth], a 
	ld a, [hl+]
	ld [RectHeight], a 

	ld a, b 
	ld [XDisp], a
	ld a, c 
	ld [YDisp], a 
	ld a, d 
	ld [CollisionThreshold], a
	
	; clear out return value 
	ld a, 0 
	ld [CollisionBitfield], a 
	
.move_x
	; check if there is any x displacement
	ld a, [XDisp]	; a = x-displacement 
	cp 0            ; is the desired x displacement 0?
	jp z, .move_y   ; not moving x, so move y 
	
	; Move the rect's x coord 
	ld a, [RectX]
	ld c, a 
	ld a, [XDisp]
	add a, c		; a = rect.x + x-disp = new x position 
	ld c, a 		; c = new position 
	ld [RectX], a 	; store new position in memory
	
	; If moving right, then add rect.width to the x coord 
	ld a, [XDisp]	; a = xdisp
	bit 7, a 		; is x-disp negative?
	jp nz, .use_x_pos
	ld a, [RectWidth]		; a = rect.width 
	sub 1 			; subtract 1 to get the last pixel on right 
	add a, c 		; c = rect.x + rect.width - 1
	ld c, a 		; set c to the x-pos being examined
	
.use_x_pos	
	
	; Retrieve the rect's y position (for indexing VRAM)
	ld a, [RectY] 	; a = rect.y 
	ld b, a 		; b = rect.y 
	
	; Multiply the y coord by 4 (divide by 8 and then mult by 32)
	; to get the VRAM row address 
	and $f8 ;zero out last 3 digits
	ld h, b			
	ld l, a
	srl h
	srl h
	srl h
	srl h
	srl h
	srl h
	sla l 
	sla l 
	
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
	add hl, bc          ; Get address of specific tile in vram
	
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
	ld bc, 32
	add hl, bc  		; add 32 to hl to get next tile to check (1 row = 32 tiles)
	jp .loop0
	
.check_y_plus_height
	;check the tile collision for point rect.y + rect.height 
	; this might do a redundant check 
	ld a, [RectHeight]
	sub 1 
	ld b, a 			; b = rect.height  - 1 
	ld a, [RectY]		; a = rect.y 

	add a, b 			; a = rect.y + rect.height - 1 
	
	;mult by 4 to get tile index 
	ld b, a
	and a, $f8   ;zero out least sig 3 digits 
	ld c, a
	srl b 
	srl b 
	srl b 
	srl b 
	srl b 
	srl b 
	
	sla c  
	sla c 

	ld a, [Scratch + 2]		; retrieve that x-tile coord from earlier
	ld h, 0 
	ld l, a 			; hl = x-tile coord 

	add hl, bc 
	ld  b, h 
	ld  c, l   			; bc now has x+y tile offset 
	
	ld a, [MapAddress]
	ld h, a 
	ld a, [MapAddress + 1]
	ld l, a 
	add hl, bc 		; get the absolute memory location of tile 
	
	ld a, [CollisionThreshold]
	ld b, a
	ld a, [hl]			; a = map entry val 
	
	cp b 						; if entry is less than threshold 
	jp c, .handle_collision_x	; it's a collision tile so handle it 

	jp .move_y 					; no collision tile, so move in Y dir now 
	
.handle_collision_x
	
	ld a, [XDisp]		; Get the original x disp 
	bit 7, a 			; is x-disp negative 
	jp z, .resolve_move_right
	
.resolve_move_left 
	ld a, [CollisionBitfield]
	or COLLIDED_LEFT		; mark that the rect collided moving left 
	ld [CollisionBitfield], a	; save bitfield
	ld a, [RectX]			; Get the rect.x coord (where it is colliding)
	add a, 8			; add 8 to the rect x position (cancel out movement to left)
	and $f8  			; zero out lower 3 bits to snap it to the tile 
	ld [RectX], a 
	jp .move_y 			; now attempt moving in y direction 
	
.resolve_move_right
	ld a, [CollisionBitfield]
	or COLLIDED_RIGHT
	ld [CollisionBitfield], a	; update the result bitfield
	ld a, [RectWidth]
	sub 1 				
	ld b, a 			; b = rect.width - 1
	ld a, [RectX]       ; a = rect.x 

	add a, b 			; a = rect.width + rect.x 
	and $f8				; snap to the tile boundary
	sub 1 				; push back one pixel from the collided tile 
	sub b				; subtract result by rect.width to get the resolved x position 
	ld [RectX], a 		; save the resolved x coord 
	
.move_y
	ld a, [YDisp]   ; a = y-displacement
	cp 0 			; is y-disp 0?
	jp z, .return	; no movement in y direction, so return. nothing else to do
	
	; Move the rect's y coord 
	ld a, [RectY]
	ld c, a 		; c = rect.y 
	ld a, [YDisp]
	add a, c 		; get the new y position and store in c
	ld  c, a 
	ld [RectY], a   ; save that new y position in rect structure	
	
	; figure out if object is moving down or up 
	ld a, [YDisp]
	bit 7, a   		; Check if new pos is negative 
	jp nz, .use_y_pos 
	ld a, [RectHeight]
	sub 1
	ld b, a 		; b = rect.height - 1
	ld a, c			; a = rect.y 
	add a, b 		; a = rect.y + rect.height - 1
	
	ld c, a			; c = rect.y + rect.height - 1 (coordinate of interest)
	
.use_y_pos
	
	; mask and multiply by 4 to get VRAM index 
	ld a, c 	; a = y-coord of interest 
	and $f8 	; zero out lower three bits 
	ld b, c 	; b = y-coord of interest 
	ld c, a 	; c = y-coord of interest (with bit 0,1,2 zeroed)
	
	; mult by 4 
	srl b 
	srl b 
	srl b 
	srl b 
	srl b 
	srl b 
	sla c 
	sla c 
	
	; prepare for looping collision check 
	ld a, [MapAddress]
	ld h, a 
	ld a, [MapAddress + 1]
	ld l, a 
	add hl, bc 			; hl = address of row to examine 
	
	; save row address for later 
	ld a, h 
	ld [Scratch], a 
	ld a, l
	ld [Scratch + 1], a 
	
	ld a, [RectX]		
	ld c, a 			; c = rect. x
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
	ld a, [RectX]	; a = rect.x 

	add a, b 	; a = rect.x + rect.width - 1 
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
	ld a, [YDisp]	; a = y-disp 
	bit 7,a 		; is the number negative?
	jp z, .resolve_move_down ;jump to the negative movement code 

.resolve_move_up
	ld a, [CollisionBitfield]
	or COLLIDED_UP
	ld [CollisionBitfield], a	; update the result bitfield
	ld a, [RectY]		; a = rect.y 
	add a, 8 		; move down 1 tile 
	and $f8			; snap to the new tile 
	ld [RectY], a 	; save rectified position 
	jp .return
	
.resolve_move_down
	ld a, [CollisionBitfield]
	or COLLIDED_DOWN
	ld [CollisionBitfield], a	; update the result bitfield
	ld a, [RectHeight]
	sub 1 
	ld b, a 			; b = rect.height - 1 
	ld a, [RectY] 		; a = rect.y 	

	add a, b 		; a = rect.y + rect.height - 1 (position of interest)
	and $f8			; snap to the collision tile 
	sub 1 			; move up one pixel (to be in a non-colliding tile)
	sub b			; subtract height to get resolved y-coord 
	ld [RectY], a 	; save new y coord 
	
.return 	
	;Final step is to save rect data to actual address 
	pop hl 			; hl = rect address 
	ld a, [RectX]
	ld [hl+], a 	; store rect.x 
	ld a, [RectY]	
	ld [hl+], a 	; store rect.y 
	ld a, [RectWidth]
	ld [hl+], a 	; store rect.width 
	ld a, [RectHeight]
	ld [hl+], a 	; store rect.height 
	
	; Load output into register
	ld a, [CollisionBitfield]
	
	ret 
	

SECTION "UtilData", BSS

fRectX:
DS 2 
fRectY:
DS 2

fXDisp:
DS 2
fYDisp:
DS 2

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
	
	; Multiply the y coord by MapWidthShift-3 (divide by 8 and then mult by MapWidth)
	; to get the Map row address 
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
	add a, 8			; add 8 to the rect x position (cancel out movement to left)
	and $f8  			; zero out lower 3 bits to snap it to the tile 
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
	and $f8				; snap to the tile boundary
	sub 1 				; push back one pixel from the collided tile 
	sub b				; subtract result by rect.width to get the resolved x position 
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
	ld a, c 	; a = y-coord of interest 
	call _MultMapWidth
	
	; prepare for looping collision check 
	ld a, [MapAddress]
	ld b, a 
	ld a, [MapAddress + 1]
	ld c, a 
	add hl, bc 			; hl = address of row to examine 
	
	; save row address for later 
	ld a, h 
	ld [Scratch], a 
	ld a, l
	ld [Scratch + 1], a 
	
	ld a, [fRectX]		
	ld c, a 			; c = rect. x
	ld b, 0 			
	
	srl c 
	srl c
	srl c 				; divide rect.x by 8 to get x tile-coord (column num)
	add hl, bc 			; add x tile coord to hl to get address of tile under inspection
	
	; add origin index to get absolute map entry address 
	ld a, [MapOriginIndex]
	ld b, a 
	ld a, [MapOriginIndex + 1]
	ld c, a 
	add hl, bc 				; absolute tile addess in rom memory
	
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
	add a, 8 		; move down 1 tile 
	and $f8			; snap to the new tile 
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
	and $f8			; snap to the collision tile 
	sub 1 			; move up one pixel (to be in a non-colliding tile)
	sub b			; subtract height to get resolved y-coord 
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
	srl c 
	srl c 
	srl c 				; c = end x tile coord
	
	; find first tile coords 
	ld a, [RectX]
	ld b, a 			; b = start pixel coords
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
; UpdateOAMFromRect_Fixed
;   push0 = [Rect Address]  
;   push1 = [OAM Address] 
;   push2 = [Rect Offset X, Rect Offset Y]
;   push3 = [Sprite Char Width/ Sprite Char Height]
;   push4 = [SpritePattern, SpriteIndex]
;   push5 = [0, FlipX = bit 1 | FlipY = bit 0]
UpdateOAMFromRect_Fixed::

	; pop off the return address and save it 
	pop bc 
	ld a, b 
	ld [Scratch], a 
	ld a, c 
	ld [Scratch + 1], a 
	
	; save params 
	pop bc
	ld a, c
	ld [SpriteFlip], a 
	
	pop bc 
	ld a, c 
	ld [SpriteIndex], a 
	ld a, b 
	ld [SpritePattern], a 
	
	pop bc 
	ld a, b 
	ld [SpriteCharWidth], a 
	ld a, c 
	ld [SpriteCharHeight], a 
	
	pop bc 
	ld a, b 
	ld [RectOffsetX], a 
	ld a, c 
	ld [RectOffsetY], a

	pop bc 
	ld a, b 
	ld [OAMAddress], a 
	ld a, c 
	ld [OAMAddress + 1], a 
	
	pop hl  
	ld a, [hl+]
	ld [RectX], a 
	inc hl 
	ld a, [hl+]
	ld [RectY], a		; Rect width / height not needed 
	
	; push back the return address
	ld a, [Scratch]
	ld b, a 
	ld a, [Scratch + 1]
	ld c, a 
	push bc 
	
	; Now to actually begin the subroutine. Use a nested loop to iterate 
	; through sprite objs, starting with top left obj.
	
	; Get the starting OAM address
	ld a, [OAMAddress]
	ld h, a 
	ld a, [OAMAddress + 1]
	ld l, a 

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
	ld c, a 			; b = obj y-coordinate  
	ld [Scratch], a 	; save the top most obj y-coordinate
	
	ld a, [RectOffsetX]
	ld b, a 
	ld a, [RectX]
	sub b 
	add a, 8 			; get obj x-coordinate 
	ld b, a 			; c = obj x-coordinate 
	
	
	; figure out which loop to run based on flip values 
	ld a, [SpriteFlip]
	and $03 		; mask away unneeded bits just in case 
	sla a 
	sla a 			; multiply by 4 to get byte offset for jumps below 
	
	push hl 		; save oam address 
	ld hl, .flip_table
	ld d, 0 
	ld e, a 
	add hl, de 
	jp [hl]			; jump into the table 
	
.flip_table
	jp .no_flip
	nop
	jp .flip_y
	nop
	jp .flip_x
	nop
	jp .flip_x_y  
	nop
	
.no_flip 

	pop hl 			; restore oam address 
	
	; Get patten index for first sprite 
	; no flip = start from first pattern
	ld a, [SpritePattern]
	ld d, a 					; d = sprite pattern 
	ld e, 0 					; e = vert loop counter 
	
	ld a, 0 
	ld [Scratch + 1], a 			; use scratch[1] for hori counter 
	
.loop_no_flip

	ld [hl], c 		; save the y obj-coord 
	inc hl 
	ld [hl], b 		; save the x obj-coord 
	inc hl 
	ld [hl], d 		; save the pattern number  
	inc hl 	
	res 6, [hl]
	res 5, [hl]		; clear y flip and x flip 
	inc hl 
	
	ld a, c 
	add a, 8
	ld c, a 		; increase y coords by 8 
	inc d 			; incease pattern number 
	inc e 			; increase counter 
	
	; check vert counter 
	push bc 		; save bc to use the registers 
	ld a, [SpriteCharHeight]
	ld b, a 
	ld a, e 
	cp b
	pop bc 			; restore the registers, won't change flags 
	jp nz, .loop_no_flip 		; vert counter != char height yet, so continue loop 
	
	; no need to adjust pattern index, as it just increments normally for no-flip 
	
	ld a, [Scratch]
	ld c, a 			; reset y obj-coord
	ld e, 0				; reset row counter 
	ld a, b 
	add a, 8
	ld b, a 			; increase obj x-coords by 8 for next iteration 
	
	; Check vertical counter to see if we are finished 
	push bc 			; save bc to use registers 
	ld a, [SpriteCharWidth]
	ld b, a 
	ld a, [Scratch+1]
	inc a 
	ld [Scratch+1], a 	; save incremented vert counter 
	cp b 				; is vert counter == char height?
	pop bc 
	jp nz, .loop_no_flip	; not finished yet. update next row of OBJs
	ret ;finished updating the sprite's OBJs 
	
	
.flip_x 

	pop hl 			; restore oam address 
	
	; Get patten index for obj first sprite 
	; flip x = NumChars - 1 - Width 
	; do a small loop to multiply width x height 
	ld a, [SpriteCharWidth]
	ld d, a 
	ld a, [SpriteCharHeight]
	ld e, a 
	ld a, 0 
.flip_x_mult_loop
	add a, e  		; add height to sum 
	dec d 
	jp nz, .flip_x_mult_loop
	
	; register a should contain the number of obj-sprites 
	sub e 
	ld d, a 
	ld a, [SpritePattern]
	add a, d 
	ld d, a 		; d = starting pattern index 
	
	ld e, 0 					; e = vert loop counter 
	
	ld a, 0 
	ld [Scratch + 1], a 			; use scratch[1] for hori counter 
	
.loop_flip_x

	ld [hl], c 		; save the y obj-coord 
	inc hl 
	ld [hl], b 		; save the x obj-coord 
	inc hl 
	ld [hl], d 		; save the pattern number  
	inc hl 	
	res 6, [hl]
	set 5, [hl]		; clear y flip and x flip 
	inc hl 

	ld a, c 
	add a, 8
	ld c, a 		; increase y coords by 8 
	inc d 			; decrease pattern number 
	inc e 			; increase counter 
	
	; check vert counter 
	push bc 		; save bc to use the registers 
	ld a, [SpriteCharHeight]
	ld b, a 
	ld a, e 
	cp b
	pop bc 			; restore the registers, won't change flags 
	jp nz, .loop_flip_x 		; vert counter != char height yet, so continue loop 
	
	; get correct pattern index for first char in next column 
	push bc 
	ld a, [SpriteCharHeight]
	ld b, a 
	ld a, d 
	sub b 
	sub b 
	ld d, a     ; d = next pattern index 
	pop bc
	
	ld a, [Scratch]
	ld c, a 			; reset y obj-coord
	ld e, 0				; reset row counter 
	ld a, b 
	add a, 8
	ld b, a 			; increase obj x-coords by 8 for next iteration 
	
	; Check vertical counter to see if we are finished 
	push bc 			; save bc to use registers 
	ld a, [SpriteCharWidth]
	ld b, a 
	ld a, [Scratch+1]
	inc a 
	ld [Scratch+1], a 	; save incremented vert counter 
	cp b 				; is vert counter == char height?
	pop bc 
	jp nz, .loop_flip_x	; not finished yet. update next row of OBJs
	ret ;finished updating the sprite's OBJs 
	

.flip_y 

	pop hl 			; restore oam address 
	
	; Get patten index for obj first sprite 
	; flip y = CharHeight - 1 
	; do a small loop to multiply width x height 
	ld a, [SpriteCharHeight]
	ld e, a 
	ld a, [SpritePattern]
	add a, e 		; add char height to sprite pattern
	sub 1 			; subtract to get starting pattern index 
	ld d, a 		; d = starting pattern index 
	
	ld e, 0 					; e = vert loop counter 
	
	ld a, 0 
	ld [Scratch + 1], a 			; use scratch[1] for hori counter 
	
.loop_flip_y

	ld [hl], c 		; save the y obj-coord 
	inc hl 
	ld [hl], b 		; save the x obj-coord 
	inc hl 
	ld [hl], d 		; save the pattern number  
	inc hl 	
	set 6, [hl]
	res 5, [hl]		; set y flip and reset x flip 
	inc hl 

	ld a, c 
	add a, 8
	ld c, a 		; increase y coords by 8 
	dec d 			; decrease pattern number 
	inc e 			; increase counter 
	
	; check vert counter 
	push bc 		; save bc to use the registers 
	ld a, [SpriteCharHeight]
	ld b, a 
	ld a, e 
	cp b
	pop bc 			; restore the registers, won't change flags 
	jp nz, .loop_flip_y 		; vert counter != char height yet, so continue loop 
	
	; get correct pattern index for first char in next column 
	push bc 
	ld a, [SpriteCharHeight]
	ld b, a 
	ld a, d 
	add b 
	add b 
	ld d, a     ; d = next pattern index 
	pop bc
	
	ld a, [Scratch]
	ld c, a 			; reset y obj-coord
	ld e, 0				; reset row counter 
	ld a, b 
	add a, 8
	ld b, a 			; increase obj x-coords by 8 for next iteration 
	
	; Check vertical counter to see if we are finished 
	push bc 			; save bc to use registers 
	ld a, [SpriteCharWidth]
	ld b, a 
	ld a, [Scratch+1]
	inc a 
	ld [Scratch+1], a 	; save incremented vert counter 
	cp b 				; is vert counter == char height?
	pop bc 
	jp nz, .loop_flip_y	; not finished yet. update next row of OBJs
	ret ;finished updating the sprite's OBJs 
	
	
.flip_x_y 

	pop hl 			; restore oam address 
	
	; Get patten index for obj first sprite 
	; flip x = NumChars - 1 - Width 
	; do a small loop to multiply width x height 
	ld a, [SpriteCharWidth]
	ld d, a 
	ld a, [SpriteCharHeight]
	ld e, a 
	ld a, 0 
.flip_x_y_mult_loop
	add a, e  		; add height to sum 
	dec d 
	jp nz, .flip_x_y_mult_loop
	
	; register a should contain the number of obj-sprites 
	sub 1 
	ld d, a 
	ld a, [SpritePattern]
	add a, d 
	ld d, a 		; d = starting pattern index 
	
	ld e, 0 					; e = vert loop counter 
	
	ld a, 0 
	ld [Scratch + 1], a 			; use scratch[1] for hori counter 
	
.loop_flip_x_y

	ld [hl], c 		; save the y obj-coord 
	inc hl 
	ld [hl], b 		; save the x obj-coord 
	inc hl 
	ld [hl], d 		; save the pattern number  
	inc hl 	
	set 6, [hl]
	set 5, [hl]		; clear y flip and x flip 
	inc hl 

	ld a, c 
	add a, 8
	ld c, a 		; increase y coords by 8 
	dec d 			; decrease pattern number 
	inc e 			; increase counter 
	
	; check vert counter 
	push bc 		; save bc to use the registers 
	ld a, [SpriteCharHeight]
	ld b, a 
	ld a, e 
	cp b
	pop bc 			; restore the registers, won't change flags 
	jp nz, .loop_flip_x_y 		; vert counter != char height yet, so continue loop 
	
	; the pattern will be correct in next column because it just decs normally
	
	ld a, [Scratch]
	ld c, a 			; reset y obj-coord
	ld e, 0				; reset row counter 
	ld a, b 
	add a, 8
	ld b, a 			; increase obj x-coords by 8 for next iteration 
	
	; Check vertical counter to see if we are finished 
	push bc 			; save bc to use registers 
	ld a, [SpriteCharWidth]
	ld b, a 
	ld a, [Scratch+1]
	inc a 
	ld [Scratch+1], a 	; save incremented vert counter 
	cp b 				; is vert counter == char height?
	pop bc 
	jp nz, .loop_flip_x_y	; not finished yet. update next row of OBJs
	ret ;finished updating the sprite's OBJs 
	
	
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