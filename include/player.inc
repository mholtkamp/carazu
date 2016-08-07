IF !DEF(PLAYER_INC)
PLAYER_INC SET 1

; Variables 
GLOBAL PlayerRect
GLOBAL PlayerPrevYLow

; Procedures 

; Player_Initialize
; No params
; No return
GLOBAL Player_Initialize

; Player_Update
; No params
; No return 
GLOBAL Player_Update

; Player_UpdateLocalOAM
; No params
; No return 
GLOBAL Player_UpdateLocalOAM

; Player_SetPosition
; b = x 
; c = y 
GLOBAL Player_SetPosition

; Player_LoadGraphics
GLOBAL Player_LoadGraphics 

; Player_Bounce
; No params 
; No returns 
GLOBAl Player_Bounce 

ENDC
