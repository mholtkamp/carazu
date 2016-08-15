IF !DEF(UTIL_INC)
UTIL_INC SET 1 

; hl = ROM tile address
; b  = 0: Sprite Tiles   1: BG Tiles 
; c  = Number of tiles to load 
; d  = rom bank 
; e  = tile index offset in vram 
GLOBAL LoadTiles


; push0 = map width, map height 
; b = x tile offset (in vram)
; c = y tile offset (in vram)
; d = ROM bank 
; e = 0: Load into BG map, 1: Load into window map
; hl = rom map address 
GLOBAL LoadMap


; hl = null-terminated text string 
; b = x tile pos 
; c = y tile pos 
; d = 0: BG, 1: Window 
GLOBAL WriteText

; b = vram map number. 0 = MAP_0     1 = MAP_1
GLOBAL ClearMap

ENDC 