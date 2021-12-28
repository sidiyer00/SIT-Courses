/*
 * taylor.s
 *
 *  Created on: Dec 9, 2020
 *      Author: sidiy
 */

 .text
 .global main
 .extern printf

 main:
 	ldr x7, =power
 	ldr d4, [x7]			// loads x into d4
 	ldr x5, =terms
 	ldr x5, [x5]			// loads i into x5 (int so regular registers)
 	ldr x0, =prt_str		// prt_srt in x0 waiting to get printf'd
 	add d0, xzr, xzr		// x1 is final summation register to be printed
 	add d2, xzr, #1
 	.global taylor			// call taylor

 taylor:
	cmp x5, #0				// if number of terms left = 1, then print
	B.EQ terminate
	sub x5, x5, #1			// decrement number of terms - used in both factorial and exponent calculations
	bl factorial			// call factorial w/x5, output stored in x2
	bl power				// call power w/x5, output stored in d2 as double
	scvtf d6, x2			// converts power to double
	fdiv d6, #1, d6			// calculates 1/factorial
	fmul d2, d2, d6			// calculates ith taylor expression
	add d0, d0, d2			// adds that to total approximation
	br lr


 power:
	sub sp, sp, #16
	str x30, [sp, #0]
	str x5, [sp, #8]
	cmp x5, #1
	B.NE power
	scvtf d3, x5
	fmul d2, d2, d3
	ldr x5, [sp, #8]
	add sp, sp, #16
	br lr

// from the slides from chapter 1

 factorial:
 	sub sp, sp, #16
 	str x30, [sp, #8]
 	str x5, [sp, #0]
 	cmp x5, #1
 	B.GE L1
 	add x2, xzr, #1
 	add sp, sp, #16
 	br lr

 L1:
 	sub x5, x5, #1
 	bl factorial
 	ldr x5, [sp, #0]
 	ldr x30, [sp, #8]
 	add sp, sp, #16
 	mul x2, x5, x2
 	br lr


terminate:
	bl printf			// prints value in d0 and exits the program

 .data
power:
	.double 4.32
terms:
	.quad 5
prt_str:
	.ascii "The approximation is %f\n"



 .end
