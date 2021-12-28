/*
 * main.s
 *
 *  Created on: Oct 18, 2020
 *      Author: sidiy
 */

 .text
 .global main
 .extern printf

 main:
// 	add x19, x0, xzr
// 	add x20, x19, #4
// 	sub x1, x20, x19
	sub sp, sp, #16
	str x30, [sp, #8]
 	ldr x0, =prt_str
 	ldr x2, =val
 	ldr x1, [x2]
 	bl printf
 	ldr x30, [sp, #8]
 	add sp, sp, #16
 	br x30

 .data
 prt_str:
 	.ascii "X1 is %d \n\0"

 val:
 	.byte 0112
 	.end


