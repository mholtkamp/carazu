INCLUDE "music/song0.inc"
INCLUDE "include/music.inc" ; Include for note equates 

	SECTION "Song0", HOME 
	
	
Song0_Instrument1:
	DB $00
	DB $80
	DB $f0
	DB $80
	
Song0_Instrument2:
	DB $80 
	DB $f0
	DB $80 
	
Song0_Instrument3:
	DB $80 
	DB $00 
	DB $20
	DB $80 
	
	
Song0_Channel1:
	DW Chain_1_0
	DW Chain_1_1 
	DW Chain_1_0
	DW Chain_1_1 
	DW END_SONG 
	
Song0_Channel2:
	DW Chain_2_0
	DW Chain_2_1 
	DW Chain_2_0
	DW Chain_2_1 
	DW END_SONG
	
Song0_Channel3:
	DW Chain_3_0
	DW Chain_3_1
	DW Chain_3_0
	DW Chain_3_1 
	DW END_SONG 
	
	
	
	
	
Chain_1_0:
	DW Phrase_1_0
	DW Phrase_1_1 
	DW Phrase_1_2 
	DW END_CHAIN 
	
Phrase_1_0:
	DB G3
	DB HOLD
	DB HOLD
	DB HOLD 
	
	DB REST 
	DB G3
	DB HOLD 
	DB HOLD 
	
	DB HOLD 
	DB HOLD 
	DB REST 
	DB REST 
	
	DB REST 
	DB REST 
	DB REST 
	DB REST 
	
Phrase_1_1:
	DB REST 
	DB REST 
	DB REST 
	DB REST 
	
	DB REST 
	DB REST 
	DB REST 
	DB REST 
	
	DB G3 
	DB HOLD 
	DB HOLD 
	DB HOLD 
	
	DB REST 
	DB G3 
	DB HOLD 
	DB HOLD 
	
Phrase_1_2:
	DB HOLD 
	DB HOLD 
	DB REST 
	DB REST 
	
	DB REST 
	DB REST 
	DB REST 
	DB REST 
	
	DB REST 
	DB REST 
	DB REST 
	DB REST 
	
	DB REST 
	DB REST 
	DB REST 
	DB REST 
	
Chain_1_1:
	DW Phrase_1_3
	DW Phrase_1_4 
	DW Phrase_1_5 
	DW END_CHAIN 
	
Phrase_1_3:
	DB F3
	DB HOLD
	DB HOLD
	DB HOLD 
	
	DB REST 
	DB F3
	DB HOLD 
	DB HOLD 
	
	DB HOLD 
	DB HOLD 
	DB REST 
	DB REST 
	
	DB REST 
	DB REST 
	DB REST 
	DB REST 
	
Phrase_1_4:
	DB REST 
	DB REST 
	DB REST 
	DB REST 
	
	DB REST 
	DB REST 
	DB REST 
	DB REST 
	
	DB F3 
	DB HOLD 
	DB HOLD 
	DB HOLD 
	
	DB REST 
	DB F3 
	DB HOLD 
	DB HOLD 
	
Phrase_1_5:
	DB HOLD 
	DB HOLD 
	DB REST 
	DB REST 
	
	DB REST 
	DB REST 
	DB REST 
	DB REST 
	
	DB REST 
	DB REST 
	DB REST 
	DB REST 
	
	DB REST 
	DB REST 
	DB REST 
	DB REST 
	
Chain_2_0:
	DW Phrase_2_0
	DW Phrase_2_1 
	DW Phrase_2_2 
	DW END_CHAIN 
	
Phrase_2_0:
	DB B3
	DB HOLD
	DB HOLD
	DB HOLD 
	
	DB REST 
	DB B3
	DB HOLD 
	DB HOLD 
	
	DB HOLD 
	DB HOLD 
	DB REST 
	DB REST 
	
	DB REST 
	DB REST 
	DB REST 
	DB REST 
	
Phrase_2_1:
	DB REST 
	DB REST 
	DB REST 
	DB REST 
	
	DB REST 
	DB REST 
	DB REST 
	DB REST 
	
	DB B3 
	DB HOLD 
	DB HOLD 
	DB HOLD 
	
	DB REST 
	DB B3 
	DB HOLD 
	DB HOLD 
	
Phrase_2_2:
	DB HOLD 
	DB HOLD 
	DB REST 
	DB REST 
	
	DB REST 
	DB REST 
	DB REST 
	DB REST 
	
	DB REST 
	DB REST 
	DB REST 
	DB REST 
	
	DB REST 
	DB REST 
	DB REST 
	DB REST 
	
Chain_2_1:
	DW Phrase_2_3
	DW Phrase_2_4 
	DW Phrase_2_5 
	DW END_CHAIN 
	
Phrase_2_3:
	DB A3
	DB HOLD
	DB HOLD
	DB HOLD 
	
	DB REST 
	DB A3
	DB HOLD 
	DB HOLD 
	
	DB HOLD 
	DB HOLD 
	DB REST 
	DB REST 
	
	DB REST 
	DB REST 
	DB REST 
	DB REST 
	
Phrase_2_4:
	DB REST 
	DB REST 
	DB REST 
	DB REST 
	
	DB REST 
	DB REST 
	DB REST 
	DB REST 
	
	DB A3 
	DB HOLD 
	DB HOLD 
	DB HOLD 
	
	DB REST 
	DB A3 
	DB HOLD 
	DB HOLD 
	
Phrase_2_5:
	DB HOLD 
	DB HOLD 
	DB REST 
	DB REST 
	
	DB REST 
	DB REST 
	DB REST 
	DB REST 
	
	DB REST 
	DB REST 
	DB REST 
	DB REST 
	
	DB REST 
	DB REST 
	DB REST 
	DB REST 
	
Chain_3_0:
	DW Phrase_3_0
	DW Phrase_3_1 
	DW Phrase_3_2 
	DW END_CHAIN 
	
Phrase_3_0:
	DB D4
	DB HOLD 
	DB HOLD 
	DB HOLD 
	
	DB REST 
	DB D4 
	DB HOLD 
	DB HOLD 
	
	DB HOLD 
	DB HOLD 
	DB REST 
	DB REST 
	
	DB G3  
	DB HOLD  
	DB B3 
	DB D4 
	
Phrase_3_1:
	DB HOLD 
	DB E4 
	DB D4 
	DB HOLD 
	
	DB B3 
	DB G3 
	DB HOLD 
	DB REST 
	
	DB D4
	DB HOLD 
	DB HOLD 
	DB HOLD 
	
	DB REST 
	DB D4 
	DB HOLD 
	DB HOLD 
	
Phrase_3_2:
	DB HOLD 
	DB HOLD 
	DB REST 
	DB REST 
	
	DB G3 
	DB HOLD 
	DB B3 
	DB D4 
	
	DB HOLD 
	DB E4
	DB D4
	DB HOLD 
	
	DB B3 
	DB G3 
	DB HOLD 
	DB REST 
	
Chain_3_1:
	DW Phrase_3_3
	DW Phrase_3_4 
	DW Phrase_3_5 
	DW END_CHAIN 
	
Phrase_3_3:
	DB C4 
	DB HOLD 
	DB HOLD 
	DB HOLD 
	
	DB REST 
	DB C4 
	DB HOLD 
	DB HOLD 
	
	DB HOLD 
	DB HOLD 
	DB REST 
	DB REST 
	
	DB F3 
	DB HOLD 
	DB A3 
	DB C4
	
Phrase_3_4:
	DB HOLD 
	DB D4 
	DB C4
	DB HOLD 
	
	DB A3
	DB F3 
	DB HOLD 
	DB REST 
	
	DB C4 
	DB HOLD 
	DB HOLD 
	DB HOLD 
	
	DB REST 
	DB C4 
	DB HOLD 
	DB HOLD 
	
Phrase_3_5:
	DB HOLD 
	DB HOLD 
	DB REST 
	DB REST 
	
	DB F3 
	DB HOLD 
	DB A3 
	DB C4
	
	DB HOLD 
	DB D4 
	DB C4
	DB HOLD 
	
	DB A3 
	DB F3 
	DB HOLD 
	DB REST 
	