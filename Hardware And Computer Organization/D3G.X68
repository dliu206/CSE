*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Display header
		LEA			HEADER,A1	Loads HEADER into address register A1
    	MOVE.B		#14,D0		Moves the number 14 into data register D0
    	TRAP   	 	#15			Displays Message

* Prompt user to input starting location
LOOP1	LEA			MESSAGE1,A1	Loads MESSAGE1 into address register A1
    	MOVE.B		#14,D0		Moves the number 14 into data register D0
    	TRAP   	 	#15			Displays Message

* Read starting address input from keyboard
		LEA		STARTADDR,A1	Set A1 to point to memory location to store user's input
		MOVE.B		#2,D0		TRAP task 2 reads a string from the keyboard into (A1),
*                               storing the length in D1.W (max 80)
		TRAP 		#15			Read address value
		MOVE.B		D1,STARTLEN	Store the length of the string

* Validate input
		CMP.W		#8,D1
		BLE			TEST1		IF length <= 8, do next test on starting address
		LEA			IOERROR1,A1 	ELSE Input is invalid, display error message,
* 									and re-prompt user to input value
		MOVE.B		#14,D0			Moves the number 14 into data register D0
    	TRAP   	 	#15			Displays Message
		BRA			LOOP1		Re-prompt user for input
		
TEST1	CMP.W		#0,D1		check if input is null (0 length)
		BNE			TEST2		IF length != 0, do next test on starting address
		LEA			IOERROR2,A1 	ELSE Input is invalid, display error message,
* 									and re-prompt user to input value
		MOVE.B		#14,D0			Moves the number 14 into data register D0
    	TRAP   	 	#15			Displays Message
		BRA			LOOP1		Re-prompt user for input
		
TEST2	PEA			STARTADDR	Push address of string being modified before calling subroutine
		PEA			STARTLEN	Push length of string being modified before calling subroutine
		BSR			STRIPZ		Strip leading 0s from input, if any exist
		LEA			(8,SP),SP	Pop both parameters off of stack after returning from subroutine
		
		CMP.W		#1,D0		If number is 0 (D1 = 1), then input is not in acceptable range
		BEQ			INVST		
		PEA			STARTADDR	Push parameter to stack before calling subroutine
		BSR			CONVHEX  	Input is correct length, convert characters from ASCII to hex
		LEA			(4,SP),SP	Pop parameter off of stack after returning from subroutine
		CMP.W		#0,D0		
		BNE			TEST3		IF input is valid, continue with next test
		LEA			IOERROR3,A1 	ELSE Input is invalid, display error message,
* 									and re-prompt user to input value
		MOVE.B		#14,D0			Moves the number 14 into data register D0
    	TRAP   	 	#15			Displays Message
		BRA			LOOP1

TEST3	
		MOVE.B		-(A0),D0	Check the least significant bit of the number to test if input is on
*								odd byte boundary (LSB = 1 iff number is odd), A0 points 1 past the last
*								byte of the hexadecimal number input by the user
		LSR.B		#1,D0		If the C flag is 1, the LSB is 1
		BCC			TESTS		IF C != 1 Check if starting address is less than $5000 to avoid loading
*								in program space or region before program starts
		LEA			IOERROR4,A1 	ELSE Input is invalid, display error message,
* 									and re-prompt user to input value
		MOVE.B		#14,D0			Moves the number 14 into data register D0
    	TRAP   	 	#15			Displays Message
		BRA			LOOP1
		
TESTS	CMP.B		#4,STARTLEN	Check if the length is less than 4,
*								meaning the starting address is less than $7000
		BGT			TESTS1		IF the length of the address is greater than 4,
*								the starting address needs to be tested to make sure it doesn't exceed the max value
		BLT			INVST		IF the length of the starting address is less
*								than 4, the starting address is invalid
		MOVE.B		STARTADDR,D1	Load the starting address in D1; since the
*									length of the address is 4, STARTADDR points
*									to the most significant byte in the address
		CMP.B		#5,D1			IF the value in D1 is greater than 5, the address is in correct format
		BGE			LOOP2			Starting address is valid, now prompt user for ending address
		
INVST	LEA			IOERROR11,A1		ELSE starting address is invalid, display
*									error message and re-prompt user for input
		MOVE.B		#14,D0			Moves the number 14 into data register D0
    	TRAP   	 	#15			Displays Message
		BRA			LOOP1		Re-prompt user for input

TESTS1	LEA			STARTADDR,A1	Load the address in A1 to compare its value to the maximum value allowed
		MOVE.L		#3,D0			Initialize loop counter to compare the input address to the max address, corresponding to the $FFFxxx part
*									where the xxx of the input address are not tested unless the first 3 digits are equal to $FFF
		CLR.L		D1
		
LOOPSA	MOVE.B		(A1)+,D1		Load the next leftmost digit from the address to be compared to the corresponding
*									digit until the digits are found to be different
		CMP.B		#$F,D1			
		BLT			LOOP2			If the value is less, the input is valid
		SUBQ		#1,D0			Decrement loop counter
		BNE			LOOPSA
		
* Test the next digit. If it equals D, continue testing. If its greater, the input is invalid. And if its less, the input is valid
		MOVE.B		(A1)+,D1
		CMP.B		#$D,D1
		BGT			INVS
		BLT			LOOP2
		
* Test the last two digits of the address by checking if they equal 00, otherwise the address is too large and the input is invalid
		MOVE.B		(A1)+,D1
		BNE			INVS
		
		MOVE.B		(A1)+,D1
		BEQ			LOOP2			Input passed tests so far, now prompt user to enter starting address

* Starting address is not in allowed range, display error message and re-prompt user for input
INVS	LEA			IOERROR13,A1
		MOVE.B		#14,D0			Moves the number 14 into data register D0
    	TRAP   	 	#15			Displays Message
		BRA			LOOP1

* Prompt user to input ending location
LOOP2	LEA			MESSAGE2,A1	Loads MESSAGE2 into address register A1
    	MOVE.B		#14,D0		Moves the number 14 into data register D0
    	TRAP   	 	#15			Displays Message

* Read ending address input from keyboard
		LEA			ENDADDR,A1	Set A1 to point to memory location to store user's input
		MOVE.B		#2,D0		TRAP task 2 reads a string from the keyboard into (A1),
*                               storing the length in D1.W (max 80)
		TRAP 		#15			Read address value
		MOVE.B		D1,ENDLEN	Store the length of the string

* Validate input
		CMP.W		#8,D1
		BLE			TEST4		IF length <= 8, do next test on ending address
		LEA			IOERROR5,A1 	ELSE Input is invalid, display error message,
* 									and re-prompt user to input value
		MOVE.B		#14,D0			Moves the number 14 into data register D0
    	TRAP   	 	#15			Displays Message
		BRA			LOOP2		Re-prompt user for input
		
TEST4	CMP.W		#0,D1		check if input is null (0 length)
		BNE			TEST5		IF length != 0, do next test on ending address
		LEA			IOERROR2,A1 	ELSE Input is invalid, display error message,
* 									and re-prompt user to input value
		MOVE.B		#14,D0			Moves the number 14 into data register D0
    	TRAP   	 	#15			Displays Message
		BRA			LOOP2		Re-prompt user for input
		
TEST5	PEA			ENDADDR		Push address of string being modified before calling subroutine
		PEA			ENDLEN		Push length of string being modified before calling subroutine
		BSR			STRIPZ		Strip leading 0s from input, if any exist
		LEA			(8,SP),SP	Pop both parameters off of stack after returning from subroutine
		
		CMP.W		#1,D0		If number is 0 (D1 = 1), then no further processing is needed
		BEQ			VALID
		PEA			ENDADDR		Push parameter to stack before calling subroutine
		BSR			CONVHEX  	Input is correct length, convert characters from ASCII to hex
		LEA			(4,SP),SP	Pop parameter off of stack after returning from subroutine
		CMP.W		#0,D0		
		BNE			TESTE			IF input is valid, continue with next test
		LEA			IOERROR3,A1 	ELSE Input is invalid, display error message,
* 									and re-prompt user to input value
		MOVE.B		#14,D0			Moves the number 14 into data register D0
    	TRAP   	 	#15			Displays Message
		BRA			LOOP2

* Verify the ending address is not larger than $00FFF00 since this portion is reserved for the stack. In addition, the memory starting at
* $FFFFFFFF grows in the opposite direction (upwards) than the memory of the program space (downwards). So the memory past $00FFF00 is not allowed to
* be used to load in the program
TESTE	CMP.B		#6,ENDLEN	Check if the length is less than 6
		BLT			VALID		IF the length of the address less than 6, the ending address is valid since its not larger than $00FFFF00
*								the ending address needs to be tested to make sure it doesn't exceed the max value
		BGT			INVEN		IF the length of the starting address is greater
*								than 6, the ending address is invalid since its too big
		BRA			TESTE1
		
INVEN	LEA			IOERROR14,A1		ELSE ending address is invalid, display
*									error message and re-prompt user for input
		MOVE.B		#14,D0			Moves the number 14 into data register D0
    	TRAP   	 	#15			Displays Message
		BRA			LOOP2		Re-prompt user for input

TESTE1	LEA			ENDADDR,A1		Load the address in A1 to compare its value to the maximum value allowed
		MOVE.L		#3,D0			Initialize loop counter to compare the input address to the max address, corresponding to the $FFFxxx part
*									where the xxx of the input address are not tested unless the first 3 digits are equal to $FFF
		CLR.L		D1
		
LOOPEA	MOVE.B		(A1)+,D1		Load the next leftmost digit from the address to be compared to the corresponding
*									digit until the digits are found to be different
		CMP.B		#$F,D1			
		BLT			LOOP2			If the value is less, the input is valid
		SUBQ		#1,D0			Decrement loop counter
		BNE			LOOPEA
		
* Test the next digit. If it equals E, continue testing. If its greater, the input is invalid. And if its less, the input is valid
		MOVE.B		(A1)+,D1
		CMP.B		#$E,D1
		BGT			INVEN
		BLT			LOOP2
		
* Test the last two digits of the address by checking if they equal 00, otherwise the address is too large and the input is invalid
		MOVE.B		(A1)+,D1
		BNE			INVEN
		
		MOVE.B		(A1)+,D1
		BNE			INVEN
		
*Input passed tests so far, now compare starting and ending address to see if they are valid in relation to each other		

* Compare the two addresses input by user to see if they are in valid format
VALID	LEA			STARTADDR,A0	Store starting address
		MOVE.B		STARTLEN,D0		Store length of starting address, also used as a counter for first loop
		LEA			ENDADDR,A1		Store ending address
		MOVE.B		ENDLEN,D1		Store length of ending address, also used as a counter for second loop
		CMP.B		D0,D1			Check if ending length is > than starting length
		BGT			TESTZ		ending length > starting length iff the ending address is after the starting address
		BNE			INV1		If the lengths are not equal, then the length of the ending address is < the length
*								of the starting address, therefore the ending address is before the starting address

* If input reaches this loop, the length of both addresses is the same. D0 will be set to 1 if both addresses are different
* and set to 0 otherwise
LOOP4	CMP.B		(A0)+,(A1)+	Compare starting address with ending address, starting with most significant bit
		BGT			TESTZ		Ending address is greater than starting address so test if both addresses are the same
		BNE			INV1		If digits are the same, test next digit
		SUBQ		#1,D0		Decrement loop counter
		BNE			LOOP4		Check if any digits remaining in address
		BRA			TESTZ		Addresses are ordered correctly, now check if addresses are the same
INV1	LEA			IOERROR6,A1 	ELSE Input is invalid, display error message,
* 									and re-prompt user to input both values
		MOVE.B		#14,D0			Moves the number 14 into data register D0
    	TRAP   	 	#15			Displays Message
		BRA			LOOP1

TESTZ	LEA			STARTADDR,A0	Reset starting address
		LEA			ENDADDR,A1		Reset ending address
		MOVE.B		#1,D0			Flag set to 1 if both addresses are equal, 0 otherwise
LOOP5	CMP.B		(A0)+,(A1)+
		BEQ			NEXT			IF the two addresses are different values, input was successful
		CLR.B		D0				Addresses are not equal, set D0 to 0
		BRA			BREAK			Break out when its known the two addresses are different
NEXT	SUBQ		#1,D1		Decrement loop counter
		BNE			LOOP5		Check if any digits remaining in address

BREAK	CMP  		#1,D0
		BNE			SUCCESS		D0 = 0 iff both strings are the same
		LEA			IOERROR7,A1 	ELSE Input is invalid, display error message,
* 									and re-prompt user to input both values
		MOVE.B		#14,D0			Moves the number 14 into data register D0
    	TRAP   	 	#15			Displays Message
		BRA			LOOP1	

* Load the starting and ending addresses, input by the user, in memory in A0 and A1, respectively
* The end address is converted first so it could be moved to A1, and after loading the start ad-
* dress
SUCCESS LEA			BLANK,A1		Load blank line to print
		MOVE.B		#14,D0			Moves the number 14 into data register D0
    	TRAP   	 	#15				Displays blank line

		LEA			ENDADDR,A0		Set A0 to contain ending address upon entering subroutine
		MOVE.B		ENDLEN,D0		Set D0 to contain the length of the ending address string
		BSR			LOADADDR
		MOVEA.L		D0,A1			Move the ending address, contained in D0, into A1

		LEA			STARTADDR,A0	Set A0 to contain starting address upon entering subroutine
		MOVE.B		STARTLEN,D0		Set D0 to contain the length of the starting address string
		BSR			LOADADDR
		MOVEA.L		D0,A0			Move the starting address, contained in D0, into A1
		
		CLR.W		LINECNT			Initialize the line counter to 0
		MOVE.L		#11,D0			Trap task 11 clears the screen when D1.W is set to $FF00
		MOVE.L		#$FF00,D1		Set up D1 so the trap task clears the screen
    	TRAP   	 	#15				Clear the output screen before displaying first screen
		CLR.L		D0				Clear out the register to contain the instruction read from memory
		
		CLR.W		LINECNT			Reset line counter before outputting new screen
		MOVE.L		#11,D0			Trap task 11 clears the screen when D1.W is set to $FF00
		MOVE.L		#$FF00,D1		Set up D1 so the trap task clears the screen
    	TRAP   	 	#15				Clear the output screen
		CLR.L		D0				Clear out the register to contain the instruction read from memory

		
LOOP9
		CMP.W		#29,LINECNT		Check if the screen is filled
		BNE			CONT			IF the screen is filled, wait for the user's input before displaying next screen

		LEA			(A1),A2			Store a copy of the ending address in A1
		
* Prompt user to select an option for the next action to take
		LEA			MESSAGE4,A1 	Prompt user to select an option
		MOVE.B		#14,D0			Moves the number 14 into data register D0
    	TRAP   	 	#15				Displays Message
    	LEA			(A2),A1			Restore ending address to A1
  
* Read input from user until correct value is input
LOOPC	MOVE.L		#5,D0			Trap task 5 reads a single character from the keyboard into D1.L
		CLR.L		D1				Clear D1 before reading in the character
		TRAP		#15				Read a character from the user
		
		CMP.L		#$31,D1			Check if user selected to move to next page
		BNE			TST2			IF user selected to show next page	THEN show next page
		BRA			NEXTPG			Display next page
		
TST2	CMP.L		#$32,D1				ELSE check if the user selected to quit
		BNE			TST3			IF the user did not select option 2, then the input is checked for 3 to restart
		BRA			TSTEND3				ELSE quit the program

TST3	CMP.L		#$33,D1				ELSE check if the user selected to restart
		BNE			LOOPC				If not, input is invalid, wait for valid input
		BRA			T_END				Else restart
		
NEXTPG	CLR.W		LINECNT			Reset line counter before outputting new screen
		MOVE.L		#11,D0			Trap task 11 clears the screen when D1.W is set to $FF00
		MOVE.L		#$FF00,D1		Set up D1 so the trap task clears the screen
    	TRAP   	 	#15				Clear the output screen
		CLR.L		D0				Clear out the register to contain the instruction read from memory
		
CONT	BSR			DECODEMEM		Pass a pointer to the next instruction to be disassebled to the op-code subroutine
		ADDQ		#1,LINECNT		Add 1 to the line counter
		CLR.L		D0				Clear out the register to contain the instruction read from memory
		
		CMPA.L		A0,A1			Check if end is reached
		BCC.S		LOOP9
		
		LEA			MESSAGE3,A1 	
		MOVE.B		#14,D0			
    	TRAP   	 	#15	
		
TSTEND1	MOVE.L		#5,D0		TRAP task 5 reads a number in
		CLR.L		D1
		TRAP 		#15			Read address value
		
		CMP.L		#$31,D1		If zero end, if 1 restart
		BNE			TSTEND2		Not 1? Branch to test if end
		
T_END	MOVE.L		#11,D0			Trap task 11 clears the screen when D1.W is set to $FF00
		MOVE.L		#$FF00,D1		Set up D1 so the trap task clears the screen
    	TRAP   	 	#15				Clear the output screen before displaying first screen

		LEA			MESSAGE6,A1 	Display Restart message
		MOVE.B		#14,D0			
    	TRAP   	 	#15	
		
		BRA			START		Branch back to start

TSTEND2 CMP.L		#$30,D1		If 0, end
		BEQ			TSTEND3		0?
		
		LEA			IOERROR10,A1 	ERROR message since not 0 or 1.
		MOVE.B		#14,D0			
    	TRAP   	 	#15	
		BEQ			TSTEND1			Ask to reenter

TSTEND3	
		MOVE.L		#11,D0			Trap task 11 clears the screen when D1.W is set to $FF00
		MOVE.L		#$FF00,D1		Set up D1 so the trap task clears the screen
    	TRAP   	 	#15				Clear the output screen before displaying first screen	
    	
    	* Display header
		LEA			HEADER,A1	Loads HEADER into address register A1
    	MOVE.B		#14,D0		Moves the number 14 into data register D0
    	TRAP   	 	#15			Displays Message
		
		LEA			MESSAGE5,A1 	
		MOVE.B		#14,D0			
    	TRAP   	 	#15		

	    SIMHALT             ; halt simulator


**********************************************************************************************************************************
* I/O Subroutine: CONVHEX
* Convert an ASCII string to a string containing hexadecimal numbers and validate input
* after calling the subroutine, if input is valid, D0 will contain a 1, otherwise it will
* be set to 0 due to the ASCII string not containing valid hexadecimal digits (a-f, A-F, or 0-9),
* if the input is valid, A1 contains the hexadecimal address contained in the ASCII string stored
* Prior to calling the subroutine, A1 contains the address of the string being passed as a parameter. 
* The register A0 is used to traverse the string to convert each bit to hexadecimal while testing if its a valid hex digit.
* The parameter is contained on the stack prior to entering the function with the address of the string being converted buried
* 4 bytes underneath the address of the program counter popped on the stack upon entering the subroutine
CONVHEX MOVEQ		#1,D0		Assume input is valid, unless proven otherwise
		LEA			(4,SP),A0	A0 points to the address of the ASCII string being converted
		MOVEA.L		(A0),A0		Read the address of the parameter off of the stack
LOOP3	CMP.B		#$30,(A0)   IF ASCII character is >= $30, check if its 0-9
		BLT			INVALID			ELSE input is invalid, exit function and return 0 in D0
		CMP.B		#$39,(A0)	IF character is not in range 0-9, check if its < A
		BGT			TESTA			ELSE character is 0-9, strip $30 from the value to convert to hex
*                                   and increment A0 to point to next byte of string
		SUB.B		#$30,(A0)+
		BRA			DONE
TESTA	CMP.B		#$41,(A0)	IF ASCII character is >= $41, check if its A-F
		BLT			INVALID			ELSE input is invalid, exit function and return 0 in D0
		CMP.B		#$46,(A0)	IF character is not in range A-F, check if its < a
		BGT			TESTB			ELSE character is A-F, strip $37 from the value to convert to hex
*                                   and increment A0 to point to next byte of string
		SUB.B		#$37,(A0)+
		BRA			DONE
TESTB	CMP.B		#$61,(A0)	IF ASCII character is >= $61, check if its a-f
		BLT			INVALID			ELSE input is invalid, exit function and return 0 in D0
		CMP.B		#$66,(A0)	IF character in range A-F, strip $57 from the value to convert to hex
*                               and increment A0 to point to next byte of string
		BGT			INVALID			ELSE input is invalid; not in acceptable range
		SUB.B		#$57,(A0)+
DONE	SUBQ.B		#1,D1		Decrement loop counter
		BNE			LOOP3		Continue processing next character of string if more characters remain
		BRA			FINISH		Input was valid, (A0) contains the converted hex string	
INVALID	MOVE.L		#0,D0		Set status of register to show invalid input, data in (A0) is unreliable
FINISH	RTS						Exit function


**********************************************************************************************************************************
* I/O Subroutine: STRIPZ
* Strip the leading zeros from an ASCII string, which updating its length. A1 will contain the modified ASCII string with leading
* 0s removed after exiting the subroutine, with data register D1 containing the updated length. This function also modifies the
* string stored in memory, as well as its size by accepting their memory locations as parameters. The parameters passed to the 
* calling function, in the order the are passed, are: the memory location of the string being modified, and the memory location
* of its size. The registers A0 and A1 are used to read the first and second parameters, respectively, off of the stack. The
* register D0 is used to keep track of if the number is 0, and is set to 1 until a nonzero digit is encountered. D2 contains a
* copy of the original length to test if the string was modified, and A2 points to the beginning of the string to use in the
* second loop if needed. The first popped off of the stack is the address of the length of the string being modified. This address
* is buried 4 bytes underneath the address of the program counter popped on the stack upon entering the subroutine. The next param-
* eter popped off of the stack is the address of the string being modified. This parameter is buried 8 bytes underneath the top of
* the stack upon entering the subroutine
STRIPZ	MOVEQ		#1,D0		Assume number is zero, unless proven otherwise
		MOVE		D1,D2		Create copy of original length
		
* The first and second parameters are buried underneath the return address of the PC, so move the stack
* by an offset of 4 bytes to access the first parameter, and an offset of 8 bytes to access the second parameter
		LEA			(4,SP),A0	A0 points to the address in memory of the length of the ASCII string being modified
		MOVEA.L		(A0),A0		Read the address of the first parameter off of the stack
		LEA			(8,SP),A1	A1 points to the address in memory of the length of the ASCII string being modified
		MOVEA.L		(A1),A1		Read the address of the second parameter off of the stack
		LEA			(A1),A2		Store a copy of the starting address of the string in A2
		
LOOP6	CMP.B		#$30,(A1)+	The ASCII character 0 is $30 in hexadecimal, compare this to the MSB of the ASCII string
		BNE			NONZ		IF the digit is not 0, set D1 to 0 to show the number is not 0 and break out of the loop
		SUB.B		#1,(A0)		Decrement size to remove leading 0
		SUBQ		#1,D1		Decrement loop counter
		BNE			LOOP6		Continue if there are more characters to process and no nonzero digits were encountered
		BRA			NXTTST

NONZ	CLR.B		D0			Number is nonzero iff D0 = 0

NXTTST	CMP.B		#1,D0		Check if address is 0 (case where input is all 0s and original length was <= 8)
		BNE			NONZ1
		MOVE.B		#1,(A0)		IF number is 0, set size to 1, and update string to be 0
		MOVE.B		#0,(A2)		Set value in memory to 0
		BRA			DONE1
		
NONZ1 	CMP.B		(A0),D2		Check if size was updated by comparing to original size
		BEQ			DONE1		No leading 0s were detected, exit subroutine

* Update the ASCII string in memory to not contain any leading zeros, A1 points 1 byte past the first nonzero digit, the value
* in D1 is the remaining number of digits
		LEA			(-1,A1),A1	Move A1 back 1 byte to point to the first nonzero digit
LOOP7	MOVE.B		(A1)+,(A2)+	Move the string without leading zeros to the beginning address of the string
		SUBQ		#1,D1		Decrement loop counter
		BNE			LOOP7		Continue until all nonzero digits are shifter to their correct location
		
* At this point, A1 points 1 past the end of the string, so (A2) needs to be set to 0 to set the null terminator for the new string
		MOVE.B		(A1)+,(A2)+	When executing this code, (A1) contains the null terminator (0), so this code copies it into (A2)
		
DONE1	MOVE.B		(A0),D1		Update/restore size of loop counter so it could be used again if needed
		RTS						Return to calling function


**********************************************************************************************************************************
* I/O Subroutine: LOADADDR
* Converts an address in memory stored as a string of hexadecimal digits, with a maximum lentgh of 8 into a 32 bit address. If the
* length of the string being converted is less than 8 digits, the value is not sign extended
* Upon entering the subroutine, A0 contains the address of the string in memory and D0 contains the length of the string. This sub-
* routine uses D0 to load in the address from memory, then loads the address in A0 when the subroutine finishes its processing.
* This method also uses D1 as a temporary register to read the a word of memory, corresponding to a single digit before proc-
* cessing it and inserting it into D0 by masking it, based on its value, in order to pack 2 digits into each byte of D0. The re-
* sulting number will be an 8 digit hex value stored in D0 corresponding to the address in memory contained in the string. Also,
* the register D2 will contain the loop counter.
LOADADDR	CLR.L	D1			Clear the register storing the byte to be processed
			CLR.L	D2			Clear the register storing the loop counter for the first/second loop
			MOVE.B	D0,D2		Create a copy of the size
			CLR.L	D0			Clear D0 so it could now be used as to contain the hexadecimal number
LOOP8		MOVE.B	(A0)+,D1	Move the next byte to D1 for processing
			
* The following section corresponds to a switch statement to determine the mask which needs
* to be applied to insert the digit in D0
			CMP.B	#0,D1
			BNE		ONE			Test for next digit if digit being compared is not equal to the value in D1
			
* No need to set bit, since D0 was cleared. So the bit is already set to 0, simply break out of switch statement
			BRA		NEXTCODE	Break out from switch after inserting digit in D1 into its correct location in D0
ONE			CMP.B	#$1,D1
			BNE		TWO			Test for next digit if digit being compared is not equal to the value in D1
			ORI.B  	#$01,D0		Convert the LSB of D0 to 0
			BRA		NEXTCODE	Break out from switch after inserting digit in D1 into its correct location in D0
TWO			CMP.B	#$2,D1
			BNE		THREE		Test for next digit if digit being compared is not equal to the value in D1
			ORI  	#$02,D0		Convert the LSB of D0 to 0
			BRA		NEXTCODE	Break out from switch after inserting digit in D1 into its correct location in D0
THREE		CMP.B	#$3,D1
			BNE		FOUR		Test for next digit if digit being compared is not equal to the value in D1
			ORI  	#$03,D0		Convert the LSB of D0 to 0
			BRA		NEXTCODE	Break out from switch after inserting digit in D1 into its correct location in D0
FOUR		CMP.B	#$4,D1
			BNE		FIVE		Test for next digit if digit being compared is not equal to the value in D1
			ORI  	#$04,D0		Convert the LSB of D0 to 0
			BRA		NEXTCODE	Break out from switch after inserting digit in D1 into its correct location in D0
FIVE		CMP.B	#$5,D1
			BNE		SIX			Test for next digit if digit being compared is not equal to the value in D1
			ORI  	#$05,D0		Convert the LSB of D0 to 0
			BRA		NEXTCODE	Break out from switch after inserting digit in D1 into its correct location in D0
SIX			CMP.B	#$6,D1
			BNE		SEVEN		Test for next digit if digit being compared is not equal to the value in D1
			ORI  	#$06,D0		Convert the LSB of D0 to 0
			BRA		NEXTCODE	Break out from switch after inserting digit in D1 into its correct location in D0
SEVEN		CMP.B	#$7,D1
			BNE		EIGHT		Test for next digit if digit being compared is not equal to the value in D1
			ORI  	#$07,D0		Convert the LSB of D0 to 0
			BRA		NEXTCODE	Break out from switch after inserting digit in D1 into its correct location in D0
EIGHT		CMP.B	#$8,D1
			BNE		NINE		Test for next digit if digit being compared is not equal to the value in D1
			ORI  	#$08,D0		Convert the LSB of D0 to 0
			BRA		NEXTCODE	Break out from switch after inserting digit in D1 into its correct location in D0
NINE		CMP.B	#$9,D1
			BNE		A			Test for next digit if digit being compared is not equal to the value in D1
			ORI  	#$09,D0		Convert the LSB of D0 to 0
			BRA		NEXTCODE	Break out from switch after inserting digit in D1 into its correct location in D0
A			CMP.B	#$A,D1
			BNE		B			Test for next digit if digit being compared is not equal to the value in D1
			ORI  	#$0A,D0		Convert the LSB of D0 to 0
			BRA		NEXTCODE	Break out from switch after inserting digit in D1 into its correct location in D0
B			CMP.B	#$B,D1
			BNE		C			Test for next digit if digit being compared is not equal to the value in D1
			ORI  	#$0B,D0		Convert the LSB of D0 to 0
			BRA		NEXTCODE	Break out from switch after inserting digit in D1 into its correct location in D0
C			CMP.B	#$C,D1
			BNE		D			Test for next digit if digit being compared is not equal to the value in D1
			ORI  	#$0C,D0		Convert the LSB of D0 to 0
			BRA		NEXTCODE	Break out from switch after inserting digit in D1 into its correct location in D0
D			CMP.B	#$D,D1
			BNE		E			Test for next digit if digit being compared is not equal to the value in D1
			ORI  	#$0D,D0		Convert the LSB of D0 to 0
			BRA		NEXTCODE	Break out from switch after inserting digit in D1 into its correct location in D0
E			CMP.B	#$E,D1
			BNE		F			Test for next digit if digit being compared is not equal to the value in D1
			ORI  	#$0E,D0		Convert the LSB of D0 to 0
			BRA		NEXTCODE	Break out from switch after inserting digit in D1 into its correct location in D0
F			ORI.B  	#$0F,D0		Convert the LSB of D0 to 0
*								No comparison since digit must be F if it reached this point

NEXTCODE	ROL.L	#4,D0		Shift the contents of D0 1 nibble to the right to insert next digit
			SUBQ	#1,D2		Decrement loop counter
			BNE		LOOP8		Continue until all digits are processed
			
			ROR.L	#4,D0		Upon exiting the loop(s), the address in D0 is rotated 1 bit to the left, so this
*								code will move the digits to their correct location
	 		RTS
	 		
	 		
**********************************************************************************************************************************
* I/O Subroutine: PRINTNOP
* Outputs the instruction NOP located at the memory address specified by the value in the address register A0. Prior to calling
* this subroutine, A2 contains the memory location of the instruction. After exiting the subroutine the instruction along with its
* memory location will be output to the display
PRINTNOP	BSR		PRINTMEM		Print the memory location stored in A1 corresponding to where the instruction is
			
			LEA			PNOP,A1		Loads name of instruction into address register A1
    		MOVE.B		#14,D0		Moves the number 14 into data register D0
    		TRAP   	 	#15			Displays Message

			RTS


**********************************************************************************************************************************
* I/O Subroutine: PRINTMEM
* Outputs the memory location with leading 0s. Since an address contains 32 bits, the number of digits being printed will be 8.
* Prior to entering the subroutine, A2 contains the memory location to print. After exiting the subroutine, the longword
* memory address will be output to the display. D6 is used to contain the loop counter corresponding to the 8 digits to print.
* D3 will be used to contain the address of the instruction to print. D4 contains a copy of the byte con-
* taining the first digit to print. D5 contains another copy of the same byte contating the second digit to print.
* This is since there are two digits packed in one byte, so a mask is used to isolate the digit to print. D2 is used for the the
* trap function, along with D1, and D0 to display the number.
PRINTMEM	MOVEM.L		A1/D4-D6,-(SP)	Save state of program
			MOVE.L		#4,D6			Loop counter, corresponds to 8 digits to print.
*										This is because two characters are read at a time
			CLR.L		D5				Clear D5 since it was also used in the DECODEMEM subroutine
			CLR.L		D4				Clear D4 since it was also used in the DECODEMEM subroutine

			MOVE.L		A2,D3			Move the address of the instruction to D2		
			
* Rotate the address to the left set the next two bytes into place, so they could be printed
LOOPA		ROL.L		#8,D3
			
			MOVE.B		D3,D4			Move the least significant bit of the address to D3 for the first digit to print
			MOVE.B		D4,D5			Create a copy of the address in D4 for the second digit to print
			
*			Read the first character in the byte
			ANDI.B		#$F0,D4			Isolate leftmost digit to print
			LSR.B		#4,D4			The left digit in the byte is shifted one bit to the left,
*								    	so shift it to its correct place to print
			MOVE.B		#15,D0			TRAP task 15 displays an unsigned number in D1.L in decimal notation
			MOVE.L		D4,D1			Move digit to D1 to display it
			MOVE.B		#16,D2			Display in hexadecimal
			TRAP   	 	#15				Displays number in D1
			
*			Read the second character in the byte
			ANDI.B		#$0F,D5			Isolate the rightmost digit to print
			MOVE.B		#15,D0			TRAP task 15 displays an unsigned number in D1.L in decimal notation
			MOVE.L		D5,D1			Move digit to D1 to display it
			MOVE.B		#16,D2			Display in hexadecimal
			TRAP   	 	#15				Displays number in D1
			
			SUBQ		#1,D6			Decrement loop counter
			BNE			LOOPA			Continue until entire address is printed
				
			MOVEM.L		(SP)+,A1/D4-D6	Restore program to its state prior to entering the subroutine
			RTS


**********************************************************************************************************************************
* I/O Subroutine: PRINTMEMW
* Outputs a word of memory with leading 0s. Since a word contains 16 bits, the number of digits being printed will be 4.
* Prior to entering the subroutine, A2 contains the memory location to print. After exiting the subroutine, the word
* memory address will be output to the display. D6 is used to contain the loop counter corresponding to the 4 digits to print.
* D3 will be used to contain the address of the instruction to print. D4 contains a copy of the byte con-
* taining the first digit to print. D5 contains another copy of the same byte contating the second digit to print.
* This is since there are two digits packed in one byte, so a mask is used to isolate the digit to print. D2 is used for the the
* trap function, along with D1, and D0 to display the number.
PRINTMEMW	MOVEM.L		A1/D4-D6,-(SP)	Save state of program
			MOVE.L		#2,D6			Loop counter, corresponds to 8 digits to print.
*										This is because two characters are read at a time
			CLR.L		D5				Clear D5 since it was also used in the DECODEMEM subroutine
			CLR.L		D4				Clear D4 since it was also used in the DECODEMEM subroutine
			MOVE.L		A2,D3			Move the address of the instruction to D2
			
* Rotate the address to the left set the next two bytes into place, so they could be printed
LOOPB		ROL.W		#8,D3
			
			MOVE.B		D3,D4			Move the least significant bit of the address to D3 for the first digit to print
			MOVE.B		D4,D5			Create a copy of the address in D4 for the second digit to print
			
*			Read the first character in the byte
			ANDI.B		#$F0,D4			Isolate leftmost digit to print
			LSR.B		#4,D4			The left digit in the byte is shifted one bit to the left,
*								    	so shift it to its correct place to print
			MOVE.B		#15,D0			TRAP task 15 displays an unsigned number in D1.L in decimal notation
			MOVE.L		D4,D1			Move digit to D1 to display it
			MOVE.B		#16,D2			Display in hexadecimal
			TRAP   	 	#15				Displays number in D1
			
*			Read the second character in the byte
			ANDI.B		#$0F,D5			Isolate the rightmost digit to print
			MOVE.B		#15,D0			TRAP task 15 displays an unsigned number in D1.L in decimal notation
			MOVE.L		D5,D1			Move digit to D1 to display it
			MOVE.B		#16,D2			Display in hexadecimal
			TRAP   	 	#15				Displays number in D1
			
			SUBQ		#1,D6			Decrement loop counter
			BNE			LOOPB			Continue until entire address is printed
				
			MOVEM.L		(SP)+,A1/D4-D6	Restore program to its state prior to entering the subroutine
			RTS


**********************************************************************************************************************************
* I/O Subroutine: PRINTMEMB
* Outputs a byte of memory with leading 0s. Since a byte contains 8 bits, the number of digits being printed will be 2.
* Prior to entering the subroutine, A2 contains the memory location to print. After exiting the subroutine, the byte
* memory address will be output to the display. D3 will be used to contain the address of the instruction to print.
* D4 contains a copy of the byte containing the first digit to print. D5 contains another copy of the same byte contating
* the second digit to print This is since there are two digits packed in one byte, so a mask is used to isolate the digit to print.
* D2 is used for the the trap function, along with D1, and D0 to display the number.
PRINTMEMB	MOVEM.L		A1/D4-D6,-(SP)	Save state of program
			CLR.L		D5				Clear D5 since it was also used in the DECODEMEM subroutine
			CLR.L		D4				Clear D4 since it was also used in the DECODEMEM subroutine
			MOVE.L		A2,D3			Move the address of the instruction to D2
			
			MOVE.B		D3,D4			Move the least significant bit of the address to D3 for the first digit to print
			MOVE.B		D4,D5			Create a copy of the address in D4 for the second digit to print
			
*			Read the first character in the byte
			ANDI.B		#$F0,D4			Isolate leftmost digit to print
			LSR.B		#4,D4			The left digit in the byte is shifted one bit to the left,
*								    	so shift it to its correct place to print
			MOVE.B		#15,D0			TRAP task 15 displays an unsigned number in D1.L in decimal notation
			MOVE.L		D4,D1			Move digit to D1 to display it
			MOVE.B		#16,D2			Display in hexadecimal
			TRAP   	 	#15				Displays number in D1
			
*			Read the second character in the byte
			ANDI.B		#$0F,D5			Isolate the rightmost digit to print
			MOVE.B		#15,D0			TRAP task 15 displays an unsigned number in D1.L in decimal notation
			MOVE.L		D5,D1			Move digit to D1 to display it
			MOVE.B		#16,D2			Display in hexadecimal
			TRAP   	 	#15				Displays number in D1
				
			MOVEM.L		(SP)+,A1/D4-D6	Restore program to its state prior to entering the subroutine
			RTS



**********************************************************************************************************************************
* I/O Subroutine: PRINTRTS
* Outputs the instruction RTS located at the memory address specified by the value in the address register A0. Prior to calling
* this subroutine, A2 contains the memory location of the instruction. After exiting the subroutine the instruction along with its
* memory location will be output to the display
PRINTRTS	BSR			PRINTMEM		Print the memory location stored in A1 corresponding to where the instruction is
			
			LEA			PRTS,A1		Loads name of instruction into address register A1
    		MOVE.B		#14,D0		Moves the number 14 into data register D0
    		TRAP   	 	#15			Displays Message

			RTS


***************************************************************************************************************************************
* P_EA_XN
* Prints EA on left, fetch or no fetch from EAFETCH, followed by Data or 
* address register, from DORA.
P_EA_XN		MOVEM.L		D0-D1/A1,-(SP)	Save program state
			CLR.L		D0
			
			LEA			(A3),A1		Load the left modifier to display
			MOVE.B		#14,D0		Moves the number 14 into data register D0
    		TRAP   	 	#15			Displays modifier
    		
    		MOVEA.L		D5,A2		Moves EA of instruction into address register A2 so it could be printed using a subroutine
    		
P_EA_XN1	CMP.B		#0,EAFETCH  Corresponds to EA with no fetch
			BNE			P_EA_XN2
    		
    		MOVE.B		#15,D0		Moves number 15 to D0
			MOVE.B		D7,D1		Moves EAREG to D1
			TRAP		#15			Displays EAREG

			BRA			P_EA_XN4	Jumps to display right modifier
			

P_EA_XN2    CMP.B		#2,EAFETCH	Check if memory to print is long
    		BNE			P_EA_XN3	If not, print word
			
			JSR			PRINTMEM	If long, print long
			BRA			P_EA_XN4	Move on to next print

P_EA_XN3    BSR			PRINTMEMW   Print the word of memory corresponding to the EA type

P_EA_XN4	LEA			(A4),A1		Load the right modifier to display
			MOVE.B		#14,D0		Moves the number 14 into data register D0
    		TRAP   	 	#15			Displays modifier
	
			LEA			COMMA,A1	Load comma to print
			MOVE.B		#14,D0		Moves the number 14 into data register D0
    		TRAP   	 	#15			Displays comma

			CMP.B		#0,DORA		Compares if address reg or data reg
			BNE			P_EA_XN5  
			LEA			DREG,A1		Load Data register to print
			BRA			P_EA_XN6	
			
P_EA_XN5	LEA			AREG,A1		Load address register to print

P_EA_XN6	MOVE.B		#14,D0		Moves the number 14 into data register D0
    		TRAP   	 	#15			Displays the letter D
    		
    		MOVE.B		#15,D0		TRAP task 15 displays an unsigned number in D1.L in decimal notation
			CLR.L		D1			Clear D1
			MOVE.B		(REGL),D1		Move register number to D1 to display it
			TRAP   	 	#15			Displays number in D1
			
			LEA			BLANK,A1	Load blank line to print
			MOVE.B		#14,D0		Moves the number 14 into data register D0
    		TRAP   	 	#15			Displays blank line
			
P_EA_XN7	MOVEM.L		(SP)+,D0-D1/A1	Return program state when done
			RTS

*****************************************************************************************************************************
* P_XN_EA
* Prints D or A reg based on DORA variable and
* EA on right, fetch or no fetch, long or word based on EAFETCH
P_XN_EA		MOVEM.L		D0-D1/A1,-(SP)	Save program state
			CLR.L		D0
			
			CMP.B		#0,DORA		Compares if address reg or data reg
			BNE			P_XN_EA5  
			LEA			DREG,A1		Load Data register to print
			BRA			P_XN_EA6	
			
P_XN_EA5	LEA			AREG,A1	

P_XN_EA6	MOVE.B		#14,D0		Moves the number 14 into data register D0
    		TRAP   	 	#15			Displays the letter D
    		
    		MOVE.B		#15,D0		TRAP task 15 displays an unsigned number in D1.L in decimal notation
			CLR.L		D1			Clear D1
			MOVE.B		(REGL),D1		Move register number to D1 to display it
			TRAP   	 	#15			Displays number in D1
			
			LEA			COMMA,A1	Load comma to print
			MOVE.B		#14,D0		Moves the number 14 into data register D0
    		TRAP   	 	#15			Displays comma
			
			LEA			(A3),A1		Load the left modifier to display
			MOVE.B		#14,D0		Moves the number 14 into data register D0
    		TRAP   	 	#15			Displays modifier
    		
    		MOVEA.L		D5,A2		Moves EA of instruction into address register A2 so it could be printed using a subroutine
    		
P_XN_EA1	CMP.B		#0,EAFETCH  Corresponds to EA with no fetch
			BNE			P_XN_EA2
    		
    		MOVE.B		#15,D0		Moves number 15 to D0
			MOVE.B		D7,D1		Moves EAREG to D1
			TRAP		#15			Displays EAREG

			BRA			P_XN_EA4	Jumps to display right modifier
			

P_XN_EA2    CMP.B		#2,EAFETCH	Check if memory to print is long
    		BNE			P_XN_EA3	If not, print word
			
			JSR			PRINTMEM	If long, print long
			BRA			P_XN_EA4	Move on to next print

P_XN_EA3    BSR			PRINTMEMW   Print the word of memory corresponding to the EA type

P_XN_EA4	LEA			(A4),A1		Load the right modifier to display
			MOVE.B		#14,D0		Moves the number 14 into data register D0
    		TRAP   	 	#15			Displays modifier
			
			LEA			BLANK,A1	Load blank line to print
			MOVE.B		#14,D0		Moves the number 14 into data register D0
    		TRAP   	 	#15			Displays blank line
			
P_XN_EA7	MOVEM.L		(SP)+,D0-D1/A1	Return program state when done
			RTS

**********************************************************************************************************************************
* I/O Subroutine: P_JSR
*Prints the JSR instruction.
*Inputs: 
*EAMODE - Contains the mode of the instruction passed from GETEA
*A1 - Contains the memory address of the instruction.
*D7 - Contains the register number for (An) mode.
*D5 - Contains the EA field of the instruction.
*Outputs:
*None


P_JSR		MOVEM.L		D0-D1/A1,-(SP)		Save program state
			CLR.L		D0
			
*			(An) mode check
   			CMP.B		#2,EAMODE		Check if EAMODE is (An)
   			BEQ			P_JSR_AI			If yes, branch to Address Indirect (JSR_AI)
*			Word mode check		
    			CMP.B		#7,EAMODE		Check if EAMODE is Word mode
   			BEQ			P_JSR_WORD		If yes, branch to Word
*			Long mode check			
   			CMP.B		#8,EAMODE		Check if EAMODE is Long mode
   			BEQ			P_JSR_LONG		If yes, branch to Long
   
*			Print address indirect			
P_JSR_AI		BSR			PRINTMEM		Print the memory location stored in A1 corresponding to where the instruction is
			LEA			P_JSR_PRINT,A1	Load the instruction to display
			MOVE.B		#14,D0			Moves the number 14 into data register D0
    			TRAP   	 	#15				Displays instruction
			LEA			(A3),A1			Load the left modifier to display
			MOVE.B		#14,D0			Moves the number 14 into data register D0
    			TRAP   	 	#15				Displays modifier
    			MOVE.W		D7,D1			Load the register # to display
			MOVE.B		#15,D0			Moves the number 14 into data register D0
    			TRAP   	 	#15				Displays modifier
    			LEA			(A4),A1			Load the right modifier to display
			MOVE.B		#14,D0			Moves the number 14 into data register D0
    			TRAP   	 	#15				Displays modifier						    
*			Print blank line
			LEA			BLANK,A1			Load blank line to print
			MOVE.B		#14,D0			Moves the number 14 into data register D0
    			TRAP   	 	#15				Displays blank line
*			Branch out of subroutine			
			BRA			P_JSR_END		Exit subroutine when done outputting

*			Print word
P_JSR_WORD	BSR 			PRINTMEM
			LEA			P_JSR_PRINT,A1	Load the instruction to display
			MOVE.B		#14,D0			Moves the number 14 into data register D0
    			TRAP   	 	#15				Displays instruction
    			LEA			HEXVAL,A1		Load the instruction to display
			MOVE.B		#14,D0			Moves the number 14 into data register D0
    			TRAP   	 	#15				Displays instruction		
    			MOVEA.W	D5,A2			Moves EA of instruction into address register A2 so it could be printed using a subroutine
     			BSR			PRINTMEMW   		Print the word of memory corresponding to the EA type
*			Print blank line
			LEA			BLANK,A1			Load blank line to print
			MOVE.B		#14,D0			Moves the number 14 into data register D0
    			TRAP   	 	#15				Displays blank line
*			Branch out of subroutine			
			BRA			P_JSR_END		Exit subroutine when done outputting
			
*			Print long
P_JSR_LONG	BSR 			PRINTMEM
			LEA			P_JSR_PRINT,A1	Load the instruction to display
			MOVE.B		#14,D0			Moves the number 14 into data register D0
    			TRAP   	 	#15				Displays instruction
    			LEA			HEXVAL,A1		Load the instruction to display
			MOVE.B		#14,D0			Moves the number 14 into data register D0
    			TRAP   	 	#15				Displays instruction		
    			MOVEA.L		D5,A2			Moves EA of instruction into address register A2 so it could be printed using a subroutine
     			BSR			PRINTMEM  		Print the word of memory corresponding to the EA type
*			Print blank line
			LEA			BLANK,A1			Load blank line to print
			MOVE.B		#14,D0			Moves the number 14 into data register D0
    			TRAP   	 	#15				Displays blank line
*			Branch out of subroutine			
			BRA			P_JSR_END		Exit subroutine when done outputting

			    
P_JSR_END	MOVEM.L		(SP)+,D0-D1/A1		Return program state when done
			RTS
			
**********************************************************************************************************************************
* I/O Subroutine: P_BRA
*Prints the BRA instruction. Checks for both positive and negative displacement, and byte or word size.
*Inputs:
*A2 - Contains the memory location of the instruction.
*D7 - Contains the instruction
*Outputs:
*None

P_BRA		MOVEM.L		D0-D1/A1,-(SP)		Save program state
			CLR.L		D0

*			Print memory and command
			MOVEA.L		A2,A3			Save memory location for displacement calculation		
			BSR			PRINTMEM		Print the memory location stored in A2 corresponding to where the instruction is
    
*			Check the displacement length	
    			ANDI.W		#$00FF,D7		Apply mask to isolate least significant byte of instruction
			CMP.B		#$00,D7			    Check for 16-bit displacement
			BEQ			P_BRA_W

*			Print 8-bit displacement	
			*Mask to determine positive or negative displacement
			LEA			P_BRA_PRINTB,A1	Load the instruction to display
			MOVE.B		#14,D0			Moves the number 14 into data register D0
    			TRAP   	 	#15				Displays instruction
			MOVE.L		D7,D3			Copy displacement byte to check sign
			ANDI.B		#$80,D3			Mask most significant bit
			CMP.W		#0,D3
			BGT			P_BRA_NEG		
			*Print positive displacement
			ADD.L		A3,D7			Add memory and displacement
			ADD.L		#2,D7			Add 2 for byte instruction	
			MOVEA.L		D7,A2			Moves the final value to register A2 so it could be printed using a subroutine
			LEA			HEXVAL,A1		Load the instruction to display
			MOVE.B		#14,D0			Moves the number 14 into data register D0
    			TRAP   	 	#15				Displays instruction
			BSR			PRINTMEM			
			LEA			BLANK,A1			Load blank line to print
			MOVE.B		#14,D0			Moves the number 14 into data register D0
    			TRAP   	 	#15				Displays blank line
*			Branch out of subroutine			
			BRA			P_BRA_END		Exit subroutine when done outputting
			
*			For negative displacement			
P_BRA_NEG	NEG.B		D7				Change displacement from negative value to positive value
			SUB.L		#2,D7			Subtract 2 for byte instruction (Actually means that we are adding 2 to A3)	
			SUB.L		D7,A3			Subtract displacement from memory
			MOVEA.L		A3,A2			Moves the final value to register A2 so it could be printed using a subroutine
			LEA			HEXVAL,A1		Load the instruction to display
			MOVE.B		#14,D0			Moves the number 14 into data register D0
    			TRAP   	 	#15				Displays instruction
			BSR			PRINTMEM			
			LEA			BLANK,A1			Load blank line to print
			MOVE.B		#14,D0			Moves the number 14 into data register D0
    			TRAP   	 	#15				Displays blank line
*			Branch out of subroutine			
			BRA			P_BRA_END		Exit subroutine when done outputting

*			Print 16-bit displacement
P_BRA_W		*Mask to determine positive or negative displacement
			LEA			P_BRA_PRINTW,A1	Load the instruction to display
			MOVE.B		#14,D0			Moves the number 14 into data register D0
    			TRAP   	 	#15				Displays instruction
			MOVE.W		(A0)+,D7			Move 16-bit displacement from A0 into D7
			MOVE.L		D7,D3			Copy displacement byte to check sign
			ANDI.W		#BRA_16BIT,D3	Mask most significant bit
			CMP.W		#BRA_16BIT,D3
			CMP.W		#0,D3
			BGT			P_BRA_WN		
			*Print positive displacement
			ADD.W		A3,D7			Add memory and displacement
			ADD.W		#2,D7			Add 2 for word instruction	
			MOVEA.L		D7,A2			Moves the final value to register A2 so it could be printed using a subroutine
			LEA			HEXVAL,A1		Load the instruction to display
			MOVE.B		#14,D0			Moves the number 14 into data register D0
    			TRAP   	 	#15				Displays instruction
			BSR			PRINTMEM			
			LEA			BLANK,A1			Load blank line to print
			MOVE.B		#14,D0			Moves the number 14 into data register D0
    			TRAP   	 	#15				Displays blank line
*			Branch out of subroutine			
			BRA			P_BRA_END		Exit subroutine when done outputting
			
*			For negative displacement			
P_BRA_WN	NEG.W		D7				Change displacement from negative value to positive value
			SUB.L		#2,D7			Subtract 2 for word instruction (Actually means that we are adding 2 to A3)	
			SUB.L		D7,A3			Subtract displacement from memory
			MOVEA.L		A3,A2			Moves the final value to register A2 so it could be printed using a subroutine
			LEA			HEXVAL,A1		Load the instruction to display
			MOVE.B		#14,D0			Moves the number 14 into data register D0
    			TRAP   	 	#15				Displays instruction
			BSR			PRINTMEM			
			LEA			BLANK,A1			Load blank line to print
			MOVE.B		#14,D0			Moves the number 14 into data register D0
    			TRAP   	 	#15				Displays blank line
*			Branch out of subroutine			
			BRA			P_BRA_END		Exit subroutine when done outputting


			    
P_BRA_END	MOVEM.L		(SP)+,D0-D1/A1		Return program state when done
			RTS
			
**********************************************************************************************************************************
* I/O Subroutine: P_BGT
*Prints the BGT instruction. Checks for both positive and negative displacement, and byte or word size.
*Inputs:
*A2 - Contains the memory location of the instruction.
*D7 - Contains the instruction
*Outputs:
*None

P_BGT		MOVEM.L		D0-D1/A1,-(SP)		Save program state
			CLR.L		D0

*			Print memory and command
			MOVEA.L		A2,A3			Save memory location for displacement calculation		
			BSR			PRINTMEM		Print the memory location stored in A2 corresponding to where the instruction is
    
*			Check the displacement length	
    			ANDI.W		#$00FF,D7		Apply mask to isolate least significant byte of instruction
			CMP.B		#$00,D7			    Check for 16-bit displacement
			BEQ			P_BGT_W

*			Print 8-bit displacement	
			*Mask to determine positive or negative displacement
			LEA			P_BGT_PRINTB,A1	Load the instruction to display
			MOVE.B		#14,D0			Moves the number 14 into data register D0
    			TRAP   	 	#15				Displays instruction
			MOVE.L		D7,D3			Copy displacement byte to check sign
			ANDI.B		#$80,D3			Mask most significant bit
			CMP.W		#0,D3
			BGT			P_BGT_NEG	
			*Print positive displacement
			ADD.L		A3,D7			Add memory and displacement
			ADD.L		#2,D7			Add 2 for byte instruction	
			MOVEA.L		D7,A2			Moves the final value to register A2 so it could be printed using a subroutine
			LEA			HEXVAL,A1		Load the instruction to display
			MOVE.B		#14,D0			Moves the number 14 into data register D0
    			TRAP   	 	#15				Displays instruction
			BSR			PRINTMEM			
			LEA			BLANK,A1			Load blank line to print
			MOVE.B		#14,D0			Moves the number 14 into data register D0
    			TRAP   	 	#15				Displays blank line
*			Branch out of subroutine			
			BRA			P_BGT_END		Exit subroutine when done outputting
			
*			For negative displacement			
P_BGT_NEG	NEG.B		D7				Change displacement from negative value to positive value
			SUB.L		#2,D7			Subtract 2 for byte instruction (Actually means that we are adding 2 to A3)	
			SUB.L		D7,A3			Subtract displacement from memory
			MOVEA.L		A3,A2			Moves the final value to register A2 so it could be printed using a subroutine
			LEA			HEXVAL,A1		Load the instruction to display
			MOVE.B		#14,D0			Moves the number 14 into data register D0
    			TRAP   	 	#15				Displays instruction
			BSR			PRINTMEM			
			LEA			BLANK,A1			Load blank line to print
			MOVE.B		#14,D0			Moves the number 14 into data register D0
    			TRAP   	 	#15				Displays blank line
*			Branch out of subroutine			
			BRA			P_BGT_END		Exit subroutine when done outputting

*			Print 16-bit displacement
P_BGT_W		*Mask to determine positive or negative displacement
			LEA			P_BGT_PRINTW,A1	Load the instruction to display
			MOVE.B		#14,D0			Moves the number 14 into data register D0
    			TRAP   	 	#15				Displays instruction
			MOVE.W		(A0)+,D7			Move 16-bit displacement from A0 into D7
			MOVE.L		D7,D3			Copy displacement byte to check sign
			ANDI.W		#BRA_16BIT,D3	Mask most significant bit
			CMP.W		#BRA_16BIT,D3
			CMP.W		#0,D3
			BGT			P_BGT_WN		
			*Print positive displacement
			ADD.W		A3,D7			Add memory and displacement
			ADD.W		#2,D7			Add 2 for word instruction	
			MOVEA.L		D7,A2			Moves the final value to register A2 so it could be printed using a subroutine
			LEA			HEXVAL,A1		Load the instruction to display
			MOVE.B		#14,D0			Moves the number 14 into data register D0
    			TRAP   	 	#15				Displays instruction
			BSR			PRINTMEM			
			LEA			BLANK,A1			Load blank line to print
			MOVE.B		#14,D0			Moves the number 14 into data register D0
    			TRAP   	 	#15				Displays blank line
*			Branch out of subroutine			
			BRA			P_BGT_END		Exit subroutine when done outputting
			
*			For negative displacement			
P_BGT_WN	NEG.W		D7				Change displacement from negative value to positive value
			SUB.L		#2,D7			Subtract 2 for word instruction (Actually means that we are adding 2 to A3)	
			SUB.L		D7,A3			Subtract displacement from memory
			MOVEA.L		A3,A2			Moves the final value to register A2 so it could be printed using a subroutine
			LEA			HEXVAL,A1		Load the instruction to display
			MOVE.B		#14,D0			Moves the number 14 into data register D0
    			TRAP   	 	#15				Displays instruction
			BSR			PRINTMEM			
			LEA			BLANK,A1			Load blank line to print
			MOVE.B		#14,D0			Moves the number 14 into data register D0
    			TRAP   	 	#15				Displays blank line
*			Branch out of subroutine			
			BRA			P_BGT_END		Exit subroutine when done outputting
			    
P_BGT_END	MOVEM.L		(SP)+,D0-D1/A1		Return program state when done
			RTS
	
**********************************************************************************************************************************
* I/O Subroutine: P_BLE
*Prints the BLE instruction. Checks for both positive and negative displacement, and byte or word size.
*Inputs:
*A2 - Contains the memory location of the instruction.
*D7 - Contains the instruction
*Outputs:
*None

P_BLE		MOVEM.L		D0-D1/A1,-(SP)		Save program state
			CLR.L		D0
			
*			Print memory and command
			MOVEA.L		A2,A3			Save memory location for displacement calculation		
			BSR			PRINTMEM		Print the memory location stored in A2 corresponding to where the instruction is
    
*			Check the displacement length	
    			ANDI.W		#$00FF,D7		Apply mask to isolate least significant byte of instruction
			CMP.B		#$00,D7			    Check for 16-bit displacement
			BEQ			P_BLE_W

*			Print 8-bit displacement	
			LEA			P_BLE_PRINTB,A1	Load the instruction to display
			MOVE.B		#14,D0			Moves the number 14 into data register D0
    			TRAP   	 	#15				Displays instruction
			*Mask to determine positive or negative displacement
			MOVE.L		D7,D3			Copy displacement byte to check sign
			ANDI.B		#$80,D3			Mask most significant bit
			CMP.W		#0,D3
			BGT			P_BLE_NEG		
			*Print positive displacement
			ADD.L		A3,D7			Add memory and displacement
			ADD.L		#2,D7			Add 2 for byte instruction	
			MOVEA.L		D7,A2			Moves the final value to register A2 so it could be printed using a subroutine
			LEA			HEXVAL,A1		Load the instruction to display
			MOVE.B		#14,D0			Moves the number 14 into data register D0
    			TRAP   	 	#15				Displays instruction
			BSR			PRINTMEM			
			LEA			BLANK,A1			Load blank line to print
			MOVE.B		#14,D0			Moves the number 14 into data register D0
    			TRAP   	 	#15				Displays blank line
*			Branch out of subroutine			
			BRA			P_BLE_END		Exit subroutine when done outputting
			
*			For negative displacement			
P_BLE_NEG	NEG.B		D7				Change displacement from negative value to positive value
			SUB.L		#2,D7			Subtract 2 for byte instruction (Actually means that we are adding 2 to A3)	
			SUB.L		D7,A3			Subtract displacement from memory
			MOVEA.L		A3,A2			Moves the final value to register A2 so it could be printed using a subroutine
			LEA			HEXVAL,A1		Load the instruction to display
			MOVE.B		#14,D0			Moves the number 14 into data register D0
    			TRAP   	 	#15				Displays instruction
			BSR			PRINTMEM			
			LEA			BLANK,A1			Load blank line to print
			MOVE.B		#14,D0			Moves the number 14 into data register D0
    			TRAP   	 	#15				Displays blank line
*			Branch out of subroutine			
			BRA			P_BLE_END		Exit subroutine when done outputting

*			Print 16-bit displacement
P_BLE_W		*Mask to determine positive or negative displacement
			LEA			P_BLE_PRINTW,A1	Load the instruction to display
			MOVE.B		#14,D0			Moves the number 14 into data register D0
    			TRAP   	 	#15				Displays instruction
			MOVE.W		(A0)+,D7			Move 16-bit displacement from A0 into D7
			MOVE.L		D7,D3			Copy displacement byte to check sign
			ANDI.W		#BRA_16BIT,D3	Mask most significant bit
			CMP.W		#BRA_16BIT,D3
			CMP.W		#0,D3
			BGT			P_BLE_WN			
			*Print positive displacement
			ADD.W		A3,D7			Add memory and displacement
			ADD.W		#2,D7			Add 2 for word instruction	
			MOVEA.L		D7,A2			Moves the final value to register A2 so it could be printed using a subroutine
			LEA			HEXVAL,A1		Load the instruction to display
			MOVE.B		#14,D0			Moves the number 14 into data register D0
    			TRAP   	 	#15				Displays instruction
			BSR			PRINTMEM			
			LEA			BLANK,A1			Load blank line to print
			MOVE.B		#14,D0			Moves the number 14 into data register D0
    			TRAP   	 	#15				Displays blank line
*			Branch out of subroutine			
			BRA			P_BLE_END		Exit subroutine when done outputting
			
*			For negative displacement			
P_BLE_WN	NEG.W		D7				Change displacement from negative value to positive value
			SUB.L		#2,D7			Subtract 2 for word instruction (Actually means that we are adding 2 to A3)	
			SUB.L		D7,A3			Subtract displacement from memory
			MOVEA.L		A3,A2			Moves the final value to register A2 so it could be printed using a subroutine
			LEA			HEXVAL,A1		Load the instruction to display
			MOVE.B		#14,D0			Moves the number 14 into data register D0
    			TRAP   	 	#15				Displays instruction
			BSR			PRINTMEM			
			LEA			BLANK,A1			Load blank line to print
			MOVE.B		#14,D0			Moves the number 14 into data register D0
    			TRAP   	 	#15				Displays blank line
*			Branch out of subroutine			
			BRA			P_BLE_END		Exit subroutine when done outputting
			    
P_BLE_END	MOVEM.L		(SP)+,D0-D1/A1		Return program state when done
			RTS
	
**********************************************************************************************************************************
* I/O Subroutine: P_BEQ
*Prints the BEQ instruction. Checks for both positive and negative displacement, and byte or word size.
*Inputs:
*A2 - Contains the memory location of the instruction.
*D7 - Contains the instruction
*Outputs:
*None

P_BEQ		MOVEM.L		D0-D1/A1,-(SP)		Save program state
			CLR.L		D0
			
*			Print memory and command
			MOVEA.L		A2,A3			Save memory location for displacement calculation		
			BSR			PRINTMEM		Print the memory location stored in A2 corresponding to where the instruction is
    
*			Check the displacement length	
    			ANDI.W		#$00FF,D7		Apply mask to isolate least significant byte of instruction
			CMP.B		#$00,D7			    Check for 16-bit displacement
			BEQ			P_BEQ_W

*			Print 8-bit displacement	
			*Mask to determine positive or negative displacement
			LEA			P_BEQ_PRINTB,A1	Load the instruction to display
			MOVE.B		#14,D0			Moves the number 14 into data register D0
    			TRAP   	 	#15				Displays instruction	
			MOVE.L		D7,D3			Copy displacement byte to check sign
			ANDI.B		#$80,D3			Mask most significant bit
			CMP.W		#0,D3
			BGT			P_BEQ_NEG		
			*Print positive displacement		
			ADD.L		A3,D7			Add memory and displacement
			ADD.L		#2,D7			Add 2 for byte instruction	
			MOVEA.L		D7,A2			Moves the final value to register A2 so it could be printed using a subroutine
			LEA			HEXVAL,A1		Load the instruction to display
			MOVE.B		#14,D0			Moves the number 14 into data register D0
    			TRAP   	 	#15				Displays instruction
			BSR			PRINTMEM			
			LEA			BLANK,A1			Load blank line to print
			MOVE.B		#14,D0			Moves the number 14 into data register D0
    			TRAP   	 	#15				Displays blank line
*			Branch out of subroutine			
			BRA			P_BEQ_END		Exit subroutine when done outputting
			
*			For negative displacement			
P_BEQ_NEG	NEG.B		D7				Change displacement from negative value to positive value
			SUB.L		#2,D7			Subtract 2 for byte instruction (Actually means that we are adding 2 to A3)	
			SUB.L		D7,A3			Subtract displacement from memory
			MOVEA.L		A3,A2			Moves the final value to register A2 so it could be printed using a subroutine
			LEA			HEXVAL,A1		Load the instruction to display
			MOVE.B		#14,D0			Moves the number 14 into data register D0
    			TRAP   	 	#15				Displays instruction
			BSR			PRINTMEM			
			LEA			BLANK,A1			Load blank line to print
			MOVE.B		#14,D0			Moves the number 14 into data register D0
    			TRAP   	 	#15				Displays blank line
*			Branch out of subroutine			
			BRA			P_BEQ_END		Exit subroutine when done outputting

*			Print 16-bit displacement
P_BEQ_W		*Mask to determine positive or negative displacement
			LEA			P_BEQ_PRINTW,A1	Load the instruction to display
			MOVE.B		#14,D0			Moves the number 14 into data register D0
    			TRAP   	 	#15				Displays instruction
			MOVE.W		(A0)+,D7			Move 16-bit displacement from A0 into D7
			MOVE.L		D7,D3			Copy displacement byte to check sign
			ANDI.W		#BRA_16BIT,D3	Mask most significant bit
			CMP.W		#BRA_16BIT,D3
			CMP.W		#0,D3
			BGT			P_BEQ_WN			
			*Print positive displacement
			ADD.W		A3,D7			Add memory and displacement
			ADD.W		#2,D7			Add 2 for word instruction	
			MOVEA.L		D7,A2			Moves the final value to register A2 so it could be printed using a subroutine
			LEA			HEXVAL,A1		Load the instruction to display
			MOVE.B		#14,D0			Moves the number 14 into data register D0
    			TRAP   	 	#15				Displays instruction
			BSR			PRINTMEM			
			LEA			BLANK,A1			Load blank line to print
			MOVE.B		#14,D0			Moves the number 14 into data register D0
    			TRAP   	 	#15				Displays blank line
*			Branch out of subroutine			
			BRA			P_BEQ_END		Exit subroutine when done outputting
			
*			For negative displacement			
P_BEQ_WN	NEG.W		D7				Change displacement from negative value to positive value
			SUB.L		#2,D7			Subtract 2 for word instruction (Actually means that we are adding 2 to A3)	
			SUB.L		D7,A3			Subtract displacement from memory
			MOVEA.L		A3,A2			Moves the final value to register A2 so it could be printed using a subroutine
			LEA			HEXVAL,A1		Load the instruction to display
			MOVE.B		#14,D0			Moves the number 14 into data register D0
    			TRAP   	 	#15				Displays instruction
			BSR			PRINTMEM			
			LEA			BLANK,A1			Load blank line to print
			MOVE.B		#14,D0			Moves the number 14 into data register D0
    			TRAP   	 	#15				Displays blank line
*			Branch out of subroutine			
			BRA			P_BEQ_END		Exit subroutine when done outputting
			    
P_BEQ_END	MOVEM.L		(SP)+,D0-D1/A1		Return program state when done
			RTS
			
			
**********************************************************************************************************************************
* I/O Subroutine: P_LSL, P_LSR, P_LS_MEM, P_ASL, P_ASR, P_AS_MEM, P_ROL, P_ROR, P_RO_MEM
* Outputs the rotation instructions with the memory loaction displayed first, followed by the instruction, and then the operands.
* Upon entering, D6 and D7 should contain copies of the machine code. A1 contains the memory location of the instruction to be printed
* as well as a utility to print TRAP functions. (A3) and (A4) contains modifiers for the string EA parameter corresponding to its EA type.
* If an error occurs, it prints the memory location, followed by DATA, and the hex value for that instruction when it encounters a problem
* with unsupported EA values for that opcode.


P_LSL		MOVEM.L		D0-D1/A1,-(SP)		Saves the state of the program
			MOVE.L		D0,D7				Moves the machine code to D7
			
			BSR			PRINTMEM			Print the memory location stored in A1 corresponding to where the instruction is
			
			LEA			LSL_MSSG,A1
			MOVE.B		#14,D0
			TRAP		#15					Prints LSL
			
			BRA 		P_ROT_SIZE			Branches to decode the size of LSL
			
			
; Prints LSR
P_LSR		MOVEM.L		D0-D1/A1,-(SP)		Saves the state of the program
			MOVE.L		D0,D7				Moves the machine code to D7
			
			BSR			PRINTMEM			Print the memory location stored in A1 corresponding to where the instruction is
			
			LEA			LSR_MSSG,A1
			MOVE.B		#14,D0
			TRAP		#15					Prints LSR
			
			BRA			P_ROT_SIZE			Branches to decode the size of LSR

; Prints ASL
P_ASL		MOVEM.L		D0-D1/A1,-(SP)		Saves the state of the program
			MOVE.L		D0,D7				Moves the machine code to D7
			
			BSR			PRINTMEM			Print the memory location stored in A1 corresponding to where the instruction is
			
			LEA			ASL_MSSG,A1
			MOVE.B		#14,D0
			TRAP		#15					Prints ASL
			
			BRA			P_ROT_SIZE			Branches to decode the size of ASL

; Prints ASR			
P_ASR		MOVEM.L		D0-D1/A1,-(SP)		Saves the state of the program
			MOVE.L		D0,D7				Moves the machine code to D7
			
			BSR			PRINTMEM			Print the memory location stored in A1 corresponding to where the instruction is
			
			LEA			ASR_MSSG,A1
			MOVE.B		#14,D0
			TRAP		#15					Prints ASR
			
			BRA			P_ROT_SIZE			Branches to decode the size of ASR

; Prints ROL			
P_ROL		MOVEM.L		D0-D1/A1,-(SP)		Saves the state of the program
			MOVE.L		D0,D7				Moves the machine code to D7
			
			BSR			PRINTMEM			Print the memory location stored in A1 corresponding to where the instruction is
			
			LEA			ROL_MSSG,A1
			MOVE.B		#14,D0
			TRAP		#15					Prints ROL
			
			BRA			P_ROT_SIZE			Branches to decode the size of ROL

; Prints ROR			
P_ROR		MOVEM.L		D0-D1/A1,-(SP)		Saves the state of the program
			MOVE.L		D0,D7				Moves the machine code to D7
			
			BSR			PRINTMEM			Print the memory location stored in A1 corresponding to where the instruction is
			
			LEA			ROR_MSSG,A1
			MOVE.B		#14,D0
			TRAP		#15					Prints ROR
			
			BRA			P_ROT_SIZE			Branches to decode the size of ASR

; Gets the size for each of the rotation opcodes			
P_ROT_SIZE	MOVE.L		D6,D7				Moves the machine code to D7
			ANDI.L		#$C0,D7				Masks for the direction field
			LSR			#6,D7				Shifts the direction to bit 0

			CMP.W		#0,D7				Compares 0 to D7
			BEQ			P_BIT				If equals, its a byte
			
			CMP.W		#1,D7				Compares 1 to D7
			BEQ			P_WORD				If equals, its a word
			
			CMP.W		#2,D7				Compares 2 to D7
			BEQ			P_LONG				If equals, its a long

; Prints B
P_BIT		LEA			BIT,A1	
			MOVE.B		#14,D0		
			TRAP		#15					Prints B
			
			LEA			SPACE,A1
			MOVE.B		#14,D0		
			TRAP		#15					Prints Space
			
			BRA			P_ROT_CONT			Branches to find the I/R for the rotation opcode

; Prints W
P_WORD		LEA			WORD,A1
			MOVE.B		#14,D0		
			TRAP		#15					Prints W
			
			LEA			SPACE,A1
			MOVE.B		#14,D0		
			TRAP		#15					Prints Space
			
			BRA			P_ROT_CONT			Branches to find the I/R for the rotation opcode

; Prints L
P_LONG		LEA			LONG_MSSG,A1
			MOVE.B		#14,D0		
			TRAP		#15					Prints L
			
			LEA			SPACE,A1
			MOVE.B		#14,D0		
			TRAP		#15					Prints Space
					
			BRA			P_ROT_CONT			Branches to find the I/R for the rotation opcode
			
			
; Finds the I/R for the rotation opcode	
; If I/R = 0, its an immediate count
; If I/R = 1, its a data register	
P_ROT_CONT	MOVE.L		D6,D7				Moves the machine code to D7
			ANDI.L		#$20,D7				Masks for I/R
			
			LSR			#5,D7				Shifts it to bit 0
			CMP.W		#1,D7				Checks for I/R = 1
			BEQ			P_ROT_IR_1			If equals, it's I/R = 1
			BNE			P_ROT_IR_0			If not, it's I/R = 0
			
							
; If I/R is 0 its an immediate count			
P_ROT_IR_0	MOVE.L		D6,D7				Moves machine to D7
			ANDI.L		#$E00,D7			Masks for the Count/Register field
			
			LSR			#8,D7				
			LSR			#1,D7				Shifts 9 bits to the right
			LEA			PD,A1
			MOVE.B		#14,D0
			TRAP		#15					Prints the pound dollar 				
			
			MOVE.L		D7,D1
			CMP.L		#0,D1
			BNE			P_ROT_IR_X
			MOVE.B		#8,D1
			
P_ROT_IR_X	MOVE.B		#3,D0		
			TRAP		#15					Prints signed number in D1.L
			
			LEA			COMMA,A1	
			MOVE.B		#14,D0		
    		TRAP   	 	#15					Prints the comma
    				
    		BRA			P_ROT_DONE			Branches to print the last data register


; If I/R is 1, it's a data register
P_ROT_IR_1  MOVE.L		D6,D7				Moves machine to D7
			ANDI.L		#$E00,D7			Masks for the Count/Register field
			
			LSR			#8,D7				
			LSR			#1,D7				Shifts 9 bits to the right
		
			LEA			DREG,A1
			MOVE.B		#14,D0
			TRAP		#15					Prints the D char
			
			MOVE.L		D7,D1
			MOVE.B		#3,D0
			TRAP		#15					Prints num in D7 for first data register
			
			LEA			COMMA,A1	
			MOVE.B		#14,D0		
    		TRAP   	 	#15					Prints the comma
    		
    		BRA			P_ROT_DONE			Branches to print the last data register

; To print the data register the rotation opcode is affecting
P_ROT_DONE	MOVE.L		D6,D7				Moves a copy of the machine code to D7
			ANDI.L		#$7,D7				Masks for the machine code
			
			LEA			DREG,A1
			MOVE.B		#14,D0
			TRAP		#15					Prints the D char
			
			MOVE.L		D7,D1
			MOVE.B		#3,D0
			TRAP		#15					Prints last data register
			
			LEA			CRLF,A1
			MOVE.B		#14,D0
			TRAP		#15					Prints the new line
			
			BRA			BREAK4				Breaks out to program loop
			

; To print for LSL/LSR memory shift			
P_LS_MEM	MOVEM.L		D0-D1/A1,-(SP)		Saves the program state
			MOVE.L		D0,D6				Makes a copy of the machine code in D6/D7
			MOVE.L		D0,D7				
			
			BSR			PRINTMEM			Print the memory location stored in A1 corresponding to where the instruction is

			
			ANDI.L		#$100,D7			Masks for direction
			LSR.L		#8,D7				Shifts it into place
			
			CMP.B		#1,D7				If 1 then its LSL, else its LSR
			BEQ			P_LSL_MEM			It's LSL
			BRA			P_LSR_MEM			It's 0, then it's LSR

; To print LSL as a memory shift
P_LSL_MEM	CLR.L		D5					Clears the D5 Register
			
			MOVE.L		D6,D7				Loads a copy of the machine code into D7 to be masked
			ANDI.L		#$3F,D7				Masks for the EA
			MOVE.L		D7,D1				Loads the 6 bits into D1
			
			BSR			GETEA				Interpret the 6 bits corresponding to the effective address in the EA subroutine
			
			CLR.L		D1					Clear register before using
			MOVE.B		EAVALID,D1			Move flag to D1 to check for valid EA mode
			CMP			#0,D1				Check for invalid EA mode
			BEQ			ERROR1				If invalid, display error message and do not call print subroutine	
			
			CMP.B		#0,EAMODE			Checks for unsupported EAMODE for rotation subroutine: 0 
			BEQ			ERROR1
			
			CMP.B		#1,EAMODE			Checks for unsupported EAMODE for rotation subroutine: 1
			BEQ			ERROR1
			
			CMP.B		#9,EAMODE			Checks for unsupported EAMODE for rotation subroutine: 9
			BEQ			ERROR1
				
			
			LEA			LSL_SINGLE,A1	
			MOVE.B		#14,D0
			TRAP		#15			 		Prints LSL.W

			CMP.B		#4,EAMODE		
			BLE			P_An				Check if EAMODE is less than 4, (No fetch EAMODE)
			
			CMP.B		#7,EAMODE			Checks if EAMODE is 7 for .W (Needs fetch)
			BEQ			P_W					
			
			CMP.B		#8,EAMODE			Checks if EAMODE is 8 for .W (Needs fetch)
			BEQ			P_L			

			CMP.B		#9,EAMODE			Checks if EAMODE is 9 for #<data> (Needs fetch)
			BGE			P_Num	
			 
			
; To print LSR as a memory shift
P_LSR_MEM	CLR.L		D5					Clears the D5 Register
			
			MOVE.L		D6,D7				Loads a copy of the machine code into D7 to be masked
			ANDI.L		#$3F,D7				Masks for the EA
			MOVE.L		D7,D1				Loads the 6 bits into D1
			
			BSR			GETEA				Interpret the 6 bits corresponding to the effective address in the EA subroutine
			
			CLR.L		D1					Clear register before using
			MOVE.B		EAVALID,D1			Move flag to D1 to check for valid EA mode
			CMP			#0,D1				Check for invalid EA mode
			BEQ			ERROR1				If invalid, display error message and do not call print subroutine	
			
			CMP.B		#0,EAMODE			Checks for unsupported EAMODE for rotation subroutine: 0 
			BEQ			ERROR1
			
			CMP.B		#1,EAMODE			Checks for unsupported EAMODE for rotation subroutine: 1
			BEQ			ERROR1
			
			CMP.B		#9,EAMODE			Checks for unsupported EAMODE for rotation subroutine: 9
			BEQ			ERROR1
				
			
			LEA			LSR_SINGLE,A1	
			MOVE.B		#14,D0
			TRAP		#15			 		Prints LSR.W

			CMP.B		#4,EAMODE		
			BLE			P_An				Check if EAMODE is less than 4, (No fetch EAMODE)
			
			CMP.B		#7,EAMODE			Checks if EAMODE is 7 for .W (Needs fetch)
			BEQ			P_W					
			
			CMP.B		#8,EAMODE			Checks if EAMODE is 8 for .W (Needs fetch)
			BEQ			P_L			

			CMP.B		#9,EAMODE			Checks if EAMODE is 9 for #<data> (Needs fetch)
			BEQ			P_Num


; To print ASL/ASR as a memory shift			
P_AS_MEM	MOVEM.L		D0-D1/A1,-(SP)		Saves the program state
			MOVE.L		D0,D6				Makes a copy of the machine code for D6/D7
			MOVE.L		D0,D7
			
			BSR			PRINTMEM			Print the memory location stored in A1 corresponding to where the instruction is

			
			ANDI.L		#$100,D7			Masks for direction
			LSR.L		#8,D7
			
			CMP.B		#1,D7				If 1 then its ASL, else its ASR
			BEQ			P_ASL_MEM
			BRA			P_ASR_MEM

; To print ASL as a memory shift			
P_ASL_MEM	CLR.L		D5					Clears the D5 Register
			
			MOVE.L		D6,D7				Loads a copy of the machine code into D7 to be masked
			ANDI.L		#$3F,D7				Masks for the EA
			MOVE.L		D7,D1				Loads the 6 bits into D1
			
			BSR			GETEA				Interpret the 6 bits corresponding to the effective address in the EA subroutine
			
			CLR.L		D1					Clear register before using
			MOVE.B		EAVALID,D1			Move flag to D1 to check for valid EA mode
			CMP			#0,D1				Check for invalid EA mode
			BEQ			ERROR1				If invalid, display error message and do not call print subroutine	
			
			CMP.B		#0,EAMODE			Checks for unsupported EAMODE for rotation subroutine: 0 
			BEQ			ERROR1
			
			CMP.B		#1,EAMODE			Checks for unsupported EAMODE for rotation subroutine: 1
			BEQ			ERROR1
			
			CMP.B		#9,EAMODE			Checks for unsupported EAMODE for rotation subroutine: 9
			BEQ			ERROR1
				
			
			LEA			ASL_SINGLE,A1	
			MOVE.B		#14,D0
			TRAP		#15			 		Prints ASL.W

			CMP.B		#4,EAMODE		
			BLE			P_An				Check if EAMODE is less than 4, (No fetch EAMODE)
			
			CMP.B		#7,EAMODE			Checks if EAMODE is 7 for .W (Needs fetch)
			BEQ			P_W					
			
			CMP.B		#8,EAMODE			Checks if EAMODE is 8 for .W (Needs fetch)
			BEQ			P_L			

			CMP.B		#9,EAMODE			Checks if EAMODE is 9 for #<data> (Needs fetch)
			BEQ			P_Num
	
; To print ASR as a memory shift		
P_ASR_MEM	CLR.L		D5					Clears the D5 Register
			
			MOVE.L		D6,D7				Loads a copy of the machine code into D7 to be masked
			ANDI.L		#$3F,D7				Masks for the EA
			MOVE.L		D7,D1				Loads the 6 bits into D1
			
			BSR			GETEA				Interpret the 6 bits corresponding to the effective address in the EA subroutine
			
			CLR.L		D1					Clear register before using
			MOVE.B		EAVALID,D1			Move flag to D1 to check for valid EA mode
			CMP			#0,D1				Check for invalid EA mode
			BEQ			ERROR1				If invalid, display error message and do not call print subroutine	
			
			CMP.B		#0,EAMODE			Checks for unsupported EAMODE for rotation subroutine: 0 
			BEQ			ERROR1
			
			CMP.B		#1,EAMODE			Checks for unsupported EAMODE for rotation subroutine: 1
			BEQ			ERROR1
			
			CMP.B		#9,EAMODE			Checks for unsupported EAMODE for rotation subroutine: 9
			BEQ			ERROR1
				
			
			LEA			ASR_SINGLE,A1	
			MOVE.B		#14,D0
			TRAP		#15			 		Prints ASR.W

			CMP.B		#4,EAMODE		
			BLE			P_An				Check if EAMODE is less than 4, (No fetch EAMODE)
			
			CMP.B		#7,EAMODE			Checks if EAMODE is 7 for .W (Needs fetch)
			BEQ			P_W					
			
			CMP.B		#8,EAMODE			Checks if EAMODE is 8 for .W (Needs fetch)
			BEQ			P_L			

			CMP.B		#9,EAMODE			Checks if EAMODE is 9 for #<data> (Needs fetch)
			BEQ			P_Num


; Prints for ROL/ROR memory shift			
P_RO_MEM	MOVEM.L		D0-D1/A1,-(SP)		Saves the program state
			MOVE.L		D0,D6				Saves the machine code to D6 and D7
			MOVE.L		D0,D7
			
			BSR			PRINTMEM			Print the memory location stored in A1 corresponding to where the instruction is

			
			ANDI.L		#$100,D7			Masks for direction
			LSR.L		#8,D7				Shifts it into place
			
			CMP.B		#1,D7				If 1 then its ROL, else its ROR
			BEQ			P_ROL_MEM		
			BRA			P_ROR_MEM

; Prints for ROL memory shift
P_ROL_MEM	CLR.L		D5					Clears the D5 Register
			
			MOVE.L		D6,D7				Loads a copy of the machine code into D7 to be masked
			ANDI.L		#$3F,D7				Masks for the EA
			MOVE.L		D7,D1				Loads the 6 bits into D1
			
			BSR			GETEA				Interpret the 6 bits corresponding to the effective address in the EA subroutine
			
			CLR.L		D1					Clear register before using
			MOVE.B		EAVALID,D1			Move flag to D1 to check for valid EA mode
			CMP			#0,D1				Check for invalid EA mode
			BEQ			ERROR1				If invalid, display error message and do not call print subroutine	
			
			CMP.B		#0,EAMODE			Checks for unsupported EAMODE for rotation subroutine: 0 
			BEQ			ERROR1
			
			CMP.B		#1,EAMODE			Checks for unsupported EAMODE for rotation subroutine: 1
			BEQ			ERROR1
			
			CMP.B		#9,EAMODE			Checks for unsupported EAMODE for rotation subroutine: 9
			BEQ			ERROR1
				
			
			LEA			ROL_SINGLE,A1	
			MOVE.B		#14,D0
			TRAP		#15			 		Prints LSL.W

			CMP.B		#4,EAMODE		
			BLE			P_An				Check if EAMODE is less than 4, (No fetch EAMODE)
			
			CMP.B		#7,EAMODE			Checks if EAMODE is 7 for .W (Needs fetch)
			BEQ			P_W					
			
			CMP.B		#8,EAMODE			Checks if EAMODE is 8 for .W (Needs fetch)
			BEQ			P_L			

			CMP.B		#9,EAMODE			Checks if EAMODE is 9 for #<data> (Needs fetch)
			BEQ			P_Num
	

; Prints for ROR memory shift
P_ROR_MEM	CLR.L		D5					Clears the D5 Register
			
			MOVE.L		D6,D7				Loads a copy of the machine code into D7 to be masked
			ANDI.L		#$3F,D7				Masks for the EA
			MOVE.L		D7,D1				Loads the 6 bits into D1
			
			BSR			GETEA				Interpret the 6 bits corresponding to the effective address in the EA subroutine
			
			CLR.L		D1					Clear register before using
			MOVE.B		EAVALID,D1			Move flag to D1 to check for valid EA mode
			CMP			#0,D1				Check for invalid EA mode
			BEQ			ERROR1				If invalid, display error message and do not call print subroutine	
			
			CMP.B		#0,EAMODE			Checks for unsupported EAMODE for rotation subroutine: 0 
			BEQ			ERROR1
			
			CMP.B		#1,EAMODE			Checks for unsupported EAMODE for rotation subroutine: 1
			BEQ			ERROR1
			
			CMP.B		#9,EAMODE			Checks for unsupported EAMODE for rotation subroutine: 9
			BEQ			ERROR1
				
			
			LEA			ROR_SINGLE,A1	
			MOVE.B		#14,D0
			TRAP		#15			 		Prints LSL.W

			CMP.B		#4,EAMODE		
			BLE			P_An				Check if EAMODE is less than 4, (No fetch EAMODE)
			
			CMP.B		#7,EAMODE			Checks if EAMODE is 7 for .W (Needs fetch)
			BEQ			P_W					
			
			CMP.B		#8,EAMODE			Checks if EAMODE is 8 for .W (Needs fetch)
			BEQ			P_L			

			CMP.B		#9,EAMODE			Checks if EAMODE is 9 for #<data> (Needs fetch)
			BEQ			P_Num            			


; Prints for address register
P_An
		
			LEA			(A3),A1				Load the left modifier to display
			MOVE.B		#14,D0				Moves the number 14 into data register D0
    		TRAP   	 	#15					Displays modifier
    		
    		MOVE.B       #15,D0        		TRAP task 15 displays an unsigned number in D1.L in decimal notation
            CLR.L        D1            		Clear D1
            MOVE.B       (REGL),D1        	Move register number to D1 to display it
            TRAP         #15            	Displays number in D1
            
            MOVE.B		D7,D1
            MOVE.B		#3,D0
            TRAP		#15					Prints the address register number stored in D7

			LEA			(A4),A1				Load the right modifier to display
			MOVE.B		#14,D0				Moves the number 14 into data register D0
    		TRAP   	 	#15					Displays modifier
    		
    		LEA			CRLF,A1
    		MOVE.B		#14,D0
    		TRAP		#15					Prints the new line
    		
    		BRA			BREAK4				Branches back to loop

; Prints for (XXX).W    			
P_W			LEA			(A3),A1				Load the left modifier to display
			MOVE.B		#14,D0				Moves the number 14 into data register D0
    		TRAP   	 	#15					Displays modifier
    		
    		MOVE.B       #15,D0        		TRAP task 15 displays an unsigned number in D1.L in decimal notation
            CLR.L        D1            		Clear D1
            MOVE.B       (REGL),D1        	Move register number to D1 to display it
            TRAP         #15            	Displays number in D1
            
            
            MOVEA.L		D5,A2				Moves EA of instruction into address register A2 so it could be printed using a subroutine
     		BSR			PRINTMEMW   		Print the word of memory corresponding to the EA type


			LEA			(A4),A1				Load the right modifier to display
			MOVE.B		#14,D0				Moves the number 14 into data register D0
    		TRAP   	 	#15					Displays modifier
    		
    		LEA			CRLF,A1
    		MOVE.B		#14,D0
    		TRAP		#15					Prints the new line
    		
    		BRA			BREAK4				Branches back to loop
    		
; Prints for (XXX).L
P_L			LEA			(A3),A1				Load the left modifier to display
			MOVE.B		#14,D0				Moves the number 14 into data register D0
    		TRAP   	 	#15					Displays modifier
    		
    		MOVE.B       #15,D0        		TRAP task 15 displays an unsigned number in D1.L in decimal notation
            CLR.L        D1            		Clear D1
            MOVE.B       (REGL),D1        	Move register number to D1 to display it
            TRAP         #15            	Displays number in D1
            
            
            MOVEA.L		D5,A2				Moves EA of instruction into address register A2 so it could be printed using a subroutine
     		BSR			PRINTMEM   		Print the word of memory corresponding to the EA type


			LEA			(A4),A1				Load the right modifier to display
			MOVE.B		#14,D0				Moves the number 14 into data register D0
    		TRAP   	 	#15					Displays modifier
    		
    		LEA			CRLF,A1
    		MOVE.B		#14,D0
    		TRAP		#15					Prints the new line
    		
    		BRA			BREAK4				Branches back to loop
 

; Prints for #<data>   		
P_Num		LEA			(A3),A1				Load the left modifier to display
			MOVE.B		#14,D0				Moves the number 14 into data register D0
    		TRAP   	 	#15					Displays modifier
    		
    		MOVE.B       #15,D0        		TRAP task 15 displays an unsigned number in D1.L in decimal notation
            CLR.L        D1            		Clear D1
            MOVE.B       (REGL),D1        	Move register number to D1 to display it
            
		    TRAP         #15            	Displays number in D1
            
            
            MOVEA.L		D5,A2				Moves EA of instruction into address register A2 so it could be printed using a subroutine
     		BSR			PRINTMEMW   		Print the word of memory corresponding to the EA type


			LEA			(A4),A1				Load the right modifier to display
			MOVE.B		#14,D0				Moves the number 14 into data register D0
    		TRAP   	 	#15					Displays modifier
    		
    		
    		LEA			CRLF,A1
    		MOVE.B		#14,D0
    		TRAP		#15					Prints the new line
    		
    		BRA			BREAK4				Branches back to loop
; In case an error occurs for uncompatible EAMODE flags, prints DATA followed by the hex value
ERROR1		LEA			IOERROR8,A1			Load invalid op-code message			
			MOVE.B		#14,D0				Moves the number 14 into data register D0
    		TRAP   	 	#15					Displays <TAB>DATA  <TAB>
    		
			* Clear registers before using
    		CLR.L		D5					
    		CLR.L		D1
    		
    		MOVE.W		(A2),D1				(A2) contains the hex value of the word
    		MOVEA.L		D1,A2				Set A2 to contain the hex value of the word to print in the subroutine PRINTMEMW
    		BSR			PRINTMEMW			Print the hex value of the word
    		
    		CLR.L			D1				Clear register before using
			MOVE.B			EAVALID,D1		Move flag to D1 to check for valid EA mode
			CMP.L			#0,D1			Check for invalid EA mode
			BNE				DONE_BLANK2
			
			LEA				IOERROR12,A1		ELSE starting address is invalid, display
			MOVE.B			#14,D0			
    		TRAP   	 		#15	
    		
DONE_BLANK2 LEA			BLANK,A1			Load blank line to print
			MOVE.B		#14,D0				Moves the number 14 into data register D0
    		TRAP   	 	#15					Advances output to beginning of next line
    		
    		BRA			BREAK4				Branches back to loop
    		
BREAK4		MOVEM.L		(SP)+,D0-D1/A1
			BRA 		DONE2

**********************************************************************************************************************************
* I/O Subroutine: P_MOVEM
* Outputs the MOVEM instruction with the memory location displayed first, followed by the instruction, and then the operands.
* Upon entering, A1 contains the memory location of the instruction to print. A1 is also used by the trap function to 
* display the string at the location pointed to by it. Also, D0 is used by the trap function to display a null terminated string,
* D5 contains the EA of the operand to print, and D6 contains the register number. (A3) and (A4) contain modifiers for the string 
* EA parameter corresponding to its EA type, or its set to 0 (null) if not used corresponding to the left and right sides of the
* operand, respectively. D1.L is used to store the number to print for the trap function.  D5 contains the operand to print. Upon
* entering the subroutine, D7 will contain the EA register number or a flag for (xxx).W or (xxx).L to determine if its W or L. In
* addition, D5 contains the operand fetched from memory if a CPU fetch was required for (xxx).W or (xxx).L EA modes
P_MOVEM		MOVEM.L		D0-D2/A1,-(SP)	Save program state
			CLR.L		D0
			CLR.B		MTRFLAG		Reset MTRFLAG
			CLR.B		PREVREG

			BSR			PRINTMEM	Print the memory location stored in A1 corresponding to where the instruction is
			
			CMP.B		#1,SIZE		Check if the size of the operation is word transfer
			BNE			MOVEML		IF SIZE != 0, then the size is a long transer
			
			LEA			MOVEMW1,A1	Load the instruction to display
			MOVE.B		#14,D0		Moves the number 14 into data register D0
    		TRAP   	 	#15			Displays instruction
			BRA			NEXT6

MOVEML		LEA			MOVEML1,A1	Load the instruction to display
			MOVE.B		#14,D0		Moves the number 14 into data register D0
    		TRAP   	 	#15			Displays instruction

NEXT6		CMP.B		#0,DR		Check if dr mode is register to memory
			BNE			MTR			IF dr mode is not register to memory, its memory to register
			
			CMP.B		#4,EAMODE	Check if EA mode is address register indirect with pre-decrement
			BNE			NONPD		The register mask is different for address register indirect with pre-decrement,
*									so the order of bits the registers are stored in will be different. This test will determine
*									the order of the bits in the register mask of the instruction and process them accordingly

			CLR.B		REGCOUNT	Initialize the register counter to correspond correspond to the register number
			CLR.B		FIRSTREG	Initialize the flag to check if a leading backslash needs to be printed
			CLR.B		PRINTL		Initialize the flag to check if last register(s) still need to be printed after
*									reading through a portion of the register list mask
			MOVE.B		#$FF,SSTART	Initialize the flag to determine if any values were printed yet
			
*									to register #0, for the first iteration of the loop
			MOVE.B		#7,COUNT	Initialize the loop counter to correspond to the bit for A0 in the register mask

* Scan all of the address registers of the register list mask
LOOPD		CLR.L		D1
			CLR.L		D0	
			MOVE.W		REGMASK,D0
			MOVE.B		COUNT,D1
			BTST.L		D1,D0   Test the bit corresponding to the number in COUNT to see if its 0
			BEQ			Z			If Z flag of CCR is set, the register is not used
			
* The following block is entered if the bit tested = 1
			CMP.B		#7,COUNT	Check if this is the first time going through the loop
			BEQ			NEXT7       IF its the first time, there's no need to check for a sequence before the first bit
			CMP.B		#1,PREVREG	ELSE check if there's a sequence of registers, e.g. A0, A1, A2, etc.
			BNE			NEXT7			by checking if the previous register was set
			CLR.L		D1
			MOVE.B		PREVREG,D1
			CMP.B		#1,D1		Check if the previous register is set
			BNE			NEXT7
			BRA			SEQEXIST	Sequence already exists, no need to set the starting location	
			
Z			CMP.B		#7,COUNT	Check if this is the first time going through the loop
			BEQ			NEXT8       IF its the first time, there's no need to check if you need to print
		    		
* Check if there are any new registers that need to be prined by looking at if the previous bit is 0,
* INVARIANT: the previous and current bit are 0 iff no new register were added
	
			CLR.L		D0
			MOVE.B		PREVREG,D0	
			MOVE.B		#0,PREVREG	Update previous register to show its not set
			CMP.B		#0,D0		Check if previous register was set
			BEQ			NEXT8		Only print if the last register was set, otherwise continue loop
			
* Check if no registers have been set
REPRINT		CMP.B		#0,FIRSTREG
			BEQ			NOTFIRST

			LEA			BACKSL,A1	Load the backslash to display
			MOVE.B		#14,D0		Moves the number 14 into data register D0
    		TRAP   	 	#15			Displays backslash

NOTFIRST	MOVE.B		#1,FIRSTREG
			CLR.L		D0
			MOVE.B		SSTART,D0
			CLR.L		D1
			MOVE.B		SEND,D1
			
* Check if the value being printed is a single register or a range of values
			CMP.B		D0,D1
			BEQ			PSINGLE		If the start and end of the sequence are the same, print a single value
*										ELSE print the sequence in range format
		
*			Display the first register in the range
			LEA			AREG,A1		Load the register type to display
			MOVE.B		#14,D0		Moves the number 14 into data register D0
    		TRAP   	 	#15			Displays register type
    		
			MOVE.B		#15,D0		TRAP task 15 displays an unsigned number in D1.L in decimal notation
			MOVE.B		SSTART,D1	Move register number for start of sequence to D1 to display it
			MOVE.L		#10,D2		D2 contains the base of the digit to print
			TRAP   	 	#15			Displays number in D1	

			LEA			DASH,A1		Load the register type to display
			MOVE.B		#14,D0		Moves the number 14 into data register D0
    		TRAP   	 	#15			Prints a dash
    		
*			Display the second register in the range

			LEA			AREG,A1		Load the register type to display
			MOVE.B		#14,D0		Moves the number 14 into data register D0
    		TRAP   	 	#15			Displays register type
    		
			MOVE.B		#15,D0		TRAP task 15 displays an unsigned number in D1.L in decimal notation
			MOVE.L		#10,D2		D2 contains the base of the digit to print
			MOVE.B		SEND,D1		Move register number for end of sequence to D1 to display it
			TRAP   	 	#15			Displays number in D1

			BRA			NEXT8				
										
PSINGLE		LEA			AREG,A1		Load the register type to display
			MOVE.B		#14,D0		Moves the number 14 into data register D0
    		TRAP   	 	#15			Displays register type
    		
			MOVE.B		#15,D0		TRAP task 15 displays an unsigned number in D1.L in decimal notation
			MOVE.B		SSTART,D1	Move register number for start of sequence to D1 to display it
			MOVE.L		#10,D2		D2 contains the base of the digit to print
			TRAP   	 	#15			Displays number in D1	

			BRA 		NEXT8

* Update the end of the sequence to the new value
NEXT7		CLR.B		SSTART				Unset the $FF flag used to test for no registers being set
			MOVE.B		REGCOUNT,SSTART
SEQEXIST	MOVE.B		REGCOUNT,SEND

* Update the previous register flag for the next iteration of the loop to test, to show its being used
			MOVE.B		#1,PREVREG
			
NEXT8		CMP.B		#1,PRINTL	Check if printing after exiting loop the first time
*									if true, break out
			BEQ			NOPRINT
			ADDQ.B		#1,REGCOUNT	Increment register counter to advance to next register
			SUBQ.B		#1,COUNT	Decrement loop counter and advance to next bit to test
			CMP.B		#0,COUNT
			BGE			LOOPD		Continue looping until all address registers are read
			
* Reset count and scan the data registers of the register list mask
			
* Check if the first bit was 1, if so there's either a
* range of registers or a singe register needing to be printed
			MOVE.W		REGMASK,D0
			BTST.L		#0,D0
			BEQ			NOPRINT		Don't need to print anything if the CCR flag Z = 1
			MOVE.B		#1,PRINTL		
			BRA			REPRINT		Print the last register(s) for the outoput
			
NOPRINT		CLR.B		REGCOUNT	Initialize the register counter to correspond to the register number
			CLR.B		PREVREG
			CLR.B		PRINTL		Reset PRINTL for next loop
			MOVE.B		#15,COUNT	Reload the loop counter to correspond to the bit for D0 in the register mask
			MOVE.B		#$FF,SSTART	Initialize the flag to determine if any registers were printed

* Scan all of the data registers of the register list mask
LOOPE		CLR.L		D1
			CLR.L		D0	
			MOVE.W		REGMASK,D0
			MOVE.B		COUNT,D1
			BTST.L		D1,D0   Test the bit corresponding to the number in COUNT to see if its 0
			BEQ			ZZ			If Z flag of CCR is set, the register is not used
			
* The following block is entered if the bit tested = 1
			CMP.B		#$FF,SSTART	Check if this is the first time going through the loop
			BEQ			NEXT9       IF its the first time, there's no need to check for a sequence before the first bit
			CMP.B		#1,PREVREG	ELSE check if there's a sequence of registers, e.g. A0, A1, A2, etc.
			BNE			NEXT9			by checking if the previous register was set
			CLR.L		D1
			MOVE.B		PREVREG,D1
			CMP.B		#1,D1		Check if the previous register is set
			BNE			NEXT9
			BRA			SEQEXIST1	Sequence already exists, no need to set the starting location	
			
ZZ			CMP.B		#$FF,SSTART	Check if this is the first time going through the loop
			BEQ			NEXTA       IF its the first time, there's no need to check if you need to print
		    		
* Check if there are any new registers that need to be prined by looking at if the previous bit is 0,
* INVARIANT: the previous and current bit are 0 iff no new register were added
	
			CLR.L		D0
			MOVE.B		PREVREG,D0	
			MOVE.B		#0,PREVREG	Update previous register to show its not set
			CMP.B		#0,D0		Check if previous register was set
			BEQ			NEXTA		Only print if the last register was set, otherwise continue loop
			
* Check if no registers have been set
REPRINT1	CMP.B		#0,FIRSTREG
			BEQ			NOTFIRST1

			LEA			BACKSL,A1	Load the backslash to display
			MOVE.B		#14,D0		Moves the number 14 into data register D0
    		TRAP   	 	#15			Displays backslash

NOTFIRST1	MOVE.B		#1,FIRSTREG
			CLR.L		D0
			MOVE.B		SSTART,D0
			CLR.L		D1
			MOVE.B		SEND,D1
			
* Check if the value being printed is a single register or a range of values
			CMP.B		D0,D1
			BEQ			PSINGLE1		If the start and end of the sequence are the same, print a single value
*										ELSE print the sequence in range format

*			Display the first register in the range
			LEA			DREG,A1		Load the register type to display
			MOVE.B		#14,D0		Moves the number 14 into data register D0
    		TRAP   	 	#15			Displays register type
    		
			MOVE.B		#15,D0		TRAP task 15 displays an unsigned number in D1.L in decimal notation
			MOVE.B		SSTART,D1	Move register number for start of sequence to D1 to display it
			MOVE.L		#10,D2		D2 contains the base of the digit to print
			TRAP   	 	#15			Displays number in D1	

			LEA			DASH,A1		Load the register type to display
			MOVE.B		#14,D0		Moves the number 14 into data register D0
    		TRAP   	 	#15			Prints a dash
    		
*			Display the second register in the range

			LEA			DREG,A1		Load the register type to display
			MOVE.B		#14,D0		Moves the number 14 into data register D0
    		TRAP   	 	#15			Displays register type
    		
			MOVE.B		#15,D0		TRAP task 15 displays an unsigned number in D1.L in decimal notation
			MOVE.L		#10,D2		D2 contains the base of the digit to print
			MOVE.B		SEND,D1		Move register number for end of sequence to D1 to display it
			TRAP   	 	#15			Displays number in D1

			BRA			NEXTA				
										
PSINGLE1	LEA			DREG,A1		Load the register type to display
			MOVE.B		#14,D0		Moves the number 14 into data register D0
    		TRAP   	 	#15			Displays register type
    		
			MOVE.B		#15,D0		TRAP task 15 displays an unsigned number in D1.L in decimal notation
			MOVE.B		SSTART,D1	Move register number for start of sequence to D1 to display it
			MOVE.L		#10,D2		D2 contains the base of the digit to print
			TRAP   	 	#15			Displays number in D1	

			BRA 		NEXTA

* Update the end of the sequence to the new value
NEXT9		CLR.B		SSTART				Unset the $FF flag used to test for no registers being set
			MOVE.B		REGCOUNT,SSTART
SEQEXIST1	MOVE.B		REGCOUNT,SEND

* Update the previous register flag for the next iteration of the loop to test, to show its being used
			MOVE.B		#1,PREVREG
			
NEXTA		CMP.B		#1,PRINTL	Check if printing after exiting loop the first time
*									if true, break out
			BEQ			PRINTEA
			ADDQ.B		#1,REGCOUNT	Increment register counter to advance to next register
			SUBQ.B		#1,COUNT	Decrement loop counter and advance to next bit to test
			CMP.B		#8,COUNT
			BGE			LOOPE		Continue looping until all data registers are read
			
* Check if the first bit was 1, if so there's either a
* range of registers or a singe register needing to be printed
			MOVE.W		REGMASK,D0
			BTST.L		#8,D0
			BEQ			PRINTEA	Don't need to print anything if the CCR flag Z = 1, now prince the EA
			MOVE.B		#1,PRINTL		
			BRA			REPRINT1	Print the last register(s) for the output
			
			BRA			RETURN

* Print all other EA modes than address register indirect with pre-decrement separately since they have a different
* mapping of bits in their register list mask	
NONPD		CLR.B		REGCOUNT	Initialize the register counter to correspond to register number
			CLR.B		FIRSTREG	Initialize the flag to check if a leading backslash needs to be printed
			CLR.B		PRINTL		Initialize the flag to check if last register(s) still need to be printed after
*									reading through a portion of the register list mask
			CLR.B		PREVREG
*									to register #0, for the first iteration of the loop
			MOVE.B		#8,COUNT	Initialize the loop counter to correspond to the bit for A0 in the register mask

* Scan all of the address registers of the register list mask
LOOPF		CLR.L		D1
			CLR.L		D0	
			MOVE.W		REGMASK,D0
			MOVE.B		COUNT,D1
			BTST.L		D1,D0   Test the bit corresponding to the number in COUNT to see if its 0
			BEQ			ZZZ			If Z flag of CCR is set, the register is not used
			
* The following block is entered if the bit tested = 1
			CMP.B		#8,COUNT	Check if this is the first time going through the loop
			BEQ			NEXTB       IF its the first time, there's no need to check for a sequence before the first bit
			CMP.B		#1,PREVREG	ELSE check if there's a sequence of registers, e.g. A0, A1, A2, etc.
			BNE			NEXTB			by checking if the previous register was set
			CLR.L		D1
			MOVE.B		PREVREG,D1
			CMP.B		#1,D1		Check if the previous register is set
			BNE			NEXTB
			BRA			SEQEXIST2	Sequence already exists, no need to set the starting location	
			
ZZZ			CMP.B		#8,COUNT	Check if this is the first time going through the loop
			BEQ			NEXTC      IF its the first time, there's no need to check if you need to print
		    		
* Check if there are any new registers that need to be prined by looking at if the previous bit is 0,
* INVARIANT: the previous and current bit are 0 iff no new register were added
	
			CLR.L		D0
			MOVE.B		PREVREG,D0	
			MOVE.B		#0,PREVREG	Update previous register to show its not set
			CMP.B		#0,D0		Check if previous register was set
			BEQ			NEXTC		Only print if the last register was set, otherwise continue loop
			
* Check if no registers have been set
REPRINT2	CMP.B		#0,FIRSTREG
			BEQ			NOTFIRST2

			LEA			BACKSL,A1	Load the backslash to display
			MOVE.B		#14,D0		Moves the number 14 into data register D0
    		TRAP   	 	#15			Displays backslash

NOTFIRST2	MOVE.B		#1,FIRSTREG
			CLR.L		D0
			MOVE.B		SSTART,D0
			CLR.L		D1
			MOVE.B		SEND,D1
			
* Check if the value being printed is a single register or a range of values
			CMP.B		D0,D1
			BEQ			PSINGLE2	If the start and end of the sequence are the same, print a single value
*										ELSE print the sequence in range format

*			Display the first register in the range
			LEA			AREG,A1		Load the register type to display
			MOVE.B		#14,D0		Moves the number 14 into data register D0
    		TRAP   	 	#15			Displays register type
    		
			MOVE.B		#15,D0		TRAP task 15 displays an unsigned number in D1.L in decimal notation
			MOVE.B		SSTART,D1	Move register number for start of sequence to D1 to display it
			MOVE.L		#10,D2		D2 contains the base of the digit to print
			TRAP   	 	#15			Displays number in D1	

			LEA			DASH,A1		Load the register type to display
			MOVE.B		#14,D0		Moves the number 14 into data register D0
    		TRAP   	 	#15			Prints a dash
    		
*			Display the second register in the range

			LEA			AREG,A1		Load the register type to display
			MOVE.B		#14,D0		Moves the number 14 into data register D0
    		TRAP   	 	#15			Displays register type
    		
			MOVE.B		#15,D0		TRAP task 15 displays an unsigned number in D1.L in decimal notation
			MOVE.L		#10,D2		D2 contains the base of the digit to print
			MOVE.B		SEND,D1		Move register number for end of sequence to D1 to display it
			TRAP   	 	#15			Displays number in D1
			
			BRA			NEXTC				
										
PSINGLE2	LEA			AREG,A1		Load the register type to display
			MOVE.B		#14,D0		Moves the number 14 into data register D0
    		TRAP   	 	#15			Displays register type
    		
			MOVE.B		#15,D0		TRAP task 15 displays an unsigned number in D1.L in decimal notation
			MOVE.B		SSTART,D1	Move register number for start of sequence to D1 to display it
			MOVE.L		#10,D2		D2 contains the base of the digit to print
			TRAP   	 	#15			Displays number in D1	

			BRA 		NEXTC

* Update the end of the sequence to the new value
NEXTB		CLR.B		SSTART		Unset the $FF flag used to test for no registers being set
			MOVE.B		REGCOUNT,SSTART
SEQEXIST2	MOVE.B		REGCOUNT,SEND

* Update the previous register flag for the next iteration of the loop to test, to show its being used
			MOVE.B		#1,PREVREG
			
NEXTC		CMP.B		#1,PRINTL	Check if printing after exiting loop the first time
*									if true, break out
			BEQ			NOPRINT2
			ADDQ.B		#1,REGCOUNT	Increment register counter to advance to next register
			ADDQ.B		#1,COUNT	Increment loop counter and advance to next bit to test
			CMP.B		#$F,COUNT
			BLE			LOOPF		Continue looping until all address registers are read
			
* Reset count and scan the data registers of the register list mask
			
* Check if the first bit was 1, if so there's either a
* range of registers or a singe register needing to be printed
			MOVE.W		REGMASK,D0
			BTST.L		#$F,D0
			BEQ			NOPRINT2	Don't need to print anything if the CCR flag Z = 1
			MOVE.B		#1,PRINTL		
			BRA			REPRINT2	Print the last register(s) for the outoput
			
NOPRINT2	CLR.B		REGCOUNT	Initialize the register counter to correspond
			CLR.B		PRINTL		Reset PRINTL for next loop
			MOVE.B		#0,COUNT	Reload the loop counter to correspond to the bit for D0 in the register mask
			CLR.B		PREVREG

* Scan all of the data registers of the register list mask
LOOPF1		CLR.L		D1
			CLR.L		D0	
			MOVE.W		REGMASK,D0
			MOVE.B		COUNT,D1
			BTST.L		D1,D0 	    Test the bit corresponding to the number in COUNT to see if its 0
			BEQ			ZZZZ		If Z flag of CCR is set, the register is not used
			
* The following block is entered if the bit tested = 1
			CMP.B		#0,COUNT	Check if this is the first time going through the loop
			BEQ			NEXTD       IF its the first time, there's no need to check for a sequence before the first bit
			CMP.B		#1,PREVREG	ELSE check if there's a sequence of registers, e.g. A0, A1, A2, etc.
			BNE			NEXTD			by checking if the previous register was set
			BRA			SEQEXIST3	Sequence already exists, no need to set the starting location	
			
ZZZZ		CMP.B		#$FF,SSTART	Check if this is the first time going through the loop
			BEQ			NEXTE       IF its the first time, there's no need to check if you need to print
		    		
* Check if there are any new registers that need to be prined by looking at if the previous bit is 0,
* INVARIANT: the previous and current bit are 0 iff no new register were added
	
			CLR.L		D0
			MOVE.B		PREVREG,D0	
			MOVE.B		#0,PREVREG	Update previous register to show its not set
			CMP.B		#0,D0		Check if previous register was set
			BEQ			NEXTE		Only print if the last register was set, otherwise continue loop
			
* Check if no registers have been set
REPRINT3	CMP.B		#0,FIRSTREG
			BEQ			NOTFIRST3

			LEA			BACKSL,A1	Load the backslash to display
			MOVE.B		#14,D0		Moves the number 14 into data register D0
    		TRAP   	 	#15			Displays backslash

NOTFIRST3	MOVE.B		#1,FIRSTREG
			CLR.L		D0
			MOVE.B		SSTART,D0
			CLR.L		D1
			MOVE.B		SEND,D1
			
* Check if the value being printed is a single register or a range of values
			CMP.B		D0,D1
			BEQ			PSINGLE3		If the start and end of the sequence are the same, print a single value
*										ELSE print the sequence in range format

*			Display the first register in the range
			LEA			DREG,A1		Load the register type to display
			MOVE.B		#14,D0		Moves the number 14 into data register D0
    		TRAP   	 	#15			Displays register type
    		
			MOVE.B		#15,D0		TRAP task 15 displays an unsigned number in D1.L in decimal notation
			MOVE.B		SSTART,D1	Move register number for start of sequence to D1 to display it
			MOVE.L		#10,D2		D2 contains the base of the digit to print
			TRAP   	 	#15			Displays number in D1	

			LEA			DASH,A1		Load the register type to display
			MOVE.B		#14,D0		Moves the number 14 into data register D0
    		TRAP   	 	#15			Prints a dash
    		
*			Display the second register in the range

			LEA			DREG,A1		Load the register type to display
			MOVE.B		#14,D0		Moves the number 14 into data register D0
    		TRAP   	 	#15			Displays register type
    		
			MOVE.B		#15,D0		TRAP task 15 displays an unsigned number in D1.L in decimal notation
			MOVE.L		#10,D2		D2 contains the base of the digit to print
			MOVE.B		SEND,D1		Move register number for end of sequence to D1 to display it
			TRAP   	 	#15			Displays number in D1
			
* Check if dr mode is MTR and if printing last line to see if using this subroutine for this mode
			CMP.B		#1,DR
			BNE			NEXTE
			CMP.B		#1,PRINTL
			BEQ			NEXTMTR1
			
			BRA			NEXTE				
										
PSINGLE3	LEA			DREG,A1		Load the register type to display
			MOVE.B		#14,D0		Moves the number 14 into data register D0
    		TRAP   	 	#15			Displays register type
    		
			MOVE.B		#15,D0		TRAP task 15 displays an unsigned number in D1.L in decimal notation
			MOVE.B		SSTART,D1	Move register number for start of sequence to D1 to display it
			MOVE.L		#10,D2		D2 contains the base of the digit to print
			TRAP   	 	#15			Displays number in D1	
			
* Check if dr mode is MTR and if printing last line to see if using this subroutine for this mode
			CMP.B		#1,DR
			BNE			NEXTE
			CMP.B		#1,PRINTL
			BEQ			NEXTMTR1
			
			BRA 		NEXTE

* Update the end of the sequence to the new value
NEXTD		CLR.B		SSTART				Unset the $FF flag used to test for no registers being set
			MOVE.B		REGCOUNT,SSTART
SEQEXIST3	MOVE.B		REGCOUNT,SEND

* Update the previous register flag for the next iteration of the loop to test, to show its being used
			MOVE.B		#1,PREVREG
			
NEXTE		CMP.B		#1,PRINTL	Check if printing after exiting loop the first time
*									if true, break out
			BEQ			PRINTEA
			ADDQ.B		#1,REGCOUNT	Increment register counter to advance to next register
			ADDQ.B		#1,COUNT	Increment loop counter and advance to next bit to test
			CMP.B		#7,COUNT
			BLE			LOOPF1		Continue looping until all data registers are read
			
* Check if the first bit was 1, if so there's either a
* range of registers or a singe register needing to be printed
			MOVE.W		REGMASK,D0
			
* This code checks if this subroutine is being used by the MTR dr mode
*			Check if dr mode is MTR and if printing last line to see if using this subroutine for this mode
			CMP.B		#1,DR
			BEQ			NEXTMTR1
			
			BTST.L		#7,D0
			BEQ			PRINTEA		Don't need to print anything if the CCR flag Z = 1, now print the EA
			MOVE.B		#1,PRINTL		
			BRA			REPRINT3	Print the last register(s) for the output
			
			BRA			RETURN
			
MTR			MOVE.B		#1,MTRFLAG	Set MTRFLAG to true

			BRA			PRINTEA1	Print the EA operand

NEXTMTR		LEA			COMMA,A1	Load comma to print
			MOVE.B		#14,D0		Moves the number 14 into data register D0
    		TRAP   	 	#15			Displays comma
    		
    		BRA			NONPD		Print the register list
    		
NEXTMTR1	BTST.L		#7,D0
			BEQ			NOPEA1		Don't need to print anything if the CCR flag Z = 1, now print the EA
			MOVE.B		#1,PRINTL		
			BRA			REPRINT3	Print the last register(s) for the output

NOPEA1		LEA			BLANK,A1	Load blank line to print
			MOVE.B		#14,D0		Moves the number 14 into data register D0
    		TRAP   	 	#15			Displays comma
			
    		BRA			RETURN		Return when done outputting
    		
    		
* Print the EA mode next

PRINTEA		CLR.L		D0
			LEA			COMMA,A1	Load comma to display
			MOVE.B		#14,D0		Moves the number 14 into data register D0
    		TRAP   	 	#15			Displays comma
    		
* Check if CPU was required to make an outside fetch; used to determine if an address needs to be printed
PRINTEA1	CMP.B		#0,EAFETCH	EAFETCH = 0 iff no fetch was needed (EA is inside the instruction)
			BEQ			NOFETCH1
			
* A fetch was required by the CPU, so print the effective address of the operand
			MOVEA.L		D5,A2
			CMP.B		#7,EAMODE	Test if EAMODE = 7 (absolute address word)
			BNE			PADR1		Print the address as a long corresponding to DR = 1
			
			LEA			(A3),A1		Load left modifier to display
			MOVE.B		#14,D0		Moves the number 14 into data register D0
    		TRAP   	 	#15			Displays left modifier of EA if it exists

			BSR			PRINTMEMW	Print the EA of the operand as a 16 bit word
			
			LEA			(A4),A1		Load right modifier to display
			MOVE.B		#14,D0		Moves the number 14 into data register D0
    		TRAP   	 	#15			Displays right modifier of EA if it exists
    		
    		CMP.B		#1,MTRFLAG	Check if blank line needs to be printed
    		BEQ			NEXTMTR
    		LEA			BLANK,A1	Load blank line to print
			MOVE.B		#14,D0		Moves the number 14 into data register D0
    		TRAP   	 	#15			Displays blank line
    		
    		BRA			RETURN			Done outputting, now return from subroutine	
    				
PADR1		MOVEA.L		A3,A1		Load left modifier to display
			MOVE.B		#14,D0		Moves the number 14 into data register D0
    		TRAP   	 	#15			Displays left modifier of EA if it exists

			BSR			PRINTMEM	Print the EA of the operand as a 32 bit longword
			
			MOVEA.L		A4,A1		Load right modifier to display
			MOVE.B		#14,D0		Moves the number 14 into data register D0
    		TRAP   	 	#15			Displays right modifier of EA if it exists
    		
    		CMP.B		#1,MTRFLAG	Check if blank line needs to be printed
    		BEQ			NEXTMTR
    		
    		LEA			BLANK,A1	Load blank line to print
			MOVE.B		#14,D0		Moves the number 14 into data register D0
    		TRAP   	 	#15			Displays blank line

    		BRA			RETURN		Done outputting
    		
* Check the register to see if its A7, if so then output the register as SP to correspond to the USP
* Before converting, the EAMODE must be a valid mode, the following test will determine if the address
* register is a candidate to be converted to SP
NOFETCH1	CMP.B		#2,EAMODE		Check for (An) EA mode
			BNE			TESTNEXTEA	
			
* A is a valid candidate, now check the register number to see if its 7
			CMP.B		#7,D7			Check if register is SP
			BNE			NOTUSP

* Output the EA field of the instruction
			LEA			MOVEMSP1,A1		Load EA field to display
			MOVE.B		#14,D0			Moves the number 14 into data register D0
    		TRAP   	 	#15				Displays (SP)
    		
    		CMP.B		#1,DR			Check if the dr mode is memory to register
			BEQ			NEXTMTR			Done outputting, now return from subroutine
			
			LEA			BLANK,A1		Load blank line to print
			MOVE.B		#14,D0			Moves the number 14 into data register D0
    		TRAP   	 	#15				Displays blank line

    		BRA			RETURN			Done outputting
			
TESTNEXTEA	CMP.B		#1,DR			Check if the dr mode is memory to register
			BEQ			USPMTR			Check for the USP for MTR mode if DR = 1
			CMP.B		#4,EAMODE		Check for -(An) EA mode
			BNE			NOTUSP			IF EA MODE is not 1 or 4
*										THEN no need to convert register to user stack pointer

			* A is a valid candidate, now check the register number to see if its 7
			CMP.B		#7,D7			Check if register is SP (A7)
			BNE			NOTUSP
			
*			Output the EA field of the instruction
			LEA			MOVEMSP2,A1		Load EA field to display
			MOVE.B		#14,D0			Moves the number 14 into data register D0
    		TRAP   	 	#15				Displays -(SP)
    		BRA			RETURN			Done outputting, now return from subroutine	
			
USPMTR		CMP.B		#3,EAMODE		Check for (An)+ EA mode
			BNE			NOTUSP			IF EA MODE is not 1 or 3
*										THEN no need to convert register to user stack pointer

			* A is a valid candidate, now check the register number to see if its 7
			CMP.B		#7,D7			Check if register is SP (A7)
			BNE			NOTUSP
			
*			Output the EA field of the instruction
			LEA			MOVEMSP3,A1		Load EA field to display
			MOVE.B		#14,D0			Moves the number 14 into data register D0
    		TRAP   	 	#15				Displays (SP)+
    		
    		BRA			NEXTMTR			Done outputting, now return from subroutine	

NOTUSP		MOVEA.L		A3,A1		Load the left modifier of the EA to display
			MOVE.B		#14,D0		Moves the number 14 into data register D0
    		TRAP   	 	#15			Displays left modifier if it exists
    		
    		CLR.L		D1
    		CLR.L		D2
    		MOVE.B		#15,D0		TRAP task 15 displays an unsigned number in D1.L in decimal notation
			MOVE.B		D7,D1		Move register number to D1 to display it
			MOVE.L		#10,D2		D2 contains the base of the digit to print
			TRAP   	 	#15			Displays number in D1	
    		
			LEA			(A4),A1		Load right modifier to display
			MOVE.B		#14,D0		Moves the number 14 into data register D0
    		TRAP   	 	#15			Displays right modifier of EA if it exists
    		
    		CMP.B		#1,DR		Check if dr mode = 1
    		BEQ			NEXTMTR
    		
			LEA			BLANK,A1	Load blank line to print
			MOVE.B		#14,D0		Moves the number 14 into data register D0
    		TRAP   	 	#15			Displays blank line
	
RETURN		MOVEM.L		(SP)+,D0-D2/A1	Return program state when done
			RTS
			
		
**********************************************************************************************************************************
* Op-Code Subroutine: DECODEMEM
* Upon entering the subroutine, A0 contains a pointer to the memory to decode. A word of this memory will be read into D0 and
* and this corresponds to the op-code word of the instruction being disassembled. This subroutine will process the opcode word
* and then call the corresponding EA subroutine to determine the effective addressing type if the instruction has an effective
* addressing type. The CPU will then know if it needs to fetch additional operands in memory. The two parameters will then be
* passed to the corresponding output. Also, D0 must be cleared prior to calling the subroutine. D1 will contain a copy of the
* instruction so a mask could be applied during each test without losing its value. D4 will contain the 3 bits corresponding
* to the register number if the instruction uses a data or address register, its also used to store 3 bits for the opmode.
* D5 will be used to contain the amount of bits to shift. D5 will contain the operand to print after calling EA subroutine
* D6 is used as a flag to determine if the CPU needs to make a fetch after calling the EA subroutine. If a word in memory cannot
* be decoded to a legitamite instruction, an error message will be displayed showing the memory address of the word along with
* the hex value of the word. D0 is also used as a register for instructions
DECODEMEM	MOVEM.L			A1,-(SP)	Save program state
			LEA				(A0),A2		Load the address of the instruction into A2 to know where to print
			MOVE.W			(A0)+,D0	Move the op-code word into D0 to process
*										following the instruction after executing this code
			
			MOVE.B			#1,EAVALID		Make sure EAVALID flag is set before instruction read.
			
			MOVE.L			D0,D1
			MOVE.L			D0,D4
			ANDI.W			#OPBYTE,D1
			
			EORI.W			#$F000,D1         Check for ADD instruction
			CMP.W			#0,D1			IF the bits are the same as the op-code for ADD, then D1 contains 0
			BEQ				ERROR		ELSE scan op-code for next instruction
			
			
			
* The following code corresponds to a switch statement to scan the op-code and process the instruction at (A2) if its supported

* Test for supported no operand instructions

* Test for NOP instruction
			CMP.L			#NOP,D0			Scan the op-code of the instruction to check if its NOP
			BNE				NEXT0			IF the op-code word doesn't match, test the next op-code
			BSR				PRINTNOP		Output the instruction to the display, along with its memory location
			BRA				DONE2			Break out of switch statement once instruction is displayed

* Test for RTS instruction			
NEXT0		
			CMP.L			#RTS,D0			Scan the op-code of the instruction to check if its RTS
			BNE				NEXT1			IF the op-code word doesn't match, test the next op-code
			BSR				PRINTRTS		Output the instruction to the display, along with its memory location
			BRA				DONE2			Break out of switch statement once instruction is displayed
			
* TODO Test for supported single operand instructions
			
* TODO Single operand instructions, e.g. BRA, CLR, JSR

* TODO Test for supported two operand instructions
			
* Create a copy of the op-code to use to apply the masks to it to check if the op-code is equivalent to the value being tested


NEXT1
*******************************************************************************************************************************
NEXT_ADD_A
			* Load D1 and D4 with a copy of the instruction in (A2)
			MOVE.L			D0,D1
			MOVE.L			D0,D4
			ANDI.W			#OPBYTE,D1		Apply mask to isolate most significant byte of opcode word


*ADD/ADDA STARTS HERE
			
			* Test for ADD instruction
			EORI.L			#ADD,D1         Check for ADD instruction
			CMP.L			#0,D1			IF the bits are the same as the op-code for ADD, then D1 contains 0
			BNE				NEXT_ADDQ		ELSE scan op-code for next instruction
			
*			Clear out register before using
			CLR.L			D5				D5 will contain the amount of bits to shift, if needed
			
* Scan the effective address bits of the instruction
			MOVE.L			D0,D1			Reset D1; will contain EA field of the instruction
			ANDI.W			#ADDEA,D1		Isolate the 6 bits corresponding to the EA field
			
			* Check the register bits of the instruction to find the register number, and store it in D4
			ANDI.L			#REGNUM,D4		Isolate the register bits
			MOVE.B			#9,D5			Load the shift count into the register for the next instruction
			LSR.L			D5,D4			Shift 9 bits to the right to set rightmost bit at
*											beginning (LSB) to normalize register value to allow it to be interpreted

*			D4 now contains the register number, move it to REGL to use in the output subroutine
			MOVE.B			D4,REGL
			
* Scan the opmode bits of the instruction
			MOVE.L			D0,D4 			Reset D4 to apply mask to it
			ANDI.W			#OPMODE,D4		Isolate the 3 opmode bits
			LSR.L			#6,D4			Move the bits into their correct position so the value is correctly set

* The opmode determines if the instruction is ADD or ADDA, so this needs to be checked


* Check for ADDA first
			CMP.B			#3,D4			Check if the opmode is word for the ADDA instruction
			BEQ				ADDACONT
			CMP.B			#7,D4			Check if opmode is long for the ADDA instruction
			BNE				ADDCHECK		Must be another add
			MOVE.L			#2,D4
			BRA				ADDACONT2
			
*			Store the mode 1 in D4, corresponding to word
ADDACONT	MOVE.L			#1,D4
			CLR.L			D6					Assume no operand fetch is needed by the CPU, unless proven otherwise
			
* Call EA subroutine
ADDACONT2	BSR				GETEA				Interpret the 6 bits corresponding to the effective address in the EA subroutine
			
			CLR.L			D1					Clear register before using
			MOVE.B			EAVALID,D1			Move flag to D1 to check for valid EA mode
			CMP				#0,D1				Check for invalid EA mode
			BEQ				ERROR				If invalid, display error message and do not call print subroutine
			
P_ADDA		MOVEM.L			D0-D1/A1,-(SP)		Save program state
			CLR.L			D0

			BSR				PRINTMEM			Print the memory location stored in A1 corresponding to where the instruction is	
			
			CMP.B			#1,D4				Check if EA mode is word
			BNE				P_ADDA1				If EA mode is not word, check if it is a long
			LEA				ADDAW,A1			Load the instruction to display
			BRA				P_ADDA2
			
P_ADDA1		LEA				ADDAL,A1 			otherwise load long instruction
			
P_ADDA2		MOVE.B			#14,D0				Moves the number 14 into data register D0
    		TRAP   	 		#15					Displays instruction
			
			MOVEM.L			(SP)+,D0-D1/A1	Return program state when done
			
			MOVE.B			#1,DORA			Using address register
			BSR				P_EA_XN			Using register as destination
			BRA				DONE2

*Check the other opmodes for ADD now that its known the instruction is not ADDA	
ADDCHECK	CMP.W			#4,D4			Checking if opcode is greater than 4 for DN right
			BGE				ADDDNL 			Move to left Dn ADD	
			
			CLR.L			D6				Assume no fetch op
			BSR				GETEA
			
			CMP.B			#1,EAMODE		Check if address register EA
			BEQ				ADDRCHK			IF so branch to check if byte error
			JMP				ADDRNEXT

ADDRCHK		CMP.W			#0,D4			Check if byte instruction	
			BEQ 			ERROR			IF address mode is 1, then byte is not allowed

ADDRNEXT
			MOVE.B			EAVALID,D1		Move flat to D1 to check for valid EA mode
			CMP				#0,D1			Check for invalid EA mode
			BEQ				ERROR			If invalid, display error message and do not call print subroutine
			CMP				#1,D6			Check if fetch is needed

P_ADDR		MOVEM.L			D0-D1/A1,-(SP)	Save program state
			CLR.L			D0

			BSR				PRINTMEM		Print the memory location stored in A1 corresponding to where the instruction is	
			
			CMP.B			#0,D4			Check if EA mode is word
			BNE				P_ADDR_N 		If EA mode is not word, it must be long
			LEA				ADDB,A1			Load ADD.B
			JMP				P_ADDR_N3 		Call trap print
			
P_ADDR_N	CMP.B			#1,D4			Check if EA mode is word
			BNE				P_ADDR_N2		If EA mode is not word, it must be long
			LEA				ADDW,A1			Load add.w
			JMP				P_ADDR_N3 		Call trap print
			
P_ADDR_N2 	LEA				ADDL,A1			Load add.l
			
	
P_ADDR_N3	MOVE.B			#14,D0			Moves the number 14 into data register D0
    		TRAP   	 		#15				Displays instruction
    		
    		MOVEM.L			(SP)+,D0-D1/A1	Return program state when done
			
			MOVE.B			#0,DORA			Data register print
			BSR				P_EA_XN
			BRA				DONE2			Break out when done printing						

* Add for data register
ADDDNL		
			SUB.B			#4,D4			Subtract four from D4 for GETEA and print functions to identify size
			CLR.L			D6				Assume no fetch op
			BSR				GETEA
			
			CMP.B			#1,EAMODE		Check if address register EA
			BEQ				ADDLCHK			IF so branch to check if byte error
			JMP				ADDLNEXT

ADDLCHK		CMP.W			#0,D4			Check if byte instruction	
			BEQ 			ERROR			IF address mode is 1, then byte is not allowed

ADDLNEXT
			MOVE.B			EAVALID,D1		Move flat to D1 to check for valid EA mode
			CMP				#0,D1			Check for invalid EA mode
			BEQ				ERROR			If invalid, display error message and do not call print subroutine
			CMP				#1,D6			Check if fetch is needed

P_ADDL		MOVEM.L			D0-D1/A1,-(SP)	Save program state
			CLR.L			D0

			BSR				PRINTMEM		Print the memory location stored in A1 corresponding to where the instruction is	
			
			CMP.B			#0,D4			Check if EA mode is word
			BNE				P_ADDL_N 		If EA mode is not word, it must be long
			LEA				ADDB,A1			Load ADD.B
			JMP				P_ADDL_N3 		Call trap print
			
P_ADDL_N	CMP.B			#1,D4			Check if EA mode is word
			BNE				P_ADDL_N2		If EA mode is not word, it must be long
			LEA				ADDW,A1			Load ADD.W
			JMP				P_ADDL_N3 		Call trap print
			
P_ADDL_N2 	LEA				ADDL,A1			Load ADD.L
			
	
P_ADDL_N3	MOVE.B			#14,D0			Moves the number 14 into data register D0
    		TRAP   	 		#15				Displays instruction
    		
    		MOVEM.L			(SP)+,D0-D1/A1	Return program state when done
			
			MOVE.B			#0,DORA			Data register print
			BSR				P_XN_EA
			BRA				DONE2			Break out when done printing	
			
			
NEXT_ADDQ	MOVE.L			D0,D1			Reset D1

*ADDQ STARTS HERE 
			MOVE.L			D0,D4
			ANDI.W			#OPBYTE,D1		Apply mask to isolate most significant byte of opcode word
			
			* Test for ADDQ instruction
			EORI.L			#ADDQ,D1         Check for ADDQ instruction
			CMP.L			#0,D1			IF the bits are the same as the op-code for ADD, then D1 contains 0
			BNE				NEXT_SUB
			
*			Clear out register before using
			CLR.L			D5				D5 will contain the amount of bits to shift, if needed
			
* Scan the effective address bits of the instruction
			MOVE.L			D0,D1			Reset D1; will contain EA field of the instruction
			ANDI.W			#ADDEA,D1		Isolate the 6 bits corresponding to the EA field

* Check the register bits of the instruction to find the register number, and store it in D4
			ANDI.L			#REGNUM,D4		Isolate the register bits
			MOVE.B			#9,D5			Load the shift count into the register for the next instruction
			LSR.L			D5,D4			Shift 9 bits to the right to set rightmost bit at
*											beginning (LSB) to normalize register value to allow it to be interpreted

			CMP.B			#0,D4			When D4 contains 0, the number to add is 8.
			BNE				ADDQCONT		If else, continue
			MOVE.B			#8,REGL
			JMP				ADDQCONT2
ADDQCONT						
*			D4 now contains the register number, move it to REGL to use in the output subroutine
			MOVE.B			D4,REGL

			
ADDQCONT2
* Scan the opmode bits of the instruction
			MOVE.L			D0,D4 			Reset D4 to apply mask to it
			ANDI.W			#OPMODE,D4		Isolate the 3 opmode bits
			LSR.L			#6,D4			Move the bits into their correct position so the value is correctly s			
			
			CMP.B			#3,D4			Check if there is a leading 0 in the opcode, or size is 3
			BGE				ERROR			If so, it is not an ADDQ
			
			CLR				D6				Clear Register before using
* Call EA subroutine
			BSR				GETEA			Interpret the 6 bits corresponding to the effective address in the EA subroutine
			
			CLR.L			D1				Clear register before using
			MOVE.B			EAVALID,D1		Move flag to D1 to check for valid EA mode
			
			CMP.B			#9,EAMODE		If destination is literal, move to error
			BEQ				NEXT_SUB
			
			CMP.B			#0,D1			Check for invalid EA mode
			BEQ				ERROR			If invalid, display error message and do not call print subroutine
			CMP				#1,D6			Check if fetch is needed
			
P_ADDQ		MOVEM.L			D0-D1/A1,-(SP)	Save program state
			CLR.L			D0

			BSR				PRINTMEM		Print the memory location stored in A1 corresponding to where the instruction is	
			
			CMP.B			#0,D4			Check if EA mode is word
			BNE				P_ADDQ_N 		If EA mode is not word, it must be long
			LEA				ADDQB,A1		Load ADDQ.B
			JMP				P_ADDQ_N3 		Call trap print
			
P_ADDQ_N	CMP.B			#1,D4			Check if EA mode is word
			BNE				P_ADDQ_N2		If EA mode is not word, it must be long
			LEA				ADDQW,A1		Load ADDQ.W
			JMP				P_ADDQ_N3 		Call trap print
			
P_ADDQ_N2 	LEA				ADDQL,A1
			

P_ADDQ_N3	MOVE.B			#14,D0		Moves the number 14 into data register D0
    		TRAP   	 		#15			Displays instruction

			LEA				IMDTM,A1	
			MOVE.B			#14,D0		Moves the number 14 into data register D0
    		TRAP   	 		#15			Displays the letter D
    		
    		MOVE.B			#15,D0		TRAP task 15 displays an unsigned number in D1.L in decimal notation
			CLR.L			D1			Clear D1
			MOVE.B			(REGL),D1	Move register number to D1 to display it
			TRAP   	 		#15			Displays number in D1
			
			LEA				COMMA,A1	Load comma to print
			MOVE.B			#14,D0		Moves the number 14 into data register D0
    		TRAP   	 		#15			Displays comma
			
			LEA				(A3),A1		Load the left modifier to display
			MOVE.B			#14,D0		Moves the number 14 into data register D0
    		TRAP   	 		#15			Displays modifier
    		
    		MOVEA.L			D5,A2		Moves EA of instruction into address register A2 so it could be printed using a subroutine
    		
			CMP.B			#0,EAFETCH  Corresponds to EA with no fetch
			BNE				P_ADDQ2
    		
    		MOVE.B			#15,D0		Moves number 15 to D0
			MOVE.B			D7,D1		Moves EAREG to D1
			TRAP			#15			Displays EAREG

			BRA				P_ADDQ4		Jumps to display right modifier
			

P_ADDQ2    	CMP.B			#2,EAFETCH	Check if memory to print is long
    		BNE				P_ADDQ3		If not, print word
			
			JSR				PRINTMEM	If long, print long
			BRA				P_ADDQ4		Move on to next print

P_ADDQ3   	BSR				PRINTMEMW   Print the word of memory corresponding to the EA type

P_ADDQ4		LEA				(A4),A1		Load the right modifier to display
			MOVE.B			#14,D0		Moves the number 14 into data register D0
    		TRAP   	 		#15			Displays modifier
			
			LEA				BLANK,A1	Load blank line to print
			MOVE.B			#14,D0		Moves the number 14 into data register D0
    		TRAP   	 		#15			Displays blank line

			MOVEM.L			(SP)+,D0-D1/A1
			
           	BRA				DONE2			Break out when done printing


NEXT_SUB
			* Load D1 and D4 with a copy of the instruction in (A2)
			MOVE.L			D0,D1
			MOVE.L			D0,D4
			ANDI.W			#OPBYTE,D1		Apply mask to isolate most significant byte of opcode word


*SUB STARTS HERE
			
			* Test for SUB instruction
			EORI.L			#SUB,D1         Check for SUB instruction
			CMP.L			#0,D1			IF the bits are the same as the op-code for SUB, then D1 contains 0
			BNE				NEXT_AND		ELSE scan op-code for next instruction
			
*			Clear out register before using
			CLR.L			D5				D5 will contain the amount of bits to shift, if needed
			
*		 	Scan the effective address bits of the instruction
			MOVE.L			D0,D1			Reset D1; will contain EA field of the instruction
			ANDI.W			#ADDEA,D1		Isolate the 6 bits corresponding to the EA field
			
* 			Check the register bits of the instruction to find the register number, and store it in D4
			ANDI.L			#REGNUM,D4		Isolate the register bits
			MOVE.B			#9,D5			Load the shift count into the register for the next instruction
			LSR.L			D5,D4			Shift 9 bits to the right to set rightmost bit at
*											beginning (LSB) to normalize register value to allow it to be interpreted

*			D4 now contains the register number, move it to REGL to use in the output subroutine
			MOVE.B			D4,REGL
			
* 			Scan the opmode bits of the instruction
			MOVE.L			D0,D4 			Reset D4 to apply mask to it
			ANDI.W			#OPMODE,D4		Isolate the 3 opmode bits
			LSR.L			#6,D4			Move the bits into their correct position so the value is correctly set

			CLR.L			D6				Assume no operand fetch is needed by the CPU, unless proven otherwise
			
			CMP.W			#7,D4			If opmode is 7, unrecognized
			BEQ				NEXT_AND			
			CMP.W			#3,D4			If opmode is 3, unrecognized
			BEQ				NEXT_AND	
			
			CMP.W			#4,D4			Checking if opcode is greater than 4 for DN right
			BGE				SUBDL 			Move to left Dn Sub
			
			CLR.L			D6				Assume no fetch op
			BSR				GETEA
			
			CMP.B			#1,EAMODE		Check if address register EA
			BEQ				SUBDRCHK			IF so branch to check if byte error
			JMP				SUBDRNEXT

SUBDRCHK	CMP.W			#0,D4			Check if byte instruction	
			BEQ 			ERROR			IF address mode is 1, then byte is not allowed

SUBDRNEXT
			MOVE.B			EAVALID,D1		Move flat to D1 to check for valid EA mode
			CMP				#0,D1			Check for invalid EA mode
			BEQ				ERROR			If invalid, display error message and do not call print subroutine
			CMP				#1,D6			Check if fetch is needed
			
P_SUBR		MOVEM.L			D0-D1/A1,-(SP)	Save program state
			CLR.L			D0

			BSR				PRINTMEM		Print the memory location stored in A1 corresponding to where the instruction is	
			
			CMP.B			#0,D4			Check if EA mode is word
			BNE				P_SUBR_N 		If EA mode is not word, it must be long
			LEA				SUBB,A1			Load ADD.B
			JMP				P_SUBR_N3 		Call trap print
			
P_SUBR_N	CMP.B			#1,D4			Check if EA mode is word
			BNE				P_SUBR_N2		If EA mode is not word, it must be long
			LEA				SUBW,A1
			JMP				P_SUBR_N3 		Call trap print
			
P_SUBR_N2   LEA				SUBL,A1
			

P_SUBR_N3	MOVE.B			#14,D0			Moves the number 14 into data register D0
    		TRAP   	 		#15				Displays instruction
			MOVEM.L			(SP)+,D0-D1/A1	Return program state when done
			
			
			MOVE.B			#0,DORA
			BSR				P_EA_XN
			
			BRA				DONE2
* Add for data register on right
SUBDL		
			SUB.B			#4,D4			Subtract four from D4 for GETEA and print functions to identify size
			CLR.L			D6				Assume no fetch op
			BSR				GETEA
			
			CMP.B			#1,EAMODE		Check if address register EA
			BEQ				SUBDLCHK		IF so branch to check if byte error
			JMP				SUBDLNEXT

SUBDLCHK	CMP.W			#0,D4			Check if byte instruction	
			BEQ 			ERROR			IF address mode is 1, then byte is not allowed

SUBDLNEXT
			MOVE.B			EAVALID,D1		Move flat to D1 to check for valid EA mode
			CMP				#0,D1			Check for invalid EA mode
			BEQ				ERROR			If invalid, display error message and do not call print subroutine
			CMP				#1,D6			Check if fetch is needed
			
			CMP.B			#9,EAMODE		If trying to write to immediate data, branch error
			BEQ				NEXT_AND
			
			CMP.B			#1,EAMODE		If trying to write to immediate data, branch error
			BLE				NEXT_AND
			
P_SUBL		MOVEM.L			D0-D1/A1,-(SP)	Save program state
			CLR.L			D0

			BSR				PRINTMEM		Print the memory location stored in A1 corresponding to where the instruction is	
			
			CMP.B			#0,D4			Check if EA mode is word
			BNE				P_SUBL_N 		If EA mode is not word, it must be long
			LEA				SUBB,A1			Load ADD.B
			JMP				P_SUBL_N3 		Call trap print
			
P_SUBL_N	CMP.B			#1,D4			Check if EA mode is word
			BNE				P_SUBL_N2		If EA mode is not word, it must be long
			LEA				SUBW,A1
			JMP				P_SUBL_N3 		Call trap print
			
P_SUBL_N2   LEA				SUBL,A1
			

P_SUBL_N3	MOVE.B			#14,D0			Moves the number 14 into data register D0
    		TRAP   	 		#15				Displays instruction
			MOVEM.L			(SP)+,D0-D1/A1	Return program state when done
			
			
			MOVE.B			#0,DORA
			BSR				P_XN_EA			
			BRA				DONE2			Break out when done printing	

NEXT_AND	MOVE.L			D0,D1
			MOVE.L			D0,D4
			ANDI.W			#OPBYTE,D1		Apply mask to isolate most significant byte of opcode word


*AND STARTS HERE
			
			* Test for AND instruction
			EORI.L			#AND,D1         Check for AND instruction
			CMP.L			#0,D1			IF the bits are the same as the op-code for AND, then D1 contains 0
			BNE				NEXT_LEA				ELSE scan op-code for next instruction
			
*			Clear out register before using
			CLR.L			D5				D5 will contain the amount of bits to shift, if needed
			
* 			Scan the effective address bits of the instruction
			MOVE.L			D0,D1			Reset D1; will contain EA field of the instruction
			ANDI.W			#ADDEA,D1		Isolate the 6 bits corresponding to the EA field
			
* 			Check the register bits of the instruction to find the register number, and store it in D4
			ANDI.L			#REGNUM,D4		Isolate the register bits
			MOVE.B			#9,D5			Load the shift count into the register for the next instruction
			LSR.L			D5,D4			Shift 9 bits to the right to set rightmost bit at
*											beginning (LSB) to normalize register value to allow it to be interpreted

*			D4 now contains the register number, move it to REGL to use in the output subroutine
			MOVE.B			D4,REGL
			
* 			Scan the opmode bits of the instruction
			MOVE.L			D0,D4 			Reset D4 to apply mask to it
			ANDI.W			#OPMODE,D4		Isolate the 3 opmode bits
			LSR.L			#6,D4			Move the bits into their correct position so the value is correctly set

			CLR.L			D6				Assume no operand fetch is needed by the CPU, unless proven otherwise
			
			CMP.W			#3,D4			If opcode is 3, it is wrong
			BEQ				NEXT_LEA			
			
			CMP.W			#7,D4			If opcode is 7, it is wrong
			BEQ 			NEXT_LEA
			
			CMP.W			#4,D4			Checking if opcode is greater than 4 for DN right
			BGE				ANDDL 			Move to left Dn AND
			
			CLR.L			D6				Assume no fetch op
			BSR				GETEA
			
			CMP.B			#1,EAMODE		Check if address register EA
			BEQ				ANDDRCHK			IF so branch to check if byte error
			JMP				ANDDRNEXT

ANDDRCHK	CMP.W			#0,D4			Check if byte instruction	
			BEQ 			ERROR			IF address mode is 1, then byte is not allowed

ANDDRNEXT
			MOVE.B			EAVALID,D1		Move flat to D1 to check for valid EA mode
			CMP				#0,D1			Check for invalid EA mode
			BEQ				ERROR			If invalid, display error message and do not call print subroutine
			
			
			MOVEM.L			D0-D1/A1,-(SP)	Save program state
			CLR.L			D0

			BSR				PRINTMEM	Print the memory location stored in A1 corresponding to where the instruction is	
			
			CMP.B			#0,D4			Check if EA mode is word
			BNE				P_ANDR_N 	If EA mode is not word, it must be long
			LEA				ANDB,A1		Load AND.B
			JMP				P_ANDR_N3 	Call trap print
				
P_ANDR_N	CMP.B			#1,D4			Check if EA mode is word
			BNE				P_ANDR_N2		If EA mode is not word, it must be long
			LEA				ANDW,A1
			JMP				P_ANDR_N3 	Call trap print
			
P_ANDR_N2 	LEA				ANDL,A1
			

P_ANDR_N3	MOVE.B			#14,D0		Moves the number 14 into data register D0
    		TRAP   	 		#15			Displays instruction
			MOVEM.L			(SP)+,D0-D1/A1
			
			
			MOVE.B			#0,DORA
			BSR				P_EA_XN
								
			BRA				DONE2
* 			AND for data register on right
ANDDL		
			SUB.B			#4,D4			Subtract four from D4 for GETEA and print functions to identify size
			CLR.L			D6				Assume no fetch op
			BSR				GETEA
			
			CMP.B			#1,EAMODE		Check if address register EA
			BEQ				NEXT_LEA		IF so branch to check if byte error

ANDDLNEXT
			MOVE.B			EAVALID,D1		Move flat to D1 to check for valid EA mode
			CMP				#0,D1			Check for invalid EA mode
			BEQ				ERROR			If invalid, display error message and do not call print subroutine
			CMP				#1,D6			Check if fetch is needed
			
			CMP.B			#9,EAMODE		If trying to write to immediate data, branch error
			BEQ				ERROR
			
			MOVEM.L			D0-D1/A1,-(SP)	Save program state
			CLR.L			D0

			BSR				PRINTMEM		Print the memory location stored in A1 corresponding to where the instruction is	
			
			CMP.B			#0,D4			Check if EA mode is word
			BNE				P_ANDL_N 		If EA mode is not word, it must be long
			LEA				ANDB,A1			Load AND.B
			JMP				P_ANDL_N3 		Call trap print
				
P_ANDL_N	CMP.B			#1,D4			Check if EA mode is word
			BNE				P_ANDL_N2		If EA mode is not word, it must be long
			LEA				ANDW,A1
			JMP				P_ANDL_N3 		Call trap print
			
P_ANDL_N2 	LEA				ANDL,A1
			

P_ANDL_N3	MOVE.B			#14,D0			Moves the number 14 into data register D0
    		TRAP   	 		#15				Displays instruction
			MOVEM.L			(SP)+,D0-D1/A1
			
			MOVE.B			#0,DORA
			BSR				P_XN_EA
				
			BRA				DONE2
				
NEXT_LEA	MOVE.L			D0,D1
			MOVE.L			D0,D4
			ANDI.W			#OPBYTE,D1		Apply mask to isolate most significant byte of opcode word


*LEA STARTS HERE
			
* 			Test for LEA instruction
			EORI.L			#LEA,D1         Check for LEA instruction
			CMP.L			#0,D1			IF the bits are the same as the op-code for LEA, then D1 contains 0
			BNE				NEXT_NOT		ELSE scan op-code for next instruction
			
*			Clear out register before using
			CLR.L			D5				D5 will contain the amount of bits to shift, if needed
			
* 			Scan the effective address bits of the instruction
			MOVE.L			D0,D1			Reset D1; will contain EA field of the instruction
			ANDI.W			#ADDEA,D1		Isolate the 6 bits corresponding to the EA field
			
* 			Check the register bits of the instruction to find the register number, and store it in D4
			ANDI.L			#REGNUM,D4		Isolate the register bits
			MOVE.B			#9,D5			Load the shift count into the register for the next instruction
			LSR.L			D5,D4			Shift 9 bits to the right to set rightmost bit at
*											beginning (LSB) to normalize register value to allow it to be interpreted

*			D4 now contains the register number, move it to REGL to use in the output subroutine
			MOVE.B			D4,REGL
			
* 			Scan the opmode bits of the instruction
			MOVE.L			D0,D4 			Reset D4 to apply mask to it
			ANDI.W			#OPMODE,D4		Isolate the 3 opmode bits
			LSR.L			#6,D4			Move the bits into their correct position so the value is correctly set

			CLR.L			D6				Assume no operand fetch is needed by the CPU, unless proven otherwise
		
			CMP.W			#7,D4			Checking if opcode is 7 for LEA
			BNE				NEXT_NOT 		Move to next if not
			
			CLR.L			D6				Assume no fetch op
			BSR				GETEA
			
			CMP.B			#1,EAMODE		Make sure EAMODE is valid for instruction
			BLE				NEXT_NOT
			
			CMP.B			#3,EAMODE
			BEQ				NEXT_NOT
			
			CMP.B			#4,EAMODE
			BEQ				NEXT_NOT
			
			CMP.B			#9,EAMODE
			BEQ				NEXT_NOT
			
			MOVE.B			EAVALID,D1		Move flat to D1 to check for valid EA mode
			CMP				#0,D1			Check for invalid EA mode
			BEQ				ERROR			If invalid, display error message and do not call print subroutine
			CMP				#1,D6			Check if fetch is needed
			
			MOVEM.L			D0-D1/A1,-(SP)	Save program state
			CLR.L			D0

			BSR				PRINTMEM		Print the memory location stored in A1 corresponding to where the instruction is	
			
			LEA				LEAP,A1			Load the instruction to display
			MOVE.B			#14,D0			Moves the number 14 into data register D0
    		TRAP   	 		#15				Displays instruction
			MOVEM.L			(SP)+,D0-D1/A1
			
			MOVE.B			#1,DORA
			BSR				P_EA_XN
				
			BRA				DONE2			Break out when done printing					
	

NEXT_NOT		
			MOVE.L			D0,D1
			MOVE.L			D0,D4
			ANDI.W			#OPMASK,D1		Apply mask to isolate most significant byte of opcode word


*NOT STARTS HERE
			
* 			Test for NOT instruction
			EORI.L			#NOT,D1         Check for NOT instruction
			CMP.L			#0,D1			IF the bits are the same as the op-code for NOT, 
			BNE				NEXT_OR			ELSE scan op-code for next instruction
				
*			Clear out register before using
			CLR.L			D5				D5 will contain the amount of bits to shift, if needed
			
* 			Scan the effective address bits of the instruction
			MOVE.L			D0,D1			Reset D1; will contain EA field of the instruction
			ANDI.W			#ADDEA,D1		Isolate the 6 bits corresponding to the EA field
			
* 			Check the register bits of the instruction to find the register number, and store it in D4
			ANDI.L			#REGNUM,D4		Isolate the register bits
			MOVE.B			#9,D5			Load the shift count into the register for the next instruction
			LSR.L			D5,D4			Shift 9 bits to the right to set rightmost bit at
*											beginning (LSB) to normalize register value to allow it to be interpreted

*			D4 now contains the register number, move it to REGL to use in the output subroutine
			MOVE.B			D4,REGL
			
* 			Scan the opmode bits of the instruction
			MOVE.L			D0,D4 			Reset D4 to apply mask to it
			ANDI.W			#OPMODE,D4		Isolate the 3 opmode bits
			LSR.L			#6,D4			Move the bits into their correct position so the value is correctly set
			
			CMP.W			#3,D4			If size is 3, it is not NOT
			BEQ				NEXT_OR
			
			CLR.L			D6				Assume no fetch op
			BSR				GETEA
			
			MOVE.B			EAVALID,D1		Move flat to D1 to check for valid EA mode
			CMP				#0,D1			Check for invalid EA mode
			BEQ				ERROR			If invalid, display error message and do not call print subroutine
			
			CMP.B			#1,EAMODE		If addressing mode is not valid, branch
			BEQ				NEXT_OR
			
			CMP.B			#9,EAMODE
			BEQ				NEXT_OR		



P_NOT		MOVEM.L			D0-D1/A1,-(SP)	Save program state
			CLR.L			D0

			BSR				PRINTMEM		Print the memory location stored in A1 corresponding to where the instruction is	
				
			CMP.B			#0,D4			Check if EA mode is byte
			BNE				P_NOT_NX 		If EA mode is not byte, it must be word/long
			LEA				NOTB,A1			Load ADD.B
			JMP				P_NOT_NX3 		Call trap print
			
P_NOT_NX	CMP.B			#1,D4			Check if EA mode is word
			BNE				P_NOT_NX2		If EA mode is not word, it must be long
			LEA				NOTW,A1
			JMP				P_NOT_NX3 		Call trap print
			
P_NOT_NX2   LEA				NOTL,A1
P_NOT_NX3	MOVE.B			#14,D0			Moves the number 14 into data register D0
    		TRAP   	 		#15				Displays instruction

			MOVE.B			#0,DORA
			
			LEA				(A3),A1			Load the left modifier to display
			MOVE.B			#14,D0			Moves the number 14 into data register D0
    		TRAP   	 		#15				Displays modifier
    		
    		MOVEA.L			D5,A2			Moves EA of instruction into address register A2 so it could be printed using a subroutine
    		
P_NOT1		CMP.B			#0,EAFETCH  	Corresponds to EA with no fetch
			BNE				P_NOT2
    		
    		MOVE.B			#15,D0			Moves number 15 to D0
			MOVE.B			D7,D1			Moves EAREG to D1
			TRAP			#15				Displays EAREG

			BRA				P_NOT4			Jumps to display right modifier
			

P_NOT2    	CMP.B			#2,EAFETCH		Check if memory to print is long
    		BNE				P_NOT3			If not, print word
			
			JSR				PRINTMEM		If long, print long
			BRA				P_NOT4			Move on to next print

P_NOT3   	BSR				PRINTMEMW   	Print the word of memory corresponding to the EA type

P_NOT4		LEA				(A4),A1			Load the right modifier to display
			MOVE.B			#14,D0			Moves the number 14 into data register D0
    		TRAP   	 		#15				Displays modifier
			
			LEA				BLANK,A1		Load blank line to print
			MOVE.B			#14,D0			Moves the number 14 into
			TRAP   	 		#15				Displays blank line
			
			MOVEM.L			(SP)+,D0-D1/A1			
			
			BRA				DONE2
			
NEXT_OR		
			MOVE.L			D0,D1
			MOVE.L			D0,D4
			ANDI.W			#OPBYTE,D1		Apply mask to isolate most significant byte of opcode word


*OR STARTS HERE
			
* 			Test for OR instruction
			EORI.L			#OR,D1         	Check for OR instruction
			CMP.L			#0,D1			IF the bits are the same as the op-code for OR, 
			BNE				NEXT_MOVEA		ELSE scan op-code for next instruction
			
*			Clear out register before using
			CLR.L			D5				D5 will contain the amount of bits to shift, if needed
			
* 			Scan the effective address bits of the instruction
			MOVE.L			D0,D1			Reset D1; will contain EA field of the instruction
			ANDI.W			#ADDEA,D1		Isolate the 6 bits corresponding to the EA field
			
			* Check the register bits of the instruction to find the register number, and store it in D4
			ANDI.L			#REGNUM,D4		Isolate the register bits
			MOVE.B			#9,D5			Load the shift count into the register for the next instruction
			LSR.L			D5,D4			Shift 9 bits to the right to set rightmost bit at
*											beginning (LSB) to normalize register value to allow it to be interpreted

*			D4 now contains the register number, move it to REGL to use in the output subroutine
			MOVE.B			D4,REGL
			
* 			Scan the opmode bits of the instruction
			MOVE.L			D0,D4 			Reset D4 to apply mask to it
			ANDI.W			#OPMODE,D4		Isolate the 3 opmode bits
			LSR.L			#6,D4			Move the bits into their correct position so the value is correctly set
			
			CMP.W			#3,D4			If opcode is 3, it is wrong
			BEQ				NEXT_MOVEA			
			
			CMP				#7,D4			If instruction has 7 as opmode, it is LEA, meaning program needs to cont
			BEQ				NEXT_MOVEA		Branch to next instruction check
			
			CLR.L			D6				Assume no fetch op
			
			CMP.W			#4,D4			Checking if opcode is greater than 4 for DN right
			BGE				ORDL 			Move to left Dn OR

			BSR				GETEA
			
			CMP.B			#1,EAMODE		Check if address register EA
			BEQ				ORDRCHK			IF so branch to check if byte error
			JMP				ORDRNEXT

ORDRCHK		CMP.W			#0,D4			Check if byte instruction	
			BEQ 			ERROR			IF address mode is 1, then byte is not allowed

ORDRNEXT
			MOVE.B			EAVALID,D1		Move flat to D1 to check for valid EA mode
			CMP				#0,D1			Check for invalid EA mode
			BEQ				ERROR			If invalid, display error message and do not call print subroutine
			
			CMP.B			#1,EAMODE		If EAMODE is An, go to next instruction
			BEQ				NEXT_MOVEA
			
			MOVEM.L			D0-D1/A1,-(SP)	Save program state
			CLR.L			D0

			BSR				PRINTMEM		Print the memory location stored in A1 corresponding to where the instruction is	
			
			CMP.B			#0,D4			Check if EA mode is word
			BNE				P_ORR_N 		If EA mode is not word, it must be long
			LEA				ORB,A1			Load ADD.B
			JMP				P_ORR_N3 		Call trap print
			
P_ORR_N		CMP.B			#1,D4			Check if EA mode is word
			BNE				P_ORR_N2		If EA mode is not word, it must be long
			LEA				ORW,A1
			JMP				P_ORR_N3 		Call trap print
			
P_ORR_N2 	LEA				ORL,A1

P_ORR_N3	MOVE.B			#14,D0			Moves the number 14 into data register D0
    		TRAP   	 		#15				Displays instruction

			MOVEM.L			(SP)+,D0-D1/A1	Return program state when done

			MOVE.B			#0,DORA
			BSR				P_EA_XN
			
			BRA				DONE2

ORDL		
			SUB.B			#4,D4			Subtract four from D4 for GETEA and print functions to identify size
			CLR.L			D6				Assume no fetch op
			BSR				GETEA
			
			CMP.B			#1,EAMODE		Check if address register EA
			BEQ				ORDLCHK			IF so branch to check if byte error
			JMP				ORDLNEXT

ORDLCHK		CMP.W			#0,D4			Check if byte instruction	
			BEQ 			ERROR			IF address mode is 1, then byte is not allowed

ORDLNEXT
			MOVE.B			EAVALID,D1		Move flat to D1 to check for valid EA mode
			CMP				#0,D1			Check for invalid EA mode
			BEQ				ERROR			If invalid, display error message and do not call print subroutine

			CMP.B			#1,EAMODE		If EAMODE is An or Dn, go to next instruction
			BLE				NEXT_MOVEA

			MOVEM.L			D0-D1/A1,-(SP)	Save program state
			CLR.L			D0

			BSR				PRINTMEM		Print the memory location stored in A1 corresponding to where the instruction is	
			
			CMP.B			#0,D4			Check if EA mode is word
			BNE				P_ORL_N 		If EA mode is not word, it must be long
			LEA				ORB,A1			Load ADD.B
			JMP				P_ORL_N3 		Call trap print
			
P_ORL_N		CMP.B			#1,D4			Check if EA mode is word
			BNE				P_ORL_N2		If EA mode is not word, it must be long
			LEA				ORW,A1
			JMP				P_ORL_N3 		Call trap print
			
P_ORL_N2 	LEA				ORL,A1

P_ORL_N3	MOVE.B			#14,D0			Moves the number 14 into data register D0
    		TRAP   	 		#15				Displays instruction

			MOVEM.L			(SP)+,D0-D1/A1	Return program state when done

			MOVE.B			#0,DORA
			BSR				P_XN_EA			

			BRA				DONE2			Break out when done printing	

NEXT_MOVEA
			MOVE.L			D0,D1
			MOVE.L			D0,D4
			ANDI.W			#OPBYTE,D1		Apply mask to isolate most significant byte of opcode word


*MOVEA STARTS HERE
			
			* Test for MOVEA instruction
			CMP.L			#0,D1
			BEQ				NEXT_MOVEQ			If size is 0, it is nto a MOVEA
			
			CMP.L			#MOVEA,D1			IF the bits are the same as the op-code for MOVEA, then D1 contains 0
			BGT	     		NEXT_MOVEQ			ELSE scan op-code for next instruction
			
*			Clear out register before using
			CLR.L			D5				D5 will contain the amount of bits to shift, if needed
			
* Scan the effective address bits of the instruction
			MOVE.L			D0,D1			Reset D1; will contain EA field of the instruction
			ANDI.W			#ADDEA,D1		Isolate the 6 bits corresponding to the EA field
			
			* Check the register bits of the instruction to find the register number, and store it in D4
			ANDI.L			#REGNUM,D4		Isolate the register bits
			MOVE.B			#9,D5			Load the shift count into the register for the next instruction
			LSR.L			D5,D4			Shift 9 bits to the right to set rightmost bit at
*											beginning (LSB) to normalize register value to allow it to be interpreted

*			D4 now contains the register number, move it to REGL to use in the output subroutine
			MOVE.B			D4,REGL
			
* 			Scan the opmode bits of the instruction
			MOVE.L			D0,D4 			Reset D4 to apply mask to it
			ANDI.W			#OPMODE,D4		Isolate the 3 opmode bits
			LSR.L			#6,D4			Move the bits into their correct position so the value is correctly set

			CLR.L			D6				Assume no operand fetch is needed by the CPU, unless proven otherwise
			
			CMP.W			#1,D4			Checking if opmode is 1 for MOVEA
			BNE				NEXT_MOVE		Move to next if not
			
			
			
			MOVE.L			D0,D4			MOVE instruction back into D4
			ANDI.W			#OPBYTE,D4		Isolate instruction byte to retrieve size
			ROR.L			#8,D4
			ROR.L			#4,D4
			
			CMP.L			#3,D4    		If the size is 3, it is a word
			BEQ				MOVEA_NX		
			MOVE.B			#2,D4			Move the long size 3 to D4 to signal for print .L
			JMP				MOVEA_NX2		

MOVEA_NX	MOVE.B			#1,D4			Move the word size 2 to D4 to signal for print.W
			

MOVEA_NX2	CLR.L			D6				Assume no fetch op
			BSR				GETEA
			
			MOVE.B			EAVALID,D1		Move flat to D1 to check for valid EA mode
			CMP				#0,D1			Check for invalid EA mode
			BEQ				ERROR			If invalid, display error message and do not call print subroutine
			
			MOVEM.L			D0-D1/A1,-(SP)	Save program state
			CLR.L			D0

			BSR				PRINTMEM		Print the memory location stored in A1 corresponding to where the instruction is	
			
			CMP.B			#1,D4			Check if EA mode is word
			BNE				P_MOVEA			If EA mode is not word, it must be long
			
			LEA				MOVEAW,A1		Load the instruction to display
			BRA				P_MOVEA2
			
P_MOVEA		LEA				MOVEAL,A1
			
P_MOVEA2	MOVE.B			#14,D0			Moves the number 14 into data register D0
    		TRAP   	 		#15				Displays instruction
			MOVEM.L			(SP)+,D0-D1/A1	Return program state when done
			
			MOVE.B			#1,DORA
			BSR				P_EA_XN
			
			BRA				DONE2			Break out when done printing	

NEXT_MOVE	
			MOVE.L			D0,D4 			Reset D4 to apply mask to it
			ANDI.W			#OPMODE,D4		Isolate the 3 opmode bits
			LSR.L			#6,D4			Move the bits into their correct position so the value is correctly set

			CLR.L			D6				Assume no operand fetch is needed by the CPU, unless proven otherwise
			
*			These next checks make sure the opcode is valid before we start printing
			CMP.W			#5,D4
			BEQ				NEXT_MOVEQ
			CMP.W			#6,D4
			BEQ				NEXT_MOVEQ
			
			CMP.W			#7,D4			
			BNE				MOVECONT
			CMP.B			#2,REGL
			BEQ				NEXT_MOVEQ
			CMP.B			#3,REGL
			BEQ				NEXT_MOVEQ
			


MOVECONT	CLR.L			D6				Assume no fetch op
			BSR				GETEA
			
			MOVE.B			EAVALID,D1		Move flat to D1 to check for valid EA mode
			CMP				#0,D1			Check for invalid EA mode
			BEQ				ERROR			If invalid, display error message and do not call print subroutine
			
			MOVE.L			D0,D4			MOVE instruction back into D4
			ANDI.W			#OPBYTE,D4		Isolate instruction byte to retrieve size
			ROR.L			#8,D4
			ROR.L			#4,D4
			
			
			MOVEM.L			D0-D1/A1,-(SP)	Save program state
			CLR.L			D0

			BSR				PRINTMEM		Print the memory location stored in A1 corresponding to where the instruction is	
			
			
			CMP.B			#1,D4			Check if EA mode is byte
			BNE				P_MOVECMP		If EA mode is not byte, it must be word or long
			
			LEA				MOVEB,A1		Load the instruction to display
			BRA				P_MOVE2
			
P_MOVECMP	CMP.B			#3,D4
			BNE				P_MOVE
			
			LEA				MOVEW,A1
			BRA				P_MOVE2
			
			
P_MOVE		LEA				MOVEL,A1
			
P_MOVE2		MOVE.B			#14,D0			Moves the number 14 into data register D0
    		TRAP   	 		#15				Displays instruction

			LEA				(A3),A1		Load the left modifier to display
			MOVE.B			#14,D0		Moves the number 14 into data register D0
    		TRAP   	 		#15			Displays modifier
    		
    		MOVEA.L			D5,A2		Moves EA of instruction into address register A2 so it could be printed using a subroutine
    		
			CMP.B			#0,EAFETCH  Corresponds to EA with no fetch
			BNE				P_MOVE3
    		
    		MOVE.B			#15,D0		Moves number 15 to D0
			MOVE.B			D7,D1		Moves EAREG to D1
			TRAP			#15			Displays EAREG

			BRA				P_MOVE5		Jumps to display right modifier
			

P_MOVE3    	CMP.B			#2,EAFETCH	Check if memory to print is long
    		BNE				P_MOVE4		If not, print word
			
			JSR				PRINTMEM	If long, print long
			BRA				P_MOVE5		Move on to next print

P_MOVE4   	BSR				PRINTMEMW   Print the word of memory corresponding to the EA type

P_MOVE5		LEA				(A4),A1		Load the right modifier to display
			MOVE.B			#14,D0		Moves the number 14 into data register D0
    		TRAP   	 		#15			Displays modifier
	
			LEA				COMMA,A1	Load comma to print
			MOVE.B			#14,D0		Moves the number 14 into data register D0
    		TRAP   	 		#15			Displays comma


			MOVEM.L			(SP)+,D0-D1/A1	Return program state when done
			
			MOVE.L			D0,D4 			Reset D4 to apply mask to it
			ANDI.W			#OPMODE,D4		Isolate the 3 opmode bits
			LSL.W			#2,D4			Move the bits into their left side so rotate works later
			
			MOVE.B			REGL,D4			
			LSL.B			#5,D4
			
			LSR.W			#5,D4
			
			MOVE.L			D4,D1
			
			CLR.L			D6				Assume no fetch op
			BSR				GETEA

			MOVEM.L			D0-D2/A1,-(SP)	Save program state
			CLR.L			D0
			CLR.L			D2

			LEA				(A3),A1			Load the left modifier to display
			MOVE.B			#14,D0			Moves the number 14 into data register D0
    		TRAP   	 		#15				Displays modifier
    		
    		MOVEA.L			D5,A2			Moves EA of instruction into address register A2 so it could be printed using a subroutine
    		
			CMP.B			#0,EAFETCH  	Corresponds to EA with no fetch
			BNE				P_MOVE_3
    		
    		MOVE.L			#3,D0			Moves number 15 to D0
			MOVE.B			D7,D1			Moves EAREG to D1
			TRAP			#15				Displays EAREG

			BRA				P_MOVE_5		Jumps to display right modifier

P_MOVE_3    CMP.B			#2,EAFETCH		Check if memory to print is long
    		BNE				P_MOVE_4		If not, print word
			
			JSR				PRINTMEM		If long, print long
			BRA				P_MOVE_5		Move on to next print

P_MOVE_4   	BSR				PRINTMEMW   	Print the word of memory corresponding to the EA type

P_MOVE_5	LEA				(A4),A1			Load the right modifier to display
			MOVE.B			#14,D0			Moves the number 14 into data register D0
    		TRAP   	 		#15				Displays modifier

			LEA				BLANK,A1		Load blank line to print
			MOVE.B			#14,D0			Moves the number 14 into data register D0
    		TRAP   	 		#15				Displays blank line
		
			MOVEM.L			(SP)+,D0-D2/A1	Return program state when done

			BRA				DONE2			Break out when done printing	
			
			



NEXT_MOVEQ
			MOVE.L			D0,D1
			MOVE.L			D0,D4
			ANDI.W			#OPBYTE,D1		Apply mask to isolate most significant byte of opcode word


*MOVEQ STARTS HERE
			
			* Test for MOVEQ instruction
			
			CMP.L			#MOVEQ,D1			IF the bits are the same as the op-code for MOVEQ
			BNE	     		NEXT_JSR			ELSE scan op-code for next instruction
			
*			Clear out register before using
			CLR.L			D5				D5 will contain the amount of bits to shift, if needed
			
* Scan the effective address bits of the instruction
			MOVE.L			D0,D1			Reset D1; will contain EA field of the instruction
			ANDI.W			#ADDEA,D1		Isolate the 6 bits corresponding to the EA field
			
			* Check the register bits of the instruction to find the register number, and store it in D4
			ANDI.L			#REGNUM,D4		Isolate the register bits
			MOVE.B			#9,D5			Load the shift count into the register for the next instruction
			LSR.L			D5,D4			Shift 9 bits to the right to set rightmost bit at
*											beginning (LSB) to normalize register value to allow it to be interpreted

*			D4 now contains the register number, move it to REGL to use in the output subroutine
			MOVE.B			D4,REGL
			
* Scan the opmode bits of the instruction
			MOVE.L			D0,D4 			Reset D4 to apply mask to it
			ANDI.W			#OPMODE,D4		Isolate the 3 opmode bits
			LSR.L			#6,D4			Move the bits into their correct position so the value is correctly set

			CMP.B			#4,D4			If 8th bit is not 0, not a MOVEQ
			BGE				NEXT_JSR		
			
			CLR.L			D6
			
			MOVE.B			D0,D6			*contain data to print in d6
			
			MOVEM.L			D0-D1/A1,-(SP)	Save program state
			CLR.L			D0

			BSR				PRINTMEM		Print the memory location stored in A1 corresponding to where the instruction is	
			
			
			LEA				MOVEQL,A1		Load the instruction to display
			MOVE.B			#14,D0			Moves the number 14 into data register D0
    		TRAP   	 		#15				Displays instruction
			MOVEM.L			(SP)+,D0-D1/A1	Return program state when done
			
			LEA				IMDTM,A3		Load modifier in output buffer (A3) to use when outputting operand to display
			LEA				NULL,A4			The right side of the operand is not used, so set A4 to null (0)
			
			LEA				(A3),A1			Load the left modifier to display
			MOVE.B			#14,D0			Moves the number 14 into data register D0
    		TRAP   	 		#15				Displays modifier
			
			MOVEA.L			D6,A2
			BSR				PRINTMEMB
			
			LEA				(A4),A1			Load the left modifier to display
			MOVE.B			#14,D0			Moves the number 14 into data register D0
    		TRAP   	 		#15				Displays modifier
    			
    		LEA				COMMA,A1		Load comma to print
			MOVE.B			#14,D0			Moves the number 14 into data register D0
    		TRAP   	 		#15				Displays comma
    		
    		LEA				DREG,A1	
			MOVE.B			#14,D0			Moves the number 14 into data register D0
    		TRAP   	 		#15				Displays the letter D
    		
    		MOVE.B			#15,D0			TRAP task 15 displays an unsigned number in D1.L in decimal notation
			CLR.L			D1				Clear D1
			MOVE.B			(REGL),D1		Move register number to D1 to display it
			TRAP   	 		#15				Displays number in D1

    		LEA				BLANK,A1		Load blank line to print
			MOVE.B			#14,D0			Moves the number 14 into data register D0
    		TRAP   	 		#15				Displays blank line
			
			BRA				DONE2			Break out when done printing			

NEXT_JSR	MOVE.L			D0,D1
			ANDI.W			#JSR_MASK,D1	Apply mask to isolate most significant byte of opcode word
			EORI.W			#JSR_CHECK,D1      Check for JSR instruction
			*CMP.W			#JSR_CHECK,D1	IF the bits are the same as the op-code, then D1 contains 0
			CMP.W			#0,D1
			BNE				NEXTBRA			ELSE scan op-code for next instruction			
* 			Scan the effective address bits of the instruction and pass it to GETEA
			MOVE.L			D0,D1			Reset D1; will contain EA field of the instruction
			ANDI.W			#ADDEA,D1		Isolate the 6 bits corresponding to the EA field
			BSR				GETEA

			MOVE.B			EAVALID,D1		Move flat to D1 to check for valid EA mode
			CMP				#0,D1			Check for invalid EA mode
			BEQ				ERROR			If invalid, display error message and do not call print subroutine

								
* 			Call print subroutine
			BSR				P_JSR			Call the corresponding print function
			BRA				DONE2			Break out when done printing

NEXTBRA		MOVE.L			D0,D1
			ANDI.W			#BRA_MASK,D1	Apply mask to isolate most significant byte of opcode word
			EORI.W			#BRA_CHECK,D1      Check for BRA instruction
			*CMP.W			#BRA_CHECK,D1	IF the bits are the same as the op-code, then D1 contains 0
			CMP.W			#0,D1
			BNE				NEXTBGT			ELSE scan op-code for next instruction			
* 			Call print subroutine
			MOVE.L			D0,D7			Save the opcode word for further masking
			BSR				P_BRA			Call the corresponding print function
			BRA				DONE2			Break out when done printing
			
NEXTBGT		MOVE.L			D0,D1
			ANDI.W			#BRA_MASK,D1	Apply mask to isolate most significant byte of opcode word
			EORI.W			#BGT_CHECK,D1      Check for BCC instruction
			*CMP.W			#BGT_CHECK,D1	IF the bits are the same as the op-code, then D1 contains 0
			CMP.W			#0,D1
			BNE				NEXTBLE			ELSE scan op-code for next instruction		
* 			Call print subroutine
			MOVE.L			D0,D7			Save the opcode word for further masking
			BSR				P_BGT			Call the corresponding print function
			BRA				DONE2			Break out when done printing
			
NEXTBLE		MOVE.L			D0,D1
			ANDI.W			#BRA_MASK,D1	Apply mask to isolate most significant byte of opcode word
			EORI.W			#BLE_CHECK,D1      Check for BCC instruction
			*CMP.W			#BLE_CHECK,D1	IF the bits are the same as the op-code, then D1 contains 0
			CMP.W			#0,D1
			BNE				NEXTBEQ			ELSE scan op-code for next instruction	
* 			Call print subroutine
			MOVE.L			D0,D7			Save the opcode word for further masking
			BSR				P_BLE			Call the corresponding print function
			BRA				DONE2			Break out when done printing
			
NEXTBEQ		MOVE.L			D0,D1
			ANDI.W			#BRA_MASK,D1	Apply mask to isolate most significant byte of opcode word
			EORI.W			#BEQ_CHECK,D1      Check for BCC instruction
			*CMP.W			#BEQ_CHECK,D1	IF the bits are the same as the op-code, then D1 contains 0
			CMP.W			#0,D1
			BNE				NEXT_LSL		ELSE scan op-code for next instruction		
* 			Call print subroutine
			MOVE.L			D0,D7			Save the opcode word for further masking
			BSR				P_BEQ			Call the corresponding print function
			BRA				DONE2			Break out when done printing

NEXT_LSL

			MOVE.L			D0,D7			Makes a copy of the machine code to be put into D6 and D7
			MOVE.L			D0,D6
			
			ANDI.W			#$FEC0,D7		Masks for memory shift
			CMP.W			#$E2C0,D7		Checks for memory shift for LSL/LSR
			BNE				NEXT_5			If not, go to next opcode
			
			BRA				P_LS_MEM		Branch to memory shift for LSL/LSR		
			BRA				DONE2			Breaks out when done printing

; Checks for LSL			
NEXT_3		MOVE.L			D0,D7			Makes a copy of the machine code to be put into D6 and D7
			MOVE.L			D0,D6
			
			ANDI.W			#$F118,D7		Masks for register shift LSL
			CMP.W			#$E108,D7		If equal then it's LSL
			BNE				NEXT_4			If not, go to next opcode
			
			BRA				P_LSL			Branch to print LSL			
			BRA				DONE2			Breaks out when done printing

; Checks for LSR
NEXT_4		MOVE.L			D0,D7			Makes a copy of the machine code to be put into D6 and D7
			MOVE.L			D0,D6		
	
			ANDI.W			#$F118,D7		Masks for register shift LSR
			CMP.W			#$E008,D7		If equal then it's LSR
			BNE				NEXT_6			If not, go to next opcode
		
			BRA				P_LSR			Branch to print LSR
			BRA				DONE2			Breaks out when done printing

; Checks for memory shift of ASR/ASL			
NEXT_5		MOVE.L			D0,D7			Makes a copy of the machine code to be put into D6 and D7	
			MOVE.L			D0,D6
			
			ANDI.W			#$FEC0,D7		Masks for the memory shift
			CMP.W			#$E0C0,D7		Checks for memory shift of ASR/ASL
			BNE				NEXT_8			If not, go to next opcode
		
			BRA				P_AS_MEM		Branch to memory shift for ASR/ASL
			BRA				DONE2			Breaks out when done printing

; Checks for ASL
NEXT_6		MOVE.L			D0,D7			Makes a copy of the machine code to be put into D6 and D7		
			MOVE.L			D0,D6
			
			ANDI.W			#$F118,D7		Masks for ASL
			CMP.W			#$E100,D7		If equal, then it's ASL
			BNE				NEXT_7			If not, go to next opcode
		
			BRA				P_ASL			Branch to print ASL
			BRA				DONE2			Breaks out when done printing
			
			
; Checks for ASR
NEXT_7		MOVE.L			D0,D7			Makes a copy of the machine code to be put into D6 and D7	
			MOVE.L			D0,D6
			
			ANDI.W			#$F118,D7		Masks for ASR
			CMP.W			#$E000,D7		If equal then it's ASR - 2 param
			BNE				NEXT_9			If not, go to next opcode
		
			BRA				P_ASR			Branch to print ASR
			BRA				DONE2			Breaks out when done printing	

; Checks for memory shift of ROR/ROL			
NEXT_8		MOVE.L			D0,D7			Makes a copy of the machine code to be put into D6 and D7
			MOVE.L			D0,D6
			
			ANDI.W			#$FEC0,D7		Masks for memory shift for ROR/ROL
			CMP.W			#$E6C0,D7		Checks for memory shift ROR/ROL
			BNE				NEXT_3			If not, go to next opcode
		
			BRA				P_RO_MEM		Branch to print memory shift for ROR/ROL
			BRA 			DONE2			Breaks out when done printing

; Checks for ROL			
NEXT_9		MOVE.L			D0,D7			Makes a copy of the machine code to be put into D6 and D7
			MOVE.L			D0,D6
			
			ANDI.W			#$F118,D7		Masks for ROL
			CMP.W			#$E118,D7		If equal then it's ROL - 2 param
			BNE				NEXT_10			If not, go to next opcode
		
			BRA				P_ROL			Branch to print ROL
			BRA				DONE2			Breaks out when done printing

; Checks for ROR
NEXT_10		MOVE.L			D0,D7			Makes a copy of the machine code to be put into D6 and D7
			MOVE.L			D0,D6
			
			ANDI.W			#$F118,D7		Masks for ROR
			CMP.W			#$E018,D7		If equal then it's ROR - 2 param
			BNE				NEXT_MOVEM		If not, were done checking
		
			BRA				P_ROR			Branch to print ROR
			BRA				DONE2			Breaks out when done printing




NEXT_MOVEM				* Load D1 and D4 with a copy of the instruction in (A2)
			MOVE.L			D0,D1
			MOVE.L			D0,D4
			ANDI.L			#MOVEM,D1		Apply mask to test for MOVEM
			EORI			#MOVEM,D1		Check for MOVEM
			CMP.L			#0,D1			IF the bits are the same as the op-code for ADD, then D1 contains 0
			BNE				ERROR 			Test next instruction if not MOVEM
			
			BTST.L			#10,D0			Check if the dn mode in bit #10 is set to 1 or 0
			BNE				NONZ2			dn bit is not 0 if zero flag is cleared
			CLR.B			DR				Set DR variable to 0 if the dr bit in the instruction equals 0
			BRA				NEXT4			Skip over non-zero part
NONZ2		MOVE.B			#1,DR			Set DR variable to 1 if the dr bit in the instruction equals 1
NEXT4		BTST.L			#6,D0			Check the size bit to see if its 1 or 0
			BNE				NONZ3
			MOVE.B			#1,SIZE			Set SIZE variable to 1 if the SIZE bit in the instruction equals 0
*											Corresponding to a word operation
			BRA				NEXT5			Skip non-zero part
			
NONZ3		MOVE.B			#2,SIZE			Set size to 2 corresponding to a long operation
NEXT5		ANDI			#MOVEMEA,D4		Isolate the 6 EA bits
			MOVE.L			D4,D1			Store the 6 EA bits in D1 before calling GETEA

			MOVE.L			#SIZE,D4		Store size in D4 for the EA subroutine to use
			MOVE.W			(A0)+,REGMASK		Read the register list mask into REGMASK		
			
* Call EA subroutine
			BSR				GETEA			Interpret the 6 bits corresponding to the effective address in the EA subroutine
			
			CLR.L			D1				Clear register before using
			MOVE.B			EAVALID,D1		Move flag to D1 to check for valid EA mode
			CMP.L			#0,D1			Check for invalid EA mode
			BEQ				ERROR			If invalid, display error message and do not call print subroutine
			
* Output MOVEM
			BSR				P_MOVEM
			BRA 			DONE2	
			


	
			
			
* Exception: Instruction at memory location in A2 cannot be decoded, display error message
ERROR		BSR			PRINTMEM			Print the memory address of the word which cannot be decoded
*											the address is contained in A2
			LEA			IOERROR8,A1			Load invalid op-code message
			
			MOVE.B		#14,D0				Moves the number 14 into data register D0
    		TRAP   	 	#15					Displays <TAB>DATA  <TAB>
    		
* Clear registers before using
    		CLR.L			D5					
    		CLR.L			D1
    		
    		MOVE.W			(A2),D1				(A2) contains the hex value of the word
    		MOVEA.L			D1,A2				Set A2 to contain the hex value of the word to print in the subroutine PRINTMEMW
    		BSR				PRINTMEMW			Print the hex value of the word
    		
    		
    		CLR.L			D1				Clear register before using
			MOVE.B			EAVALID,D1		Move flag to D1 to check for valid EA mode
			CMP.L			#0,D1			Check for invalid EA mode
			BNE				DONE_BLANK
			
			LEA				IOERROR12,A1		ELSE starting address is invalid, display
			MOVE.B			#14,D0			
    		TRAP   	 		#15			

DONE_BLANK	LEA				BLANK,A1			Load blank line to print
			MOVE.B			#14,D0				Moves the number 14 into data register D0
    		TRAP   	 		#15					Advances output to beginning of next line
	
DONE2		MOVEM.L			(SP)+,A1			Restore state of program	
			RTS


**********************************************************************************************************************************
* EA Subroutine: GETEA
* This function determines which effective addressing mode the parameter contained in (A0) is. This will be determined by reading
* the 6 effective address bits from the opcode word. Upon entering the subroutine, A0 contains a pointer to the next word
* following the opcode word in the instruction. If the effective addressing mode is not one of the supported types, an error
* message will be displayed. Upon exiting the subroutine, D2 will contain a 1 if effective addressing mode is valid and a 0 if it
* was invalid. This will be used to determine if the instruction is output in the calling subroutine. D1 will contain the 6 bits
* corresponding to the EA field upon entering this function. D3 will contain a copy of the 6 bits passed to the subroutine cor-
* responding to the subroutine so it could be manipulated by using a mask, without losing the data. A3 and A4 contain modifiers
* for the left operand, corresponding to the left and right sides of the operand, respectively.
* For example: it will add the # prior to the EA field if the mode is immediate when displaying. The same is true for A5 and A6
* for the right operand. If no modifier is needed on the corresponding side, the address register is set to null (0)
* In addition,(A0) contains the EA operand to fetch (if needed), EAFETCH and D6 contains a flag determining if the operand needs to be fethed,
* and D4 contains value corresponding to the opmode: 0 for byte, 1 for word, and 2 for long upon exiting the subroutine.
* Upon exiting the subroutine, D5 contains the operand fetched from memory. If the EA mode is invalid, an error message will be
* displayed and a flag will be set for the DECODEMEM
* subroutine to know does not need to print the instruction since it was invalid
* D7 will contain the register or flag the EA as long or word.

GETEA		MOVE.L			#1,D2			Set input validation flag, assume it was successful unless proven otherwise
			MOVE.L			D1,D3			Create a copy of the 6 bits corresponding to the EA field of the op-code word
			MOVE.B			#1,EAVALID		EA mode is valid, so set flag to 1
			CLR.L			D5
			CLR.L			D7
			CLR.B			EAFETCH			Default to no fetch
			
			LSR.B			#3,D3			Shift D3 to isolate EA mode
			MOVE.B			D3,EAMODE		Store EAMODE
			
			MOVE.L			D1,D3			Reset D3 to use again

			
* Scan the bits to see if they match one of the supported EA types
			EORI.B			#IMDT,D3		Check if the addressing mode is immediate
			CMP.W			#0,D3			IF the addressing mode is immediate, process accordingly
			BNE				NEXTEA			ELSE Check for next EA mode
			
* Fetch operand from memory in location pointed at by A0

* Check if operand is a word, or longword by looking at the value in D4
			CMP.W			#1,D4			IF D4 = 1, the size is word
			BGT				LONG			Size if long if other tests fail (D4 = 2)
			MOVE.W			(A0)+,D5		Fetch word operand from memory
			MOVE.B			#1,EAFETCH		Set EAFETCH to one for word size
			BRA				AFTER			Break out of switch when done processing

LONG		MOVE.L			(A0)+,D5		* Fetch long operand from memory
			MOVE.B			#2,EAFETCH		Set EAFETCH to two for long size

AFTER		
			ADD.B			#2,EAMODE		Stores EA Mode as immediate data
			LEA				IMDTM,A3		Load modifier in output buffer (A3) to use when outputting operand to display
			LEA				NULL,A4			The right side of the operand is not used, so set A4 to null (0)
			MOVE.L			#1,D6			Fetch was needed, so set flag to 1
			
			BRA				EADONE			Exit function when done processing
			
NEXTEA		MOVE.L			D1,D3			Reset D3 to use it to test for more EA modes

* continue scanning the 7 other modes, if not found output EA unsupported error message and set D2 to 0

* Check if operand is data register
			CMP.B			#0,EAMODE		Check if addressing mode is Dn
			BNE				NEXTEA1			
			
			LEA				DREG,A3			Load modifier in output buffer (A3) to use when outputting operand to display
			LEA				NULL,A4			The right side of the operand is not used, so set A4 to null(0)
			MOVE.L			#0,D6			Fetch not needed
			
			MOVE.B			D1,D7			Move EA into D7
			AND.B			#$7,D7			Isolate EA register
			
			BRA				EADONE

NEXTEA1		CMP.B			#1,EAMODE		Check if addressing mode is An
			BNE				NEXTEA2			

			LEA				AREG,A3			Load modifier in output buffer
			LEA				NULL,A4			The right side of the operand is not used, so set A4 to null(0)
			MOVE.L			#0,D6			Fetch not needed
			
			MOVE.B			D1,D7			Move EA into D7
			AND.B			#$7,D7			Isolate EA register
			
			BRA 			EADONE			Exit function

NEXTEA2		CMP.B			#2,EAMODE		Check if addressing mode is (An)
			BNE				NEXTEA3			

			LEA				APREG,A3		Load modifier in output buffer, (A
			LEA				APLREG,A4		The right side of the operand is ), so set A4 to null(0)
			MOVE.L			#0,D6			Fetch not needed
			
			MOVE.B			D1,D7			Move EA into D7
			AND.B			#$7,D7			Isolate EA register
			
			BRA 			EADONE			Exit function
			
NEXTEA3		CMP.B			#3,EAMODE		Check if addressing mode is (An)+
			BNE				NEXTEA4		

			LEA				APREG,A3		Load modifier in output buffer, (A
			LEA				APLPREG,A4		The right side of the operand is )+, so set A4 to null(0)
			MOVE.L			#0,D6			Fetch not needed
			
			MOVE.B			D1,D7			Move EA into D7
			AND.B			#$7,D7			Isolate EA register
			
			BRA 			EADONE			Exit function

NEXTEA4		CMP.B			#4,EAMODE		Check if addressing mode is -(An)
			BNE				NEXTEA5		

			LEA				APNREG,A3		Load modifier in output buffer, -(A
			LEA				APLREG,A4		The right side of the operand is ), so set A4 to null(0)
			MOVE.L			#0,D6			Fetch not needed
			
			MOVE.B			D1,D7			Move EA into D7
			AND.B			#$7,D7			Isolate EA register

			BRA 			EADONE			Exit function

NEXTEA5		MOVE.L			D1,D3
			
			EORI.B			#AAW,D3			Check if the addressing mode is absolute addressing word
			CMP.W			#0,D3			IF the addressing mode is AAW, process accordingly
			BNE				LONG2			ELSE Check for next EA mode
			
			MOVE.W			(A0)+,D5		Fetch word operand from memory
			MOVE.B			#0,D7
			MOVE.B			#1,EAFETCH		Set EAFETCH to one for word size

			BRA				AFTER2			Break out of switch when done processing

LONG2		MOVE.L			D1,D3

			EORI.B			#AAL,D3			Check if addressing mode is Absolute addressing long
			CMP.W			#0,D3			If not equal, branch to error.
			BNE				EAWRONG
			ADD.B			#1,EAMODE		Set EAMODE as .L
			MOVE.L			(A0)+,D5		Fetch long operand from memory
			MOVE.B			#1,D7			Flag D7 as a long
			MOVE.B			#2,EAFETCH		Set EAFETCH to two for long size


AFTER2			
			LEA				AAM,A3			Load modifier in output buffer (A3) to use when outputting operand to display
			LEA				NULL,A4			The right side of the operand is not used, so set A4 to null (0)
			MOVE.L			#1,D6			Fetch was needed, so set flag to 1
			
			BRA				EADONE			Exit function when done processing

						
* Show error message since effective address mode is unsupported if the program reaches this point
EAWRONG		MOVE.B			#0,EAVALID		EA mode is invalid, so set flag to 0	
EADONE		RTS


* Put variables and constants here

* Input error messages
IOERROR1   DC.B		CR,LF,'ERROR: Starting address cannot exceed 8 digits.',CR,LF,LF,0
IOERROR2   DC.B		CR,LF,'ERROR: Input is not a valid hexadecimal address.',CR,LF,LF,0
IOERROR3   DC.B		CR,LF,'ERROR: Input is invalid. Please enter up to 8 hexadecimal digits',CR,LF,'(0-9, A-F, a-f).',CR,LF,LF,0
IOERROR4   DC.B		CR,LF,'ERROR: Address cannot start on an odd byte boundary, please enter an',CR,LF,'even starting address (ends in 0, 2, 4, 6, 8, A, C, or E).',CR,LF,LF,0
IOERROR5   DC.B		CR,LF,'ERROR: Ending address cannot exceed 8 digits.',CR,LF,0
IOERROR6   DC.B		CR,LF,'ERROR: Starting address cannot be larger than ending address.',CR,LF,'Restarting input process...',CR,LF,LF,0
IOERROR7   DC.B		CR,LF,'ERROR: Starting address cannot be the same as ending address.',CR,LF,'Please enter two different values.',CR,LF,'Restarting input process...',CR,LF,LF,0
IOERROR11  DC.B		CR,LF,'ERROR: Starting address cannot be less than $5000.',CR,LF,'Please enter an address greater than or equal to $5000.',CR,LF,LF,0
IOERROR12  DC.B		TAB,'ERROR: Invalid EA Mode',0
IOERROR13  DC.B		LF,'ERROR: Starting address cannot be larger than $00FFFD00',CR,LF,'Please enter a value less than or equal to $00FFFD00.',CR,LF,LF,0
IOERROR14  DC.B		LF,'ERROR: Ending address cannot be larger than $00FFFE00',CR,LF,'Please enter a value less than or equal to $00FFFE00.',CR,LF,LF,0

* Used for invalid op-code error message
IOERROR8   DC.B		TAB,'DATA   ',TAB,0

* Used for invalid EA mode error message
IOERROR9   DC.B		'DATA',0
* Ending error message
IOERROR10  DC.B		CR,LF,'ERROR: Invalid ending input. Please Re-enter.',CR,LF,LF,0

* User interface messages
MESSAGE1   DC.B		'Enter a starting address greater than or equal to $5000 in hexadecimal',CR,LF,'(0-9, A-F, a-f), with a maximum length of 8 digits.',CR,LF
		   DC.B		'This value must be less than $00FFFD00.',CR,LF,'Input is not sign extended and leading 0s are allowed: ',0
MESSAGE2   DC.B		LF,'Enter an ending address in hexadecimal (0-9, A-F, a-f),',CR,LF,'with a maximum length of 8 digits.',CR,LF
		   DC.B		'This value must be less than $00FFFE00.',CR,LF,'Input is not sign extended and leading 0s are allowed: ',0
MESSAGE3   DC.B		'Ending address reached. Type 0 to finish, or 1 to restart.',CR,LF,0
MESSAGE4   DC.B		LF,'Please enter one of these options: 1 - display next page, 2 - quit, 3 - restart: ',0
MESSAGE5   DC.B		CR,LF,'Thank you for using the D3G disassembler.',CR,LF,0
MESSAGE6   DC.B		'Restarting....',CR,LF,0

* Program header
HEADER	   DC.B     '**********************************************************************',CR,LF
		   DC.B		'                       DDDDD   333333    GGGG ',CR,LF
           DC.B		'                       DD  DD     3333  GG  GG',CR,LF
		   DC.B		'                       DD   DD   3333  GG     ',CR,LF
		   DC.B		'                       DD   DD     333 GG   GG',CR,LF
		   DC.B		'                       DDDDDD  333333   GGGGGG',CR,LF
		   DC.B     '**********************************************************************',CR,LF,LF,0

* Variables and constants
CR			EQU				$D			Carraige return
LF			EQU	   			$A 			Line feed
TAB			EQU				$9			Tab character

BLANK	   DC.B		CR,LF,0		Prints a blank line
COMMA	   DC.B		$2C,0		Prints a comma
			
*PRINTING MODIFIERS
DREG	   DC.B		'D',0		Prints D when outputting a data register
AREG	   DC.B		'A',0		Prints A when outputting an address register
NULL	   DC.B		0			Sets null character (0)
APREG	   DC.B		'(A',0		Prints (A when outputting (An)
APLREG	   DC.B		')',0		Prints ) when outputting (An)
APLPREG	   DC.B		')+',0		Prints )+ when outputting (An)+
APNREG	   DC.B		'-(A',0		Prints -(A when outputting -(An)
AAM		   DC.B		'$',0		Prints $ when outputting word or long

*EAVARIABLES
EAMODE	   DS.B		1			Stores EAMODE #0-4 = NOFETCH modes. #7-9 = .W,.L,#<data> respectively  
EAFETCH	   DS.B		1			Stores Fetch/Fetch Size 0 = no fetch, 1 = fetch word, and 2 = fetch long

DORA		DS.B	1			Stores if data or or address reg, 0 for Data, 1 for Address

* Masks for opcode
OPBYTE	   	EQU			$F000		Mask to isolate the most significant op-code byte
OPMASK		EQU			$FF00		Mask to isolate half

* NOP
NOP			EQU			$4E71		Corresponds to the op-code word for the NOP instruction

* NOP output message
PNOP	   	DC.B		TAB,'NOP',CR,LF,0

* RTS
RTS 		EQU			$4E75		Corresponds to the op-code word for the RTS instruction

* RTS output message
PRTS		DC.B		TAB,'RTS',CR,LF,0 

* ADD
ADD			EQU			$D000		Mask to test if instruction is ADD
ADDQ		EQU			$5000		Mask to test if instruction is ADDQ
SUB			EQU			$9000		Mask to test if instruction is SUB
AND			EQU			$C000		MASK to test if instruction is AND
OR			EQU			$8000		Mask to test if instruction is OR
MOVEA       EQU			$3000		Mask to test if instruction is MOVEA
MOVEQ		EQU			$7000		Mask to test if instruction is MOVEQ

LEA			EQU			$4000		Mask to test if instruction is LEA
NOT			EQU			$4600		Mask to test if instruction is NOT

ADDEA		EQU			$003F		Mask to isolate 6 bits of EA field for ADD instruction
OPMODE		EQU			$01C0		Mask to isolate the three op-mode bits in the ADD instruction
REGNUM		EQU			$0E00		Mask to isolate the register number in the ADD instruction

* Used when outputting instruction
ADDAW		DC.B	TAB,'ADDA.W ',TAB,0
ADDAL		DC.B	TAB,'ADDA.L ',TAB,0

ADDB		DC.B	TAB,'ADD.B  ',TAB,0
ADDW		DC.B	TAB,'ADD.W  ',TAB,0
ADDL		DC.B	TAB,'ADD.L  ',TAB,0

ADDQB		DC.B	TAB,'ADDQ.B ',TAB,0
ADDQW		DC.B	TAB,'ADDQ.W ',TAB,0
ADDQL		DC.B	TAB,'ADDQ.L ',TAB,0

SUBB		DC.B	TAB,'SUB.B  ',TAB,0
SUBW		DC.B	TAB,'SUB.W  ',TAB,0
SUBL		DC.B	TAB,'SUB.L  ',TAB,0

ANDB		DC.B	TAB,'AND.B  ',TAB,0
ANDW		DC.B	TAB,'AND.W  ',TAB,0
ANDL		DC.B	TAB,'AND.L  ',TAB,0

LEAP		DC.B	TAB,'LEA    ',TAB,0

NOTB		DC.B	TAB,'NOT.B  ',TAB,0
NOTW		DC.B	TAB,'NOT.W  ',TAB,0
NOTL		DC.B	TAB,'NOT.L  ',TAB,0

ORB			DC.B	TAB,'OR.B   ',TAB,0
ORW			DC.B	TAB,'OR.W   ',TAB,0
ORL			DC.B	TAB,'OR.L   ',TAB,0

MOVEAW		DC.B	TAB,'MOVEA.W',TAB,0
MOVEAL		DC.B	TAB,'MOVEA.L',TAB,0

MOVEB		DC.B	TAB,'MOVE.B ',TAB,0
MOVEW		DC.B	TAB,'MOVE.W ',TAB,0
MOVEL		DC.B	TAB,'MOVE.L ',TAB,0

MOVEQL		DC.B	TAB,'MOVEQ.L',TAB,0

* EA modes
IMDT		EQU		$3C			Hex value for immediate EA mode
AAW			EQU		$38			Hex value for Absolute Addressing word
AAL			EQU		$39			Hex value for Absolute Addressing long

* Modifiers for output, used in EA subroutines
IMDTM		DC.B	'#$',0

STARTADDR	DS.B	9				Starting address of memory to disassemble, each digit requires 1 byte, needing 8 bytes + 1 byte for null terminator (00)
ENDADDR		DS.B	9				Ending address of memory to disassemble, each digit requires 1 byte, needing 8 bytes + 1 byte for null terminator (00)
STARTLEN	DS.B	1				Holds number of digits in starting address
ENDLEN		DS.B	1				Holds number of digits in ending address
REGL		DS.B	1				Register number of left operand if both operands are registers, otherwise corresponds to a single register
REGR		DS.B	1				Register number of right operand, only used if both operands are registers
EAVALID		DS.B	1				Flag to determine if EA mode is valid; used for CPU to know if it needs to print the instruction. 0 is invalid, 1 is valid

LINECNT		DS.W	1				Counter to check how many lines were printed, used to display output one screen at a time

*JSR variables

JSR_MASK 	EQU			$FFC0		Mask to isolate the most significant 10 bits
JSR_CHECK	EQU			$4E80		First 10 bits of JSR op-code	
P_JSR_PRINT	DC.B		TAB,'JSR    ',TAB,0	
HEXVAL		DC.B		'$',0			Add a '$' before the location. Also used for branch commands.

*BRA variables

BRA_MASK 		EQU		$FF00		Mask to isolate the most significant 8 bits
BRA_CHECK		EQU		$6000		First 8 bits of BRA op-code
DISP_MASK		EQU		$00FF		Mask to isolate the least significant 8 bits
BRA_16BIT		EQU		$8000		Mask to verify sign of 16-bit displacement
P_BRA_PRINTB	DC.B		TAB,'BRA.B  ',TAB,0
P_BRA_PRINTW	DC.B		TAB,'BRA.W  ',TAB,0

*BGT variables

BGT_CHECK	EQU			$6E00		First 8 bits of BGT op-code	
P_BGT_PRINTB	DC.B		TAB,'BGT.B  ',TAB,0
P_BGT_PRINTW	DC.B		TAB,'BGT.W  ',TAB,0

*BLE variables

BLE_CHECK	EQU			$6F00		First 8 bits of BLE op-code	
P_BLE_PRINTB	DC.B		TAB,'BLE.B  ',TAB,0
P_BLE_PRINTW	DC.B		TAB,'BLE.W  ',TAB,0

*BEQ variables

BEQ_CHECK	EQU			$6700		First 8 bits of BEQ op-code	
P_BEQ_PRINTB	DC.B		TAB,'BEQ.B  ',TAB,0
P_BEQ_PRINTW	DC.B		TAB,'BEQ.W  ',TAB,0


LSL_MSSG	DC.B	TAB,'LSL.',0
LSL_SINGLE	DC.B	TAB,'LSL.W  ',TAB,0
LSR_MSSG	DC.B	TAB,'LSR.',0
LSR_SINGLE	DC.B	TAB,'LSR.W  ',TAB,0
ASL_MSSG	DC.B	TAB,'ASL.',0
ASL_SINGLE	DC.B	TAB,'ASL.W  ',TAB,0
ASR_MSSG	DC.B	TAB,'ASR.',0
ASR_SINGLE	DC.B	TAB,'ASR.W  ',TAB,0
ROL_MSSG	DC.B	TAB,'ROL.',0
ROL_SINGLE	DC.B	TAB,'ROL.W  ',TAB,0
ROR_MSSG	DC.B	TAB,'ROR.',0
ROR_SINGLE	DC.B	TAB,'ROR.W  ',TAB,0

SPACE		DC.B	' ',0
BIT			DC.B	'B ',TAB,0				Prints the B character followed by a space
WORD		DC.B	'W ',TAB,0				Prints the W character followed by a space
LONG_MSSG	DC.B	'L ',TAB,0
PD			DC.B	'#$',0
CRLF		DC.B	CR,LF,0

MOVEMW1		DC.B	TAB,'MOVEM.W',TAB,0
MOVEML1		DC.B	TAB,'MOVEM.L',TAB,0
MOVEMSP1	DC.B	'(SP)',0
MOVEMSP2	DC.B	'-(SP)',CR,LF,0
MOVEMSP3	DC.B	'(SP)+',0

DASH	   DC.B		$2D,0		Prints a dash
BACKSL	   DC.B		$2F,0		Prints a backslash

* MOVEM
MOVEM		EQU			$4880		Mask to test if instruction is MOVEM
MOVEMEA		EQU			$003F		Mask to isolate EA bits
FIRSTREG	DC.B		1			Flag to determine if its the first register being output for MOVEM, initally set to 1 for true
MTRFLAG		DC.B		0			Flag to test if MTR mode is being used



DR			DS.B	1				Stores dr mode for MOVEM with 0 corresponding with register to memory, and 1 corresponding with memory to register
SIZE		DS.B	1				Stores the size bit for MOVEM
COUNT		DS.B	1				Loop counter for outputting MOVEM
REGCOUNT	DS.B	1				Register counter for MOVEM
PREVREG		DS.B	1				Used to check if previous register is used when looking for a sequence
SEND		DS.B	1				End of sequence when outputting MOVEM
REGMASK		DS.W	1				Contains a copy of the register list mask word from the MOVEM instruction
PRINTL		DS.B	1				Flag to determine if it was necessary to print last register(s), set to 1 if true
SSTART		DS.B	1				Start of sequence when outputting MOVEM, $FF is used as a sentinel value to show if no registers were used


    END    START        ; last line of source








			













































*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
