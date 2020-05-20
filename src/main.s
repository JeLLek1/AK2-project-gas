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
dzielnikStartPtr: .long 0
ilorazStartPtr: .long 0x0, 0x0
resztaStartPtr: .long 0

.section .text

.global _start, dataStartPtr, dataLength, rootStartPtr, rootLength
_start:

	call termLoad			#wczytanie danych

	call root			#obliczenie pierwiastka do późniejszych obliczeń

	movl $2, %eax
	shll $2, %eax				#długość w bajtach
	pushl %eax				#argumnet funkcji
	call allocate				#funkcja alokacji
	addl $4, %esp				#zdjęcie argumentu
	movl %eax, dzielnikStartPtr		#wynik funkcji

	movl $2, %eax
	shll $2, %eax				#długość w bajtach
	pushl %eax				#argumnet funkcji
	call allocate				#funkcja alokacji
	addl $4, %esp				#zdjęcie argumentu
	movl %eax, resztaStartPtr		#wynik funkcji

	movl dataLength, %eax
	shll $2, %eax				#długość w bajtach
	pushl %eax				#argumnet funkcji
	call allocate				#funkcja alokacji
	addl $4, %esp				#zdjęcie argumentu
	movl %eax, ilorazStartPtr		#wynik funkcji

	#movl dzielnikStartPtr, %eax
	movl dzielnikStartPtr, %eax
	movl $0x1, (%eax)
	movl $0x0, 4(%eax)

	pushl $2
	pushl resztaStartPtr
	pushl $2
	pushl ilorazStartPtr
	pushl $2
	pushl dzielnikStartPtr
	call bindiv
	addl $24, %esp

	movl $SYS_EXIT, %eax		#kod komendy systemowej wyjscia
	xorl %ebx, %ebx			#zwraca status 0
	int $0x80			#wywolanie komendy systemowej
