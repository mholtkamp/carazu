IF !DEF(STATS_INC)
STATS_INC SET 1 

; Equates 
HEART_ENTRY_X EQU 1 
BUBBLE_ENTRY_X EQU 16 
DEBUG_LY_ENTRY_X EQU 7

; Variables 
GLOBAL HeartEntries
GLOBAL BubbleEntries
GLOBAL DebugLYEntries

GLOBAL PlayerHearts
GLOBAL PlayerBubbles
GLOBAL DebugLY

; Procedures 
GLOBAL Stats_Reset
GLOBAL Stats_LoadFromSave
GLOBAL Stats_LoadGraphics
GLOBAL Stats_Update
GLOBAL Stats_Hide
GLOBAL Stats_Show 

GLOBAL Stats_RecordLY


ENDC 