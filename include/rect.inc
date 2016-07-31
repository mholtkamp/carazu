
IF !DEF(RECT_INC)
RECT_INC SET 1

BIT_COLLIDED_LEFT  EQU 0
BIT_COLLIDED_RIGHT EQU 1 
BIT_COLLIDED_UP    EQU 2
BIT_COLLIDED_DOWN  EQU 3

BIT_SPIKE EQU 0 
BIT_DOOR EQU 1 
BIT_SECRET_DOOR EQU 2 
BIT_SPRING_UP EQU 4
BIT_SPRING_DOWN EQU 5 
BIT_SPRING_LEFT EQU 6 
BIT_SPRING_RIGHT EQU 7

; MoveRect_Fixed
; input: 
;   hl = rect address 
;   bc = x-move component 
;   de = y-move component 
;    a = collision threshold
; output:
; 	 a = collision bitfield
;	 b =  special bitfield 
GLOBAL MoveRect_Fixed

; CheckRectGrounded
; input:
;   hl - rect 	
;    a - collision threshold 
; output:
;	a - 1 if grounded, 0 otherwise 
GLOBAL CheckRectGrounded_Fixed

; UpdateSpriteOAM
;   push0 = [Rect Address]  
;   push1 = [OAM Address] 
;   push2 = [Rect Offset X, Rect Offset Y]
;   push3 = [Sprite Char Width/ Sprite Char Height]
;   push4 = [SpritePattern, SpriteIndex]
;   push5 = [0, FlipX/FlipY]
GLOBAL UpdateOAMFromRect_Fixed 


; Rect_CheckSpecials
; input:
;   hl = rect 
; 
; output:
;  b = special bitfield 
GLOBAL Rect_CheckSpecials

; RectOverlapsRect_Int
; hl = rect1 
; de = rect2
; ret: a = 1 if overlap. 0 otherwise 
GLOBAL RectOverlapsRect_Int

; RectOverlapsRect_Int_Fixed
; hl = rect1 (int)
; de = rect2 (fixed)
; ret: a = 1 if overlap. 0 otherwise 
GLOBAL RectOverlapsRect_Int_Fixed

ENDC 