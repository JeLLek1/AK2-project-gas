#Obliczanie pierwiastka kwadratowego liczby dataStartWsk
#schemat pierwiastka taki, jak na zajęciach AK1(binarny cyfra po cyfrze)
#
#Dane:
# dataStartWsk - początek obszaru pamięci dla pierwiastka do obliczenia
# dataLength - długość danych * 4 bajty
#
#Wynik:
# rootStartWsk - początek obszatu pamięci dla wyniku
#
#Zmienne lokalne:
# numberTempPtr - wskaźnik początku kopii liczby pierwiastkowanej
# bit - zawsze 1 bit na danej pozycji 32 bitowej
# bitIndex - indeks segmentu danych
# ifCarry - podczas przesunięcia w prawo przechowywane czy ma zostać dodany ostatni bit

.section .data
	.equ numberTempPtr, -4
	.equ bit, -8
	.equ bitIndex, -12
.section .text

.global root

.type root, @function
root:
	pushl %ebp
	movl %esp, %ebp			#prolog funkcji (jakby trzeba bylo korzystac z argumentow
	subl $16, %esp			#miejsce na zmienne lokalne

	#alokacja pamięci dla wyniku
	movl dataLength, %eax
	shll $2, %eax			#długość w bajtach
	pushl %eax			#argumnet funkcji
	call allocate			#funkcja alokacji
	addl $4, %esp			#zdjęcie argumentu
	movl %eax, rootStartPtr		#wynik funkcji
	#===========================

	#alokacja pamięci dla kopii liczby pierwiastkowanej i kopiowanie danych + czyszczenie wyniku
	movl dataLength, %eax
	shll $2, %eax				#długość w bajtach
	pushl %eax				#argumnet funkcji
	call allocate				#funkcja alokacji
	addl $4, %esp				#zdjęcie argumentu
	movl %eax, numberTempPtr(%ebp)		#wynik funkcji

	movl dataLength, %esi
	movl dataStartPtr, %edx			#przeniesienie adresu początku do rejestru
	movl numberTempPtr(%ebp), %ecx		#przeniesienie atresu początku temp do rejestru
	movl rootStartPtr, %ebx			#przeniesienie adresu początku root do rejestru
copyToTemp:
	decl %esi
	movl (%edx,%esi,4), %eax
	movl %eax, (%ecx,%esi,4)		#skopiowanie wartości do pamięci temp
	movl $0, (%ebx,%esi,4)			#czyść miejsce na wynik pierwiastka
	cmpl $0, %esi				#wykonuj dopuki(%eax>0)
	jg copyToTemp
	#===========================

	#Wyliczenie pierwszej 1 różnicy (zmiana co 4 potęgę)
	movl $0x40000000, bit(%ebp)		#ustawienie przedostatniego bitu (0100...0)
	movl $0, bitIndex(%ebp)			#indeks bitu jest równy końcowi danych

	movl dataStartPtr, %eax
	movl (%eax), %eax			#wczytanie najwyższej pozycji liczby
	#bit będzie przesuwany o 2 w prawo aż będzie mniejszy lub równy liczbie.
	#z racji że jakaś liczba zawsze jest w indeksie 0 to wystarczy tylko ten indeks sprawdzić
searchHiPow4:
	cmpl bit(%ebp), %eax
	jae skipSearchHiPow4			#jeżeli %eax większe lub równe od ustawianego bitu to przestań przesuwać bit
	shrl $2, bit(%ebp)			#przesunięcie bitu o dwa w prawo
	jmp searchHiPow4
skipSearchHiPow4:
	#===================================================




	#obliczanie pierwiastka
	movl rootStartPtr, %edx			#przeniesienie adresu początku root do rejestru
	movl numberTempPtr(%ebp), %ecx		#przeniesienie atresu początku temp do rejestru
	movl bitIndex(%ebp), %eax		#przenieś indeks bitu do rejestru
rootLoop:
	movl bitIndex(%ebp), %eax		#przenieś indeks bitu do rejestru
	movl bit(%ebp), %ebx
	addl %ebx, (%edx,%eax,4)		#dodaj bit do wyniku
	
	#czy temp jest większe lub równe wynikowi
	movl $0, %esi
rootIfLower:
	movl (%ecx, %esi, 4), %eax		#przenieś segment danych temp o indeksie tem do rejestru
	cmpl (%edx, %esi, 4), %eax		#porównaj temp do wyniku
	ja tempGreater				#jezeli wieksze
	jb tempLower 				#jezeli mniejsze
	incl %esi				#inkrementacja indeksu
	#jezeli rowne to sprawdzaj dalej. jezeli do konca rowne to zrob to samo co w tempGreater
	cmpl dataLength, %esi			#dopóki indeks mniejszy niż długość danych
	jb rootIfLower
tempGreater:
	#1
	#odejmowanie temp = temp - (wynik+bit)
	clc					#cztszczenie flagi
	pushf					#dodanie flagi na stos
	movl dataLength, %esi			#przenieś długość danych do rejestru
subtractTemp:
	decl %esi				#zmniejszenie indeksu
	movl (%edx, %esi, 4), %eax		#przeniesienie części wyniku do rejestru
	popf
	sbbl %eax, (%ecx, %esi, 4)		#odjęcie od części temp część wyniku
	pushf
	cmpl $0, %esi
	jg subtractTemp				#dopuki indeks większy od 0 to odejmuj
	popf					#ściągnij flagę ze stosu (żeby nie leżała tam a i tak się nie przyda - warunek rootIfLower spełniony to liczba i tak nie będzie ujemna)

	movl bitIndex(%ebp), %eax		#przenieś indeks bitu do rejestru
	movl bit(%ebp), %ebx			#przeniesienie bitu do rejestru
	subl %ebx, (%edx,%eax,4)		#odjęcie bitu od wyniku

	pushl rootStartPtr			#pierwszy argument funkcji
	pushl dataLength			#drugi argument funkcji
	call shiftOne				#przesunięcie liczby w prawo o 1
	addl $8, %esp				#usunięcie ze stosu argumentów funkcji

	movl bitIndex(%ebp), %eax		#przenieś indeks bitu do rejestru
	movl bit(%ebp), %ebx			#przeniesienie bitu do rejestru
	addl %ebx, (%edx,%eax,4)		#dodanie bitu od wyniku

	jmp tempSkipLower
tempLower:
	#2
	movl bitIndex(%ebp), %eax		#przenieś indeks bitu do rejestru
	movl bit(%ebp), %ebx			#przeniesienie bitu do rejestru
	subl %ebx, (%edx,%eax,4)		#odjęcie bitu od wyniku

	pushl rootStartPtr			#pierwszy argument funkcji
	pushl dataLength			#drugi argument funkcji
	call shiftOne				#przesunięcie liczby w prawo o 1
	addl $8, %esp				#usunięcie ze stosu argumentów funkcji

tempSkipLower:		
	
	shrl $2, bit(%ebp)			#przesunięcie bitu o dwa w prawo

	cmpl $0, bit(%ebp)			#jeżeli bit różny od zera to wróć do pętli
	jne rootLoop
	incl bitIndex(%ebp)			#jeżeli bit równy 0 do zwiększ indeks
	movl $0x40000000, bit(%ebp)		#ustaw bit na przedostatni
	movl bitIndex(%ebp), %eax		#przenieś indeks bitu do rejestru
	cmpl %eax, dataLength			#jeżeli dataLength>bitIndex to wróć
	ja rootLoop
skipRootLoop:
	#======================





	#zwalnianie pamięci zabranej przez kopię liczby pierwiastkowanej
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
