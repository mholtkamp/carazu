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