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
dataStartWsk: .long 0
dataLength: .long 0

.section .text

.global _start, dataStartWsk, dataLength
_start:

	call termLoad
	movl $SYS_EXIT, %eax		#kod komendy systemowej wyjscia
	xorl %ebx, %ebx			#zwraca status 0
	int $0x80			#wywolanie komendy systemowej
