#Pobieranie czasu systemowego
#
#Dane:
# seed - zmienna globalna przechowująca aktualny seed losowania
#
#stałe:
# SYS_TIME - kod wywołania systemowego pobrania czasu

.section .data
	seed: .long 0
	.equ SYS_TIME, 13
.section .text

.global srand_vec, seed

.type srand_vec, @function
srand_vec:
	pushl %ebp
	movl %esp, %ebp			#prolog funkcji
	pushl %ebx			#zachowanie rejestru ebx (zarezerwowany)

	#pobranie czasu systemowego
	movl $SYS_TIME, %eax		#kod wywołania systemowego
	leal seed, %ebx			#wcztanie wskaźnika na seed jako argument
	int $0x80
	#==========================

	popl %ebx			#przywrócenie rejestru ebx (zarezerwowany)
	movl %ebp, %esp			#odtworzenie starego stosu
	popl %ebp
	ret
	