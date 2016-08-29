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

Level7Props:
DB 64			; Map Width 
DB 32 			; Map Height 
DB 2 			; Map Bank 
DB 0 			; Tileset 

DB 0 			; Map Origin X
DB 14 			; Map Origin Y
DB 2 			; Player Spawn X
DB 28 			; Player Spawn Y

DW Level7Items			; Item List Pointer
DW Level7Enemies		; Enemy List Pointer 
DW Level7Map 			; Pointer to map data 
DB 0,0 					; 2 extra bytes to make 16-bytes long 

Level8Props:
DB 128			; Map Width 
DB 64 			; Map Height 
DB 4 			; Map Bank 
DB 0 			; Tileset 

DB 0 			; Map Origin X
DB 45 			; Map Origin Y
DB 2 			; Player Spawn X
DB 60 			; Player Spawn Y

DW Level8Items			; Item List Pointer
DW Level8Enemies		; Enemy List Pointer 
DW Level8Map 			; Pointer to map data 
DB 0,0 					; 2 extra bytes to make 16-bytes long 

Level9Props:
DB 32			; Map Width 
DB 128 			; Map Height 
DB 4 			; Map Bank 
DB 0 			; Tileset 

DB 4 			; Map Origin X
DB 0 			; Map Origin Y
DB 15 			; Player Spawn X
DB 4 			; Player Spawn Y

DW Level9Items			; Item List Pointer
DW Level9Enemies		; Enemy List Pointer 
DW Level9Map 			; Pointer to map data 
DB 0,0 					; 2 extra bytes to make 16-bytes long 

Level10Props:
DB 32			; Map Width 
DB 128 			; Map Height 
DB 4 			; Map Bank 
DB 1 			; Tileset 

DB 0 			; Map Origin X
DB 0 			; Map Origin Y
DB 5 			; Player Spawn X
DB 1 			; Player Spawn Y

DW Level10Items			; Item List Pointer
DW Level10Enemies		; Enemy List Pointer 
DW Level10Map 			; Pointer to map data 
DB 0,0 					; 2 extra bytes to make 16-bytes long 

Level11Props:
DB 64			; Map Width 
DB 64 			; Map Height 
DB 5 			; Map Bank 
DB 1 			; Tileset 

DB 0 			; Map Origin X
DB 5 			; Map Origin Y
DB 5 			; Player Spawn X
DB 14 			; Player Spawn Y

DW Level11Items			; Item List Pointer
DW Level11Enemies		; Enemy List Pointer 
DW Level11Map 			; Pointer to map data 
DB 0,0 					; 2 extra bytes to make 16-bytes long 

Level12Props:
DB 128			; Map Width 
DB 32 			; Map Height 
DB 5 			; Map Bank 
DB 1 			; Tileset 

DB 0 			; Map Origin X
DB 14 			; Map Origin Y
DB 2 			; Player Spawn X
DB 28 			; Player Spawn Y

DW Level12Items			; Item List Pointer
DW Level12Enemies		; Enemy List Pointer 
DW Level12Map 			; Pointer to map data 
DB 0,0 					; 2 extra bytes to make 16-bytes long 

Level13Props:
DB 32			; Map Width 
DB 32 			; Map Height 
DB 5 			; Map Bank 
DB 1 			; Tileset 

DB 0 			; Map Origin X
DB 14 			; Map Origin Y
DB 2 			; Player Spawn X
DB 25 			; Player Spawn Y

DW Level13Items			; Item List Pointer
DW Level13Enemies		; Enemy List Pointer 
DW Level13Map 			; Pointer to map data 
DB 0,0 					; 2 extra bytes to make 16-bytes long 

Level14Props:
DB 128			; Map Width 
DB 128 			; Map Height 
DB 6 			; Map Bank 
DB 1 			; Tileset 

DB 53 			; Map Origin X
DB 1 			; Map Origin Y
DB 64 			; Player Spawn X
DB 10 			; Player Spawn Y

DW Level14Items			; Item List Pointer
DW Level14Enemies		; Enemy List Pointer 
DW Level14Map 			; Pointer to map data 
DB 0,0 					; 2 extra bytes to make 16-bytes long 

Level15Props:
DB 64			; Map Width 
DB 64 			; Map Height 
DB 5 			; Map Bank 
DB 1 			; Tileset 

DB 41 			; Map Origin X
DB 45 			; Map Origin Y
DB 59 			; Player Spawn X
DB 60 			; Player Spawn Y

DW Level15Items			; Item List Pointer
DW Level15Enemies		; Enemy List Pointer 
DW Level15Map 			; Pointer to map data 
DB 0,0 					; 2 extra bytes to make 16-bytes long 

Level16Props:
DB 32			; Map Width 
DB 128 			; Map Height 
DB 7 			; Map Bank 
DB 1 			; Tileset 

DB 0 			; Map Origin X
DB 109 			; Map Origin Y
DB 6 			; Player Spawn X
DB 124 			; Player Spawn Y

DW Level16Items			; Item List Pointer
DW Level16Enemies		; Enemy List Pointer 
DW Level16Map 			; Pointer to map data 
DB 0,0 					; 2 extra bytes to make 16-bytes long 

Level17Props:
DB 64			; Map Width 
DB 128 			; Map Height 
DB 7 			; Map Bank 
DB 2 			; Tileset 

DB 43 			; Map Origin X
DB 110 			; Map Origin Y
DB 60 			; Player Spawn X
DB 125 			; Player Spawn Y

DW Level17Items			; Item List Pointer
DW Level17Enemies		; Enemy List Pointer 
DW Level17Map 			; Pointer to map data 
DB 0,0 					; 2 extra bytes to make 16-bytes long 


Level18Props:
DB 64			; Map Width 
DB 32 			; Map Height 
DB 8 			; Map Bank 
DB 2 			; Tileset 

DB 0 			; Map Origin X
DB 14 			; Map Origin Y
DB 2 			; Player Spawn X
DB 28 			; Player Spawn Y

DW Level18Items			; Item List Pointer
DW Level18Enemies		; Enemy List Pointer 
DW Level18Map 			; Pointer to map data 
DB 0,0 					; 2 extra bytes to make 16-bytes long 


Level19Props:
DB 64			; Map Width 
DB 64 			; Map Height 
DB 8 			; Map Bank 
DB 2 			; Tileset 

DB 0 			; Map Origin X
DB 36 			; Map Origin Y
DB 2 			; Player Spawn X
DB 46 			; Player Spawn Y

DW Level19Items			; Item List Pointer
DW Level19Enemies		; Enemy List Pointer 
DW Level19Map 			; Pointer to map data 
DB 0,0 					; 2 extra bytes to make 16-bytes long 


Level20Props:
DB 128			; Map Width 
DB 32 			; Map Height 
DB 7 			; Map Bank 
DB 2 			; Tileset 

DB 0 			; Map Origin X
DB 6 			; Map Origin Y
DB 2 			; Player Spawn X
DB 14 			; Player Spawn Y

DW Level20Items			; Item List Pointer
DW Level20Enemies		; Enemy List Pointer 
DW Level20Map 			; Pointer to map data 
DB 0,0 					; 2 extra bytes to make 16-bytes long 


Level21Props:
DB 32			; Map Width 
DB 32			; Map Height 
DB 8  			; Map Bank 
DB 2 			; Tileset 

DB 0 			; Map Origin X
DB 14 			; Map Origin Y
DB 2 			; Player Spawn X
DB 28  			; Player Spawn Y

DW Level21Items			; Item List Pointer
DW Level21Enemies		; Enemy List Pointer 
DW Level21Map 			; Pointer to map data 
DB 0,0 					; 2 extra bytes to make 16-bytes long 

Level22Props:
DB 32			; Map Width 
DB 32			; Map Height 
DB 8  			; Map Bank 
DB 0 			; Tileset 

DB 0 			; Map Origin X
DB 9 			; Map Origin Y
DB 2 			; Player Spawn X
DB 18  			; Player Spawn Y

DW Level22Items			; Item List Pointer
DW Level22Enemies		; Enemy List Pointer 
DW Level22Map 			; Pointer to map data 
DB 0,0 					; 2 extra bytes to make 16-bytes long 

Level23Props:
DB 32			; Map Width 
DB 32			; Map Height 
DB 8  			; Map Bank 
DB 1 			; Tileset 

DB 0 			; Map Origin X
DB 9 			; Map Origin Y
DB 2 			; Player Spawn X
DB 18  			; Player Spawn Y

DW Level23Items			; Item List Pointer
DW Level23Enemies		; Enemy List Pointer 
DW Level23Map 			; Pointer to map data 
DB 0,0 					; 2 extra bytes to make 16-bytes long 

Level24Props:
DB 32			; Map Width 
DB 32			; Map Height 
DB 8  			; Map Bank 
DB 2 			; Tileset 

DB 0 			; Map Origin X
DB 9 			; Map Origin Y
DB 2 			; Player Spawn X
DB 18  			; Player Spawn Y

DW Level24Items			; Item List Pointer
DW Level24Enemies		; Enemy List Pointer 
DW Level24Map 			; Pointer to map data 
DB 0,0 					; 2 extra bytes to make 16-bytes long 