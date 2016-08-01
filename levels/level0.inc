IF !DEF(LEVEL0_INC)
LEVEL0_INC SET 1 

Level0MapWidth  EQU 64
Level0MapHeight EQU 32
Level0MapBank   EQU 1
Level0TileSet EQU 0 

; Map positioning
Level0MapOriginX EQU 0
Level0MapOriginY EQU 12 
Level0MapOriginIndex EQU Level0MapOriginY*Level0MapWidth + Level0MapOriginX

; Player sprite positioning
Level0SpawnX EQU 40 
Level0SpawnY EQU 40 

GLOBAL Level0Map

ENDC