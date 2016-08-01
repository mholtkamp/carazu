INCLUDE "include/music.inc"
INCLUDE "include/sound.inc"
INCLUDE "include/constants.inc"

; Song Includes 
INCLUDE "music/song0.inc"

	SECTION "MusicVariables", BSS 
	
FramesPerTick:
DS 1

Frame: 
DS 1 

Tick:
DS 1 

ActiveChannels:
DS 1 

PlayStatus:
DS 1 

SongBank:
DS 1 

Instrument_1:
DS 2 
Instrument_2:
DS 2 
Instrument_3:
DS 2 
Instrument_4:
DS 2 

Phrase_1:
DS 2 
Phrase_2:
DS 2 
Phrase_3: 
DS 2 
Phrase_4:
DS 2 

ChainCursor_1:
DS 2 
ChainCursor_2:
DS 2 
ChainCursor_3:
DS 2 
ChainCursor_4:
DS 2 

SongCursor_1:
DS 2 
SongCursor_2:
DS 2 
SongCursor_3:
DS 2 
SongCursor_4:
DS 2 

Song_1:
DS 2 
Song_2:
DS 2 
Song_3:
DS 2 
Song_4:
DS 2 

Scratch:
DS 1 

Channel3Playing:
DS 1 

	SECTION "MusicProcedures", HOME 
	
InitializeMusic::

	ret 
	
; LoadSong
; c = song number, max song # = 31 
LoadSong::

	; clear all song data 
	call ResetSongData

	sla c 
	sla c 		; mult c by 4 for jump table 
	
	ld b, 0 	; bc = jump table offset
	ld hl, .jump_table
	add hl, bc 
	
.jump_table
	jp .load_0
	nop
	jp .load_1
	nop 
	
.setup

	call SetupCursors
	
	; Set play status to SONG_PLAY
	ld a, SONG_PLAY
	ld [PlayStatus], a 		; now UpdateSong will play the song 
	
	call PlayNote			; play the first note
	
	ret 
	
	
	
	
.load_0 

	; Save song bank
	ld a, Song0_Bank
	ld [SongBank], a 
	; switch song banks 
	ld [ROM_BANK_WRITE_ADDR], a 
	
	; BPM 
	ld a, Song0_FramesPerTick
	ld [FramesPerTick], a 
	
	; Instruments
	ld a, Song0_Instrument1 & $00ff 
	ld [Instrument_1], a 
	ld a, (Song0_Instrument1 & $ff00) >> 8 
	ld [Instrument_1 + 1], a 
	
	ld a, Song0_Instrument2 & $00ff 
	ld [Instrument_2], a 
	ld a, (Song0_Instrument2 & $ff00) >> 8 
	ld [Instrument_2 + 1], a 
	
	ld a, Song0_Instrument3 & $00ff 
	ld [Instrument_3], a 
	ld a, (Song0_Instrument3 & $ff00) >> 8 
	ld [Instrument_3 + 1], a 
	
	; Song channels
	ld a, Song0_Channel1 & $00ff 
	ld [Song_1], a 
	ld a, (Song0_Channel1 & $ff00) >> 8 
	ld [Song_1 + 1], a 

	ld a, Song0_Channel2 & $00ff 
	ld [Song_2], a 
	ld a, (Song0_Channel2 & $ff00) >> 8 
	ld [Song_2 + 1], a

	ld a, Song0_Channel3 & $00ff 
	ld [Song_3], a 
	ld a, (Song0_Channel3 & $ff00) >> 8 
	ld [Song_3 + 1], a 
	
	ld a, Song0_ChannelBitfield
	ld [ActiveChannels], a 
	
	jp .setup 
	
	
.load_1 

	jp .setup  
	
	
ResetSongData::

	ld a, 0 
	ld [FramesPerTick], a 
	ld [Tick], a 
	ld [Frame], a 
	ld [ActiveChannels], a 
	ld [PlayStatus], a 
	ld [Channel3Playing], a 
	
	ld [Instrument_1], a 
	ld [Instrument_1 + 1], a 
	ld [Instrument_2], a 
	ld [Instrument_2 + 1], a 
	ld [Instrument_3], a 
	ld [Instrument_3 + 1], a 
	ld [Instrument_4], a 
	ld [Instrument_4 + 1], a 
	
	ld [Phrase_1], a 
	ld [Phrase_1 + 1], a 
	ld [Phrase_2], a 
	ld [Phrase_2 + 1], a 
	ld [Phrase_3], a 
	ld [Phrase_3 + 1], a 
	ld [Phrase_4], a 
	ld [Phrase_4 + 1], a 
	
	ld [ChainCursor_1], a 
	ld [ChainCursor_1 + 1], a 
	ld [ChainCursor_2], a 
	ld [ChainCursor_2 + 1], a 
	ld [ChainCursor_3], a 
	ld [ChainCursor_3 + 1], a 
	ld [ChainCursor_4], a 
	ld [ChainCursor_4 + 1], a 
	
	ld [SongCursor_1], a 
	ld [SongCursor_1 + 1], a 
	ld [SongCursor_2], a 
	ld [SongCursor_2 + 1], a 
	ld [SongCursor_3], a 
	ld [SongCursor_3 + 1], a 
	ld [SongCursor_4], a 
	ld [SongCursor_4 + 1], a 
	
	ld [Song_1], a 
	ld [Song_1 + 1], a 
	ld [Song_2], a 
	ld [Song_2 + 1], a 
	ld [Song_3], a 
	ld [Song_3 + 1], a 
	ld [Song_4], a 
	ld [Song_4 + 1], a 
	
	
	ret 
	
SetupCursors::

.channel_1 
	; Setup channel 1 
	ld a, [Song_1]
	ld l, a 
	ld [SongCursor_1], a 
	ld a, [Song_1 + 1]
	ld h, a 
	ld [SongCursor_1 + 1], a 		; have song cursor point to beginning of song 
	
	or l 
	jp z, .channel_2 
	
	ld e, [hl]
	inc hl 
	ld d, [hl]			; de = address of starting chain
	
	ld a, e 
	ld [ChainCursor_1], a 
	ld a, d 
	ld [ChainCursor_1 + 1], a 	; chain cursor is now pointing to first chain address
								; data at this address is the address of first phrase in chain
	
	ld a, [de]
	ld [Phrase_1], a 
	inc de 
	ld a, [de]
	ld [Phrase_1 + 1], a 	; store address of first phrase 
	
.channel_2 
	; Setup channel 2 
	ld a, [Song_2]
	ld l, a 
	ld [SongCursor_2], a 
	ld a, [Song_2 + 1]
	ld h, a 
	ld [SongCursor_2 + 1], a 		; have song cursor point to beginning of song 
	
	or l 
	jp z, .channel_3
	
	ld e, [hl]
	inc hl 
	ld d, [hl]			; de = address of starting chain
	
	ld a, e 
	ld [ChainCursor_2], a 
	ld a, d 
	ld [ChainCursor_2 + 1], a 	; chain cursor is now pointing to first chain address
								; data at this address is the address of first phrase in chain
	
	ld a, [de]
	ld [Phrase_2], a 
	inc de 
	ld a, [de]
	ld [Phrase_2 + 1], a 	; store address of first phrase 
	
.channel_3 
	; Setup channel 3  
	ld a, [Song_3]
	ld l, a 
	ld [SongCursor_3], a 
	ld a, [Song_3 + 1]
	ld h, a 
	ld [SongCursor_3 + 1], a 		; have song cursor point to beginning of song 
	
	or l 
	jp z, .channel_4 
	
	ld e, [hl]
	inc hl 
	ld d, [hl]			; de = address of starting chain
	
	ld a, e 
	ld [ChainCursor_3], a 
	ld a, d 
	ld [ChainCursor_3 + 1], a 	; chain cursor is now pointing to first chain address
								; data at this address is the address of first phrase in chain
	
	ld a, [de]
	ld [Phrase_3], a 
	inc de 
	ld a, [de]
	ld [Phrase_3 + 1], a 	; store address of first phrase 
	
.channel_4 
	; Setup channel 4 
	ld a, [Song_4]
	ld l, a 
	ld [SongCursor_4], a 
	ld a, [Song_4 + 1]
	ld h, a 
	ld [SongCursor_4 + 1], a 		; have song cursor point to beginning of song 
	
	or l 
	ret z 
	
	ld e, [hl]
	inc hl 
	ld d, [hl]			; de = address of starting chain
	
	ld a, e 
	ld [ChainCursor_4], a 
	ld a, d 
	ld [ChainCursor_4 + 1], a 	; chain cursor is now pointing to first chain address
								; data at this address is the address of first phrase in chain
	
	ld a, [de]
	ld [Phrase_4], a 
	inc de 
	ld a, [de]
	ld [Phrase_4 + 1], a 	; store address of first phrase 
	
	ret 
	
UpdateSong::

	; switch rom banks to correct song bank 
	ld a, [SongBank]
	ld [ROM_BANK_WRITE_ADDR], a 
	
	; If song is paused, do nothing 
	ld a, [PlayStatus]
	cp SONG_PAUSE  
	ret z 
	
	; Increment frame counter 
	ld a, [FramesPerTick]
	ld b, a 
	ld a, [Frame]
	inc a
	ld [Frame], a 
	cp b 
	ret nz 
	ld a, 0 
	ld [Frame], a 			; reset frame counter 
	
	; Frame == FramesPerTick so incremement tick 
	ld a, [Tick]
	inc a
	ld [Tick], a 
	cp TICKS_PER_PHRASE 
	jp nz, .play_note 
	ld a, 0 
	ld [Tick], a 			; reset tick counter 
	
	; Get next phrase 
	call AdvanceCursors
	
	
.play_note
	call PlayNote
	
	ret 
	
AdvanceCursors::
	
.channel_1 
	ld hl, ActiveChannels
	bit CHANNEL_1_BIT, [hl]
	jp z, .channel_2 
	
	ld a, [ChainCursor_1]
	ld l, a 
	ld a, [ChainCursor_1 + 1]
	ld h, a 
	inc hl 
	inc hl 			; chain cursor pointing to next phrase address 
	
	ld a, l  
	ld [ChainCursor_1], a 
	ld a, h 
	ld [ChainCursor_1 + 1], a 	; save the new chain cursor 
	
	ld a, [hl+]
	ld e, a 
	ld a, [hl]
	ld d, a 		; de = next phrase address 
	
	or e 			
	jp z, .channel_1_next_chain
	
	
.channel_1_next_phrase 
	; DE = NEXT_PHRASE_ADDRESS 
	; chain cursor is pointing at next phrase, and it's not END_CHAIN 
	; so update the phrase pointer 
	ld a, e 
	ld [Phrase_1], a 
	ld a, d 
	ld [Phrase_1 + 1], a 
	
	jp .channel_2 

.channel_1_next_chain 
	ld a, [SongCursor_1]
	ld e, a 
	ld a, [SongCursor_1 + 1]
	ld d, a 					; de = song cursor 
	
	inc de 
	inc de 						; de = next chain in song 
	
	ld a, e 
	ld [SongCursor_1], a 
	ld a, d 
	ld [SongCursor_1 + 1], a 
	
	ld a, [de]
	ld c, a 
	inc de 
	ld a, [de]
	or c 						; [SongCursor_1] == 0? Is the chain END_SONG?
	jp z, .channel_1_reset_song
	
	dec de ; decrement to make sure this is pointing at next chain 
	
.channel_1_next_chain_save
	; DE = SONG_CURSOR 
	ld a, [de]
	ld l, a 
	ld [ChainCursor_1], a 
	inc de 
	ld a, [de]
	ld h, a 
	ld [ChainCursor_1 + 1], a 
	
	; save next phrase in de 
	ld a, [hl+]
	ld e, a 
	ld a, [hl]
	ld d, a 
	jp .channel_1_next_phrase
	
.channel_1_reset_song
	
	; just set song cursor to song start. make sure de = new song cursor 
	ld a, [Song_1]
	ld e, a 
	ld [SongCursor_1], a 
	ld a, [Song_1 + 1]
	ld d, a 
	ld [SongCursor_1 + 1], a 
	
	jp .channel_1_next_chain_save 
	
	
	
.channel_2 
	ld hl, ActiveChannels
	bit CHANNEL_2_BIT, [hl]
	jp z, .channel_3 
	
	ld a, [ChainCursor_2]
	ld l, a 
	ld a, [ChainCursor_2 + 1]
	ld h, a 
	inc hl 
	inc hl 			; chain cursor pointing to next phrase address 
	
	ld a, l  
	ld [ChainCursor_2], a 
	ld a, h 
	ld [ChainCursor_2 + 1], a 	; save the new chain cursor 
	
	ld a, [hl+]
	ld e, a 
	ld a, [hl]
	ld d, a 		; de = next phrase address 
	
	or e 			
	jp z, .channel_2_next_chain
	
	
.channel_2_next_phrase 
	; DE = NEXT_PHRASE_ADDRESS 
	; chain cursor is pointing at next phrase, and it's not END_CHAIN 
	; so update the phrase pointer 
	ld a, e 
	ld [Phrase_2], a 
	ld a, d 
	ld [Phrase_2 + 1], a 
	
	jp .channel_3 

.channel_2_next_chain 
	ld a, [SongCursor_2]
	ld e, a 
	ld a, [SongCursor_2 + 1]
	ld d, a 					; de = song cursor 
	
	inc de 
	inc de 						; de = next chain in song 
	
	ld a, e 
	ld [SongCursor_2], a 
	ld a, d 
	ld [SongCursor_2 + 1], a 
	
	ld a, [de]
	ld c, a 
	inc de 
	ld a, [de]
	or c 						; [SongCursor_2] == 0? Is the chain END_SONG?
	jp z, .channel_2_reset_song
	
	dec de ; decrement to make sure this is pointing at next chain 
	
.channel_2_next_chain_save
	; DE = SONG_CURSOR 
	ld a, [de]
	ld l, a 
	ld [ChainCursor_2], a 
	inc de 
	ld a, [de]
	ld h, a 
	ld [ChainCursor_2 + 1], a 
	
	; save next phrase in de 
	ld a, [hl+]
	ld e, a 
	ld a, [hl]
	ld d, a 
	jp .channel_2_next_phrase
	
.channel_2_reset_song
	
	; just set song cursor to song start. make sure de = new song cursor 
	ld a, [Song_2]
	ld e, a 
	ld [SongCursor_2], a 
	ld a, [Song_2 + 1]
	ld d, a 
	ld [SongCursor_2 + 1], a 
	
	jp .channel_2_next_chain_save 
	
.channel_3 
	ld hl, ActiveChannels
	bit CHANNEL_3_BIT, [hl]
	jp z, .channel_4 
	
	ld a, [ChainCursor_3]
	ld l, a 
	ld a, [ChainCursor_3 + 1]
	ld h, a 
	inc hl 
	inc hl 			; chain cursor pointing to next phrase address 
	
	ld a, l  
	ld [ChainCursor_3], a 
	ld a, h 
	ld [ChainCursor_3 + 1], a 	; save the new chain cursor 
	
	ld a, [hl+]
	ld e, a 
	ld a, [hl]
	ld d, a 		; de = next phrase address 
	
	or e 			
	jp z, .channel_3_next_chain
	
	
.channel_3_next_phrase 
	; DE = NEXT_PHRASE_ADDRESS 
	; chain cursor is pointing at next phrase, and it's not END_CHAIN 
	; so update the phrase pointer 
	ld a, e 
	ld [Phrase_3], a 
	ld a, d 
	ld [Phrase_3 + 1], a 
	
	jp .channel_4

.channel_3_next_chain 
	ld a, [SongCursor_3]
	ld e, a 
	ld a, [SongCursor_3 + 1]
	ld d, a 					; de = song cursor 
	
	inc de 
	inc de 						; de = next chain in song 
	
	ld a, e 
	ld [SongCursor_3], a 
	ld a, d 
	ld [SongCursor_3 + 1], a 
	
	ld a, [de]
	ld c, a 
	inc de 
	ld a, [de]
	or c 						; [SongCursor_3] == 0? Is the chain END_SONG?
	jp z, .channel_3_reset_song
	
	dec de ; decrement to make sure this is pointing at next chain 
	
.channel_3_next_chain_save
	; DE = SONG_CURSOR 
	ld a, [de]
	ld l, a 
	ld [ChainCursor_3], a 
	inc de 
	ld a, [de]
	ld h, a 
	ld [ChainCursor_3 + 1], a 
	
	; save next phrase in de 
	ld a, [hl+]
	ld e, a 
	ld a, [hl]
	ld d, a 
	jp .channel_3_next_phrase
	
.channel_3_reset_song
	
	; just set song cursor to song start. make sure de = new song cursor 
	ld a, [Song_3]
	ld e, a 
	ld [SongCursor_3], a 
	ld a, [Song_3 + 1]
	ld d, a 
	ld [SongCursor_3 + 1], a 
	
	jp .channel_3_next_chain_save 	
	
.channel_4 
	ld hl, ActiveChannels
	bit CHANNEL_4_BIT, [hl]
	ret 
	
	ld a, [ChainCursor_4]
	ld l, a 
	ld a, [ChainCursor_4 + 1]
	ld h, a 
	inc hl 
	inc hl 			; chain cursor pointing to next phrase address 
	
	ld a, l  
	ld [ChainCursor_4], a 
	ld a, h 
	ld [ChainCursor_4 + 1], a 	; save the new chain cursor 
	
	ld a, [hl+]
	ld e, a 
	ld a, [hl]
	ld d, a 		; de = next phrase address 
	
	or e 			
	jp z, .channel_4_next_chain
	
	
.channel_4_next_phrase 
	; DE = NEXT_PHRASE_ADDRESS 
	; chain cursor is pointing at next phrase, and it's not END_CHAIN 
	; so update the phrase pointer 
	ld a, e 
	ld [Phrase_4], a 
	ld a, d 
	ld [Phrase_4 + 1], a 
	
	ret 

.channel_4_next_chain 
	ld a, [SongCursor_4]
	ld e, a 
	ld a, [SongCursor_4 + 1]
	ld d, a 					; de = song cursor 
	
	inc de 
	inc de 						; de = next chain in song 
	
	ld a, e 
	ld [SongCursor_4], a 
	ld a, d 
	ld [SongCursor_4 + 1], a 
	
	ld a, [de]
	ld c, a 
	inc de 
	ld a, [de]
	or c 						; [SongCursor_4] == 0? Is the chain END_SONG?
	jp z, .channel_4_reset_song
	
	dec de ; decrement to make sure this is pointing at next chain 
	
.channel_4_next_chain_save
	; DE = SONG_CURSOR 
	ld a, [de]
	ld l, a 
	ld [ChainCursor_4], a 
	inc de 
	ld a, [de]
	ld h, a 
	ld [ChainCursor_4 + 1], a 
	
	; save next phrase in de 
	ld a, [hl+]
	ld e, a 
	ld a, [hl]
	ld d, a 
	jp .channel_4_next_phrase
	
.channel_4_reset_song
	
	; just set song cursor to song start. make sure de = new song cursor 
	ld a, [Song_4]
	ld e, a 
	ld [SongCursor_4], a 
	ld a, [Song_4 + 1]
	ld d, a 
	ld [SongCursor_4 + 1], a 
	
	jp .channel_4_next_chain_save 
	
	
	
PlayNote::

.channel_1 

	ld a, [ActiveChannels]
	bit CHANNEL_1_BIT, a 
	jp z, .channel_2 
	
	; get note from phrase 
	ld a, [Phrase_1]
	ld l, a 
	ld a, [Phrase_1 + 1]
	ld h, a 
	
	ld b, 0 
	ld a, [Tick]
	ld c, a 
	
	add hl, bc 		; hl = address of current note 
	
	ld a, [hl]		; 
	ld c, a 		; c = note enum val 
	
	cp REST
	jp z, .channel_1_play_rest
	
	cp HOLD 
	jp z, .channel_2 	; nothing to do, hold note
	
	ld a, [Instrument_1]
	ld l, a 
	ld a, [Instrument_1 + 1]
	ld h, a 
	
	ld a, [hl+]
	ld [rNR10], a 
	ld a, [hl+]
	ld [rNR11], a 
	ld a, [hl+]
	ld [rNR12], a 
	ld a, [hl]
	ld [Scratch], a 		; Scratch saves last instrument data (hold/count)
	
	; look up note 
	ld hl, NoteTable
	sla c 			; shift note enum value by 2 to get table index (table contains words, not bytes)
	add hl, bc 		; bc should have note enum value in it 
	ld a, [hl+]
	ld e, a 
	ld a, [hl]
	ld d, a 		; de = should have frequency X-Value 
	
	ld a, e 
	ld [rNR13], a  ; store low frequency 
	
	ld a, [Scratch] ; get hold/count value 
	or d 			; get frequency high + hold/count
	ld [rNR14], a 	; store high frequency + hold/count 
	
	jp .channel_2 
	
.channel_1_play_rest 
	ld a, 0 
	ld [rNR12], a 
	ld a, $80
	ld [rNR14], a 
	jp .channel_2 
	
.channel_2 

	ld a, [ActiveChannels]
	bit CHANNEL_2_BIT, a 
	jp z, .channel_3 
	
	; get note from phrase 
	ld a, [Phrase_2]
	ld l, a 
	ld a, [Phrase_2 + 1]
	ld h, a 
	
	ld b, 0 
	ld a, [Tick]
	ld c, a 
	
	add hl, bc 		; hl = address of current note 
	
	ld a, [hl]		; 
	ld c, a 		; c = note enum val 
	
	cp REST
	jp z, .channel_2_play_rest
	
	cp HOLD 
	jp z, .channel_3 	; nothing to do, hold note
	
	ld a, [Instrument_2]
	ld l, a 
	ld a, [Instrument_2 + 1]
	ld h, a 
	
	ld a, [hl+]
	ld [rNR21], a 
	ld a, [hl+]
	ld [rNR22], a 
	ld a, [hl]
	ld [Scratch], a 		; Scratch saves last instrument data (hold/count)
	
	; look up note 
	ld hl, NoteTable
	sla c 			; shift note enum value by 2 to get table index (table contains words, not bytes)
	add hl, bc 		; bc should have note enum value in it 
	ld a, [hl+]
	ld e, a 
	ld a, [hl]
	ld d, a 		; de = should have frequency X-Value 
	
	ld a, e 
	ld [rNR23], a  ; store low frequency 
	
	ld a, [Scratch] ; get hold/count value 
	or d 			; get frequency high + hold/count
	ld [rNR24], a 	; store high frequency + hold/count 
	
	jp .channel_3
	
.channel_2_play_rest 
	ld a, 0 
	ld [rNR22], a 
	ld a, $80
	ld [rNR24], a 
	jp .channel_3
	
	
.channel_3 

	ld a, [ActiveChannels]
	bit CHANNEL_3_BIT, a 
	jp z, .channel_4  
	
	; get note from phrase 
	ld a, [Phrase_3]
	ld l, a 
	ld a, [Phrase_3 + 1]
	ld h, a 
	
	ld b, 0 
	ld a, [Tick]
	ld c, a 
	
	add hl, bc 		; hl = address of current note 
	
	ld a, [hl]		; 
	ld c, a 		; c = note enum val 
	
	cp REST
	jp z, .channel_3_play_rest
	
	cp HOLD 
	jp z, .channel_4 	; nothing to do, hold note
	
	ld a, [Instrument_3]
	ld l, a 
	ld a, [Instrument_3 + 1]
	ld h, a 
	
	ld a, [hl+]
	ld [rNR30], a 
	ld a, [hl+]
	ld [rNR31], a 
	ld a, [hl+]
	ld [rNR32], a 
	ld a, [hl]
	ld [Scratch], a 		; Scratch saves last instrument data (hold/count)
	
	; look up note 
	ld hl, NoteTable
	sla c 			; shift note enum value by 2 to get table index (table contains words, not bytes)
	add hl, bc 		; bc should have note enum value in it 
	ld a, [hl+]
	ld e, a 
	ld a, [hl]
	ld d, a 		; de = should have frequency X-Value 
	
	ld a, e 
	ld [rNR33], a  ; store low frequency 
	
	ld a, [Scratch] ; get hold/count value 
	or d 			; get frequency high + hold/count
	ld [rNR34], a 	; store high frequency + hold/count 
	
	ld a, 1
	ld [Channel3Playing], a 
	
	jp .channel_4 
	
.channel_3_play_rest 
	ld a, [Channel3Playing]
	cp 0 
	jp z, .channel_4 				; channel 3 is already resting so do not "rest" again 
	ld a, $00 
	ld [rNR30], a 
	ld a, $80 
	ld [rNR34], a 
	ld a, 0
	ld [Channel3Playing], a 		; now that channel 3 is resting, set this to 0
									; to avoid the nasty tick sound.
	jp .channel_4 
	
.channel_4 

	ret 
	
	
	
NoteTable::
DW 44
DW 157
DW 263
DW 363
DW 457
DW 547
DW 631
DW 711
DW 786
DW 856
DW 923
DW 986
DW 1046
DW 1102
DW 1155
DW 1205
DW 1253
DW 1297
DW 1339
DW 1379
DW 1417
DW 1452
DW 1486
DW 1517
DW 1547
DW 1575
DW 1602
DW 1627
DW 1650
DW 1673
DW 1694
DW 1714
DW 1732
DW 1750
DW 1767
DW 1783
DW 1798
DW 1812
DW 1825
DW 1837
DW 1849
DW 1860
DW 1871
DW 1881
DW 1890
DW 1899
DW 1907
DW 1915
DW 1923
DW 1930
DW 1936
DW 1943
DW 1949
DW 1954
DW 1959
DW 1964
DW 1969
DW 1974
DW 1978
DW 1982
DW 1985
DW 1989
DW 1992
DW 1995
DW 1998
DW 2001
DW 2004
DW 2006
DW 2009
DW 2011
DW 2013
DW 2015
