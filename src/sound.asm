INCLUDE "include/sound.inc"
INCLUDE "include/constants.inc"

	SECTION "Sound", HOME 
	
DefaultWave::
DB $ff, $ee, $dd, $cc, $bb, $aa, $99, $88
DB $77, $66, $55, $44, $33, $22, $11, $00  
	
Initialize_Sound::

	ld a, $ff 
	ld [rNR52], a 		; enable all sound 
	
	ld a, $ff 
	ld [rNR51], a 		; output all sound channels to L+R terminals 
	
	ld a, $77 
	ld [rNR50],a 			; set each output terminal volumne to max 
	
	; Load default wave pattern
	ld b, 0 
	ld hl, DefaultWave
	ld de, WAVE_PATTERN_RAM
	
	; Turn wave channel on 
	ld a, $80
	ld [rNR30], a 
	
.loop
	ld a, [hl+]
	ld [de], a 
	inc de 
	inc b 
	ld a, b 
	cp 16 
	jp nz, .loop 
	
	ret 
	
; PlaySound_1
; a = sweep env 
; b = duty/length 
; c = volume env
; de = frequency 
; h = loop/count
PlaySound_1::

	ld [rNR10],a 
	ld a, b 
	ld [rNR11], a 
	ld a, c 
	ld [rNR12], a 
	ld a, e 
	ld [rNR13], a 
	ld a, d 
	or h 
	or RESTART_SOUND
	ld [rNR14], a 
	
	ret 
	
; PlaySound_2
; b = duty/length 
; c = volume env
; de = frequency 
; h = loop/count 
PlaySound_2::

	ld a, b 
	ld [rNR21], a 
	ld a, c 
	ld [rNR22], a 
	ld a, e 
	ld [rNR23], a 
	ld a, d 
	or h 
	or RESTART_SOUND
	ld [rNR24], a 
	
	ret 
	
; PlaySound_3
; b = length 
; c = volume 
; de = frequency
; h = loop/count 
PlaySound_3::

	ld a, $80 
	ld [rNR30], a 
	ld a, b 
	ld [rNR31], a 
	ld a, c 
	ld [rNR32], a 
	ld a, e 
	ld [rNR33], a 
	ld a, d
	or h 
	or RESTART_SOUND
	ld [rNR34], a 

	ret 

; PlaySound_4
; b = length 
; c = volume envelope 
; d = poly counter 
; e = loop/count 
PlaySound_4::

	ld a, b 
	ld [rNR41], a 
	ld a, c 
	ld [rNR42], a 
	ld a, d 
	ld [rNR43], a 
	ld a, e 
	or RESTART_SOUND
	ld [rNR44], a 
	
	ret 
	
StopSound_1::

	ld a, $00 
	ld [rNR12], a 
	ld a, RESTART_SOUND | COUNT_SOUND
	ld [rNR14], a 
	ret 
	
StopSound_2::

	ld a, $00 
	ld [rNR22], a 
	ld a, RESTART_SOUND | COUNT_SOUND
	ld [rNR24], a 
	ret 
	
StopSound_3::

	ld a, WAVE_VOL_MUTE
	ld [rNR32], a 
	ld a, RESTART_SOUND | COUNT_SOUND
	ld [rNR34], a 
	ret 
	
StopSound_4:

	ld a, $00 
	ld [rNR42], a 
	ld a, RESTART_SOUND | COUNT_SOUND
	ld [rNR44], a 
	ret 
	
	
StopAllSound:
	call StopSound_1
	call StopSound_2
	call StopSound_3
	call StopSound_4
	ret 