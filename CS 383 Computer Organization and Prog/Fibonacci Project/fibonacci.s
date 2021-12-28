	/*
 * fibonacci.s
 *
 *  Created on: Oct 31, 2020
 *      Author: sidiy
 */

 .text
 .global main
 .extern printf

 main:
 	ldr x0, =prt_str
	ldr x5, =fib_num
	ldr x5, [x5]
	mov x6, #1
	add x7, xzr, xzr
 	.global fib

 fib:
	cmp x5, #1
	B.NE fib_recursive
	mov x1, x6
	sub sp, sp, #16
	str x30, [sp, #0]
	bl printf
	ldr x30, [sp,#0]
	add sp, sp, #16
	br x30

 fib_recursive:
 	sub sp, sp, #16
 	str x30, [sp, #0]
 	add x8, xzr, x6
 	add x6, x6, x7
 	add x7, x8, xzr
 	sub x5, x5, 1
	bl fib
 	ldr x30, [sp, #0]
 	add sp, sp, #16
 	br x30

 .data
 prt_str:
 	.ascii "The requested fib number: %d \n\0"
 fib_num:
 	.byte 5
.end
