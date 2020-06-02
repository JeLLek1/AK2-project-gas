#algorytm wyliczania (a*b) mod n
#
#argumenty funkcji
# a - argument a (pierwszy składnik iloczynu)
# b - argument b (drugi składnik iloczynu)
# n - argument n (mianownik modulo)
# result - wskaźnik na wynik
#
#zmienne lokalne:
# mask - maska bitowa
# resultTmp - kopia wyniku mnożenia modulo potrzebna do obliczeń
# aTmp - kopia argumentu a potrzebna do obliczeń (aby nie zepsuć argumentu a)
# aTmp1 - druga kopia argumentu a potrzebna do obliczeń
#

.section .data
	.equ mask, -4
	.equ resultTmp, -8
	.equ aTmp, -12
	.equ aTmp1, -16
	.equ a, 8
	.equ b, 12
	.equ n, 16
	.equ result, 20
.section .text

.global modMul

.type modMul, @function
modMul:
	push %ebp
	mov %esp, %ebp			#nowa ramka call
	subl $20, %esp			#miejsce na zmienne lokalne

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

	#alokacja pamięci dla kopii wyniku
	movl dataLength, %eax
	shll $2, %eax				#długość w bajtach
	pushl %eax				#argumnet funkcji
	call allocate				#funkcja alokacji
	addl $4, %esp				#zdjęcie argumentu
	movl %eax, resultTmp(%ebp)		#wynik funkcji
	#==========================================

	#alokacja pamięci dla kopii a
	movl dataLength, %eax
	shll $2, %eax				#długość w bajtach
	pushl %eax				#argumnet funkcji
	call allocate				#funkcja alokacji
	addl $4, %esp				#zdjęcie argumentu
	movl %eax, aTmp(%ebp)			#wynik funkcji
	#==========================================

	#alokacja pamięci dla drugiej kopii a
	movl dataLength, %eax
	shll $2, %eax				#długość w bajtach
	pushl %eax				#argumnet funkcji
	call allocate				#funkcja alokacji
	addl $4, %esp				#zdjęcie argumentu
	movl %eax, aTmp1(%ebp)			#wynik funkcji
	#==========================================


	movl mask(%ebp), %eax			#wskaźnik na maskę do rejestru
	movl result(%ebp), %edx			#wskaźnik na wynik do rejestru
	movl dataLength, %esi
	decl %esi				#ostatnia komórka maski i wyniku
	movl $1, (%eax, %esi, 4)		#na ostatniej pozycji maski 1
	movl $0, (%edx, %esi, 4)		#na ostatniej pozycji wyniku 0 
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
	movl aTmp(%ebp), %edx			#wskaźnik na kopię argumentu a do rejestru
copyA:
	movl (%eax, %esi, 4), %ebx		#przechowanie wartości argumentu a
	movl %ebx, (%edx, %esi, 4)		#przeniesienie argumentu a do aTmp
	incl %esi
	cmpl dataLength, %esi
	jb copyA 				#kopiuj dopuki indeks mniejszy od długości danych
	#======================

	#pętla kolejnych obliczeń
modMulLoop:

	#test czy maska=/=0
	movl mask(%ebp), %eax			#wskaźnik na maskę do rejestru
	movl $0, %esi
testMask:
	cmpl $0, (%eax, %esi, 4)
	jne testMaskSkip			#jeżeli jakikolwiek element różny od 0 to powtarzaj algorytm
	incl %esi				#zwiększenie indeksu
	cmpl dataLength, %esi
	jb testMask 				#dopóki nie sprawdzono całej maski powtarzaj
	jmp modMulLoopSkip			#jeżeli cała maska równa 0 to koniec algorytmu
testMaskSkip:
	#=======================

	#test czy (maska & b) =/= 0
	movl $0, %esi				#ustawienie indeksu
	movl mask(%ebp), %eax			#wskaźnik na maskę do rejestru
	movl b(%ebp), %edx			#wskaźnik na b do rejestru
checkWithMask:
	movl (%eax, %esi, 4), %ebx		#element maski do rejestru
	andl (%edx, %esi, 4), %ebx		#operacja and na elemencie maski i argumencie b
	cmpl $0, %ebx 
	jne checkWithMaskSkip			#jeżeli operacja and różna od zera to koniec sprawdzania
	incl %esi				#zwiększenie licznika
	cmpl dataLength, %esi
	jb checkWithMask 			#dopóki indeks mniejszy od długości danych, sprawdzaj
	jmp checkWithMaskNot 			#jeżeli (maska & b) == 0 to pomiń operację
checkWithMaskSkip:
	#========================

	#dodanie a do wyniku
	movl dataLength, %esi			#ustawienie indeksu
	movl result(%ebp), %eax			#wskaźnik na result do rejestru
	movl aTmp(%ebp), %edx			#wskaźnik na a do rejestru
	clc					#wyczyszczenie flagi przeniesienia
	pushf					#odłożenie flag na stos
addToResult:
	decl %esi				#zmniejszenie indeksu
	movl (%edx, %esi, 4), %ebx		#przeniesienie a (pierwszego składnika sumy) do rejestru
	popf 					#pobranie flag ze stosu
	adcl %ebx, (%eax, %esi, 4)		#dodania do wyniku argumentu a
	pushf 					#odłożenie flag na stos
	cmpl $0, %esi
	jne addToResult 			#dopóki indeks =/= 0 powtarzaj dodawanie
	popf					#pobranie flag ze stosu (czyszczenie stosu)
	#===================

	#reszta z dzielenia wyniku przez n
	pushl dataLength			#długość licznika
	pushl result(%ebp)			#licznik
	pushl dataLength			#długość reszty
	pushl resultTmp(%ebp)			#reszta
	pushl dataLength			#długość mianownika
	pushl n(%ebp)				#mianownik
	call bindiv 				
	addl $24, %esp
	#=================================

	#skopiowanie reszty do wyniku
	movl $0, %esi				#indeks od 0
	movl result(%ebp), %eax			#wskaźnik na result do rejestru
	movl resultTmp(%ebp), %edx		#wskaźnik na resultTmp do rejestru
copyTempRes:
	movl (%edx, %esi, 4), %ebx		#przechowanie wartości w rejestrze
	movl %ebx, (%eax, %esi, 4)		#przeniesienie wartości z resultTmp do result
	incl %esi				#zwiększenie indeksu
	cmpl dataLength, %esi
	jb copyTempRes 				#dopóki indeks mniejszy od długości powtarzaj kopiowanie
	#============================
checkWithMaskNot:

	#przesunięcie bitowo a w lewo
	pushl dataLength 			#długość elementu
	pushl aTmp(%ebp)			#element do przesunięcia
	call shiftOneLeft
    	addl $8, %esp				#pobranie ze stosu argumentów
	#============================

	#reszta z dzielenia a%n
	pushl dataLength			#długość licznika
	pushl aTmp(%ebp)			#licznik
	pushl dataLength			#długość reszty
	pushl aTmp1(%ebp)			#reszta
	pushl dataLength			#długość mianownika
	pushl n(%ebp)				#mianownik
	call bindiv 				
	addl $24, %esp
	#======================

	#skopiowanie reszty do aTmp
	movl $0, %esi				#indeks od 0
	movl aTmp(%ebp), %eax			#wskaźnik na result do rejestru
	movl aTmp1(%ebp), %edx			#wskaźnik na resultTmp do rejestru
copyTempA:
	movl (%edx, %esi, 4), %ebx		#przechowanie wartości w rejestrze
	movl %ebx, (%eax, %esi, 4)		#przeniesienie wartości z resultTmp do result
	incl %esi				#zwiekszenie indeksu
	cmpl dataLength, %esi
	jb copyTempA 				#dopóki indeks mniejszy od długości powtarzaj kopiowanie
	#============================

	#przesunięcie bitowe maski w lewo
	pushl dataLength 			#długość elementu
	pushl mask(%ebp)			#element do przesunięcia
	call shiftOneLeft
    	addl $8, %esp				#pobranie ze stosu argumentów
	#================================

	jmp modMulLoop
modMulLoopSkip:

	#zwalnianie pamięci zabranej przez drugą kopię a
	movl dataLength, %eax
	shll $2, %eax			#długość w bajtach
	negl %eax			#negacja długości w bajtach
	pushl %eax			#argumnet funkcji
	call allocate			#funkcja alokacji
	addl $4, %esp			#zdjęcie argumentu
	#===============================================================

	#zwalnianie pamięci zabranej przez kopię s
	movl dataLength, %eax
	shll $2, %eax			#długość w bajtach
	negl %eax			#negacja długości w bajtach
	pushl %eax			#argumnet funkcji
	call allocate			#funkcja alokacji
	addl $4, %esp			#zdjęcie argumentu
	#===============================================================

	#zwalnianie pamięci zabranej przez kopię wyniku
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
	