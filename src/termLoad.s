#termLoad Funkcja służąca do wczytania liczby z terminalu
#
#zmienne:
# character - służy do przechowania aktualnie przetwarzanego znaku
# inputSize - ilość znaków wprowadzonych przez użytkownika
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
# SYS_BRK - kod wywołania systemowego zmiany przerwania programu
#
#procedury:
# error_empty - wywolywana, gdy został podany pusty ciąg znaków
# error_wrong - wywoływana, gdy został podany nieprawidłowy znak

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

termLoad:
	pushl %ebp
	movl %esp, %ebp			#prolog funkcji (jakby trzeba bylo korzystac z argumentow

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

	xor %esi, %esi			#liczba przetworzonych bajtów. Wstaw 0

loadSign:

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

endChecking:
	incl %esi			#inkrementacja iloścli znaków
	pushl %eax			#dodanie na stos wartości
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

loadEnd: #źle policzyłem trzeba to zmienić trochęq
	movl $4, %ebx			#wartosc, przez którą liczba będzie dzielona
	movl %esi, %eax			#wartość do podzielenia
	movl $0, %edx			#wartość do podzielenia
	divl %ebx
	movl $4, %eax
	subl %edx, %eax			#reszte odejmuję od 4 żeby zobaczyć ile bajtów brakuje
	cmpl $4, %eax			#jeżeli zostało 4 to znaczy że nie trzeba nic dodawać
	jne skipReset
	movl $0, %eax

skipReset:
	addl %esi, %eax			#dodanie bajtów do pełnego double word
	movl $8, %ebx
	mull %ebx			#pomnożenie przez wartość bajta
	movl %eax, %edi			#ilość bitów do zalokowania e %edi

	#pobranie wartości obecnego przerwania programu
	movl $SYS_BRK, %eax
	xorl %ebx, %ebx
	int $0x80
	#==============================================

	popl %ebp			#epilog funkcji
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
