IF !DEF(LEVEL2_INC)
LEVEL2_INC SET 1 

Level2MapWidth  EQU 32
Level2MapHeight EQU 128
Level2MapBank   EQU 1
Level2TileSet EQU 0 

; Map positioning
Level2MapOriginX EQU 0
Level2MapOriginY EQU 0 
Level2MapOriginIndex EQU Level2MapOriginY*Level2MapWidth + Level2MapOriginX

; Player sprite positioning
Level2SpawnX EQU 2 
Level2SpawnY EQU 8 

GLOBAL Level2Map

ENDC