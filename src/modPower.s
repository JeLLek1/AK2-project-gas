#algorytm wyliczania (a^e) mod n
#
#argumenty funkcji
# a - argument a (podstawa potęgi)
# e - argument e (wykładnik potęgi)
# n - argument n (mianownik modulo)
# result - wskaźnik na wynik
#
#zmienne lokalne:
# mask - maska bitowa
# remainder - reszta kolejnych potęg modulo
# tmp - zmienna pomocnicza podczas liczenia 

.section .data
	.equ a, 8
	.equ e, 12
	.equ n, 16
	.equ result, 20
	.equ mask, -4
	.equ remainder, -8
	.equ tmp, -12
.section .text

.global modPower

.type modPower, @function
modPower:
	push %ebp
	mov %esp, %ebp			#nowa ramka call
	subl $16, %esp			#miejsce na zmienne lokalne

	pushl %esi              	# zapisanie rejestrów lokalnych
	pushl %ebx              	# zapisanie rejestrów lokalnych

	#alokacja pamięci dla maski
	movl dataLength, %eax
	shll $2, %eax				#długość w bajtach
	pushl %eax				#argumnet funkcji
	call allocate				#funkcja alokacji
	addl $4, %esp				#zdjęcie argumentu
	movl %eax, mask(%ebp)			#wynik funkcji
	#==========================================

	#alokacja pamięci dla remainder
	movl dataLength, %eax
	shll $2, %eax				#długość w bajtach
	pushl %eax				#argumnet funkcji
	call allocate				#funkcja alokacji
	addl $4, %esp				#zdjęcie argumentu
	movl %eax, remainder(%ebp)		#wynik funkcji
	#==========================================

	#alokacja pamięci dla tmp
	movl dataLength, %eax
	shll $2, %eax				#długość w bajtach
	pushl %eax				#argumnet funkcji
	call allocate				#funkcja alokacji
	addl $4, %esp				#zdjęcie argumentu
	movl %eax, tmp(%ebp)			#wynik funkcji
	#==========================================

	movl mask(%ebp), %eax			#wskaźnik na maskę do rejestru
	movl result(%ebp), %edx			#wskaźnik na wynik do rejestru
	movl dataLength, %esi
	decl %esi				#ostatnia komórka maski i wyniku
	movl $1, (%eax, %esi, 4)		#na ostatniej pozycji maski 1
	movl $1, (%edx, %esi, 4)		#na ostatniej pozycji wyniku 1 
	#wypełnianie reszty maski i wyniku zerami
fillMask:
	cmpl $0, %esi
	je fillMaskSkip				#jeżeli indeks 0 to koniec wypełniania
	decl %esi				#zmniejszenie indeksu
	movl $0, (%eax, %esi, 4)		#wypełnienie zerem maski
	movl $0, (%edx, %esi, 4)		#wypełnienie zerem wyniku
	jmp fillMask
fillMaskSkip:

	#kopiowanie parametru a
	movl $0, %esi				#indeks na 0
	movl a(%ebp), %eax			#wskaźnik na argument a do rejestru
	movl remainder(%ebp), %edx		#wskaźnik na kopię argumentu a do rejestru
copyA:
	movl (%eax, %esi, 4), %ebx		#przechowanie wartości argumentu a
	movl %ebx, (%edx, %esi, 4)		#przeniesienie argumentu a do tmp
	incl %esi
	cmpl dataLength, %esi
	jb copyA 				#kopiuj dopuki indeks mniejszy od długości danych
	#======================


	#pętla kolejnych obliczeń
modPowerLoop:
	
	#test czy maska=/=0
	movl mask(%ebp), %eax			#wskaźnik na maskę do rejestru
	movl $0, %esi
testMask:
	cmpl $0, (%eax, %esi, 4)
	jne testMaskSkip			#jeżeli jakikolwiek element różny od 0 to powtarzaj algorytm
	incl %esi				#zwiększenie indeksu
	cmpl dataLength, %esi
	jb testMask 				#dopóki nie sprawdzono całej maski powtarzaj
	jmp modPowerLoopSkip			#jeżeli cała maska równa 0 to koniec algorytmu
testMaskSkip:
	#=======================

	#test czy (maska & e) =/= 0
	movl $0, %esi				#ustawienie indeksu
	movl mask(%ebp), %eax			#wskaźnik na maskę do rejestru
	movl e(%ebp), %edx			#wskaźnik na e do rejestru
checkWithMask:
	movl (%eax, %esi, 4), %ebx		#element maski do rejestru
	andl (%edx, %esi, 4), %ebx		#operacja and na elemencie maski i argumencie e
	cmpl $0, %ebx 
	jne checkWithMaskSkip			#jeżeli operacja and różna od zera to koniec sprawdzania
	incl %esi				#zwiększenie licznika
	cmpl dataLength, %esi
	jb checkWithMask 			#dopóki indeks mniejszy od długości danych, sprawdzaj
	jmp checkWithMaskNot 			#jeżeli (maska & e) == 0 to pomiń operację
checkWithMaskSkip:
	#========================

	#obliczanie tmp = (result * remainder) mod n
	pushl tmp(%ebp) 
	pushl n(%ebp)
	pushl remainder(%ebp)
	pushl result(%ebp)			
	call modMul
    	addl $16, %esp	
    	#===========================================

    	#kopiowanie tmp do result
	movl $0, %esi				#indeks od 0
	movl result(%ebp), %eax			#wskaźnik na result do rejestru
	movl tmp(%ebp), %edx			#wskaźnik na tmp do rejestru
copyTempRes:
	movl (%edx, %esi, 4), %ebx		#przechowanie wartości w rejestrze
	movl %ebx, (%eax, %esi, 4)		#przeniesienie wartości z tmp do result
	incl %esi				#zwiększenie indeksu
	cmpl dataLength, %esi
	jb copyTempRes 				#dopóki indeks mniejszy od długości powtarzaj kopiowanie
    	#========================

	checkWithMaskNot:

	#obliczanie tmp = (remainder * remainder) mod n
	pushl tmp(%ebp) 
	pushl n(%ebp)
	pushl remainder(%ebp)
	pushl remainder(%ebp)			
	call modMul
    	addl $16, %esp	
    	#===========================================

    	#kopiowanie tmp do remainder
	movl $0, %esi				#indeks od 0
	movl remainder(%ebp), %eax		#wskaźnik na remainder do rejestru
	movl tmp(%ebp), %edx			#wskaźnik na tmp do rejestru
copyTempRem:
	movl (%edx, %esi, 4), %ebx		#przechowanie wartości w rejestrze
	movl %ebx, (%eax, %esi, 4)		#przeniesienie wartości z tmp do remainder
	incl %esi				#zwiększenie indeksu
	cmpl dataLength, %esi
	jb copyTempRem 				#dopóki indeks mniejszy od długości powtarzaj kopiowanie
    	#========================

    	#przesunięcie bitowe maski w lewo
	pushl dataLength 			#długość elementu
	pushl mask(%ebp)			#element do przesunięcia
	call shiftOneLeft
    	addl $8, %esp				#pobranie ze stosu argumentów
	#================================

	jmp modPowerLoop
modPowerLoopSkip:


	#zwalnianie pamięci zabranej przez tmp
	movl dataLength, %eax
	shll $2, %eax			#długość w bajtach
	negl %eax			#negacja długości w bajtach
	pushl %eax			#argumnet funkcji
	call allocate			#funkcja alokacji
	addl $4, %esp			#zdjęcie argumentu
	#===============================================================

	#zwalnianie pamięci zabranej przez remainder
	movl dataLength, %eax
	shll $2, %eax			#długość w bajtach
	negl %eax			#negacja długości w bajtach
	pushl %eax			#argumnet funkcji
	call allocate			#funkcja alokacji
	addl $4, %esp			#zdjęcie argumentu
	#===============================================================

	#zwalnianie pamięci zabranej przez maske
	movl dataLength, %eax
	shll $2, %eax			#długość w bajtach
	negl %eax			#negacja długości w bajtach
	pushl %eax			#argumnet funkcji
	call allocate			#funkcja alokacji
	addl $4, %esp			#zdjęcie argumentu
	#===============================================================

	popl %ebx
   	popl %esi

	movl %ebp, %esp
	popl %ebp			#Przwywrócenie starej ramki call
	ret
