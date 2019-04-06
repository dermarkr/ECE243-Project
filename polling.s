//Need to include the C file not sure how to at the moment


		.text			//code to poll for keybutton presses
		.global _start
		.extern draw
		.extern higlight_column
		
//Arbitrarily decided these addresses I hope they don't do anything


		
//Need to draw to game when to program starts		

_start:			BL		draw	
				B		DRAW_SCORE
				
POLLING_START:	
				LDR		R0, =BUTTONS		//assigns the location the PB presses are stored		
				LDR		R1, =PUSH_BUTTON_LOCATION		//PB press location
				LDR 	R1, [R1]
			
POLLC1:			LDRB	R2, [R1]	//Loads PB values
				CMP		R2, #0		//Checks if PB pressed
				BEQ		POLLC1
				CMP		R2, #0b1000 //checks if PB was valid
				BEQ		WAIT_RESTART
				AND		R2, #0x0000000f
				STR		R2, [R0]	//if PB pressed stored in memory
				B		WAITPOLLC1		//goes to check for second press
				
WAITPOLLC1:		LDRB	R4, [R1]
				CMP		R4, #0
				BEQ		PREPOLLC2
				B		WAITPOLLC1

PREPOLLC2:		BL		higlight_column
				LDR		R1, =PUSH_BUTTON_LOCATION		//PB press location
				LDR		R1, [R1]
				LDR		R0, =BUTTONS
				LDR		R2, [R0]
				
POLLC2:			
				LDRB	R3, [R1]	//Loads PB values
				CMP		R3, R2
				BEQ		INVALID
				CMP		R3, #0		//Checks if PB pressed
				BEQ		POLLC2
				CMP		R3, #0b1000 //checks if PB was valid
				BEQ		WAIT_RESTART
				STRB	R3, [R0, #1]	//if PB pressed stored in memory
				B		WAITPOLLC2		//goes to logic functions
				
WAITPOLLC2:		LDRB	R4, [R1]
				CMP		R4, #0
				BEQ		LOGIC_START
				B		WAITPOLLC2
			
			//Logic function written assuming max disk count is 10
INVALID:		LDRB	R4, [R1]
				CMP		R4, #0
				BEQ		_start
				B		INVALID

LOGIC_START:	
				//MOV		R10, #160

				CMP		R2, #0b0001		//assigns R2 to the key number by checking value against masks
				MOVEQ	R2, #0
				CMP		R2, #0b0010
				MOVEQ	R2, #1
				CMP		R2, #0b0100
				MOVEQ	R2, #2
				
				//MUL 	R7, R2, R10		//Multiplies by 160 as that is the length of one row of the tower Array
				
				LDR R10, =COLUMN0
				CMP		R2, #0
				MOVEQ	R7, R10
				
				LDR R10, =COLUMN1
				CMP		R2, #1
				MOVEQ	R7, R10
				
				LDR R10, =COLUMN2
				CMP		R2, #2
				MOVEQ	R7, R10
				
				CMP		R3, #0b0001		//assigns R3 to the key number by checking value against masks
				MOVEQ	R3, #0
				CMP		R3, #0b0010
				MOVEQ	R3, #1
				CMP		R3, #0b0100
				MOVEQ	R3, #2
				
				//MUL		R8, R3, R10			//Multiplies by 40 as that is the length of one row of the tower Array

				LDR R10, =COLUMN0
				CMP		R3, #0
				MOVEQ	R8, R10
				
				LDR R10, =COLUMN1
				CMP		R3, #1
				MOVEQ	R8, R10
				
				LDR R10, =COLUMN2
				CMP		R3, #2
				MOVEQ	R8, R10
				
				
				ADD		R9, R7, #40
				//ADD		R6, R2, #1		//setting limit to column
				//MUL		R9, R6, R10		//for example, if r2 was column 0, then r6 = 1, r9 = 1 * 160 = 160 = the start address of
											//the second column
				//ADD		R9, #16		//potentially incorrect offset
CHECK_TOP_C1:	
				CMP		R7, R9			//checking if end of column was reached
				BGE		_start	//it end of column reached buttom press was invalid and returning to polling
				LDR		R4, [R7]	//checking disk value 
				ADD		R7, #4
				CMP		R4, #0			//if disk value is not zero then that is the top disk on the column
				BEQ		CHECK_TOP_C1	//if disk value is zero cycles throught checktop again for the next memory location
				SUB		R7, #4
				
				
				ADD		R9, R8, #40
				//ADD		R6, R3, #1		//setting limit to column
				//LDR 	R6, =3
				//LDR 	R10, =5
				//MUL		R9, R6, R10		//for example, if r3 was column 0, then r6 = 1, r9 = 1 * 160 = 160 = the start address of
											//the second column
				//ADD		R9, #16		//potentially incorrect offset
				
				
CHECK_TOP_C2:	
				CMP		R8, R9			//checking if end of column was reached
				BGE		C2_EMPTY		//if so going to C2_EMPTY to set disk size to 0
				LDR		R5, [R8]	//checking disk value 
				ADD		R8, #4
				CMP		R5, #0			//if disk value is not zero then that is the top disk on the column
				BEQ		CHECK_TOP_C2	//if disk value is zero cycles throught checktop again for the next memory location
				
//the following subroutine checks legality of the move that the user requested
CHECK_LEGAL:	MOV		R1, #0
				CMP		R5, #0	
				BEQ		MOVING_EMPTY
				
				CMP		R4, R5			//checks if the disk being moved is smaller than the one its being moved on top of
				BGT		_start	//if not the move is invalid and it just back to polling
				
				STR		R1, [R7]		//moving disks
				SUB		R8, #8
				STR		R4, [R8]
				B		ADD_SCORE		//drawing new positions to screen
				
//the following subroutine does (unnecessary) operations when a column that is being moved to is empty				
C2_EMPTY:		MOV		R5, #0			//ensuring a value is stored in r5(for legality)
				//SUB		R8, R8, #16		//potentially incorrect thing
				B		CHECK_LEGAL

//the following subroutine moves a disk into an empty column
MOVING_EMPTY:	SUB		R8, #4
				STR		R4, [R8]
				STR		R5, [R7]
				B		ADD_SCORE
				
ADD_SCORE:		LDR		R0, =SCORE
				LDR		R1, [R0]
				ADD		R1, #1
				STR		R1, [R0]
				B		_start
				
DRAW_SCORE:		LDR		R0, =0xC900004A
				LDR		R1, =83
				STRB	R1, [R0]
				ADD		R0, #1
				LDR 	R1, =67
				STRB	R1, [R0]
				ADD		R0, #1
				LDR 	R1, =79
				STRB	R1, [R0]
				ADD		R0, #1
				LDR 	R1, =82
				STRB	R1, [R0]
				ADD		R0, #1
				LDR 	R1, =69
				STRB	R1, [R0]
				LDR		R0, =0xC90000CA
				LDR		R2, =SCORE
				LDR		R2, [R2]
				BL		HEX_TO_DEC
				LDR		R1, =48
				ADD		R6, R1
				ADD		R5, R1
				ADD		R4, R1
				ADD		R3, R1
				ADD		R2, R1
				STRB	R6, [R0]
				ADD		R0, #1
				STRB	R5, [R0]
				ADD		R0, #1
				STRB	R4, [R0]
				ADD		R0, #1
				STRB	R3, [R0]
				ADD		R0, #1
				STRB	R2, [R0]
				B		POLLING_START

HEX_TO_DEC:		
			MOV    	R3, #0			// Setting the quotients to zero
			MOV	   	R4, #0
			MOV    	R5, #0
			MOV		R6, #0
			LDR		R7, =10000
DTENTHOU:	CMP    	R2, R7			// Checking if the value is greater than the Divisor to the fourth power 
            BLT    	DTHOU			// Moving to the next function if Divisor is greater than the remaining value
            SUB    	R2, R7			// Subtracting the divisor from the remaining value
            ADD    	R6, #1			// incrementing Thousands value for each time through the full function
            B      	DTENTHOU		// going back to beginning of function 
DTHOU:		CMP    	R2, #1000		// Checking if the value is greater than the Divisor to the fourth power 
            BLT    	DHUND			// Moving to the next function if Divisor is greater than the remaining value
            SUB    	R2, #1000		// Subtracting the divisor from the remaining value
            ADD    	R5, #1			// incrementing Thousands value for each time through the full function
            B      	DTHOU			// going back to beginning of function 
DHUND:		CMP    	R2, #100		// Checking if the value is greater than the Divisor to the Third power
            BLT    	DTEN			// Moving to the next function if Divisor is greater than the remaining value
            SUB    	R2, #100		// Subtracting the divisor from the remaining value
            ADD    	R4, #1			// incrementing Hundreds value for each time through the full function
            B      	DHUND			// going back to beginning of function
DTEN:       CMP    	R2, #10			// Checking if the value is greater than the Divisor to the Second power
            BLT    	DIV_END			// Moving to the next function if Divisor is greater than the remaining value
            SUB    	R2, #10			// Subtracting the divisor from the remaining value
            ADD    	R3, #1			// incrementing Tens value for each time through the full function
            B      	DTEN			// going back to beginning of function
DIV_END:    MOV    	PC, LR

WAIT_RESTART:	LDRB	R4, [R1]
				CMP		R4, #0
				BEQ		RESTART
				B		WAIT_RESTART
				
RESTART:		LDR		R0, =SCORE
				LDR		R1, [R0]
				MOV		R1, #0
				STR		R1, [R0]
				MOV		R0, #0
				MOV 	R4, #4	//size of an integer, in bytes
				LDR 	R3, =COLUMN0	//address that the data is being stored in
				MOV		R1, #1	//data being stored into arrays (to represent the disks)
				MOV		R2, #1	//iterate value stored in array
				

BUILDTOWER:		STR		R1, [R3]
				ADD		R3, R4
				ADD		R1, R2
				CMP		R1, #11
				BLT		BUILDTOWER	
				MOV		R1, #0
				

FILLEMPTY:		STR		R0, [R3]
				ADD		R3, R4
				ADD		R1, R2
				CMP		R1, #20
				BLT		FILLEMPTY
				B		_start
			
		BUTTONS:	.word	0x0, 0x0
		COLUMN0:	.word	0x00000001
					.word 	0x00000002 
					.word 	0x00000003
					.word 	0x00000004
					.word 	0x00000005
					.word 	0x00000006
					.word 	0x00000007
					.word	0x00000008
					.word 	0x00000009
					.word 	0x0000000A
		COLUMN1:	.word	0
					.word 	0
					.word 	0
					.word 	0 
					.word 	0
					.word 	0
					.word 	0 
					.word	0
					.word 	0
					.word 	0
		COLUMN2:	.word	0
					.word 	0
					.word 	0
					.word 	0 
					.word 	0
					.word 	0
					.word 	0 
					.word	0
					.word 	0
					.word 	0
		PUSH_BUTTON_LOCATION:
					.word 	0xFF200050
		SCORE:		.byte   0



.end
			
			