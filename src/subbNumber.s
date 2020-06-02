#odjęcie dword od dużej liczby
#
#argumenty funkcji
# dword - argument a (podstawa potęgi)
# bigNumber - argument e (wykładnik potęgi)
# result - wskaźnik na wynik
#

.section .data
	.equ dword, 8
	.equ bigNumber, 12
	.equ result, 16
.section .text

.global subNumber

.type subNumber, @function
subNumber:
	push %ebp
	mov %esp, %ebp			#nowa ramka call
	subl $4, %esp			#miejsce na zmienne lokalne

	pushl %ebx
   	pushl %esi

	movl dataLength, %esi			#ustawienie indeksu
	movl bigNumber(%ebp), %eax		#wskaźnik na bigNumber do rejestru
	movl result(%ebp), %edx			#wskaźnik na result do rejestru
	decl %esi				#ostatnia pozycja
	movl (%eax, %esi, 4), %ebx
	subl dword(%ebp), %ebx			#odjęcie dword od ostatniej pozycji
	movl %ebx, (%edx, %esi, 4)		#przeniesienie wyniku do result
	pushf					#zachowanie flag
sub3FromData:
	cmpl $0, %esi
	je sub3FromDataSkip			#wykonuj dopóki indeks różny od 0
	decl %esi				#zmniejszenie indeksu
	movl (%eax, %esi, 4), %ebx		#przeniesienie kolejnej pozycji data do rejestru
	popf 					#pobranie flag ze stosu
	sbbl $0, %ebx				#odjęcie flagi, jeżeli jest
	movl %ebx, (%edx, %esi, 4)		#przeniesienie wyniku do result
	pushf 					#odłożenie flag na stos
	jmp sub3FromData
sub3FromDataSkip:
	popf					#pobranie ostatniej flagi ze stosu

	popl %ebx
   	popl %esi

	movl %ebp, %esp
	popl %ebp			#Przwywrócenie starej ramki call
	ret
