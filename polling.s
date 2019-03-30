//Need to include the C file not sure how to at the moment

		.text			//code to poll for keybutton presses
		.global _start
		
//Arbitrarily decided these addresses I hope they don't do anything


		
//Need to draw to game when to program starts		

_start:			LDR		R0, =0				//assigns the location the PB presses are stored
				MOV 	R4, #16
				MOV 	R3, #0
				MOV		R1, #0				//Populating Tower
				MOV		R2, #1

BUILDTOWER:		
				STR		R1, [R3]
				ADD		R3, R4
				ADD		R1, R2
				CMP		R1, #2
				BEQ		FILLEMPTY
				B		BUILDTOWER
				
				

FILLEMPTY:		
				STR		R0, [R3]
				ADD		R3, R4
				ADD		R1, R2
				CMP		R1, #7
				BLT		FILLEMPTY

				
				
POLLING_START:	MOV		R0, #BUTTONS		//assigns the location the PB presses are stored		
				LDR		R1, =0xFF200050		//PB press location
			
POLLC1:			LDRB	R2, [R1]	//Loads PB values
				CMP		R2, #0		//Checks if PB pressed
				BEQ		POLLC1
				CMP		R2, #0b1000 //checks if PB was valid
				BEQ		POLLC1
				STRB	R2, [R0]	//if PB pressed stored in memory
				B		WAITPOLLC1		//goes to check for second press
				
WAITPOLLC1:		LDRB	R4, [R1]
				CMP		R4, #0
				BEQ		POLLC2
				B		WAITPOLLC1
			
POLLC2:			LDRB	R3, [R1]	//Loads PB values
				CMP		R3, #0		//Checks if PB pressed
				BEQ		POLLC2
				CMP		R3, #0b1000 //checks if PB was valid
				BEQ		POLLC2
				STRB	R3, [R0, #8]	//if PB pressed stored in memory
				B		WAITPOLLC2		//goes to logic functions
				
WAITPOLLC2:		LDRB	R4, [R1]
				CMP		R4, #0
				BEQ		LOGIC_START
				B		WAITPOLLC2
			
			//Logic function written assuming max disk count is 10


LOGIC_START:	
				MOV		R10, #32

				CMP		R2, #0b0001		//assigns R2 to the key number by checking value against masks
				MOVEQ	R2, #0
				CMP		R2, #0b0010
				MOVEQ	R2, #1
				CMP		R2, #0b0100
				MOVEQ	R2, #2
				
				MUL 	R7, R2, R10		//Multiplies by 40 as that is the length of one row of the tower Array
				
				CMP		R3, #0b0001		//assigns R3 to the key number by checking value against masks
				MOVEQ	R3, #0
				CMP		R3, #0b0010
				MOVEQ	R3, #1
				CMP		R3, #0b0100
				MOVEQ	R3, #2
				
				MUL		R8, R3, R10			//Multiplies by 40 as that is the length of one row of the tower Array

				ADD		R6, R2, #1		//setting limit to column
				MUL		R9, R6, R10
				ADD		R9, #16
CHECK_TOP_C1:	
				CMP		R7, R9			//checking if end of column was reached
				BGE		POLLING_START	//it end of column reached buttom press was invalid and returning to polling
				LDR		R4, [R7]	//checking disk value 
				ADD		R7, #16
				CMP		R4, #0			//if disk value is not zero then that is the top disk on the column
				BEQ		CHECK_TOP_C1	//if disk value is zero cycles throught checktop again for the next memory location
				SUB		R7, #16
				
				ADD		R6, R3, #1		//setting limit to column
				MUL		R9, R6, R10
				ADD		R9, #16
				
CHECK_TOP_C2:	
				CMP		R8, R9			//checking if end of column was reached
				BGE		C2_EMPTY		//if so going to C2_EMPTY to set disk size to 0
				LDR		R5, [R8]	//checking disk value 
				ADD		R8, #16
				CMP		R5, #0			//if disk value is not zero then that is the top disk on the column
				BEQ		CHECK_TOP_C2	//if disk value is zero cycles throught checktop again for the next memory location
				

CHECK_LEGAL:	MOV		R1, #0
				CMP		R4, R5			//checks if the disk being moved is smaller than the one its being moved on top of
				BLT		POLLING_START	//if not the move is invalid and it just back to polling
				
				STR		R1, [R7]		//moving disks
				SUB		R8, #16
				STR		R4, [R8]
				B		POLLING_START			//drawing new positions to screen
				
C2_EMPTY:		MOV		R5, #0
				SUB		R8, R8, #16
				B		CHECK_LEGAL
			
			
		BUTTONS:	.byte	0x0, 0x0


.end
			
			