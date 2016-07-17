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
GLOBAL BGFocusPixelsX
GLOBAL BGFocusPixelsY
GLOBAL LevelColThresh
GLOBAL LevelNum
GLOBAL MapWidth
GLOBAL MapHeight
GLOBAL MapWidthShift
GLOBAL MapOriginX
GLOBAL MapOriginY
GLOBAL MapOriginIndex
GLOBAL MapOriginIndexPlus
GLOBAL MapAddress
GLOBAL MapStreamDir

; Procedures 
GLOBAL Level_Initialize
GLOBAL Level_Reset 
GLOBAL Level_Load 
GLOBAL Level_Update

;TEST DELETE
GLOBAL _Level_LoadLeft
GLOBAL _Level_LoadTop
GLOBAL _Level_LoadRight
GLOBAL _Level_LoadBottom

ENDC 