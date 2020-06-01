#generowanie liczb pseudolosowych wektora
#sposób LCG
#
#Dane:
# seed - zmienna globalna przechowująca aktualny seed losowania
#
#argumenty funckji
# vector - wskaźnik na początek wektora
#
#stałe
#
# randA - do liczby pseudolosowej rand = randA*seed+randC
# randC - do liczby pseudolosowej rand = randA*seed+randC

.section .data
	.equ vector, 8
	.equ length, 12
	.equ randA, 1103515245
	.equ randC, 12345
.section .text

.global random_vec

.type random_vec, @function
random_vec:
	pushl %ebp
	movl %esp, %ebp				#prolog funkcji 
	subl $8, %esp
	pushl %edi              # save local register
    pushl %esi              # save local register
    pushl %ebx              # save local register

	movl length(%ebp), %eax
	movl %eax, -4(%ebp)

	movl seed, %eax				#pobranie aktualnego seedu

	movl $0, %esi				#iteracja pętli
random_loop:
	movl $randA, %edx			#randA jako argument mnożenia
	mull %edx				#mnożenie razy randA (radA*seed+randC)
	addl $randC, %eax  			#dodanie randC

	xorl %edx, %edx				#druga część dzielnej jest 0
	movl vector(%ebp), %ebx			#wkskaźnik na wektor
	movl %eax, (%ebx, %esi, 4)		#przeniesienie wyniku do odpowiedniej pozycji wektora

	incl %esi
	cmpl -4(%ebp), %esi
	jb random_loop				#wykonaj dla wszystkich pozycji wektora

	movl %eax, seed 			#nowy seed do pamięci

	popl %ebx
    popl %esi
    popl %edi
	movl %ebp, %esp				#odtworzenie starego stosu
	popl %ebp
	ret
