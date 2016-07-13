IF !DEF(LEVEL_INC)
LEVEL_INC SET 1

; Constants 
VRAM_MAP_WIDTH EQU 24
VRAM_MAP_HEIGHT EQU 24


; Variables 
GLOBAL BGScrollX
GLOBAL BGScrollY 
GLOBAL LevelColThresh
GLOBAL LevelNum

; Procedures 
GLOBAL Level_Initialize 
GLOBAL Level_Load 
GLOBAL Level_Update

ENDC 