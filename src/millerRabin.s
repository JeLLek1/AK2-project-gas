#Test millera Rabina
#
#Dane:
# dataStartPtr - początek obszaru pamięci dla liczby testowanej
# dataLength - długość danych * 4 bajty
# millerTestCount - ilość testów Millera-Rabina
#
#Zmienne lokalne:
# dataTempPtr - kopia sprawdzanej liczby
# counterShift - liczba przesunięc przy podzieleniu przez 2
#
#stałe tekstowe:
# msg_info - informacja o typie algorytmu i o prawdopodobieństwie
# msg_no_prime - informacja wyswietlana, jezeli liczba nie jest pierwsza
# msg_prime - informacja wyswietlana, jezeli liczba jest pierwsza
#
#stałe:
# MSG_INFO_L - długość tekstu informacji
# MSG_NO_PRIME_L - długość tekstu, jeżeli liczba nie jest pierwsza
# MSG_PRIME_L - długość tekstu, jeżeli liczba jest pierwsza
# SYS_WRITE - kod wywołania systemowego zapisu do pliku
# STD_OUT - kod wyjścia terminala podczas zapisu

.section .data
	.equ SYS_WRITE, 4
	.equ STD_OUT, 1
	.equ dataTempPtr, -4
	.equ counterShift, -8
.section .text
msg_info:
	.ascii "\nTest Millera-Rabina:\nPrawdopodobienstwo bledu: 1/4^"
	.equ MSG_INFO_L, . - msg_info
msg_no_prime:
	.ascii "\nPodana liczba nie jest piewsza\n"
	.equ MSG_NO_PRIME_L, . - msg_no_prime
msg_prime:
	.ascii "\nPodana liczba jest piewsza\n"
	.equ MSG_PRIME_L, . - msg_prime

.global millerRabin

.type millerRabin, @function
millerRabin:
	pushl %ebp
	movl %esp, %ebp			#prolog funkcji (jakby trzeba bylo korzystac z argumentow
	subl $12, %esp			#miejsce na zmienne lokalne

	#wypisanie w terminalu informacji msg_info
	movl $SYS_WRITE, %eax
	movl $STD_OUT, %ebx
	movl $msg_info, %ecx
	movl $MSG_INFO_L, %edx
	int $0x80
	#=========================================
	#wypisanie w terminalu prawdopodobieństwa
	pushl millerTestCount		#argument
	call displayNumber
	addl $4, %esp			#zdjęcie argumentów ze stosu

	#alokacja pamięci dla kopii liczby testowanej
	movl dataLength, %eax
	shll $2, %eax				#długość w bajtach
	pushl %eax				#argumnet funkcji
	call allocate				#funkcja alokacji
	addl $4, %esp				#zdjęcie argumentu
	movl %eax, dataTempPtr(%ebp)		#wynik funkcji
	#==========================================
	
	#wskaźniki do rejestrów
	movl dataTempPtr(%ebp), %eax		#wskaźnik na początek kopii danych do rejestru
	movl dataStartPtr, %ecx			#wskaźnik na początek danych do rejestru

	#test czy nie parzysta
	movl dataLength, %esi
	decl %esi				#ostatnia komórka
	movl (%ecx,%esi,4), %ebx		#ostatnia komórka do %ebx
	shrl $1, %ebx
	jnc isNoPrime				#jeżeli zero to liczba podzielna przez 2, koniec algorytmu

	#kopia liczby testowanej
	movl $0, %esi				#początkowy indeks kopii
copyData:
	movl (%ecx,%esi,4), %ebx		#komórka do rejestru
	movl %ebx, (%eax, %esi, 4)		#z rejestru do komórki kopii
	incl %esi
	cmpl dataLength, %esi
	jb copyData				#dopóki %esi nie jest równe długości danych to kopiuj

	#odjęcie jeden
	movl dataLength, %esi
	decl %esi				#ostatnia komórka
	subl $1, (%eax, %esi, 4)		#odjęcie 1 od ostatniej komórki (Liczba nieparzysta więc nie trzeba się martwić o resztę komórek)

	#podzielenie przez 2 tyle razy ile się da
	movl $0, counterShift(%ebp)		#ilość przesunięć na początku równa 0
shiftIfNo1:
	movl dataLength, %esi
	decl %esi				#indeks ostatniej komórki
	movl dataTempPtr(%ebp), %eax
	movl (%eax, %esi, 4), %eax		#ostatnia komórka
	shrl $1, %eax
	jc shiftIfNo1Skip			#jeżeli niepodzielna przez 2 to kniec pętli
	incl counterShift(%ebp)			#zwiększenie licznika przesunięć
	pushl dataTempPtr(%ebp)			#pierwszy argument funkcji
	pushl dataLength			#drugi argument funkcji
	call shiftOne				#przesunięcie liczby w prawo o 1
	jmp shiftIfNo1 				#kolejna iteracja
shiftIfNo1Skip:
	#od teraz można zapisać liczbę w dataStartPtr jako
	#1+(2^counterShift(%ebp))*dataTempPtr(%ebp)
	#gdzie dataTempPtr(%ebp) jest nieparzyste

	#pętla testów Millera Rabina
testCountLoop:
	
	decl millerTestCount
	cmpl $0, millerTestCount
	jne testCountLoop

	#wypisanie w terminalu informacji msg_prime
	movl $SYS_WRITE, %eax
	movl $STD_OUT, %ebx
	movl $msg_prime, %ecx
	movl $MSG_PRIME_L, %edx
	int $0x80
	#=========================================
	jmp isPrimeEnd

isNoPrime:
	#wypisanie w terminalu informacji msg_no_prime
	movl $SYS_WRITE, %eax
	movl $STD_OUT, %ebx
	movl $msg_no_prime, %ecx
	movl $MSG_NO_PRIME_L, %edx
	int $0x80
	#=========================================
isPrimeEnd:

	#zwalnianie pamięci zabranej przez kopię testowanej liczby
	movl dataLength, %eax
	shll $2, %eax			#długość w bajtach
	negl %eax			#negacja długości w bajtach
	pushl %eax			#argumnet funkcji
	call allocate			#funkcja alokacji
	addl $4, %esp			#zdjęcie argumentu
	#===============================================================

	movl %ebp, %esp			#odtworzenie starego stosu
	popl %ebp
	ret
