# losowa liczb na podanej liczbie dword
# losuje kolejne czlony za pomoca random.s (seed wziety za pomoca srand.s)
# potem dzieli przez podany dzielnik (tutaj wprost podany, a docelowo powinien byc z arg)

.section .data
	.equ restTempPtr, -4
	.equ randomStartPtr, 8
	.equ denomPtr, 12
.section .bss
.lcomm data, 4

.section .text

.global lessrand

.type lessrand, @function
lessrand:
    	pushl %ebp
    	movl %esp, %ebp
    	subl $8, %esp
  
    	pushl %edi              # save local register
    	pushl %esi              # save local register
    	pushl %ebx              # save local register

    	#alokacja pamięci dla reszty z dzielenia
	movl dataLength, %eax
	shll $2, %eax				#długość w bajtach
	pushl %eax				#argumnet funkcji
	call allocate				#funkcja alokacji
	addl $4, %esp				#zdjęcie argumentu
	movl %eax, restTempPtr(%ebp)		#wynik funkcji
	#==========================================
    
    	pushl dataLength
	pushl randomStartPtr(%ebp)
    	call random
    	addl $8, %esp

	pushl dataLength
    	pushl randomStartPtr(%ebp)
   	pushl dataLength
	pushl restTempPtr(%ebp)
	pushl dataLength
	pushl denomPtr(%ebp)
	call bindiv # - tu twoja funkcja
	addl $20, %esp
	
    	#skopiowanie reszty do wyniku
	movl $0, %esi				#indeks od 0
	movl randomStartPtr(%ebp), %eax		#wskaźnik na randomStartPtr do rejestru
	movl restTempPtr(%ebp), %edx		#wskaźnik na restTempPtr do rejestru
copyTempRes:
	movl (%edx, %esi, 4), %ebx		#przechowanie wartości w rejestrze
	movl %ebx, (%eax, %esi, 4)		#przeniesienie wartości z resultTmp do result
	incl %esi				#zwiększenie indeksu
	cmpl dataLength, %esi
	jb copyTempRes 				#dopóki indeks mniejszy od długości powtarzaj kopiowanie
	#============================

    	#zwalnianie pamięci zabranej przez reszte z dzielenia
    	movl dataLength, %eax
   	shll $2, %eax           #długość w bajtach
   	negl %eax               #negacja długości w bajtach
   	pushl %eax              #argumnet funkcji
    	call allocate           #funkcja alokacji
    	addl $4, %esp           #zdjęcie argumentu
   	#===============================================================

    	popl %ebx
    	popl %esi
    	popl %edi

    	movl %ebp, %esp			#odtworzenie starego stosu
	popl %ebp
    ret
