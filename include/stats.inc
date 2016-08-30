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
GLOBAL HasFermata
GLOBAL HasBass
GLOBAL HasAllegro
GLOBAL PlayTime
GLOBAL RecordTime
GLOBAL RecordBubbles
GLOBAL Secret1
GLOBAL Secret2
GLOBAL Secret3 
GLOBAL DebugLY

; Procedures 
GLOBAL Stats_ResetRun
GLOBAL Stats_LoadFromSave
GLOBAL Stats_InitNoSave
GLOBAL Stats_SaveRun
GLOBAL Stats_SaveRecords
GLOBAL Stats_SaveSecrets
GLOBAL Stats_LoadGraphics
GLOBAL Stats_Update
GLOBAL Stats_Hide
GLOBAL Stats_Show
GLOBAL Stats_LoadFinale 
GLOBAL Stats_IncrementTimer

GLOBAL Stats_RecordLY


ENDC 