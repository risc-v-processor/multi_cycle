`timescale 1ns / 1ps

module Exec_tb;

	// Inputs
	reg [31:0] Operand1;
	reg [31:0] Operand2;
	reg [4:0] Operation;

	// Outputs
	wire [31:0] Out;
	wire bcond;
	
	reg [31:0] Operands [0:5];
	reg [4:0] alu_op [0:17];
	
	integer index1,index2,index3;
	integer read_op,read_alu;
		
		
	// Instantiate the Unit Under Test (UUT)
	Exec uut (
		.Operand1(Operand1), 
		.Operand2(Operand2),
      .Operation(Operation),		
		.Out(Out),
      .bcond(bcond)		
	);
		
		
	initial
	begin
		// Initialize Inputs
		
		Operand1 = 0;
		Operand2 = 0;
		Operation = 5'bx;
		
		// Wait 5ns for global reset to finish
		#5;       
	   		
		//Monitor signals
		$monitor("Time: %g Operand 1: %d Operand 2: %d Output: %d",$time,Operand1,Operand2,Out);
		
		//Read operands from the file "Operands.txt" and store in array
		read_op=$fopen("Operands.txt","r");
		$readmemh("Operands.txt", Operands);
	   //Read operation codes from the file "aluop.txt" and store in array  
		read_alu=$fopen("aluop.txt","r");
		$readmemb("aluop.txt", alu_op);
		
		//Stimulus
		repeat(18)
			begin
				//Generate random index to access the array containing the operands and the operation codes
				index1={$random}%6;	
				index2={$random}%6;
				index3={$random}%15;
				
				Operand1=Operands[index1];				
				Operand2=Operands[index2];
				Operation=alu_op[index3];
				
				#5;
			end
		#5 $finish;		
	end
endmodule

