#Wyświetlanie liczbę podaną w argumencie w postaci 16-tkowej
#
#Argumenty 
# number - liczba do wyświetlenia
#
#stałe:
# SYS_WRITE - kod wywołania systemowego zapisu do pliku
# STD_OUT - kod wyjścia terminala podczas zapisu
#
#zmienne lokalne
# signPtr - znak do wyświetlenia
# shift - ilość bitów do przesunięcia w prawo

.section .data
	.equ SYS_WRITE, 4
	.equ STD_OUT, 1
	.equ signPtr, -4
	.equ shift, -8
	.equ number, 8

.section .text

.global displayNumber

.type displayNumber, @function
displayNumber:
	pushl %ebp
	movl %esp, %ebp			#prolog funkcji (jakby trzeba bylo korzystac z argumentow
	subl $12, %esp			#miejsce na zmienne lokalne

	movb $0, shift(%ebp)		#ilość przesunięć pierwszej liczby
printNumber:
	movl number(%ebp), %eax		#liczba do rejestru
	movb shift(%ebp), %cl 		#ilość przesunięc do rejestru
	shll %cl, %eax			#przesunięcie w lewo aby obciąć lewą stronę
	shrl $28, %eax			#przesunięcie w prawo aby obciąć prawą stronę

	addl $48, %eax			#dodanie dla znaku 0-9
	cmpl $57, %eax			#jeżeli nie mieści się w zakresie to dodaj kolejne
	jbe skipAdd
	addl $7, %eax			#dla wyśwyetlenia A-F
skipAdd:
	movl %eax, signPtr(%ebp)	#znak do wyświetlenia
	#wyświetlenie cyfry
	movl $SYS_WRITE, %eax
	movl $STD_OUT, %ebx
	leal signPtr(%ebp), %ecx		#adres znaku do wyświetlenia
	movl $1, %edx			#jeden znak
	int $0x80
	#=================
	addb $4, shift(%ebp)		#zmiana co 4
	cmpb $32, shift(%ebp)		#dopuki przesinięcie nie jest 0 to powtarzaj
	jne printNumber

	movl %ebp, %esp			#odtworzenie starego stosu
	popl %ebp
	ret
