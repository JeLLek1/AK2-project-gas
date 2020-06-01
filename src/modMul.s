#algorytm tyliczania (a*b) mod n
#
#zmienne lokalne:
# mask - maska bitowa
# result - wynik mnożenia modulo
#
#

.section .data
	.equ mask, -4
	.equ result, -8

.section .text

.global modMul

.type modMul, @function
modMul:
	push %ebp
	mov %esp, %ebp			#nowa ramka call
	subl $12, %esp			#miejsce na zmienne lokalne

	#alokacja pamięci dla maski
	movl dataLength, %eax
	shll $2, %eax				#długość w bajtach
	pushl %eax				#argumnet funkcji
	call allocate				#funkcja alokacji
	addl $4, %esp				#zdjęcie argumentu
	movl %eax, mask(%ebp)			#wynik funkcji
	#==========================================

	#alokacja pamięci dla wyniku
	movl dataLength, %eax
	shll $2, %eax				#długość w bajtach
	pushl %eax				#argumnet funkcji
	call allocate				#funkcja alokacji
	addl $4, %esp				#zdjęcie argumentu
	movl %eax, result(%ebp)			#wynik funkcji
	#==========================================


	movl mask(%ebp), %eax			#wskaźnik na maskę do rejestru
	movl result(%ebp), %edx			#wskaźnik na wynik do rejestru
	movl dataLength, %esi
	decl %esi				#ostatnia komórka maski i wyniku
	movl $1, (%eax, %esi, 4)		#na ostatniej pozycji maski 1
	movl $0, (%edx, %esi, 4)		#na ostatniej pozycji wyniku 0 
	#wypełnianie reszty maski i wyniku zerami
fillMask:
	cmpl $0, %esi
	je fillMaskSkip				#jeżeli indeks 0 to koniec wypełniania
	decl %esi				#zmniejszenie indeksu
	movl $0, (%eax, %esi, 4)		#wypełnienie zerem maski
	movl $0, (%edx, %esi, 4)		#wypełnienie zerem wyniku
	jmp fillMask
fillMaskSkip:

	#pętla kolejnych obliczeń
modMulLoop:
	#test czy maska=/=0
	movl mask(%ebp), %eax			#wskaźnik na maskę do rejestru
	movl $0, %esi
testMask:
	cmpl $0, (%eax, %esi, 4)
	jne testMaskSkip			#jeżeli jakikolwiek element różny od 0 to powtarzaj algorytm
	incl %esi				#zwiększenie indeksu
	cmpl dataLength, %esi
	jb testMask 				#dopóki nie sprawdzono całej maski powtarzaj
	jmp modMulLoopSkip			#jeżeli cała maska równa 0 to koniec algorytmu
testMaskSkip:
	
	

	jmp modMulLoop
modMulLoopSkip:


	#zwalnianie pamięci zabranej przez maske
	movl dataLength, %eax
	shll $2, %eax			#długość w bajtach
	negl %eax			#negacja długości w bajtach
	pushl %eax			#argumnet funkcji
	call allocate			#funkcja alokacji
	addl $4, %esp			#zdjęcie argumentu
	#===============================================================

	movl result(%ebp), %eax		#zwrócenie wskaźnika na wynik

	movl %ebp, %esp
	popl %ebp			#Przwywrócenie starej ramki call
	ret
