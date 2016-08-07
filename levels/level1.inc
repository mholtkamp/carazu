IF !DEF(LEVEL1_INC)
LEVEL1_INC SET 1 

Level1MapWidth  EQU 32
Level1MapHeight EQU 32
Level1MapBank   EQU 1
Level1TileSet EQU 0 

; Map positioning
Level1MapOriginX EQU 0
Level1MapOriginY EQU 12 
Level1MapOriginIndex EQU Level1MapOriginY*Level1MapWidth + Level1MapOriginX

; Player sprite positioning
Level1SpawnX EQU 2 
Level1SpawnY EQU 28 

GLOBAL Level1Map

ENDC