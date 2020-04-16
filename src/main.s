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
	.equ STATUS_SUCCESS, 0

.section .text

.global _start
_start:
	movl $SYS_EXIT, %eax		#kod komendy systemowej wyjscia
	call test
	int $0x80			#wywolanie komendy systemowej
