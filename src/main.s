#Projekt AK2
#Sprawdzanie pierwszości wielkich liczb
#
#
#
#
#
#
#
.section .data
	.equ SYS_EXIT, 1

.section .text

.global _start
_start:
	call termLoad
	movl $SYS_EXIT, %eax		#kod komendy systemowej wyjscia
	xorl %ebx, %ebx			#zwraca status 0
	int $0x80			#wywolanie komendy systemowej
