IF !DEF(SONG0_INC)
SONG0_INC SET 1 

Song0_ChannelBitfield EQU %00000111 

GLOBAL Song0_Channel1
GLOBAL Song0_Channel2
GLOBAL Song0_Channel3

GLOBAL Song0_Instrument1
GLOBAL Song0_Instrument2
GLOBAL Song0_Instrument3 

Song0_FramesPerTick EQU 7 

ENDC
