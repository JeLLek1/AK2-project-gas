#Podejście naiwne w sprawdzaniu, czy liczba jest pierwsza
#
#Dane:
# rootStartPtr - początek obszaru pamięci dla pierwiastka sprawdzanej liczby
# dataLength - długość danych * 4 bajty
#
#Zmienne lokalne:
# restTempPtr - wskaźnik na początek pamięci reszty z dzielenia
# incTempPtr - wskaźnik na początek pamięci liczby inkrementowanej
#
#stałe tekstowe:
# msg_info - informacja o typie algorytmu
# msg_no_prime - informacja wyswietlana, jezeli liczba nie jest pierwsza
# msg_prime - informacja wyswietlana, jezeli liczba jest pierwsza
# showProgress - postęp obliczeń
#
#stałe:
# MSG_INFO_L - długość tekstu informacji
# MSG_NO_PRIME_L - długość tekstu, jeżeli liczba nie jest pierwsza
# MSG_PRIME_L - długość tekstu, jeżeli liczba jest pierwsza
# SYS_READ - kod wywoławnia systemowego czytania z pliku
# SYS_WRITE - kod wywołania systemowego zapisu do pliku
# STD_IN - kod wejscie terminala podczas odczytu
# STD_OUT - kod wyjścia terminala podczas zapisu
#
#
.section .data
	.equ SYS_READ, 3
	.equ SYS_WRITE, 4
	.equ STD_IN, 0
	.equ STD_OUT, 1
	.equ restTempPtr, -4
	.equ incTempPtr, -8
	.equ showProgress, -12
.section .text
msg_info:
	.ascii "\nSprawdzanie pierwszosci metoda nawina:\n"
	.equ MSG_INFO_L, . - msg_info
msg_no_prime:
	.ascii "Podana liczba nie jest piewsza\n"
	.equ MSG_NO_PRIME_L, . - msg_no_prime
msg_prime:
	.ascii "Podana liczba jest piewsza\n"
	.equ MSG_PRIME_L, . - msg_prime

.global naiveAproach

.type naiveAproach, @function
naiveAproach:
	pushl %ebp
	movl %esp, %ebp			#prolog funkcji (jakby trzeba bylo korzystac z argumentow
	subl $16, %esp			#miejsce na zmienne lokalne

	#wypisanie w terminalu informacji msg_info
	movl $SYS_WRITE, %eax
	movl $STD_OUT, %ebx
	movl $msg_info, %ecx
	movl $MSG_INFO_L, %edx
	int $0x80
	#=========================================

	#alokacja pamięci dla reszty z dzielenia
	movl dataLength, %eax
	shll $2, %eax				#długość w bajtach
	pushl %eax				#argumnet funkcji
	call allocate				#funkcja alokacji
	addl $4, %esp				#zdjęcie argumentu
	movl %eax, restTempPtr(%ebp)		#wynik funkcji
	#==========================================

	#alokacja pamięci dla liczby ikrementowanej
	movl dataLength, %eax
	shll $2, %eax				#długość w bajtach
	pushl %eax				#argumnet funkcji
	call allocate				#funkcja alokacji
	addl $4, %esp				#zdjęcie argumentu
	movl %eax, incTempPtr(%ebp)		#wynik funkcji
	#==========================================

	#sprawdzenie podzielności przez 2
	movl dataStartPtr, %eax			#wskaźnik początku liczby sprawdzanej do rejestru
	movl dataLength, %esi			#długość liczby do rejestru
	decl %esi				#ostatnia część danych jest o 1 mniejsza niż długość
	movl (%eax, %esi, 4), %eax		#przesunięcie wskaźnika danych na ostatnią część danych
	rcrl $1, %eax				#pobranie ostatniego bitu
	jnc isNoPrim				#jezeli jest podzielnia przez 2 to nie pierwsza

	#ostatnia pozycja liczby ikrementowanej równa 3 (bo 2 sprawdzone)
	movl incTempPtr(%ebp), %eax
	movl $3, (%eax, %esi, 4)		#w %esi jest już pozycja ostatniego dword
	#wypełnianie reszty danych zerami
	cmpl $0, %esi				#jeżeli długość liczby to 1 to nie trzeba wypełniać
	je skipFillZero
fillZero:
	decl %esi				#zmniejszenie %esi o 1
	movl $0, (%eax, %esi, 4)		#wstawienie do kolejnych komórek liczby inkrementowanej 0
	cmpl $0, %esi				#wypełniaj, dopóki %esi nie będzie mniejsze od 0 
	jne fillZero
skipFillZero:
	
	#pokazywanie postępu
	movl $0, showProgress(%ebp)		#zerowanie testu czy przedostatnia komórka się zmieniła

	#sprawdzanie czy dane wprowadzone są podzielne przez kolejne liczby z incTempPtr
	#sprawdzanie co 2 pozycje bo na pewno nie jest podzielna przez 2
testNaiveAproach:
	
	#tutaj będzie dzielonko
	#incTempPtr(%ebp) - wskaźnik na początek liczby przez którą trzeba dzielić
	#dataStartPtr - wskaźnik na liczbę którą trzeba podzielić
	#dataLength - długość liczby
	#(dzielnik i dzielna zawsze są tej samej długości, 
	#nigdzie tego nie zmieniam. Nawet jak inc jest równe 3 
	#to dalej jest przechowywane w tylu komórkach co testowana liczba, 
	#więc nie musisz tego robić jako argument, dataLenght może być wszędzie na stałe)
	#argumenty funkcji
	#call bindiv - tu twoja funkcja
	#cmpl $0, %eax
	#je isNoPrim - jak będzie %eax równe 0 to znaczy że nie jest pierwsza - koniec zadania
	
	#wyświetlenie postępu
	cmpl $2, dataLength
	jb skipShowProgress			#jeżeli długość jest mniejsza niż 2 nie ma sensu pokazywać postępu
	movl dataLength, %esi
	subl $2, %esi				#interesuje nas przedostatnia komórka
	movl incTempPtr(%ebp), %eax
	movl (%eax, %esi, 4), %eax		#potrzebna przedostatnia komórka
	cmpl showProgress(%ebp), %eax		#jeżeli się nie zmieniła to pomić
	je skipShowProgress
	pushl incTempPtr(%ebp)			#początek sprawdzanych danych
	call progress 				#funkcja pokazująca pgrogres testu
	addl $4, %esp				#zdjęcie argumentów ze stosu
	incl showProgress(%ebp)			#następny do wyświetlenia
skipShowProgress:
	#dodanie 2 do incTempPtr
	movl incTempPtr(%ebp), %eax		#początek tablicy liczb inkrementowanych
	movl rootStartPtr, %ebx			#początek tablicy pierwiastka do rejestru
	movl dataLength, %esi
	decl %esi				#ostatnia pozycja liczby
	add $2, (%eax, %esi, 4)			#dodanie 2 do ostatniej pozycji
	#nie trzeba martwić się o przepełnienie bo pierwiastek zawsze jest dużo mniejszy

addCarry:
	jnc skipAddCarry			#jeżeli brak przeniesienia to pomiń
	decl %esi
	adc $0, (%eax, %esi, 4)			#dodanie przeniesienia do kolejnych pozycji
	jmp skipAddCarry
skipAddCarry:
	
	#test czy większa lub równa
	movl $0, %esi				#zaczynając od najwyższej pozycji
testIfLower:
	movl (%eax, %esi, 4), %ecx		#przeniesienie wartości komórki do rejestru
	cmpl (%ebx,%esi, 4), %ecx	#porównanie z wartością pierwiastka
	ja skipTestIfLower			#jeżeli większa to koniec testu
	jb testNaiveAproach			#jeżeli mniejsza to dalej testuj
	incl %esi				#inkrementacja indeksu
	cmpl dataLength, %esi			#dopóki %esi 
	jb testIfLower 
	jmp testNaiveAproach			#jeżeli równa to ostatni test
skipTestIfLower:

	#wypisanie w terminalu informacji msg_prime
	movl $SYS_WRITE, %eax
	movl $STD_OUT, %ebx
	movl $msg_prime, %ecx
	movl $MSG_PRIME_L, %edx
	int $0x80
	#=========================================
	jmp isPrime
isNoPrim:
	#wypisanie w terminalu informacji msg_no_prime
	movl $SYS_WRITE, %eax
	movl $STD_OUT, %ebx
	movl $msg_no_prime, %ecx
	movl $MSG_NO_PRIME_L, %edx
	int $0x80
	#=========================================
isPrime:
	#zwalnianie pamięci zabranej przez liczbe inkrementowana
	movl dataLength, %eax
	shll $2, %eax			#długość w bajtach
	negl %eax			#negacja długości w bajtach
	pushl %eax			#argumnet funkcji
	call allocate			#funkcja alokacji
	addl $4, %esp			#zdjęcie argumentu
	#===============================================================

	#zwalnianie pamięci zabranej przez reszte z dzielenia
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
