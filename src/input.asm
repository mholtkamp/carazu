INCLUDE "include/input.inc"
INCLUDE "include/constants.inc"
	
	SECTION "InputData", BSS
	
InputsHeld:
DS	1 

InputsPrev:
DS 	1 


	SECTION "InputCode", HOME 
	
Input_Update::

	ld a, [InputsHeld]	; get last frames inputs 
	ld [InputsPrev], a 	; save them in the prev inputs register 
	
	ld a, $20       ; Get D-Pad input first 
	ld [rP1], a   ; select D-Pad buttons
	ld a, [rP1]   
	ld a, [rP1]   ; get values twice to make sure proper results are returned
	cpl 
	and $0f         ; only need bottom 4 bits
	swap a
	ld b, a 
	ld a, $10       ; prepare to query for buttons 
	ld [rP1], a 
	ld a, [rP1]     ; read many times to make sure proper results are retrieved
	ld a, [rP1]
	ld a, [rP1]
	ld a, [rP1]
	ld a, [rP1]
	ld a, [rP1]
	cpl 
	and $0f 
	or b            ; combine buttons and d-pad to one byte
	ld [InputsHeld], a ; store held buttons in memory
	ld a, $30          ; reset (?) joypad. aka do not request what inputs are down
	ld [rP1], a 
	ret
	