TITLE Elementary Arithmetic     (Proj_trantr3.asm)

; Author: 					Tran Tran
; Last Modified:			10/03/2022
; OSU email					trantr3@oregonstate.edu
; Course number/section:	CS271 400
; Project					01 - Basic Logic and Arithmetic
; Due Date					Oct 16
; Description:				This program will take three values from user input 
;							 display sum and difference, quotient and remainder
; Input:					three values A, B, C (A>B>C)
;Output:					 the sum and differences: (A+B, A-B, A+C, A-C, B+C, B-C, A+B+C,A/C,A/B,B/C)

INCLUDE Irvine32.inc

.data
Greeting	BYTE	"-----------Elementary Arithmetic      by Tran Tran----------"
			BYTE	13,10,"**EC:This program will calculate and display the quotients and remainders",0
			BYTE	13,10,"**EC:This program will repeat until the user chooses to quit",0
			BYTE	13,10,"**EC:This program will verify whether the inputs are in strictly descending order",0
Manual		BYTE	13,10,"Enter 3 nummbers A > B > C to calculate the sums, differences, quotients and remainders",13,10,0
Prompt1		BYTE	13,10,"Enter the first number: ",0
Prompt2		BYTE	13,10,"Enter the second number: ", 0
Prompt3		BYTE	13,10,"Enter the third number: ", 0
Invalid		BYTE	13,10,"Error: Numbers are not in descending order. Please try again!",0
Display		BYTE	13,10,"----Here is your calculation----", 0
Quit?		BYTE	13,10,"Shall we continue?(y/n) ", 0


;string representing subtract, add, and equal sign to display 
plus		BYTE	" + ",0
equal		BYTE	" = ",0
subtract	BYTE	" - ",0
remainder	BYTE	" remainder: ",0
divide		BYTE	"/",0

;val1, val2, val3 to be entered by user
val1		DWORD	0
val2		DWORD	0
val3		DWORD	0
quit		BYTE	?

;result to be displayed
sum12		DWORD	0
sum23		DWORD	0
sum13		DWORD	0
diff12		DWORD	0
diff23		DWORD	0
diff13		DWORD	0
sum123		DWORD	0
div12		DWORD	0
rem12		DWORD	0
div23		DWORD	0
rem23		DWORD	0
div13		DWORD	0
rem13		DWORD	0
Goodbye		BYTE	13,10,"-----Thanks for using Elementary Arithmetic! See you next time-------",0


.code
main PROC
;Introduction
	MOV		EDX, OFFSET Greeting
	Call	WriteString
	Call	CrLf

	MOV		EDX, OFFSET Manual
	Call	WriteString
	Call	CrLf

awake:
;Get the data
	;first number
	MOV		EDX, OFFSET Prompt1
	Call	writeString
	Call	readInt
	MOV		val1, EAX

	;second number: if input is valid, jump to next action
	;otherwise, display invalid message and loop prompting2 again
prompting2:
	MOV		EDX, OFFSET Prompt2
	Call	writeString
	Call	ReadInt
	CMP		val1, EAX
	MOV		val2, EAX
	JA		prompting3
	MOV		EDX, OFFSET Invalid
	Call	writeString
	LOOP	prompting2

	;third number: if input is valid, jump to next action
	;otherwise, display invalid message and loop prompting3 again
prompting3:
	MOV		EDX, OFFSET Prompt3
	Call	writeString
	Call	ReadInt
	CMP		val2, EAX
	MOV		val3, EAX
	JA		calculating
	MOV		EDX, OFFSET Invalid
	Call	writeString
	LOOP	prompting3


;Calculate the required values
calculating:
	;sum of value 1 and value 2
	mov		eax, val1
	mov		ebx, val2
	add		eax, ebx
	mov		sum12, eax

	;sum of three values
	add		eax, val3
	mov		sum123, eax	
	
	;sum of value of 1 and 3 by subtracting value 2 from total sum
	sub		eax, val2
	mov		sum13, eax

	;sum of valud 2 and 3
	add		ebx, val3
	mov		sum23, ebx
	mov		eax, val1
	mov		ebx, val2

	;difference of value 1 and 2
	sub		eax, ebx
	mov		diff12, eax

	;difference of value 2 and 3
	sub		ebx, val3
	mov		diff23, ebx

	;difference of value 1 and 3 = (diff12)+diff(23)
	add		ebx, diff12
	mov		diff13 , ebx

	;value 1 divided by value 2
	mov		eax, val1
	mov		edx, 0
	div		val2
	mov		div12, eax
	mov		rem12, edx

	;value 1 divided by value 3
	mov		eax, val1
	mov		edx, 0
	div		val3
	mov		div13, eax
	mov		rem13, edx

	;value 2 divided by value 3
	mov		eax, val2
	mov		edx, 0
	div		val3
	mov		div23, eax
	mov		rem23, edx

;display result
displaying:
	MOV		EDX, OFFSET Display
	Call	writeString
	Call	CrLf
	;sum of value 1 and 2
	mov		eax, val1
	Call	writeDec
	mov		edx, offset plus
	Call	writeString
	mov		eax, val2
	Call	writeDec
	mov		edx, offset equal
	Call	writeString
	mov		eax, sum12
	Call	writeDec
	Call	CrLf

	;difference of value 1 and 2
	mov		eax, val1
	Call	writeDec
	mov		edx, offset subtract
	Call	writeString
	mov		eax, val2
	Call	writeDec
	mov		edx, offset equal
	Call	writeString
	mov		eax, diff12
	Call	writeDec
	Call	CrLf

	;sum of valud 1 and 3
	mov		eax, val1
	Call	writeDec
	mov		edx, offset plus
	Call	writeString
	mov		eax, val3
	Call	writeDec
	mov		edx, offset equal
	Call	writeString
	mov		eax, sum13
	Call	writeDec
	Call	CrLf

	;difference of value 1 and 3
	mov		eax, val1
	Call	writeDec
	mov		edx, offset subtract
	Call	writeString
	mov		eax, val3
	Call	writeDec
	mov		edx, offset equal
	Call	writeString
	mov		eax, diff13
	Call	writeDec
	Call	CrLf

	;sum of valud 2 and 3
	mov		eax, val2
	Call	writeDec
	mov		edx, offset plus
	Call	writeString
	mov		eax, val3
	Call	writeDec
	mov		edx, offset equal
	Call	writeString
	mov		eax, sum23
	Call	writeDec
	Call	CrLf

	
	;difference of value 2 and 3
	mov		eax, val2
	Call	writeDec
	mov		edx, offset subtract
	Call	writeString
	mov		eax, val3
	Call	writeDec
	mov		edx, offset equal
	Call	writeString
	mov		eax, diff23
	Call	writeDec
	Call	CrLf

	
	;sum of three values
	mov		eax, val1
	Call	writeDec
	mov		edx, offset plus
	Call	writeString
	mov		eax, val2
	Call	writeDec
	mov		edx, offset plus
	Call	writeString
	mov		eax, val3
	Call	writeDec
	mov		edx, offset equal
	Call	writeString
	mov		eax, sum123
	Call	writeDec
	Call	CrLf

	;value 1 divided by value 2
	mov		eax, val1
	Call	writeDec
	mov		edx, offset divide
	Call	writeString
	mov		eax, val2
	Call	writeDec
	mov		edx, offset equal
	Call	writeString
	mov		eax, div12
	Call	writeDec
	mov		edx, offset remainder
	Call	writeString
	mov		eax, rem12
	Call	writeDec
	Call	CrLf

	;value 1 divided by value 3
	mov		eax, val1
	Call	writeDec
	mov		edx, offset divide
	Call	writeString
	mov		eax, val3
	Call	writeDec
	mov		edx, offset equal
	Call	writeString
	mov		eax, div13
	Call	writeDec
	mov		edx, offset remainder
	Call	writeString
	mov		eax, rem13
	Call	writeDec
	Call	CrLf

	;value 2 divided by value 3
	mov		eax, val2
	Call	writeDec
	mov		edx, offset divide
	Call	writeString
	mov		eax, val3
	Call	writeDec
	mov		edx, offset equal
	Call	writeString
	mov		eax, div23
	Call	writeDec
	mov		edx, offset remainder
	Call	writeString
	mov		eax, rem23
	Call	writeDec
	Call	CrLf

;ask whether user want to quit
	;if user choose 'y', jump to awake section
	;otherwise, go to asleep section
	mov		edx, OFFSET	Quit?
	Call	writeString
	Call	readChar
	CMP		al, 'y'
	jz		awake

;Say goodbye
asleep:
	MOV		EDX, OFFSET Goodbye
	Call	WriteString
	Call	CrLf

	Invoke ExitProcess,0	; exit to operating system
main ENDP


END main
