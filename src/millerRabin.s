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
# randomNumber - liczba pseudolosowa
# tmp - zmienna pomocnicza do obliczeń
# firstMiler - kolejne wyrazy ciągu Millera Rabina
# counterLoop - licznik obliczeń kolejnych wyrazów ciągu Millera Rabina
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
	.equ randomNumber, -12
	.equ tmp, -16
	.equ firstMiller, -20
	.equ counterLoop, -24
	.equ firstMillerTemp, -28
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
	subl $32, %esp			#miejsce na zmienne lokalne

	pushl %esi              	# zapisanie rejestrów lokalnych
	pushl %ebx              	# zapisanie rejestrów lokalnych

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

	#alokacja pamięci dla liczby losowej
	movl dataLength, %eax
	shll $2, %eax				#długość w bajtach
	pushl %eax				#argumnet funkcji
	call allocate				#funkcja alokacji
	addl $4, %esp				#zdjęcie argumentu
	movl %eax, randomNumber(%ebp)		#wynik funkcji
	#==========================================

	#alokacja pamięci dla liczby tmp
	movl dataLength, %eax
	shll $2, %eax				#długość w bajtach
	pushl %eax				#argumnet funkcji
	call allocate				#funkcja alokacji
	addl $4, %esp				#zdjęcie argumentu
	movl %eax, tmp(%ebp)			#wynik funkcji
	#==========================================
	
	#alokacja pamięci dla liczby firstMiller
	movl dataLength, %eax
	shll $2, %eax				#długość w bajtach
	pushl %eax				#argumnet funkcji
	call allocate				#funkcja alokacji
	addl $4, %esp				#zdjęcie argumentu
	movl %eax, firstMiller(%ebp)		#wynik funkcji
	#==========================================

	#alokacja pamięci dla liczby firstMillerTemp
	movl dataLength, %eax
	shll $2, %eax				#długość w bajtach
	pushl %eax				#argumnet funkcji
	call allocate				#funkcja alokacji
	addl $4, %esp				#zdjęcie argumentu
	movl %eax, firstMillerTemp(%ebp)	#wynik funkcji
	#==========================================
	
	#wskaźniki do rejestrów
	movl dataTempPtr(%ebp), %eax		#wskaźnik na początek kopii danych do rejestru
	movl dataStartPtr, %ecx			#wskaźnik na początek danych do rejestru

	#test, czy poniżej 3
	cmpl $1, dataLength
	ja skipCheckIfLow			#jeżeli długość większa od 1 to na pewno większa od 3
	cmpl $3, (%ecx)
	jbe testCountLoopEnd 			#jeżeli mniejsza lub równa 3 to jest pierwsza
skipCheckIfLow:

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
	decl %esi				#ostatnia komórka
	subl $1, (%eax, %esi, 4)		#odjęcie 1 od ostatniej komórki (Liczba nieparzysta więc nie trzeba się martwić o resztę komórek)

	#podzielenie przez 2 tyle razy ile się da
	movl $0, counterShift(%ebp)		#ilość przesunięć na początku równa 0
shiftIfNo1:
	decl %esi				#indeks ostatniej komórki
	movl dataTempPtr(%ebp), %eax
	movl (%eax, %esi, 4), %eax		#ostatnia komórka
	shrl $1, %eax
	jc shiftIfNo1Skip			#jeżeli niepodzielna przez 2 to kniec pętli
	incl counterShift(%ebp)			#zwiększenie licznika przesunięć
	pushl dataTempPtr(%ebp)			#pierwszy argument funkcji
	pushl dataLength			#drugi argument funkcji
	call shiftOne				#przesunięcie liczby w prawo o 1
	addl $8, %esp				#zdjęcie argumentów
	jmp shiftIfNo1 				#kolejna iteracja
shiftIfNo1Skip:
	#od teraz można zapisać liczbę w dataStartPtr jako
	#1+(2^counterShift(%ebp))*dataTempPtr(%ebp)
	#gdzie dataTempPtr(%ebp) jest nieparzyste

	call srand				#ustawienie seedu liczby pseudolosowej

	#pętla testów Millera Rabina
testCountLoop:
	
	cmpl $0, millerTestCount
	je testCountLoopEnd			#jeżeli ilość testów do zrobienia równa 0 to koniec

	#liczba pseudolosowa randomNumber <2; dataStartPtr-2>

	#odjęcie 3 od dataStartPtr
	pushl tmp(%ebp)				#wskaźnik na wynik
	pushl dataStartPtr 			#wskaśnik na odjemną
	pushl $3 				#odjemnik
	call subNumber				#wywołanie funkcji
	addl $12, %esp				#zdjęcie argumentów


	#generowanie liczby pseudolosowej <0; dataStartPtr-3>
	pushl tmp(%ebp)				#wskaźnik na dzielnik liczby pseudolosowej
	pushl randomNumber(%ebp)		#wskaźnik na wynik liczby pseudolosowej
	call lessrand				#funkcja losująca
	addl $8, %esp				#zdjęcie argumentów ze stosu
	#dodanie 2 do wyniku
	movl dataLength, %esi			#ustawienie indeksu
	movl randomNumber(%ebp), %eax		#wskaźnik na randomNumber do rejestru
	decl %esi				#ostatnia pozycja
	addl $2, (%eax, %esi, 4)		#dodanie 2 do wyniku
	pushf					#zachowanie flag
add2ToRandom:
	cmpl $0, %esi
	je add2ToRandomSkip			#wykonuj dopóki indeks różny od 0
	decl %esi				#zmniejszenie indeksu
	popf 					#pobranie flag ze stosu
	adcl $0, %ebx				#dodanie flagi, jeżeli jest
	pushf
	movl %ebx, (%edx, %esi, 4)		#przeniesienie wyniku do tmp
	jmp add2ToRandom
add2ToRandomSkip:
	popf					#pobranie ostatniej flagi ze stosu
	#==================================================

	#firstMiller = (randomNumber^dataTempPtr) mod dataStartPtr
	pushl firstMiller(%ebp)			#wynik potęgi modulo
	pushl dataStartPtr 			#dzielnik
	pushl dataTempPtr(%ebp) 		#wykładnik potęgi
	pushl randomNumber(%ebp) 		#podstawa potęgi
	call modPower				#wywołanie funkcji
	addl $16, %esp				#zdjęcie argumentów
	#=======================================================

	#czy firstMiller==1
	movl dataLength, %esi			#ustawienie indeksu
	decl %esi				#ostatnia pozycja
	movl firstMiller(%ebp), %eax		#wskaźnik na firstMiller do rejestru
	cmpl $1, (%eax, %esi, 4)
	jne testIf1Skip				#jeżeli ostatni wyraż rózny od 0 to różn
testIf1:
	cmpl $0, %esi
	je continueTest 			#jeżeli wszyskie elementy są rózne od 0 to kolejna iteracja
	decl %esi				#zmniejszenie indeksu
	cmpl $0, (%eax, %esi, 4)
	jne testIf1Skip				#jeżeli rózne od zera to koniec testu
	jmp testIf1				#powtórz iteracje
testIf1Skip:
	#==================

	#czy firstMiller==dataStartPtr-1 (tmp)

	#odjęcie 1 od dataStartPtr
	pushl tmp(%ebp)				#wskaźnik na wynik
	pushl dataStartPtr 			#wskaśnik na odjemną
	pushl $1 				#odjemnik
	call subNumber				#wywołanie funkcji
	addl $12, %esp				#zdjęcie argumentów

	pushl firstMiller(%ebp)			#pierwsza liczba testowana
	pushl tmp(%ebp)				#druga liczba testowana
	call isEqual 				#czy firstMiller==tmp
	addl $8, %esp				#zdjęcie argumentów ze stosu
	cmpl $1, %eax
	je continueTest				#jeżeli równe to pomiń iteracje
	#===============================

	#generowanie kolejnych wyrazów Millera Rabina
	movl $1, counterLoop(%ebp)		#zainicjowanie licznika wyliczeń
millerNextLoop:
	movl counterLoop(%ebp), %eax		#przeniesienie licznika do rejestru
	cmpl %eax, counterShift(%ebp)
	jbe testIfNoPrime 			#jeżeli counterShift<=counterLoop to koniec wyrazów

	pushl firstMiller(%ebp)			#pierwsza liczba testowana
	pushl tmp(%ebp)				#druga liczba testowana
	call isEqual 				#czy firstMiller==tmp
	addl $8, %esp				#zdjęcie argumentów ze stosu
	cmpl $1, %eax
	je testIfNoPrime			#jeżeli równe to koniec wyrazów 

	#obliczanie firstMillerTemp = (firstMiller * firstMiller) mod dataStartPtr
	pushl firstMillerTemp(%ebp) 
	pushl dataStartPtr
	pushl firstMiller(%ebp)
	pushl firstMiller(%ebp)			
	call modMul
    	addl $16, %esp	
    	#===========================================

    	#kopiowanie firstMillerTemp do firstMiller
	movl $0, %esi				#indeks od 0
	movl firstMiller(%ebp), %eax		#wskaźnik na firstMiller do rejestru
	movl firstMillerTemp(%ebp), %edx	#wskaźnik na firstMillerTemp do rejestru
copyTempRes:
	movl (%edx, %esi, 4), %ebx		#przechowanie wartości w rejestrze
	movl %ebx, (%eax, %esi, 4)		#przeniesienie wartości z firstMillerTemp do firstMiller
	incl %esi				#zwiększenie indeksu
	cmpl dataLength, %esi
	jb copyTempRes 				#dopóki indeks mniejszy od długości powtarzaj kopiowanie
    	#========================

    	#czy firstMiller==1
	movl dataLength, %esi			#ustawienie indeksu
	decl %esi				#ostatnia pozycja
	movl firstMiller(%ebp), %eax		#wskaźnik na firstMiller do rejestru
	cmpl $1, (%eax, %esi, 4)
	jne testIf1Skipin			#jeżeli ostatni wyraż rózny od 0 to różn
testIf1in:
	cmpl $0, %esi
	je testCountLoopEnd 			#jeżeli wszyskie elementy są rózne od 0 to ostatni wyraz ciągu millera (pierwsza)
	decl %esi				#zmniejszenie indeksu
	cmpl $0, (%eax, %esi, 4)
	jne testIf1Skipin			#jeżeli rózne od zera to koniec testu
	jmp testIf1in				#powtórz iteracje
testIf1Skipin:
	#==================

	incl counterLoop(%ebp)			#zwiększenie licznika wyrazów Millera Rabina
	jmp millerNextLoop
	#============================================
testIfNoPrime:
	pushl firstMiller(%ebp)			#pierwsza liczba testowana
	pushl tmp(%ebp)				#druga liczba testowana
	call isEqual 				#czy firstMiller==tmp
	addl $8, %esp				#zdjęcie argumentów ze stosu
	cmpl $0, %eax
	je isNoPrime 				#jeżeli firstMiller=/=tmp to nie jest pierwsza
continueTest:
	decl millerTestCount			#zmniejszenie pozostałych testów
	jmp testCountLoop
testCountLoopEnd:

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

	#zwalnianie pamięci zabranej przez firstMillerTemp
	movl dataLength, %eax
	shll $2, %eax			#długość w bajtach
	negl %eax			#negacja długości w bajtach
	pushl %eax			#argumnet funkcji
	call allocate			#funkcja alokacji
	addl $4, %esp			#zdjęcie argumentu
	#===============================================================

	#zwalnianie pamięci zabranej przez firstMiller
	movl dataLength, %eax
	shll $2, %eax			#długość w bajtach
	negl %eax			#negacja długości w bajtach
	pushl %eax			#argumnet funkcji
	call allocate			#funkcja alokacji
	addl $4, %esp			#zdjęcie argumentu
	#===============================================================

	#zwalnianie pamięci zabranej przez tmp
	movl dataLength, %eax
	shll $2, %eax			#długość w bajtach
	negl %eax			#negacja długości w bajtach
	pushl %eax			#argumnet funkcji
	call allocate			#funkcja alokacji
	addl $4, %esp			#zdjęcie argumentu
	#===============================================================

	#zwalnianie pamięci zabranej przez liczbę pseudolosową
	movl dataLength, %eax
	shll $2, %eax			#długość w bajtach
	negl %eax			#negacja długości w bajtach
	pushl %eax			#argumnet funkcji
	call allocate			#funkcja alokacji
	addl $4, %esp			#zdjęcie argumentu
	#===============================================================

	#zwalnianie pamięci zabranej przez kopię testowanej liczby
	movl dataLength, %eax
	shll $2, %eax			#długość w bajtach
	negl %eax			#negacja długości w bajtach
	pushl %eax			#argumnet funkcji
	call allocate			#funkcja alokacji
	addl $4, %esp			#zdjęcie argumentu
	#===============================================================

	popl %ebx
   	popl %esi

	movl %ebp, %esp			#odtworzenie starego stosu
	popl %ebp
	ret
