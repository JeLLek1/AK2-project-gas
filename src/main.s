#Projekt AK2
#Sprawdzanie pierwszości wielkich liczb
#
#Zmienne globalne:
# dataStartPtr - wskaźnik na początek liczby testowanej
# dataLength - ilość dword liczby testowanej
# rootStartPtr - wskaźnik na początek pierwiastka
# millerTestCount - liczba testów Millera-Rabina
# 
#
.section .data
	.equ SYS_EXIT, 1

dataStartPtr: .long 0
dataLength: .long 0
rootStartPtr: .long 0
millerTestCount: .long 0
dzielnikStartPtr: .long 0
ilorazStartPtr: .long 0x0, 0x0
resztaStartPtr: .long 0

.section .text

.global _start, dataStartPtr, dataLength, rootStartPtr, rootLength, millerTestCount
_start:

	call termLoad			#wczytanie danych

	call root			#obliczenie pierwiastka do późniejszych obliczeń

	call naiveAproach		#naiwne podejście

	#call millerRabin 		#test Millera-Rabina

	movl $SYS_EXIT, %eax		#kod komendy systemowej wyjscia
	xorl %ebx, %ebx			#zwraca status 0
	int $0x80			#wywolanie komendy systemowej
