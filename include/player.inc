IF !DEF(PLAYER_INC)
PLAYER_INC SET 1

; Variables 
GLOBAL PlayerRect
GLOBAL PlayerPrevYLow
GLOBAL PlayerOnPlatform
GLOBAL PlayerGrounded
GLOBAL FermataCharge
GLOBAL FermataPulseX
GLOBAL FermataPulseY
GLOBAL PlayerSprung

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
GLOBAL Player_SetPositionFromTiles

; Player_LoadGraphics
GLOBAL Player_LoadGraphics 

; Player_Bounce
; No params 
; No returns 
GLOBAL Player_Bounce 

; Player_Damage 
; Param a = contact x-coord 
GLOBAL Player_Damage

ENDC
