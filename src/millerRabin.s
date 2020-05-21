#Test millera Rabina
#
#Dane:
# dataStartPtr - początek obszaru pamięci dla liczby testowanej
# dataLength - długość danych * 4 bajty
# millerTestCount - ilość testów Millera-Rabina
#
#Zmienne lokalne:
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
.section .text
msg_info:
	.ascii "\nTest Millera-Rabina:\nPrawdopodobieństwo Poprawności: 1/4^"
	.equ MSG_INFO_L, . - msg_info
msg_no_prime:
	.ascii "Podana liczba nie jest piewsza\n"
	.equ MSG_NO_PRIME_L, . - msg_no_prime
msg_prime:
	.ascii "Podana liczba jest piewsza\n"
	.equ MSG_PRIME_L, . - msg_prime

.global millerRabin

.type millerRabin, @function
millerRabin:
	pushl %ebp
	movl %esp, %ebp			#prolog funkcji (jakby trzeba bylo korzystac z argumentow
	subl $4, %esp			#miejsce na zmienne lokalne

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

	#kopia liczby testowanej
	movl $0, %esi			#początkowy indeks kopii
copyData:
	
	#test czy nie parzysta

	#odjęcie jeden

	#podzielenie przez 2 tyle razy ile się da

	#wypisanie w terminalu informacji msg_prime
	movl $SYS_WRITE, %eax
	movl $STD_OUT, %ebx
	movl $msg_prime, %ecx
	movl $MSG_PRIME_L, %edx
	int $0x80
	#=========================================
	jmp isPrime

isNoPrime:
	#wypisanie w terminalu informacji msg_no_prime
	movl $SYS_WRITE, %eax
	movl $STD_OUT, %ebx
	movl $msg_no_prime, %ecx
	movl $MSG_NO_PRIME_L, %edx
	int $0x80
	#=========================================
isPrime:

	movl %ebp, %esp			#odtworzenie starego stosu
	popl %ebp
	ret
