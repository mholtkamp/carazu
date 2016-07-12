SECTION "FontTiles", HOME

FullFontVRAMAddress EQU $9400		; 64 characters 
NumbersFontVRAMAddress EQU $9760	; 10 characters

FontTiles:
DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
DB $18, $18, $18, $18, $18, $18, $18, $18, $00, $00, $18, $18, $18, $18, $00, $00 
DB $36, $36, $36, $36, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
DB $6C, $6C, $FE, $FE, $FE, $FE, $6C, $6C, $FE, $FE, $FE, $FE, $6C, $6C, $00, $00 
DB $18, $18, $3C, $3C, $20, $20, $3C, $3C, $04, $04, $3C, $3C, $18, $18, $00, $00 
DB $00, $00, $C6, $C6, $CC, $CC, $18, $18, $30, $30, $66, $66, $C6, $C6, $00, $00 
DB $00, $00, $18, $18, $18, $18, $7E, $7E, $7E, $7E, $18, $18, $18, $18, $00, $00 
DB $18, $18, $18, $18, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
DB $0C, $0C, $18, $18, $30, $30, $30, $30, $30, $30, $18, $18, $0C, $0C, $00, $00 
DB $30, $30, $18, $18, $0C, $0C, $0C, $0C, $0C, $0C, $18, $18, $30, $30, $00, $00 
DB $10, $10, $54, $54, $38, $38, $FE, $FE, $38, $38, $54, $54, $10, $10, $00, $00 
DB $00, $00, $18, $18, $18, $18, $7E, $7E, $7E, $7E, $18, $18, $18, $18, $00, $00 
DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $18, $18, $30, $30, $00, $00 
DB $00, $00, $00, $00, $00, $00, $3C, $3C, $3C, $3C, $00, $00, $00, $00, $00, $00 
DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $18, $18, $18, $18, $00, $00 
DB $00, $00, $00, $00, $06, $06, $0C, $0C, $18, $18, $30, $30, $60, $60, $00, $00 
DB $3C, $3C, $66, $66, $66, $66, $66, $66, $66, $66, $66, $66, $3C, $3C, $00, $00 
DB $38, $38, $38, $38, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $00, $00 
DB $38, $38, $7C, $7C, $4C, $4C, $1C, $1C, $70, $70, $60, $60, $7C, $7C, $00, $00 
DB $7C, $7C, $7C, $7C, $04, $04, $1C, $1C, $04, $04, $7C, $7C, $7C, $7C, $00, $00 
DB $66, $66, $66, $66, $66, $66, $7E, $7E, $7E, $7E, $06, $06, $06, $06, $00, $00 
DB $3E, $3E, $7E, $7E, $70, $70, $7E, $7E, $06, $06, $7E, $7E, $7E, $7E, $00, $00 
DB $7C, $7C, $7C, $7C, $60, $60, $7E, $7E, $7E, $7E, $62, $62, $7E, $7E, $00, $00 
DB $7E, $7E, $7E, $7E, $06, $06, $0E, $0E, $1C, $1C, $18, $18, $18, $18, $00, $00 
DB $7E, $7E, $66, $66, $66, $66, $7E, $7E, $66, $66, $66, $66, $7E, $7E, $00, $00 
DB $3C, $3C, $7E, $7E, $66, $66, $66, $66, $3E, $3E, $06, $06, $06, $06, $00, $00 
DB $00, $00, $00, $00, $18, $18, $18, $18, $00, $00, $18, $18, $18, $18, $00, $00 
DB $00, $00, $00, $00, $18, $18, $18, $18, $00, $00, $18, $18, $30, $30, $00, $00 
DB $06, $06, $0C, $0C, $18, $18, $30, $30, $18, $18, $0C, $0C, $06, $06, $00, $00 
DB $00, $00, $7E, $7E, $7E, $7E, $00, $00, $7E, $7E, $7E, $7E, $00, $00, $00, $00 
DB $60, $60, $30, $30, $18, $18, $0C, $0C, $18, $18, $30, $30, $60, $60, $00, $00 
DB $78, $78, $CC, $CC, $8C, $8C, $18, $18, $30, $30, $00, $00, $30, $30, $00, $00 
DB $7C, $7C, $82, $82, $BA, $BA, $AA, $AA, $BE, $BE, $82, $82, $7C, $7C, $00, $00 
DB $38, $38, $7C, $7C, $6C, $6C, $C6, $C6, $FE, $FE, $C6, $C6, $C6, $C6, $00, $00 
DB $FC, $FC, $CC, $CC, $CC, $CC, $FE, $FE, $C6, $C6, $C6, $C6, $FE, $FE, $00, $00 
DB $7C, $7C, $FC, $FC, $C0, $C0, $C0, $C0, $C0, $C0, $FC, $FC, $7C, $7C, $00, $00 
DB $F8, $F8, $CC, $CC, $C6, $C6, $C6, $C6, $C6, $C6, $CE, $CE, $FC, $FC, $00, $00 
DB $FE, $FE, $FE, $FE, $C0, $C0, $FC, $FC, $C0, $C0, $FE, $FE, $FE, $FE, $00, $00 
DB $FE, $FE, $FE, $FE, $C0, $C0, $F8, $F8, $C0, $C0, $C0, $C0, $C0, $C0, $00, $00 
DB $7C, $7C, $FE, $FE, $C0, $C0, $CE, $CE, $C2, $C2, $FE, $FE, $7C, $7C, $00, $00 
DB $C6, $C6, $C6, $C6, $C6, $C6, $FE, $FE, $C6, $C6, $C6, $C6, $C6, $C6, $00, $00 
DB $3C, $3C, $3C, $3C, $18, $18, $18, $18, $18, $18, $3C, $3C, $3C, $3C, $00, $00 
DB $7E, $7E, $7E, $7E, $0C, $0C, $0C, $0C, $6C, $6C, $7C, $7C, $7C, $7C, $00, $00 
DB $CC, $CC, $DC, $DC, $F8, $F8, $F0, $F0, $F8, $F8, $DC, $DC, $CC, $CC, $00, $00 
DB $C0, $C0, $C0, $C0, $C0, $C0, $C0, $C0, $C0, $C0, $FE, $FE, $FE, $FE, $00, $00 
DB $C6, $C6, $EE, $EE, $FE, $FE, $FE, $FE, $D6, $D6, $C6, $C6, $C6, $C6, $00, $00 
DB $C6, $C6, $E6, $E6, $F6, $F6, $FE, $FE, $DE, $DE, $CE, $CE, $C6, $C6, $00, $00 
DB $7C, $7C, $FE, $FE, $C6, $C6, $C6, $C6, $C6, $C6, $FE, $FE, $7C, $7C, $00, $00 
DB $FC, $FC, $FE, $FE, $C6, $C6, $FE, $FE, $FC, $FC, $C0, $C0, $C0, $C0, $00, $00 
DB $78, $78, $CC, $CC, $84, $84, $84, $84, $9C, $9C, $CC, $CC, $76, $76, $00, $00 
DB $FC, $FC, $FC, $FC, $CC, $CC, $FC, $FC, $F8, $F8, $DC, $DC, $CE, $CE, $00, $00 
DB $3C, $3C, $7E, $7E, $70, $70, $38, $38, $1C, $1C, $FC, $FC, $78, $78, $00, $00 
DB $FE, $FE, $FE, $FE, $38, $38, $38, $38, $38, $38, $38, $38, $38, $38, $00, $00 
DB $C6, $C6, $C6, $C6, $C6, $C6, $C6, $C6, $C6, $C6, $FE, $FE, $7C, $7C, $00, $00 
DB $C6, $C6, $C6, $C6, $6C, $6C, $6C, $6C, $6C, $6C, $38, $38, $38, $38, $00, $00 
DB $C6, $C6, $C6, $C6, $C6, $C6, $D6, $D6, $D6, $D6, $D6, $D6, $FE, $FE, $00, $00 
DB $C6, $C6, $EE, $EE, $7C, $7C, $38, $38, $7C, $7C, $EE, $EE, $C6, $C6, $00, $00 
DB $C6, $C6, $C6, $C6, $EE, $EE, $7C, $7C, $38, $38, $38, $38, $38, $38, $00, $00 
DB $FE, $FE, $FE, $FE, $1C, $1C, $38, $38, $70, $70, $FE, $FE, $FE, $FE, $00, $00 
DB $38, $38, $30, $30, $30, $30, $30, $30, $30, $30, $30, $30, $38, $38, $00, $00 
DB $00, $00, $00, $00, $60, $60, $30, $30, $18, $18, $0C, $0C, $06, $06, $00, $00 
DB $38, $38, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $38, $38, $00, $00 
DB $10, $10, $38, $38, $6C, $6C, $C6, $C6, $00, $00, $00, $00, $00, $00, $00, $00 
DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $FE, $FE, $00, $00





LoadFont_Full::

ld bc, FullFontVRAMAddress
ld hl, FontTiles
ld de, 64*16 ; 64 characters, 16 bytes each

.loop
	ld a, [hl+]
	ld [bc], a 
	inc bc 
	dec de 
	ld a, d 
	or e 
	jp nz, .loop
	ret
	