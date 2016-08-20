INCLUDE "levels/level_properties.inc"
INCLUDE "levels/level_items.inc"
INCLUDE "levels/level_enemies.inc"
INCLUDE "levels/level_maps.inc"


	SECTION "LevelPropertiesData", DATA, BANK[1]

LevelProperties:

Level0Props:
DB 32			; Map Width 
DB 32 			; Map Height 
DB 1 			; Map Bank 
DB 0 			; Tileset 

DB 0 			; Map Origin X
DB 14 			; Map Origin Y
DB 2 			; Player Spawn X
DB 28 			; Player Spawn Y

DW Level0Items			; Item List Pointer
DW Level0Enemies		; Enemy List Pointer 
DW Level0Map 			; Pointer to map data 
DB 0,0 					; 2 extra bytes to make 16-bytes long 


Level1Props:
DB 64			; Map Width 
DB 32 			; Map Height 
DB 1 			; Map Bank 
DB 0 			; Tileset 

DB 0 			; Map Origin X
DB 14 			; Map Origin Y
DB 2 			; Player Spawn X
DB 28 			; Player Spawn Y

DW Level1Items			; Item List Pointer
DW Level1Enemies		; Enemy List Pointer 
DW Level1Map 			; Pointer to map data 
DB 0,0 					; 2 extra bytes to make 16-bytes long 


Level2Props:
DB 64			; Map Width 
DB 32 			; Map Height 
DB 2 			; Map Bank 
DB 0 			; Tileset 

DB 0 			; Map Origin X
DB 0 			; Map Origin Y
DB 2 			; Player Spawn X
DB 7 			; Player Spawn Y

DW Level2Items			; Item List Pointer
DW Level2Enemies		; Enemy List Pointer 
DW Level2Map 			; Pointer to map data 
DB 0,0 					; 2 extra bytes to make 16-bytes long 


Level3Props:
DB 64			; Map Width 
DB 64 			; Map Height 
DB 2 			; Map Bank 
DB 0 			; Tileset 

DB 0 			; Map Origin X
DB 38 			; Map Origin Y
DB 4 			; Player Spawn X
DB 47 			; Player Spawn Y

DW Level3Items			; Item List Pointer
DW Level3Enemies		; Enemy List Pointer 
DW Level3Map 			; Pointer to map data 
DB 0,0 					; 2 extra bytes to make 16-bytes long 

Level4Props:
DB 128			; Map Width 
DB 32 			; Map Height 
DB 2 			; Map Bank 
DB 0 			; Tileset 

DB 0 			; Map Origin X
DB 14 			; Map Origin Y
DB 3 			; Player Spawn X
DB 21 			; Player Spawn Y

DW Level4Items			; Item List Pointer
DW Level4Enemies		; Enemy List Pointer 
DW Level4Map 			; Pointer to map data 
DB 0,0 					; 2 extra bytes to make 16-bytes long 

Level5Props:
DB 128			; Map Width 
DB 32 			; Map Height 
DB 2 			; Map Bank 
DB 0 			; Tileset 

DB 0 			; Map Origin X
DB 12 			; Map Origin Y
DB 2 			; Player Spawn X
DB 21 			; Player Spawn Y

DW Level5Items			; Item List Pointer
DW Level5Enemies		; Enemy List Pointer 
DW Level5Map 			; Pointer to map data 
DB 0,0 					; 2 extra bytes to make 16-bytes long 

Level6Props:
DB 128			; Map Width 
DB 128 			; Map Height 
DB 3 			; Map Bank 
DB 0 			; Tileset 

DB 0 			; Map Origin X
DB 0 			; Map Origin Y
DB 2 			; Player Spawn X
DB 12 			; Player Spawn Y

DW Level6Items			; Item List Pointer
DW Level6Enemies		; Enemy List Pointer 
DW Level6Map 			; Pointer to map data 
DB 0,0 					; 2 extra bytes to make 16-bytes long 