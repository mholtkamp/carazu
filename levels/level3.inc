IF !DEF(LEVEL3_INC)
LEVEL3_INC SET 1 

Level3MapWidth  EQU 128
Level3MapHeight EQU 128
Level3MapBank   EQU 2
Level3TileSet EQU 0 

; Map positioning
Level3MapOriginX EQU 104
Level3MapOriginY EQU 0 
Level3MapOriginIndex EQU Level3MapOriginY*Level3MapWidth + Level3MapOriginX

; Player sprite positioning
Level3SpawnX EQU 90 
Level3SpawnY EQU 40 

GLOBAL Level3Map

ENDC