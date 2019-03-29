.include	"logic.s"

//Need to include the C file not sure how to at the moment

		.text			//code to poll for keybutton presses
		.global_start
		
//Arbitrarily decided these addresses I hope they don't do anything
COLUMN1:	.word   0xA0000000
COLUMN2:	.word 	0xA0000004	
TOWERSTART:	.word	0xA0000008	
		
//Need to draw to game when to program starts		

_start:			LDR		R0, =0xA0000008		//assigns the location the PB presses are stored

				MOV		R1, #1				//Populating Tower
				MOV		R2, #1
				STR		R1, [R0]
				ADD		R1, R2
				STR		R1, [R0, #4]
				ADD		R1, R2
				STR		R1, [R0, #8]
				ADD		R1, R2
				STR		R1, [R0, #12]
				ADD		R1, R2
				STR		R1, [R0, #16]
				ADD		R1, R2
				STR		R1, [R0, #20]
				ADD		R1, R2
				STR		R1, [R0, #24]
				ADD		R1, R2
				STR		R1, [R0, #28]
				ADD		R1, R2
				STR		R1, [R0, #32]
				ADD		R1, R2
				STR		R1, [R0, #36]
				MOV		R1, #0
				STR		R1, [R0, #40]
				STR		R1, [R0, #44]
				STR		R1, [R0, #48]
				STR		R1, [R0, #52]
				STR		R1, [R0, #56]
				STR		R1, [R0, #60]
				STR		R1, [R0, #64]
				STR		R1, [R0, #68]
				STR		R1, [R0, #72]
				STR		R1, [R0, #76]
				STR		R1, [R0, #80]
				STR		R1, [R0, #84]
				STR		R1, [R0, #88]
				STR		R1, [R0, #92]
				STR		R1, [R0, #96]
				STR		R1, [R0, #100]
				STR		R1, [R0, #104]
				STR		R1, [R0, #108]
				STR		R1, [R0, #112]
				STR		R1, [R0, #116]
				
				
POLLING_START:	LDR		R0, =0xA0000000		//assigns the location the PB presses are stored
				LDR		R1, =0xFF200050		//PB press location
			
POLLC1:			LDRB	R2, [R10]	//Loads PB values
				CMP		R2, #0		//Checks if PB pressed
				BEQ		POLLC1
				CMP		R2, #0b1000 //checks if PB was valid
				BEQ		POLLC1
				STRB	R2, [R0]	//if PB pressed stored in memory
				B		POLLC2		//goes to check for second press
			
POLLC2:			LDRB	R3, [R10]	//Loads PB values
				CMP		R3, #0		//Checks if PB pressed
				BEQ		POLLC2
				CMP		R3, #0b1000 //checks if PB was valid
				BEQ		POLLC2
				STRB	R3, [R0, #4]	//if PB pressed stored in memory
				B		LOGIC_START		//goes to logic functions
			
			
.end
			
			