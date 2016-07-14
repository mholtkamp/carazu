IF !DEF(LEVEL_INC)
LEVEL_INC SET 1

; Constants 
VRAM_MAP_WIDTH EQU 20
VRAM_MAP_HEIGHT EQU 18


; Variables 
GLOBAL BGScrollX
GLOBAL BGScrollY 
GLOBAL BGFocusX
GLOBAL BGFocusY
GLOBAL LevelColThresh
GLOBAL LevelNum
GLOBAL MapWidth
GLOBAL MapHeight
GLOBAL MapOriginX
GLOBAL MapOriginY
GLOBAL MapOriginIndex
GLOBAL MapOriginPlus

; Procedures 
GLOBAL Level_Initialize
GLOBAL Level_Reset 
GLOBAL Level_Load 
GLOBAL Level_Update

ENDC 