TITLE Sorting machine     (Proj5_trantr3.asm)

; Author: 					Tran Tran
; Last Modified:			11/06/2022
; OSU email					trantr3@oregonstate.edu
; Course number/section:	CS271 400
; Project					05 - Sorting machine
; Due Date					Nov 20
; Description:				Program will sort 200 random integers betwwen 15 and 50 and display the median value
; Output:					unsorted list of 200 random integers, sorted list, list of instances, median value

INCLUDE Irvine32.inc
;CONSTANT LIMIT
ARRAYSIZE	EQU		200
LO			equ		15
HI			equ		50
COL			equ		20

.data
;PROMPT
;introduction and prompting
Intro		BYTE	"~~~~~~~~~~~~~~~~~~~~ SORTING MACHINE ~~~ by Tran Tran  ~~~~~~~~~~~~~~~~~~~~~~~~"
			BYTE	13,10,13,10,"~ Purpose: Sorting Machine can sort self-generated 200 random integers from 15 to 50",
					13,10, "~ Action: It will display the original list, display the sorted list in ascending order with median value",
					13, 10, "and finally display the number of instance of each generated value, starting with the number of lowest." ,13,10,0
Goodbye		BYTE	13,10, 13, 10, "Thanks for using Sorting Machine! See you next time ",0
;display prompt
PrtUnsort	BYTE	13,10,"~~~ UNSORTED RANDOM NUMBERS ~~~", 13, 10, 13,10,0
PrtSort		BYTE	13,10,"~~~ SORTED RANDOM NUMBERS ~~~", 13, 10, 13,10, 0
PrtMedian	BYTE	13,10,"~~~ MEDIAN VALUE: ", 0
PrtInst		BYTE	13,10,13, 10,"~~~ INSTANCES IN ASCENDING ORDER ~~~",13, 10,13, 10, 0


randArray	DWORD	ARRAYSIZE DUP(?)
counts		DWORD	(HI-LO+1)	DUP(?)



.code
main PROC
	;introduction
	push	offset Intro
	call	introduction

	;fill random number onto the array
	call	Randomize				;generate random seeds
	push	offset randArray
	call	fillArray

	;display unsorted list
	push	offset prtUnsort
	push	offset randArray
	push	LENGTHOF randArray
	call	displayList

	;sorting
	push	offset randArray
	call	sortList

	;display sorted list
	push	offset PrtSort
	push	offset randArray
	push	LENGTHOF randArray
	call	displayList

	;calculate and display median
	push	offset prtMedian
	push	offset randArray
	call	displayMedian

	;create list of instances 
	push	offset randArray
	push	offset counts
	call	countList

	;display list of instances
	push	offset PrtInst
	push	offset counts
	push	LENGTHOF counts
	call	displayList


	;display closing message
	push	offset Goodbye
	call	introduction

	Invoke ExitProcess, 0 
main ENDP
;------------------------------------------------------------
; Name: introduction
; Procedure to introduce the program.
; Preconditions: Intro are strings to display the indtroduction message
; Postcondistions: EDX changed
; Receives: none
; Returns: none
; ------------------------------------------------------------
introduction PROC
	push	ebp
	mov		ebp, esp
	mov		edx, [ebp+8]
	call	writeString
	pop		ebp
	Call	CrLf
	ret		4
introduction ENDP

;------------------------------------------------------------
; Name: fillArray
; Procedure to fill the array with random numbers
; Preconditions: Empty array with initialized size, global 
; constants of size, upper bound (HI), lower bound (LO)
; and random seed
; Postcondistions: edi, ecx, eax
; Receives: address of the empty array, 
; Returns: array with self-generated random numbers
; ------------------------------------------------------------
fillArray	PROC
	push	ebp
	mov		ebp, esp
	mov		edi, [ebp+8]		;address of array in edi
	mov		ecx, ARRAYSIZE
	mov		eax, HI
	inc		eax					;since RandomRange generate within exclusive range
	sub		eax, LO

;-----generate-----------
; generate random number loop from 0-15 inclusive by
; using RandomRange from 0 - 36 (exclusive) and add 15 to the result
;------------------------
generate:
	push	eax
	call	RandomRange			;generate 0-35
	add		eax, LO
	mov		[edi], eax
	add		edi, 4				;increment to the next element
	pop		eax
	loop	generate
	
	pop		ebp
	ret		4
fillArray	ENDP

;------------------------------------------------------------
; Name: displayList
; Procedure to display the list according to its size, with one space
; between them with certain number of values displayed per row
; Preconditions: array with size
; Postcondistions: edx, ecx, ebx, esi, eax changed
; Receives: address of array and its size on system stack
; Returns: none
; ------------------------------------------------------------
displayList	PROC
	push	ebp
	mov		ebp, esp
	mov		edx, [ebp+16]	
	call	writeString			;display title
	mov		esi, [ebp+12]
	mov		ecx, [ebp+8]

	mov		ebx, 0				;to keep track of current number in a row

;------prtList------
; loop to print number in array with a space between
; increment to the next address
; if the current number printed in a row reach COL limit, print new line 
; ------------------

prtList:
	mov		eax, [esi]
	call	writeDec
	mov		al, 32
	call	writeChar
	add		esi, 4
	inc		ebx
	cmp		ebx, COL
	jne		continue
	call	crlf				;print new line
	mov		ebx, 0				;set tracker to 0
continue:
	loop	prtList
	call	crlf
	pop		ebp
	ret		12	
displayList ENDP

;------------------------------------------------------------
; Name: sortList
; Procedure to sort the list in ascending order
; Preconditions: array with size
; Postcondistions: ebx, ecx, eax, edx, edi, esi changed
; Receives: address of the array 
; Returns: sorted array
; ------------------------------------------------------------
sortList PROC USES EBP
	mov		ebp, esp
	mov		edi, [ebp+8]
	mov		ecx, ARRAYSIZE
	mov		eax, LO
	mov		edx,0				;count of sorted number
;--sort-----------	
; edx: keep track of numbers of already sorted value
; eax: contain the lowest value among those haven't been sorted 
;		(initialized to LO)
; ebx: the current position being evaluated
; ecx: counter of loops 
; sort loop will loop through every elements to find 
; the lowest value to be sorted and then swap it to the correct position
;------------------------
sort:
	mov		ecx, ARRAYSIZE
	sub		ecx, edx			;subtracting ecx from edx so that loop won't loop 			
	mov		ebx, edx			;through sorted value
	cmp		edx, ARRAYSIZE		;if number of sorted elements reach array's size
	je		return
;--findMin---------
; loop through all elements to find the lowest value
; to be sorted (eax)
; once ecx reaches 0, increment the lowest value and loop again 
;-----------------
findMin:
	cmp		[edi+ebx*4], eax
	jle		swap
	inc		ebx					;increment to the next position 
	loop	findMin
	inc		eax					
	jmp		sort
	
;--swap-----------
;once the lowest value is identified, 
;swap will call exchangeElements to swap that value with
;the value at edx position
;-----------------
swap:
	push	eax					;reserve the lowest value
	push	edi					;reserve the current position pointer
	imul	eax, ebx, 4
	add		eax, edi
	push	eax					;position of smallest number
	imul	eax, edx, 4	
	add		eax, edi
	push	eax					;position of to-change element
	call	exchangeElements
	inc		edx					;increment the tracker of sorted elements
	inc		ebx			
	pop		edi
	pop		eax
	loop	findMin

	jmp		sort
return:
	ret		4
sortList ENDP

;------------------------------------------------------------
; Name: sortList
; Procedure to exchange elements
; Preconditions: two elements within the array
; Postcondistions: eax, edi, esi changed
; Receives: address of two elements
; Returns: address of two elements swapped
; ------------------------------------------------------------

exchangeElements PROC USES EBP
	mov		ebp, esp
	mov		esi, [ebp+8]		
	mov		edi, [ebp+12]
	mov		eax, [esi]
	xchg	[edi], eax
	xchg	[esi], eax								
	ret 8
exchangeElements ENDP

;------------------------------------------------------------
; Name: displayMedian
; Procedure to calculate and display the median
; if the size of the array is even, median is equal to the average of 
; two middle elements
; if it is odd, median equal to the middle element.
; Preconditions: array with size
; Postcondistions: eax, ebx, ecx, edx, esi changed
; Receives: address of the array 
; Returns: none
; ------------------------------------------------------------
displayMedian	PROC uses ebp
	mov		ebp, esp
	mov		esi, [ebp+8]
	mov		eax, ARRAYSIZE
	xor		edx, edx
	mov		ebx, 2				
	div		ebx					;divide the size by half to get the middle position
	cmp		edx, 0				;if remainder is 0, the size is even
	je		evenSize
	mov		eax, [esi+eax*4]	;if size is odd, use the middle element
	jmp		printMed
evenSize:
	mov		ecx, [esi+eax*4]	;the first middle
	mov		eax, [esi+eax*4-4]	;the second middle
	add		eax, ecx
	div		ebx					;ebx = 2
	cmp		edx, 0				;compare the remainder
	je		printMed	
	inc		eax					;it is not 0, round it up
printMed:
	mov		edx, [ebp+12]
	call	writeString
	call	writeDec
	ret		8
displayMedian	ENDP

;------------------------------------------------------------
; Name: countList
; Procedure to calculate number of instances for each number
; within the range
; Preconditions: sorted array with size, upper bound (HI), lower bound,
;	empty array to keep the instances
; Postcondistions: eax, ebx, ecx, edi, esi changed
; Receives: address of the sorted array, address of the count array
; Returns: count array containing instances
; ------------------------------------------------------------
countList	PROC USES EBP
	mov		ebp, esp
	mov		esi,[ebp+12]		;esi contain sorted array
	mov		edi,[ebp+8]			;edi contain count array to be written to
	mov		ecx, ARRAYSIZE
	mov		ebx, LO
	mov		eax,0
;--instance-------
; loop through every element of the sorted array
; eax: keep track of the instances of the value from the lowest to the highest
; esi: contain the current position in the array
; ebx: keep track of current value in the array
; since the list is sorted, if the current position contains the different value
; from the previous position, save the instances of the current value, increment the current value
; ------------------
instance:
	cmp		[esi], ebx			
	je		increment
	mov		[edi], eax			;save instances in count array
	add		edi,4				
	inc		ebx					;increment the current value
	mov		eax, 0
	inc		ecx					;for the loop to check the current position again with the updated value
	loop	instance
	jmp		return

increment:
	add		esi, 4
	inc		eax					;increment the number of instances
	loop	instance
return:
	mov		[edi], eax			;store the instances of the last number
	ret		8

countList	ENDP



END main
