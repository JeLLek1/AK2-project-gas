#rezerwacha pamięci o wybranej długości
#
#stałe:
# SYS_BRK - kod wywołania systemowego zmiany przerwania programu
#
#zmienne lokalne:
# -4(%ebp) - tymczasowe przechowanie początku zalokowanej pamięci
#
#return:
# %eax - początek zalokowanej pamięci

.section .data
	.equ SYS_BRK, 45

.section .text

.global allocate

.type allocate, @function
allocate:
	push %ebp
	mov %esp, %ebp			#nowa ramka call
	subl $4, %esp			#miejsce na zmienną lokalną

	pushl %esi              	# zapisanie rejestrów lokalnych
	pushl %ebx              	# zapisanie rejestrów lokalnych

	movl 8(%ebp), %esi		#argument funkcji

	#pobranie wartości obecnego przerwania programu
	movl $SYS_BRK, %eax
	xorl %ebx, %ebx
	int $0x80
	#==============================================

	movl %eax, -4(%ebp)		#zapis do zmiennej lokalnej startu
	movl %eax, %ebx
	addl %esi, %ebx			#gdzie będzie koniec nowego przewania programu

	#nadanie nowej wartości przerwania programu
	movl $SYS_BRK, %eax
	int $0x80
	#==========================================
	
	movl -4(%ebp), %eax		#przywrócenie ze zmiennej lokalnej do rejestru startu

	popl %ebx
   	popl %esi
	
	movl %ebp, %esp
	popl %ebp			#Przwywrócenie starej ramki call
	ret
