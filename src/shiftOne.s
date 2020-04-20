#przesunięcie liczby o 1 w prawo
#
#Dane:
# numberPtr - początek obszaru pamięci liczby do przesunięcia
# numberLength - dlugosc liczby
#
#Zmienne:
# ifCf - czy należy dodać ostatnią pozycje

.section .data
	.equ numberPtr, 8
	.equ numberLength, 12
	.equ ifCf, -4

.section .text

.global shiftOne

.type shiftOne, @function
shiftOne:
	pushl %ebp
	movl %esp, %ebp				#prolog funkcji (jakby trzeba bylo korzystac z argumentow
	subl $4, %esp				#miejsce na zmienne lokalne

	movl $0, ifCf(%ebp)			#nadanie wartości początkowej
	movl numberPtr(%ebp), %eax		#przeniesienie wskaźnika do rejestru
	movl numberLength(%ebp), %esi		#indeks
	clc					#wyczyszczenie flag
shiftLoop:
	decl %esi				#zmniejszenie dlugosci do sprawdzenia

	shrl (%eax, %esi, 4)			#przesunięcie bitowe w prawo
	pushf					#przechowanie flag
	cmpl $0, ifCf(%ebp)			#czy nalezy dodac ostatni bit
	jne skipAddLast
	addl $0x80000000, (%eax, %esi, 4)	#dodanie ostatniego bitu
skipAddLast:
	popf					#przywrócenie flag
	
	movl $1, ifCf(%ebp)
	jc skipUnsetCf				#Czy jest przeniesienie
	movl $0, ifCf(%ebp)
skipUnsetCf:

	cmpl $0, %esi
	jge shiftLoop				#wykonuj dopoki większy lub równy indeks

	movl %ebp, %esp				#odtworzenie starego stosu
	popl %ebp
	ret
