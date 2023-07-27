TITLE String Processor     (Proj6_trantr3.asm)

; Author: 					Tran Tran
; Last Modified:			11/29
; OSU email					trantr3@oregonstate.edu
; Course number/section:	CS271 400
; Project					06 - String processor
; Due Date					Dec 04
; Description:				This program will use string processing to
;							take user input for 10 valid integers and
;							print the inputs with the sum and truncated average

INCLUDE Irvine32.inc

; --------------------------------------------------------------------------------- 
; Name: mGetString 
; 
; Get user input as string 
; 
; Preconditions: edx, ecx, eax
;
; Receives: 
; _buffer		= buffer address
; _numChar		= pointer to number of bytes read	
; ecx			= maximum character can be read
; 
; returns: 
;_buffer		= address of input string 
;_numChar		= address of enumber of bytes read
; --------------------------------------------------------------------------------- 
mGetString		MACRO	_buffer, _numChar
	pushad
	mov		edx, _buffer
	mov		ecx, MAXCHAR
	call	ReadString
	mov		[numchar], eax
	popad
ENDM

; --------------------------------------------------------------------------------- 
; Name: mDisplayString
; 
; Display string stored in parameters 
; 
; Preconditions: edx
;
; Receives: 
; _buffer		= address of string to be written
; 
; returns: none
; --------------------------------------------------------------------------------- 
mDisplayString	MACRO	 _buffer
	push	edx
	mov		edx, _buffer
	call	writeString
	pop		edx
ENDM

;CONSTANT VARIABLE
COUNT		equ		10
MAXCHAR		equ		15

ZERO		equ		48
NINE		equ		57
COL			equ		20
PRECISION	equ		6

.data
;PROMPT
;introduction and prompting
Intro		BYTE	"~~~~~~~~~~~~~~~~~~~~ Number Reader in low-level I/O procedures ~~~ by Tran Tran  ~~~~~~~~~~~~~~~~~~~~~~~~", 13, 10,
					13,10,"~ Purpose: Number Reader will process and validate user input as signed integer using string primitives",
					13,10, "~ Action: Please provide 10 signed decimal integers (each number should fit inside a 32 bit register).",13,10,
					"We will display a list of valid integers, with the sum and the average.",13,10,0
ExtraCred	BYTE	13,10, "**EC: Number each line of user input and display a running subtotal of the user’s valid numbers",
					13,10, "**EC: Read and write floating point value: ",13, 10,0
Goodbye		BYTE	13,10, 13, 10, "Thanks for using Number Reader! See you next time ",0
;display prompt
PromptInt	BYTE	". Enter a signed integer that fit inside a 32 bit register: ",0
PromptFloat	BYTE	". Enter a signed float value: ", 0

PrtError	BYTE	"INVALID INPUT! Please try again!", 13, 10,0
PrtInput	BYTE	13,10,"VALID INPUTS: ", 0
PrtSum		BYTE	13,10,"FINAL SUM: ", 0
PrtCurSum	BYTE	13, 10, "Current subtotal: ", 0
PrtAvg		BYTE	13,10,"AVERAGE: ", 0

intArray	SDWORD	COUNT		DUP(?)
sum			SDWORD	0

floatArray	REAL10	COUNT		DUP(0.0)
separator	BYTE	", ", 0

numValid	DWORD	0
floatSum	REAL10	0.0

.code
main PROC
	;introduction
	mDisplayString offset Intro
	mDisplayString offset ExtraCred

;-----------------------
;read_int
;loop (ecx = COUNT) to pass address of current position of 
;integer array into procedure readVal
;-----------------------	
	mov		ecx, COUNT
	mov		edi, offset intArray
read_int:
	;-----------------
	;lineNumber: number the current line when prompting input
	;			using numValid
	;numValid: number of valid input from user
	;-----------------
	lineNumber:
		call	crlf
		mov		eax, numValid
		inc		eax
		push	eax
		call	writeVal

	mDisplayString	offset PromptInt

	push	offset numValid
	push	edi					;edi = &(position in intArray)
	call	readVal

	mDisplayString	offset PrtCurSum

	push	offset intArray
	push	offset sum
	call	getIntSum
; -------------------------- 
; check if input is valid
;	if numValid increases after readVal, input is valid
;		update address of the next element in the array to continue loop
;	else
;		print error and increment ecx for next loop
; -------------------------- 
	mov		eax, COUNT
	sub		eax, numValid		;eax = number of entries left to prompt
	cmp		eax, ecx			;if eax = ecx, numValid doesn't increase
	je		read_int_error
	add		edi, TYPE intArray
	jmp		read_int_cont	
	
read_int_error:
	mDisplayString offset PrtError
	inc		ecx

read_int_Cont:
	loop	read_int
; -------------------------- 
; write_int loop pass value of integer array to procedure writeVal
; loop will print value followed by comma until loop reaches the 
; last value in the array
 
; -------------------------- 
	mDisplayString offset PrtInput

	mov		ecx, COUNT
	mov		esi, offset intArray
write_int:
	lodsd
	push	eax
	call	writeVal
	cmp		ecx, 1
	je		write_int_cont

	mDisplayString offset separator

write_int_cont:
	loop	write_int

;----- SUM ------
	mDisplayString offset PrtSum
	push	sum
	call	writeVal			

;-----AVERAGE-----
	mDisplayString offset PrtAvg
	push	sum
	call	GetIntAverage
;-----------------------
;read_float
;loop (ecx = COUNT) to pass address of current position of 
;float array into procedure readFloatVal
;-----------------------	
	mov		numValid, 0
	mov		ecx, COUNT
	mov		edi, offset floatArray

read_float:

	call	crlf
	mov		eax, numValid
	inc		eax
	push	eax
	call	writeVal

	mDisplayString	offset PromptFloat
	push	offset numValid
	push	edi					;edi = &floatArray
	call	readFloatVal

	mDisplayString	offset PrtCurSum

	push	offset floatArray
	push	offset floatSum
	call	getFloatSum
	call	crlf

	mov		eax, COUNT
	sub		eax, numValid		;eax = COUNT - numValid		
	cmp		eax, ecx
	je		read_float_error

	add		edi, TYPE floatArray
	jmp		read_float_cont		

read_float_error:
	mDisplayString offset PrtError
	inc		ecx

read_float_cont:
	loop	read_float
; -------------------------- 
; write_float loop pass value of float array to procedure writeFloatVal
; loop will print value followed by comma until loop reaches the 
; last value in the array
 
; -------------------------- 
	mDisplayString offset PrtInput

	mov		ecx, COUNT
	mov		esi, offset floatArray
write_float:
	push	esi
	call	writeFloatVal
	add		esi, type floatArray
	cmp		ecx, 1
	je		write_float_cont

	mDisplayString offset separator

write_float_cont:
	loop	write_float

;SUM
	mDisplayString offset PrtSum

	mov		esi, offset floatSum
	push	esi
	call	writeFloatVal	
;AVERAGE
	mDisplayString offset PrtAvg

	push	offset floatSum
	call	GetFloatAverage


	mDisplayString offset Goodbye

	Invoke ExitProcess, 0 
main ENDP

; --------------------------------------------------------------------------------- 
; Name: ReadVal
;  
; Procedure to read string input and convert string of ascii digits
; to its numeric valud representation
; 
; Preconditions: the empty array of integers
; 
; Postconditions: numValid changes if input is valid
; 
; Receives:  
; [ebp+12] = address of number of valid input
; [ebp+8] = address of position to insert integer
; MAXCHAR: constant
; ZERO and NINE are global constants containing lower and upper limit of numeric 
;	representation in ascii
; 
; returns: integer representation of user input
; --------------------------------------------------------------------------------- 
ReadVal PROC 
	local	sign:SDWORD, numChar: DWORD, readBuffer[MAXCHAR]:BYTE
	pushad
	lea		eax, numChar
	lea		edi, readBuffer
	mGetString	edi, eax
	mov		ecx, numChar
	lea		esi, readBuffer		
	mov		edi, [ebp+8]		
	mov		ebx, 0
	mov		sign, 1
; -------------------------- 
; validating loop (counter = numbers of bytes read) load one character in buffer to eax
; and check if the character is valid
;	input is valid if chracters are numeric (within 0-9) or sign (+ or -)
;
; -------------------------- 
validating:
	xor		eax, eax
	lodsb
	cmp		al, ZERO
	jl		check_pos
	cmp		al, NINE
	jg		return
; -------------------------- 
; if character is numeric, 
;	convert it to integer representation by  subtracting it from ZERO
;	increment numValid passed to the procedure
;	
; -------------------------- 
numeric:
	imul	ebx, 10
	jo		return
	sub		eax, ZERO
	imul	eax, sign
	add		ebx, eax
	jo		return
	loop	validating

	mov		[edi], ebx			;store valid input
	mov		edi, [ebp+12]		;edi = address of number of valid inputs
	inc		dword ptr [edi]
	jmp		return
	
check_pos:
	cmp		ecx, numChar
	jne 	return
	cmp		al, '+'
	jne		check_neg
	loop	validating

check_neg:
	cmp		al, '-'
	jne		return
	neg		sign
	loop	validating

return:
	popad
	ret		8
ReadVal	ENDP
; --------------------------------------------------------------------------------- 
; Name: ClearBuffer
;  
; Initialize all elements inside buffer to 0 using string primitives
; 
; Preconditions: address of buffer
; 
; Receives:  
; [ebp+8] = address of buffer
; MAXCHAR: constant variable
; 
; returns: all-zeros array
; --------------------------------------------------------------------------------- 
ClearBuffer	PROC uses ebp
	mov		ebp, esp
	pushad
	mov		edi, [ebp+8]
	mov		ecx, MAXCHAR		
	mov		eax, 0
	rep		stosb
	popad
	ret		4
ClearBuffer	endp

; --------------------------------------------------------------------------------- 
; Name: WriteVal
;  
; Convert integer array to its ascii representation to print out
; 
; Preconditions: the integer value
; 
; Receives:  
;	[ebp+8] = integer value 
; MAXCHAR is global constant
; --------------------------------------------------------------------------------- 
WriteVal PROC 
	local	numChar:DWORD, writeBuffer[MAXCHAR]:BYTE
	pushad	
	mov		numChar, 0

	lea		edi, writeBuffer
	push	edi
	call	ClearBuffer

	mov		ecx, 0
	mov		eax, [ebp+8]
	cmp		eax, 0			
	jge		convert

	push	eax
	mov		al, '-'			;write minus sign
	stosb
	pop		eax
	neg		eax
	inc		numChar
; -------------------------- 
; convert: convert integer value to ascii representation
;	separate each digits by dividing the number by 10 
;	storing the remainder
;	
; -------------------------- 
convert:

	mov		ebx, 10
	xor		edx, edx
	div		ebx
	add		edx, ZERO

	push	edx
	inc		ecx
	cmp		eax, 0			;eax = result = 0 when done converting
	jne		convert

	add		numChar, ecx

result:
	pop		eax
	stosb
	loop	result
	lea		edi, writeBuffer
	mDisplayString	edi
	popad
	ret		4
WriteVal ENDP
; --------------------------------------------------------------------------------- 
; Name: getIntSum
;  
; Get the sum of integer array
; 
; Preconditions: the array contains integers, and address to store its sum, 
;				number of integer in the array
; 
; Postconditions: none. 
; 
; Receives:  
; [ebp+12] = address of the array
; [ebp+8] = address of sum
; COUNT is global variable
; 
; returns: calculated sum
; ---------------------------------------------------------------------------------																																																									
getIntSum	PROC uses ebp
	mov		ebp, esp
	pushad
	mov		esi, [ebp+12]
	mov		edi, [ebp+8]
	mov		ecx, COUNT
	mov		sdword ptr [edi], 0

_sumLoop:
	lodsd					;eax = each value in integer array
	add		[edi], eax
	loop	_sumLoop
	mov		eax, [edi]

	push	eax
	call	writeVal
	call	crlf
	popad
	ret		8
getIntSum	ENDP
; --------------------------------------------------------------------------------- 
; Name: ReadFloatVal
;  
; Procedure to read string input and convert string of ascii digits
; to its numeric value representation
; 
; Preconditions: the empty array of  float
; 
; Postconditions: numValid changes if input is valid
; 
; Receives:  
; [ebp+12] = address of number of valid input
; [ebp+8] = address of position to insert float
; MAXCHAR: global variable
; 
; returns: float representation of string input
; --------------------------------------------------------------------------------- 
ReadFloatVal PROC 
	local	sign:SDWORD
	local	numChar: DWORD, numDecimal:SDWORD	
	local	whole:SDWORD, decimal:SDWORD
	local	readBuffer[MAXCHAR]:BYTE
	pushad

	lea		eax, numChar
	lea		edi, readBuffer
	mGetString	edi, eax

	lea		esi, readBuffer	
	mov		edi, [ebp+8]		;edi = &memory location in floatArray

	mov		ebx, 0
	mov		sign, 1
	mov		decimal, 0
	mov		numDecimal, 0
	mov		ecx, numChar
; -------------------------- 
; validating loop (counter = numbers of bytes read) load one character in buffer to eax
; and check if the character is valid
;	input is valid if chracters are numeric (within 0-9), sign (+ or -), .
;
; -------------------------- 
validating:
	xor		eax, eax
	lodsb
	cmp		al, ZERO
	jl		nonnumeric
	cmp		al, NINE
	jg		return
; -------------------------- 
; if character is numeric, 
;	convert it to integer representation by  subtracting it from ZERO
;	increment numValid passed to the procedure
;	
; -------------------------- 
numeric:
	inc		numDecimal
	imul	ebx, 10
	jo		return

	sub		eax, ZERO
	imul	eax, sign
	add		ebx, eax
	jo		return	

	loop	validating

	mov		eax, numDecimal
	cmp		eax, numChar
	jl		get_decimal

	mov		whole, ebx
	mov		ebx, 0
	jmp		get_decimal
																
nonnumeric:
	cmp		al, "."				;floating point
	jne		check_sign
	;-------------------
	;if current character is '.', store previous loaded valuable to decimal
	;	then, do validation on the next elements by initiazing ebx to 0
	;
	;--------------------
	mov		whole, ebx		
	mov		numDecimal, 0			
	mov		ebx, 0
	loop	validating
	jmp		return

check_sign:
	cmp		ecx, numChar
	jne		return
	cmp		al, '+'
	jne		check_neg
	loop	validating

check_neg:
	cmp		al, '-'
	jne		return
	neg		sign
	inc		numDecimal
	loop	validating

return:
	popad
	ret		8
;-------------------
; get_float: 
; float: initial value of float contain integer representation of float
;	divide float by the power of 10 determined by its count to get 
;	floating point
; decimal: add decimal to float on FPU stack
;--------------------
get_decimal:
	mov		decimal, ebx
	mov		ecx, numDecimal
	mov		edx, 1	

power_of_10:
	imul	edx, 10
	loop	power_of_10

	mov		numDecimal, edx

	finit
	fild	numDecimal
	fild	decimal				;change floating part from integer to float
	fdiv	st(0), st(1)
	fild	whole				;st(0) = whole, st(1) = decimal
	fadd	
	fstp	real10 ptr [edi]

	mov		edi, [ebp+12]		;if valid: increment numValid
	inc		dword ptr [edi]
	jmp		return
ReadFloatVal	ENDp

; --------------------------------------------------------------------------------- 
; Name: WriteFloatVal
;  
; Convert float value to its ascii representation to print out
; 
; Preconditions: float value passed on stack
; 
; Receives:  
;	[ebp+8] = float value 
; MAXCHAR is global constant
; PRECISION (global constant) indicates number of value after 
;
; Returns:
;	printed string of ascii digits representing float value
; --------------------------------------------------------------------------------- 
writeFloatVal	PROC
	local	wholeTrue:DWORD, sign:SDWORD
	local	whole:SDWORD, factor:SDWORD
	local	writeBuffer[MAXCHAR]:BYTE
	pushad

	lea		edi, writeBuffer
	push	edi
	call	ClearBuffer

	mov		wholeTrue, 0
	mov		factor, 10
	mov		sign, 1

	finit
	mov		esi, [ebp+8]
	fld		real10 ptr [esi]
	lea		esi, sign	
	mov		ecx, PRECISION
; -------------------------- 
; get_whole loop: maximum counter = precision 
;	first loop: store and sign (if any) whole number 
;	2nd, 3rd,... loop: multiply decimal by 10 to get the next decimal 
;	value one at a time
;	loop wlll get terminated when there is no decimal value returned from procedures
;	GetWhole will return negative sign when no more decimal value left or whole is negative

; -------------------------- 
get_whole:
	push	ecx
	mov		ecx, 0
	push	esi
	call	GetWhole
	fist	whole			;st(0) = whole, st(1) = float
	fsub	
	mov		eax, whole
	cmp		sign, 0
	jg		convert
; -------------------------- 
;wholeTrue = 0 when whole number hasn't been loaded
; if whole number has been stored and sign is negative, load minus sign
; if whole number hasn't been stored and sign is negative, there is no more decimal value, jump to write

; -------------------------- 
	cmp		wholeTrue, 0	
	je		minus_sign		
	pop		ecx
	jmp		write			

minus_sign:
	push	eax
	mov		al, '-'			
	stosb
	pop		eax
	mov		sign, 1
; -------------------------- 
; convert: convert float value to ascii representation
;	separate each digits by dividing the number by 10 
;	and pushing the remainder
;	
; -------------------------- 
convert:
	xor		edx, edx
	div		factor
	add		edx, ZERO
	push	edx
	inc		ecx
	cmp		eax, 0
	jne		convert

result:
	pop		eax
	stosb
	loop	result
	cmp		wholeTrue, 0
	je		decimal_point
	jmp		get_decimal
; -------------------------- 
; decimal_point is called after whole number is just stored to buffer
;	store decimal point and a zero right after the whole number 
;	
; -------------------------- 
decimal_point:
	mov		wholeTrue, 1
	mov		eax, '.'		
	stosb
	mov		eax,'0'
	stosb
	dec		edi				;set edi after decimal point
; -------------------------- 
;get_decimal: multiplying decimal by 10 to get the next decimal value
;	as whole by looping get_whole
;	
; -------------------------- 
get_decimal:
	fild	factor
	fmul
	pop		ecx
	loop	get_whole
	jmp		write
write:
	lea		edi, writeBuffer
	mDisplayString  edi
	popad
	ret		4
WriteFloatVal endp
		
; --------------------------------------------------------------------------------- 
; Name: GetFloatSum
;  
; Get the sum of float array
; 
; Preconditions: the array contains float array, and address to store its sum, 
;				number of value in the array
; 
; Postconditions: none. 
; 
; Receives:  
; [ebp+12] = address of the array
; [ebp+8] = address of sum
; COUNT is constant
; 
; returns: calculated sum
; ---------------------------------------------------------------------------------	
GetFloatSum	PROC uses ebp
	mov		ebp, esp
	pushad

	mov		edi, [ebp+8]
	mov		esi, [ebp+12]	

	finit
	fld		real10 ptr [esi]		;load first value of the array onto FPU stack

	mov		ecx, COUNT
	dec		ecx

_sumLoop:
	add		esi, type real10	
	fld		real10 ptr[esi]			;st(0) = array[n+1], st(1) = array[n]
	fadd							
	loop	_sumLoop

	fstp	real10 ptr[edi]			;store and pop to address of the sum
	push	edi
	call	writeFloatVal			;write sum
	popad
	ret		8
GetFloatSum	ENDP
; --------------------------------------------------------------------------------- 
; Name: getIntAverage
;  
; Get integer average by dividing sum value by count and print the result
; 
; Preconditions: calculated sum and count
; 
; Postconditions: none. 
; 
; Receives:  
; [ebp+8] = sum value
; COUNT is global constant
; 
; returns: calculated average = sum/COUNT
; ---------------------------------------------------------------------------------																																																	
GetIntAverage	PROC 
	local	sign:SDWORD
	pushad

	mov		sign, 1
	mov		eax, [ebp+8]
	mov		ebx, COUNT
	xor		edx, edx
	cmp		eax, 0
	jg		division			
	neg		eax
	mov		sign, -1				;if sum value is negative, update sign to -1

division:
	idiv	ebx						;average = sum/count *sign
	imul	eax, sign	

	push	eax
	call	writeVal
	call	crlf
	popad
	ret		4
GetIntAverage	ENDP
; --------------------------------------------------------------------------------- 
; Name: getFloatAverage
;  
; Get Float average of float array by dividing sum by count
; 
; Preconditions: the array contains float, and address to store its average, 
;				calculated sum
; 
; Postconditions: none. 
; 
; Receives:  
; [ebp+8] = address of sum value
; COUNT is global constant
; 
; returns: calculated average = sum/COUNT
; ---------------------------------------------------------------------------------	
GetFloatAverage	PROC 
	local	floatCount:SDWORD, avg:real10
	mov		floatCount, COUNT
	pushad
	mov		esi, [ebp+8]

	finit
	fld		real10 ptr [esi]		;st(0) = sum
	fild	floatCount				;st(0) = count, st(1) = sum
	fdiv
	fstp	avg
	lea		esi, avg

	push	esi
	call	writeFloatVal
	popad
	ret		4
GetFloatAverage	ENDP
; --------------------------------------------------------------------------------- 
; Name: getWhole
;  
; Get the whole part of float number
; 
; Preconditions: float value is in st(0)
; 
; Receives:  st(0) = float
; 
; returns: st(0) = whole
; ---------------------------------------------------------------------------------	
GetWhole PROC
	local	factor:SDWORD, whole: SDWORD
	pushad
	xor		ebx, ebx
	mov		factor, 100				;increase factor to increase precision
	fild	factor
	fmul	st(0), st(1)			;st(0) = float *10
	fistp	whole					;store integer round of st(0)
	fabs

	cmp		whole, 0
	jg		division

	mov		edi, [ebp+8]
	mov		ebx, -1
	mov		[edi], ebx
	neg		whole
; -------------------------- 
; division
;	false whole = integer of float multiplied by 10
;	divide false whole by 10 to get the first number
;	of the whole stored in eax 
;	
;--------------------------																
division:
	mov		eax, whole
	xor		edx, edx
	idiv	factor
	mov		whole, eax
positive:
	fild	whole
	popad
	ret		4
GetWhole	ENDP
	
END main