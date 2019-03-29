//Logic function written assuming max disk count is 10


LOGIC_START:	MOV		R1, #0

				CMP		R2, #0b0001		//assigns R2 to the key number by checking value against masks
				MOVEQ	R2, #0
				CMP		R2, #0b0010
				MOVEQ	R2, #1
				CMP		R2, #0b0100
				MOVEQ	R2, #2
				
				MUL 	R2, #40			//Multiplies by 40 as that is the length of one row of the tower Array
				
				CMP		R3, #0b0001		//assigns R3 to the key number by checking value against masks
				MOVEQ	R3, #0
				CMP		R3, #0b0010
				MOVEQ	R3, #1
				CMP		R3, #0b0100
				MOVEQ	R3, #2
				
				MUL		R3, #40			//Multiplies by 40 as that is the length of one row of the tower Array

				ADD		R6, R2, #1		//setting limit to column
				MUL		R6, #40
CHECK_TOP_C1:	ADD		R2, R1
				CMP		R2, R6			//checking if end of column was reached
				BEQ		POLLING_START	//it end of column reached buttom press was invalid and returning to polling
				LDR		R4, [R0, R2]	//checking disk value 
				ADD		R1, #4
				CMP		R4, #0			//if disk value is not zero then that is the top disk on the column
				BEQ		CHECK_TOP_C1	//if disk value is zero cycles throught checktop again for the next memory location
				MOV		R1, #0
				
				ADD		R6, R3, #1		//setting limit to column
				MUL		R6, #40
				
CHECK_TOP_C2:	ADD		R3, R1
				CMP		R3, R6			//checking if end of column was reached
				BEQ		C2_EMPTY		//if so going to C2_EMPTY to set disk size to 0
				LDR		R5, [R0, R3]	//checking disk value 
				ADD		R1, #4
				CMP		R5, #0			//if disk value is not zero then that is the top disk on the column
				BEQ		CHECK_TOP_C2	//if disk value is zero cycles throught checktop again for the next memory location
				

CHECK_LEGAL:	MOV		R1, #0
				CMP		R4, R5			//checks if the disk being moved is smaller than the one its being moved on top of
				BGT		POLLING_START	//if not the move is invalid and it just back to polling
				
				STR		R1, [R2]		//moving disks
				SUB		R3, #4
				STR		R4, R3
				B		DRAW			//drawing new positions to screen
				
C2_EMPTY:		MOV		R5, #0
				SUB		R3, R3, #4
				B		CHECK_LEGAL
				
