#termLoad Funkcja służąca do wczytania liczby z terminalu
#
#zmienne:
# character - służy do przechowania aktualnie przetwarzanego znaku
# -4(%ebp) - zmienna wykorzystywana podczas zczytywania znaków z konsoli i zamiany ich na wartość, oraz podczas pobierania danych ze stosu do dynamicznie przydzielonej pamięci, by przechować zmienianą wartość
# -8(%ebp) - ilość bitów do przesunięcia
#
#Wykorzystane zmienne globalne
# dataStartWsk - wksaźnik na początek danych przechowywanych w pamięci
# dataLength - długość zarezerwowanej pamięci dataLength*4
#
#stałe tekstowe:
# msg_load - informacja wyświetlania podczas ładowania wartości
# msg_empty - informacja wyswietlana, gdy nie podano żadnego znaku
# msg_wrong - informacja wyswietlana, gdy zostal podany nieprawidlowy znak
#
#stałe:
# MSG_LOAD_L - dlugosc stalej tekstowej msg_load
# MSG_EMPTY_L - dlugosc stalej tekstowej msg_empty
# MSG_WRONG_L - dlugosc stalej tekstowej msg_wrong
# SYS_EXIT - kod wyjscia z programu
# SYS_READ - kod wywoławnia systemowego czytania z pliku
# SYS_WRITE - kod wywołania systemowego zapisu do pliku
# STD_IN - kod wejscie terminala podczas odczytu
# STD_OUT - kod wyjścia terminala podczas zapisu
#
#procedury:
# error_empty - wywolywana, gdy został podany pusty ciąg znaków
# error_wrong - wywoływana, gdy został podany nieprawidłowy znak
# termLoad - ładowanie danych z terminala do dynamicznie przydzielonej pamięci
#	-dataStartWsk - wskaźnik na początek przydzielonej pamięci
#	-dataLength - ługość zarezerwowanej pamięci dataLength*4

.section .data
	.equ SYS_EXIT, 1
	.equ SYS_READ, 3
	.equ SYS_WRITE, 4
	.equ STD_IN, 0
	.equ STD_OUT, 1
	.equ SYS_BRK, 45

character: 
	.ascii " "
	.equ CHARACTER_L, . - character
.section .text
msg_load:
	.ascii "Podaj liczbe szesnastkowo (0-9, A-F), ktorej pierwszenstwo chcesz sprawdzic: "
	.equ MSG_LOAD_L, . - msg_load
msg_empty:
	.ascii "Nie podano zadnej wartosci. Konczenie programu\n"
	.equ MSG_EMPTY_L, . - msg_empty

msg_wrong:
	.ascii "Podano niepoprawny znak. Dozwolone znaki (0-9, A-F). Konczenie programu\n"
	.equ MSG_WRONG_L, . - msg_wrong

.global termLoad

.type termLoad, @function
termLoad:
	pushl %ebp
	movl %esp, %ebp			#prolog funkcji (jakby trzeba bylo korzystac z argumentow
	subl $8, %esp			#miejsce na zmienne lokalne

	#wypisanie w terminalu informacji msg_load
	movl $SYS_WRITE, %eax
	movl $STD_OUT, %ebx
	movl $msg_load, %ecx
	movl $MSG_LOAD_L, %edx
	int $0x80
	#=========================================

	#Wczytanie pierwszego znaku
	movl $SYS_READ, %eax
	movl $STD_IN, %ebx
	movl $character, %ecx
	movl $CHARACTER_L, %edx
	int $0x80
	#==========================

	xor %eax, %eax			#upewnienie, że na pewno w rejestrze eax jest tylko nowy znak
	movb character, %al		#przeniesienie znaku do rejestru al
	cmpb $10, %al			#jezeli pierwszy znak jest znakiem nowej linii to błąd
	je error_empty

	xor %esi, %esi			#liczba przetworzonych doubleword. Wstaw 0
	movl $0, -4(%ebp)		#wyzeruj -4(%ebp)
	movb $28, -8(%ebp)		#wstaw 28 do (przesunięcia) -8(%ebp)

loadSign:

	#sprawdzanie czy znaki są poprawne i zamiana ich na wartość danego znaku
	cmpl $48, %eax
	jge checkIfHex			#jeżeli większe lub równe 48 to musi być znak hex
	cmpl $10, %eax
	je loadEnd			#jeżeli równe 10 to znaczy że koniec linii
	jmp error_wrong			#jeżeli równe to zostaje już tylko zły znak
checkIfHex:
	cmpl $57, %eax
	jg checkIfAf			#jeżeli większe od 57 to znaczy że nie jest cyfrą
	subl $48, %eax			#jeżeli cyfra to jej wartość jest równa eax-47
	jmp endChecking			#jeżeli cyfra to już operacje zostały wykonane
checkIfAf:
	cmpl $65, %eax
	jge checkIfAfDown		#jeżeli większe lub równe 65 to sprawdź jeszcze w dół
	jmp error_wrong
checkIfAfDown:
	cmpl $70, %eax
	jle isAfSign			#jeżeli mniejsze lub równe 70 to jest znakiem A-F
	jmp error_wrong			#w przeciwnym wypadku jest złym znakiem
isAfSign:
	subl $55, %eax			#odejmuje wartość 55, aby przykładowo A(65) miało wartość 10
	#========================================================================

endChecking:
	
	#dodawanie kolejnych wartości do -4(%ebp) i jeśli się wypełni dodawanie go do stosu
	movb -8(%ebp), %cl
	shll %cl, %eax			#przesunięcie o daną ilość bitów
	addl %eax, -4(%ebp)		#dodanie nowej wartości do -4(%ebp) danych
	cmpb $0, -8(%ebp)		#jeżli różne od 0 to pomiń
	jne skipChangeShift
	movb $32, -8(%ebp)		#przenieś 32 do przesunięcia
	pushl -4(%ebp)			#dodaj -4(%ebp) danych na stos
	movl $0, -4(%ebp)		#wyzeruj -4(%ebp) dla miejsca na nowe dane
	incl %esi			#inkrementacja iloścli doubleword
skipChangeShift:
	subb $4, -8(%ebp)		#odejmij 4 od -8(%ebp) (zawsze jest to wykonywane dlatego w -8(%ebp) dane jest 32 żeby wróciło do 28)
	#=================================================================================-

	#Wczytywanie kolejnych znaków
	movl $SYS_READ, %eax
	movl $STD_IN, %ebx
	movl $character, %ecx
	movl $CHARACTER_L, %edx
	int $0x80
	#============================
	
	xorl %eax, %eax			#upewnienie, że na pewno w rejestrze eax jest tylko nowy znak
	movb character, %al		#przeniesienie znaku do rejestru al
	jmp loadSign

loadEnd:
	#zadbanie by ostatni -4(%ebp) trafił na stos
	cmpb $28, -8(%ebp)
	je skipLastSegment		#jeżeli -8(%ebp) równy 28, oznacza że wszystkie cyfry trafiły na stos
	pushl -4(%ebp)
	incl %esi			#inkrementacja iloścli doubleword
skipLastSegment:
	#==========================================

	movl %esi, dataLength		#przeniesienie długości do zmiennej
	shll $2, %esi			#długość w bajtach

	pushl %esi			#argumnet funkcji
	call allocate			#funlcka alokacji
	addl $4, %esp			#zdjęcie argumentu
	movl %eax, dataStartWsk		#wynik funkcji

	#wczytanie wartości ze stosu do pamięci
	movl dataLength, %esi			#indeks liczby
	addb $4, -8(%ebp)			#przywrócenie wartości -8(%ebp) żeby wiedzieć o ile przesunąć wartości ze stosu (FFFFF000 do 000FFFFF)
	movl dataStartWsk, %edx			#przeniesienie adresu do rejestru
	cmpb $32, -8(%ebp)
	jne skipZeroReturn			#jeżeli -8(%ebp) równy 32 to tak naprawdę będzie 0
	movb $0, -8(%ebp)
skipZeroReturn:
	popl %eax				#pobranie pierwszej wartości ze stosu
	movb $32, %cl				#ilość przesunięcia dla kolejnej liczby
	subb -8(%ebp), %cl
movToData:
	cmpl $1, %esi
	jle skipMovData				#jeżeli indeks mniejszy od jeden to zrób ostatnie przepisanie
	decl %esi
	popl %ebx				#pobranie drugiej liczby do przesunięcia
	movl %ebx, -4(%ebp)			#wartość drugiej liczby musi być zachowana dla kolejnej iteracji
	movl $0, (%edx,%esi,4)			#wyzerowanie wartości obecnego -4(%ebp)	
	xchgb %cl, -8(%ebp)			#zamiana wartości przesunięcia pierwszej i drugiej liczby
	shrl %cl, %eax				#przesunięcie w prawo pierwszej liczby
	addl %eax, (%edx,%esi,4)		#dodanie jej wartości do obecnego -4(%ebp)
	xchgb %cl, -8(%ebp)			#zamiana wartości przesunięcia pierwszej i drugiej
	cmpb $32, %cl
	je setShift0				#nie da się przesunąć o 32 bity więc ustaw na 0
	shll %cl, %ebx				#przesunięcie drugiej liczby
	jmp skipSetShift0
setShift0:
	movl $0, %ebx				#ustaw na 0
skipSetShift0:
	addl %ebx, (%edx,%esi,4)		#dodanie jej wartości do obecnego -4(%ebp)
	movl -4(%ebp), %eax			#nadanie wartości drugiej liczby jako pierwszej
	jmp movToData
skipMovData:
	decl %esi
	xchgb %cl, -8(%ebp)			#zamiana wartości przesunięcia pierwszej i drugiej
	shrl %cl, %eax				#przesunięcie w prawo ostatniej liczby
	movl $0, (%edx,%esi,4)			#wyzerowanie wartości obecnego -4(%ebp)	
	addl %eax, (%edx,%esi,4)		#dodanie wartości ostatniego elementu
	#======================================

	movl %ebp, %esp				#odtworzenie starego stosu
	popl %ebp
	ret



error_empty:
	#wypisanie wiadomosci na ekranie
	movl $SYS_WRITE, %eax
	movl $STD_OUT, %ebx
	movl $msg_empty, %ecx
	movl $MSG_EMPTY_L, %edx
	int $0x80
	#===============================

	#wyjscie z programu
	movl $SYS_EXIT, %eax
	xorl %ebx, %ebx		#zamiast wstawiania 0 (jakies zabezpieczenie przed wstrzykiwaniem terminala)
	int $0x80
	#==================
	ret

error_wrong:
	#wypisanie wiadomosci na ekranie
	movl $SYS_WRITE, %eax
	movl $STD_OUT, %ebx
	movl $msg_wrong, %ecx
	movl $MSG_WRONG_L, %edx
	int $0x80
	#===============================

errorLoadALL:
	movb character, %al
	cmpb $10, %al
	je error_exit			#jezeli nie jest 10 to doczytaj znaki do konca (dla zabezpieczenia przed wpisywaniem głupot do terminala).

	#Wczytywanie kolejnych znaków
	movl $SYS_READ, %eax
	movl $STD_IN, %ebx
	movl $character, %ecx
	movl $CHARACTER_L, %edx
	int $0x80
	#============================
	jmp errorLoadALL
	
error_exit:
	#wyjscie z programu
	movl $SYS_EXIT, %eax
	xorl %ebx, %ebx		#zamiast wstawiania 0 (jakies zabezpieczenie przed wstrzykiwaniem terminala)
	int $0x80		
	#==================
	ret
