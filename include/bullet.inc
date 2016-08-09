IF !DEF(BULLET_INC)
BULLET_INC SET 1 

BULLET_DATA_SIZE EQU 13
; Bullet Structure 
; +0 Active Flag 
; +1 Rect (fixed)
; +7 X Velocity (fixed)
; +9 Y Velocity (fixed)
; +11 GravityX
; +12 GravityY 


; Bullet public variables 
GLOBAL FireParamX
GLOBAL FireParamY
GLOBAL FireParamXVel
GLOBAL FireParamYVel
GLOBAL FireParamGravityX 
GLOBAL FireParamGravityY


; Bullet Procs 
GLOBAL ResetBullets
GLOBAL UpdateBullets 
GLOBAL Bullet_Deactivate
GLOBAL UpdateBulletSprites
GLOBAL FireEnemyBullet
GLOBAL FirePlayerBullet 
GLOBAL LoadBulletGraphics 


ENDC 