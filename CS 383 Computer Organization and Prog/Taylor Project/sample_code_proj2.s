
 .text
 .global main
 .extern printf

 main:
 SUB sp, sp, #16
 STR x30, [sp]


 // multiply theta with itself
 LDR x2, =theta
 LDR d2, [x2]
 FMUL d0, d2, d2
 LDR x0, =prt_str1
 // calling printf alters registers X0-X7
 // save them in stack to use again
 SUB sp, sp, #16
 STR d0, [sp]
 STR d2, [sp, #8]
 BL printf
 LDR d0, [sp]
 LDR d2, [sp, #8]
 ADD sp, sp, #16

// convert 5 to 5.0
// and multiply with theta
LDR x2, =n
LDR x1, [x2]
SCVTF d1, x1
FMUL d0, d1, d2
LDR x0, =prt_str2
BL printf

// return to caller
LDUR x30, [sp]
ADD sp, sp, #16
BR	x30

 .data
n:
	.quad 5
theta:
	.double 0.45
prt_str1:
	.ascii "theta square is %f \n\0"
prt_str2:
	.ascii "five times theta is %f \n\0"

 .end
