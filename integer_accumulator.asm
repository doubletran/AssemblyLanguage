TITLE Integer Accumulator     (Proj3_trantr3.asm)

; Author: 					Tran Tran
; Last Modified:			10/19/2022
; OSU email					trantr3@oregonstate.edu
; Course number/section:	CS271 400
; Project					03- Integer Accumulator
; Due Date					Oct 23
; Description:				This program will take negative numbers from user and  
;							 display the count of valid negative inputs, the sum, 
;							the maximum, the minimum, the rounded integer and decimal average
; Input:					negative numbers
;Output:					the count, sum, maximum, minimum, rounded integer average and decimal average

INCLUDE Irvine32.inc

.data
;PROMPT
;introduction and prompting
Intro		BYTE	">>>>>>>>>>>>>>>>>>>>>>>>>  INTEGER ACCUMULATOR by Tran Tran  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
			BYTE	13,10,13,10,"**EC:This program will number the lines during user input for valid entries"
			BYTE	13,10,"**EC:This program will calculate and display the average as decimal-point number"
			BYTE	13,10,13,10,"We will accumulate user input negative integers within bounds,"
			BYTE	" then display the statistics including the minimum, maximum, and averages, and the total number of valid inputs.",13,10,0
Name?		BYTE	13,10,"How can I call you? ",0
Greeting	BYTE	"Nice to meet you, ", 0
Prompt		BYTE	". Enter a number from -200 to -100 or from -50 to -1 (enter non-negative number to display the result): ",0
;error message
Error		BYTE	13,10,"Error: Numbers are not within ranges. Please try again!",0
NoInput		BYTE	13,10, "NO INPUT ENTERED.",0
;display prompt
Display		BYTE	13,10,">>>>>>>>>>>>>> Here is your statistic <<<<<<<<<<<<<<<<<", 0
PrtCount	BYTE	13,10,"Numbers of valid input: ",0
PrtSum		BYTE	13,10,"The sum of valid numbers: ",0
PrtMax		BYTE	13,10,"The maximum valid number: ", 0
PrtMin		BYTE	13,10, "The minimum valid number: ",0
PrtIntAvg	BYTE	13, 10, "The rounded integer average: ",0
PrtDecAvg	BYTE	13,10, "The rounded decimal average: ", 0

;CONSTANT LIMIT
BOTTOM_1	EQU		-200
TOP_1		EQU		-100
BOTTOM_2	EQU		-50
TOP_2		EQU		-1

;USER INPUT
userName	BYTE	100 DUP(?)
val			DWORD	0

;STATISTICS
count		DWORD	0
sum			DWORD	0
max			DWORD	0
min			DWORD	0
int_avg		DWORD	0
dec_avg		DWORD	0
avg			DWORD	0
diff		DWORD	0
factor		DWORD	100
half		DWORD	2
Goodbye		BYTE	13,10,">>>>>>>>>>>>>> Thanks for using Integer Accumulator! See you next time <<<<<<<<<<<<<<",0


.code
main PROC

;---------- INTRODUCTION---
; display program title and purposes
; perform conversational greeting: ask for user name and greet them
; --------------------------
awake:
	MOV		EDX, OFFSET Intro
	Call	WriteString
	Call	CrLf
	;ask for user name and assign input valud to name variable
	mov		edx, offset Name?
	Call	WriteString
	mov		edx, offset	userName
	mov		ecx, 100
	Call	ReadString
	;greet user with user's name
	mov		edx, offset Greeting
	call	WriteString
	mov		edx, offset userName
	call	WriteString
	call	crlf


;---------COLLECT NUMBER--------------
;prompt for number input until user enter non-negative number
;	if invalid: display error message and prompt user input
;	if valid:	update min, max, count and sum value
;-------------------------------------

prompting:
	call	crlf
	mov		eax, count
	add		eax, 1
	call	WriteDec
	MOV		EDX, OFFSET Prompt
	Call	writeString
	Call	ReadInt
	js		verify
	cmp		count, 0
	je		no_input
	mov		ecx, 1
	jmp		calculating
no_input:
	mov		edx, offset NoInput
	call	writeString
	jmp		asleep
	
verify:
	cmp		eax, BOTTOM_1
	jl		invalid
	cmp		eax, TOP_1
	jle		valid
	cmp		eax, BOTTOM_2
	jl		invalid
	jmp		valid

invalid:
	mov		edx, offset Error
	call	WriteString
	jmp		prompting

;---------UPDATE STATISTICS--------------------------------
;increment count of valid number
;add input to total sum
;initialize minimum and maximum to the first input number
;compare value to current minimum and maximum:
;	if number is larger than current maximum: update maximum
;	if number is smaller than current minimum: update minimum
;-------------------------------------	--------------------
valid:
	inc		count
	add		sum, eax
	cmp		count, 1
	je		initial
	cmp		eax, min
	jl		update_min
	cmp		eax, max
	jg		update_max
	jmp		prompting

update_min:
	mov		min, eax
	jmp		prompting
update_max:
	mov		max, eax
	jmp		prompting
initial:
	mov		min, eax
	mov		max, eax
	jmp		prompting

;----------AVEGERAGE CALCULATION---------
;rounding method:
;	step 1: take two decimal points into account into rounding
;			by multiplying sum by 100 before dividing sum by count
;	step 2: calculating the difference between quotient and unrounded integer
;			if the difference is larger than 50 ( or .50), decrement the average
;			otherwise, keep the average unchanged
;----------------------------------------	
calculating:
	;record the original quotient as average = sum/count
	mov		eax,sum
	cdq
	idiv	count
	mov		avg, eax
	;(step 1) multiply sum by factor (100) and dividing it by count 
	mov		eax, sum
	imul	eax, factor
	cdq
	idiv	count
	mov		diff, eax
	mov		eax, avg 
	imul	eax, factor ;multiply quotient by 100
	;(step 2)calculate the difference between unrounded average and quotient
	sub		eax, diff
	mov		diff, eax
	mov		eax, factor
	xor		edx, edx
	div		half      ;divide factor by half: 100/2 = 50
	cmp		diff, eax ;compare the difference with 50
	jle		update_avg	
	dec		avg			

;-------UPDATE AVERAGE-------------------------------
;we need to do 2 calculation twice for both integer average and decimal average:
;	1. after first loop:
;		update integer average
;		multiply sum by factor (100) to prepare for the next calculation of
;		two-decimal point rounded average
;	2. after second loop:
;		update decimal average and proceed to next step
;-----------------------------------------------------		
update_avg:
	mov		eax, avg
	cmp		ecx, 1		;check the number of calculating loop done
	je		updating_int_avg
	pop		sum
	mov		dec_avg, eax
	jmp		displaying

updating_int_avg:
	mov		int_avg, eax
	mov		eax, sum
	push	eax			;preserve actual value of sum on stacks
	imul	eax, factor	;multiply sum value by 100
	mov		sum, eax
	dec		ecx
	jmp		calculating

;----------DISPLAYING STATISTICS------
displaying:
	MOV		EDX, OFFSET Display
	Call	writeString
	Call	CrLf
	;count
	mov		edx, offset PrtCount
	call	WriteString
	mov		eax, count
	Call	writeDec
	;maximum
	mov		edx, offset PrtMax
	Call	writeString
	mov		eax, max
	Call	writeInt
	;minimum
	mov		edx, offset PrtMin
	Call	writeString
	mov		eax, min
	Call	writeInt
	;sum
	mov		edx, offset PrtSum
	Call	writeString
	mov		eax, sum
	Call	writeInt
	;rounded average
	mov		edx, offset PrtIntAvg
	Call	writeString
	mov		eax, int_avg
	Call	writeInt
	;decimal rounded average: print separated decimal and integer part
	mov		edx, offset PrtDecAvg
	Call	writeString
	mov		eax, dec_avg
	cdq
	idiv	factor		;divide result by factor to print the integer part
	Call	writeInt
	mov		al,'.'		;decimal point
	call	writeChar
	mov		eax, edx	;print the decimal part
	neg		eax			
	call	writeDec
	Call	CrLf

;--------- SAY GOODBYE-------
asleep:
	MOV		EDX, OFFSET Goodbye
	Call	WriteString
	Call	CrLf

	Invoke ExitProcess,0	; exit to operating system
main ENDP


END main
