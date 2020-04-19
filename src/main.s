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
dataStartPtr: .long 0
dataLength: .long 0
rootStartPtr: .long 0

.section .text

.global _start, dataStartPtr, dataLength, rootStartPtr, rootLength
_start:

	call termLoad			#wczytanie danych

	call root			#obliczenie pierwiastka do późniejszych obliczeń

	movl $SYS_EXIT, %eax		#kod komendy systemowej wyjscia
	xorl %ebx, %ebx			#zwraca status 0
	int $0x80			#wywolanie komendy systemowej
