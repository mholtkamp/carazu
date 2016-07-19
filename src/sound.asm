INCLUDE "include/sound.inc"
INCLUDE "include/constants.inc"

	SECTION "Sound", HOME 
	
Initialize_Sound::

	ld a, $ff 
	ld [rNR52], a 		; enable all sound 
	
	ld a, $ff 
	ld [rNR51], a 		; output all sound channels to L+R terminals 
	
	ld a, $77 
	ld [rNR50],a 			; set each output terminal volumne to max 
	
	ret 
	
; PlaySound_0
; a = sweep env 
; b = duty/length 
; c = volume env
; de = frequency 
PlaySound_0::

	ld [rNR10],a 
	ld a, b 
	ld [rNR11], a 
	ld a, c 
	ld [rNR12], a 
	ld a, e 
	ld [rNR13], a 
	ld a, d 
	or $c0
	ld [rNR14], a 
	
	ret 