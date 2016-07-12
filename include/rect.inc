
IF !DEF(RECT_INC)
UTIL_INC SET 1

BIT_COLLIDED_LEFT  EQU 0
BIT_COLLIDED_RIGHT EQU 1 
BIT_COLLIDED_UP    EQU 2
BIT_COLLIDED_DOWN  EQU 3

; MoveRect_Integer
;   hl = rect address
;   b  = x-move component
;   c  = y-move component
;   d  = collision threshold
; output:
; 	 a = collision bitfield
;		 BIT_COLLIDED_LEFT  0
;		 BIT_COLLIDED_RIGHT 1 
;		 BIT_COLLIDED_UP    2
;		 BIT_COLLIDED_DOWN  3
GLOBAL MoveRect_Integer

; MoveRect_Fixed
; input: 
;   hl = rect address 
;   bc = x-move component 
;   de = y-move component 
;    a = collision threshold
; output:
; 	 a = collision bitfield
;		 BIT_COLLIDED_LEFT  0
;		 BIT_COLLIDED_RIGHT 1 
;		 BIT_COLLIDED_UP    2
;		 BIT_COLLIDED_DOWN  3
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


ENDC 