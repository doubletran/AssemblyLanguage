TITLE Prime Numbers     (Proj4_trantr3.asm)

; Author: 					Tran Tran
; Last Modified:			10/31/2022
; OSU email					trantr3@oregonstate.edu
; Course number/section:	CS271 400
; Project					04- Prime Numbers
; Due Date					Nov 06
; Description:				This program will take user input as the amounts of prime numbers 
;							to be displayed by useray the count of valid negative inputs, the sum, 
; Input:					integer number - n
; Output:					n prime numbers

INCLUDE Irvine32.inc

.data
;introduction
Intro		BYTE	">>>>>>>>>>>>>>>>>>>>>>>>>  PRIME NUMBERS ARE FUN by Tran Tran  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
			BYTE	13,10,13,10,"**EC:This program will align the output columns"
			BYTE	13,10,"**EC:This program can up to 4000 primes, shown 20 rows of primes per page"
			BYTE	13,10,13,10,"Enter how many prime numbers you want to see and we handle it."
			BYTE	13,10,"Remember! we can display up to 4000 numbers for you - amazing, right!? ",0
Prompt		BYTE	13, 10, "Enter the number of primes to display [1...4000]: ",0
;error message
Error		BYTE	13,10,"Sorry! We can't take number out of range! Please try again.",0

Goodbye		BYTE	13,10,">>>>>>>>>>>>>> Thanks for using Prime Numbers! See you next time <<<<<<<<<<<<<<",0
;string and integer indicating rows and columns to nicely display prime numbers
PrtTab		BYTE	9, " ", 0
Continue?	BYTE	13, 10, "Press any key to continue... or you can press Esc to quit :( ",13,10,0
row			DWORD	20
col			DWORD	7


;CONSTANT LIMIT
BOTTOM		EQU		1
TOP			EQU		4000

count		DWORD	0
current		DWORD	0

.code
main PROC
	call introduction
	call getUserData
	call showPrimes
main ENDP

;---------- -------------------------------------------------
; Name: introduction
; Procedure to introduce the program.
; Preconditions: Intro are strings to display the indtroduction message
; Postcondistions: EDX changed
; Receives: none
; Returns: none
; ------------------------------------------------------------
introduction PROC
	MOV		EDX, OFFSET Intro
	Call	WriteString
	Call	CrLf
	ret
introduction ENDP

;---------- -------------------------------------------------
; Name: getUserData
; Procedure to collect user input as the count of prime numbers be displayed
; user have to enter numbers within range 1-4000, otherwise, the program will 
; display error messages
; Preconditions: Prompt is string, count exist
; Postcondistions: edx changed
; Receives: count  = count of prime numbers to be displayed
; Returns: valid count
; ------------------------------------------------------------
getUserData PROC
	MOV		EDX, OFFSET Prompt
	Call	writeString
	Call	ReadInt
	call	validate
getUserData	ENDP

;;---------- -------------------------------------------------
; Name: validate
; Procedure to validate user input if it is within range from 1 to 4000
; Preconditions: BOTTOM and TOP are constants specifying 
;				lower limit (1) and upper limit (4000)
;				Error are strings to be displayed if input is out of range
;				eax contains user input
; Postcondistions: EDX, EAX changed
; Receives: eax
; Returns: valid count
; ------------------------------------------------------------
validate PROC
	cmp		eax, BOTTOM
	jl		invalid
	cmp		eax, TOP
	jg		invalid
	mov		count, eax
	mov		current, 2
	ret
invalid:
	mov		edx, offset Error
	call	WriteString
	call	getUserData
validate ENDP


;---------- -------------------------------------------------
; Name: showPrimes
; Procedure to filter and display rime numbers
; Preconditions: count is updated and validated, current is initialized
;				to 2 as it is the first prime number
; Postcondistions: eax, edx changed
; Receives: count
; Returns: prime numbers
; ------------------------------------------------------------
showPrimes PROC
	mov		ecx, count		;assign count to ecx to set the number of loop
	call	crlf

;----filter------
;Loop until ecx (which is initially set equal to count) reaches 0
;The filter loop will check and print only prime numbers
;main approach: loop through odd numbers
;push the current to stack to reserve it for printing later
filter:
	push	current
	cmp		current, 2
	jne		check

;---initial------------
; called when the current is 2 - when the program starts looping
; this will set the current to 3 and print 2 after the first loop
;-----------------------
	initial:
		mov		current, 3
		jmp		print

;---check-------------------
;this inner loop will check the current value if it is prime
;	if it is, print it
;	if it is not, remove the stored current on the stack (by popping).
;				and store the next larger odd numbers as the current
;-----------------------------
	check:
		call	isPrime
		add		current, 2		;increment by 2
		cmp		ax, 1			;if current value is prime
		je		print
		pop		eax
		push	current			;store the new current value and keep checking
		jmp		check

;---print----------------
;retrieve the stored value on the stack and print it,
;then call formatTable procedure to align it nicely
;------------------------
	print:
		pop		eax
		call	writeDec
		call	formatTable
	loop	filter
	call	farewell
	ret
showPrimes ENDP

;---------- -------------------------------------------------
; Name: formatTable
; Procedure to nicely handle tab, rows, and columns according to table formatting
; Preconditions: PrtTab string contains tab key value to print
;				between values
;				col and row integer indicate numbers of rows
;				and columns in each table
; Postcondistions: eax, edx changed
; Receives: count, col, row
; Returns: none
; ------------------------------------------------------------
formatTable PROC
	mov		edx, offset PrtTab		;print tab
	call	writeString
	mov		eax, count
	inc		eax
	sub		eax, ecx				;eax = numbers of prime numbers displayed
	xor		edx, edx
	mov		ebx, COL
	div		ebx						;divide eax/ebx (col = 7)
	cmp		edx, 0					;the remainder equal 0 when the current row
									;have displayed enough columns
	je		newline					;continue printing on the next row
	ret
;-----------newline---------------
;called when program goes on to the next row
;we need to keep track of number of current rows displayed,
;once this number reach 20, program will stop and ask if user 
;wants to continue printing
;---------------------------------
newline:
	call	Crlf
	dec		row
	cmp		row, 0					
	je		pressToContinue
	ret
pressToContinue:
	mov		edx, offset Continue?
	call	writeString
	no_input:
	call	readKey
	jz		no_input
	cmp		ah, 1				;'ESC' KEY =1
	jne		continue	
	call	farewell
	continue:
	call	crlf
	mov		row, 20
	ret
formatTable	ENDP

;---------- -------------------------------------------------
; Name: isPrime
; Procedure to check wheteher the current number is prime.
; The program return 0 if it is not prime and 1 if it is prime
; procedure will check prime number by dividing the current
; value by all smaller odd divisors until it reaches itself
; Preconditions: current variable is assgned to be checked
; Postcondistions:eax, ebx changed, ax becomes the boolean value
; containing whether the number is prime or not
; Receives:current
; Returns: ax
; ------------------------------------------------------------
isPrime PROC
	mov		ebx, 3
;------division------
; the loop increments odd numbers as divisors
; and divide the current number by new divisors
; loop will stop once the current number is divisible 
;--------------------
division:
	xor		edx, edx
	mov		eax, current
	div		ebx
	cmp		edx, 0
	je		endDivision
	add		ebx, 2
	mov		eax, current
	jmp		division
;-----endDivision-----
;jumped to when remainder of the current division equals to 0
; if loop ended because it reaches the current number, it is prime 
; otherwise, it is not
;----------------------
endDivision:
	cmp		eax, 1	;if the quotient equals 1, 
					;dividend is divided by itself
	je		valid
	mov		ax, 0	;update ax = 0 (it's not prime)
	ret

valid:
	mov		ax, 1
	ret

isPrime	ENDP

;---------- -------------------------------------------------
; Name: farewell
; Procedure to display goodbye once the program exit
; Preconditions: Goodbye string contains the message
;				procedure is called when user presses exit 
;				or the program has done printing prime numbers
; Postcondistions: edx changed
; Receives: Goodbye string
; Returns: none
; ------------------------------------------------------------
farewell PROC
	call	crlf
	MOV		EDX, OFFSET Goodbye
	Call	WriteString
	Call	CrLf
	Invoke ExitProcess, 0 
	ret
farewell ENDP


END main
