IF !DEF(ENEMY_INC)
ENEMY_INC SET 1 


; Equates 
ENEMY_DATA_SIZE EQU 20
; Enemy.Type  [0]
; Enemy.ID 	  [1]
; Enemy.RectX [2]
; Enemy.RectY [4]
; Enemy.RectWidth [6]
; Enemy.RectHeight [7]
; Enemy.Scratch [8]

ENEMY_ENTRY_DATA_SIZE EQU 8
; EnemyEntry.Type[0]
; EnemyEntry.TileX[1]
; EnemyEntry.TileY[2]
; EnemyEntry.Param0[3]
; ...
; EnemyEntry.Param4[7]


; SCRATCH DATA FORMATS 

;===========
;== SLIME ==
;===========
; +8 = left boundary 	 [param0]
; +9 = right boundary	 [param1]
; +10 = xvel 			 [param2]
; +11 = jump vel     	 [param3]
; +12 = option flags 	 [param4]
; +13 = current direction, 0 = left, 1 = right 
; +14 = anim counter
; +15 = yvel 
; +17 = yoffset 


; Variables 
GLOBAL Enemies
GLOBAL EnemyList

; Procedures
GLOBAL Enemy_Spawn
GLOBAL Enemy_Update
GLOBAL Enemy_Kill
GLOBAL Enemy_Recall

GLOBAL UpdateEnemies
GLOBAL ResetEnemies
GLOBAL ResetEnemyList
GLOBAL LoadEnemyGraphics
GLOBAL LoadEnemyList
GLOBAL ScrollEnemies


ENDC 