; Print.s
; Student names: change this to your names or look very silly
; Last modification date: change this to the last modification date or look very silly
; Runs on LM4F120 or TM4C123
; EE319K lab 7 device driver for any LCD
;
; As part of Lab 7, students need to implement these LCD_OutDec and LCD_OutFix
; This driver assumes two low-level LCD functions
; ST7735_OutChar   outputs a single 8-bit ASCII character
; ST7735_OutString outputs a null-terminated string 

    IMPORT   ST7735_OutChar
    IMPORT   ST7735_OutString
    EXPORT   LCD_OutDec
    EXPORT   LCD_OutFix

d	equ	0
ctr	equ	4
	
    AREA    |.text|, CODE, READONLY, ALIGN=2
		
cm	DCB	0x20, 0x63, 0x6D, 0x00

    THUMB

  

;-----------------------LCD_OutDec-----------------------
; Output a 32-bit number in unsigned decimal format
; Input: R0 (call by value) 32-bit unsigned number
; Output: none
; Invariables: This function must not permanently modify registers R4 to R11
LCD_OutDec
	SUB SP, #8
	MOV R2, SP
	PUSH {R11, LR}
	MOV R11, R2
	MOV R2, #0
	STR R2, [R11, #ctr]
	MOV R1, R0
	CMP R1, #0
	BNE LOOP1
	MOV R0, #0x30
	BL ST7735_OutChar
	B DONEP
LOOP1	
	CMP R1, #0
	BEQ DONEPR
	MOV R2, #10
	
	UDIV R0, R1, R2
	MLS R0, R2, R0, R1
	
	STR R0, [R11, #d]
	MOV R2, #10
	UDIV R1, R2
	PUSH {R0, R1}
	LDR R2, [R11, #ctr]
	ADD R2, #1
	STR R2, [R11, #ctr]
	B LOOP1

DONEPR
	LDR R2, [R11, #ctr]
	CMP R2, #0
	BEQ DONEP
	POP {R0, R1}
	ORR R0, #0x30
	BL ST7735_OutChar
	LDR R2, [R11, #ctr]
	SUB R2, #1
	STR R2, [R11, #ctr]
	B DONEPR
	
DONEP
	POP {R11, LR}
	ADD SP, #8
	BX  LR
;* * * * * * * * End of LCD_OutDec * * * * * * * *

; -----------------------LCD _OutFix----------------------
; Output characters to LCD display in fixed-point format
; unsigned decimal, resolution 0.001, range 0.000 to 9.999
; Inputs:  R0 is an unsigned 32-bit number
; Outputs: none
; E.g., R0=0,    then output "0.000 "
;       R0=3,    then output "0.003 "
;       R0=89,   then output "0.089 "
;       R0=123,  then output "0.123 "
;       R0=9999, then output "9.999 "
;       R0>9999, then output "*.*** "
; Invariables: This function must not permanently modify registers R4 to R11
LCD_OutFix
	SUB SP, #8 ; R1 -> data , R0 -> d
	MOV R2, SP
	PUSH {R11, LR, R4, R5}
	MOV R11, R2
	MOV R1, R0
	
	LDR R2, =9999
	CMP R1, R2
	BLS NORMAL
	MOV R0, #0x2A
	BL ST7735_OutChar
	MOV R0, #0x2E
	BL ST7735_OutChar
	MOV R0, #0x2A
	BL ST7735_OutChar
	MOV R0, #0x2A
	BL ST7735_OutChar
	MOV R0, #0x2A
	BL ST7735_OutChar
	B DONEAst
	
NORMAL	
	MOV R2, #1000
	UDIV R0, R0, R2
	STR R0, [R11, #d]
	ORR R0, #0x30
	PUSH {R1, R2}
	BL ST7735_OutChar
	MOV R0, #0x2E
	BL ST7735_OutChar
	POP {R1, R2}
	MOV R2, #1000
	UDIV R0, R1, R2
	MLS R1, R2, R0, R1
	MOV R2, #100
	UDIV R0, R1, R2
	STR R0, [R11, #d]
	ORR R0, #0x30
	PUSH {R1, R2}
	BL ST7735_OutChar
	POP {R1, R2}
	MOV R2, #100
	UDIV R0, R1, R2
	MLS R1, R2, R0, R1
	MOV R2, #10
	UDIV R0, R1, R2
	STR R0, [R11, #d]
	ORR R0, #0x30
	PUSH {R1, R2}
	BL ST7735_OutChar
	POP {R1, R2}
	MOV R2, #10
	UDIV R0, R1, R2
	MLS R1, R2, R0, R1
	MOV R2, #1
	UDIV R0, R1, R2
	STR R0, [R11, #d]
	ORR R0, #0x30
	BL ST7735_OutChar

DONEAst
	LDR R0, =cm
	BL ST7735_OutString
	
	POP {R11, LR, R4, R5}
	ADD SP, #8
    BX   LR
 
     ALIGN
;* * * * * * * * End of LCD_OutFix * * * * * * * *

     ALIGN                           ; make sure the end of this section is aligned
     END                             ; end of file
