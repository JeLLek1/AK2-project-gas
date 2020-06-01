# losowa liczb na podanej liczbie dword
# losuje kolejne czlony za pomoca random.s (seed wziety za pomoca srand.s)
# potem dzieli przez podany dzielnik (tutaj wprost podany, a docelowo powinien byc z arg)

.section .data
randomLength: .long 3
.equ restTempPtr, -4
.equ denomTempPtr, -8
.equ randomStartPtr, -12
.section .bss
.lcomm data, 4

.section .text

.global lessrand

.type lessrand, @function
lessrand:
    pushl %ebp
    movl %esp, %ebp
    subl $16, %esp
  
    pushl %edi              # save local register
    pushl %esi              # save local register
    pushl %ebx              # save local register

    #alokacja pamięci dla reszty z dzielenia
	movl randomLength, %eax
	shll $2, %eax				#długość w bajtach
	pushl %eax				#argumnet funkcji
	call allocate				#funkcja alokacji
	addl $4, %esp				#zdjęcie argumentu
	movl %eax, restTempPtr(%ebp)		#wynik funkcji
	#==========================================

# dzielnik - trzeba zamienic na pobieranie dzielnika z argumentu
# i wtedy usunąć alokację oraz wpisanie wartosci
	#alokacja pamięci dla dzielnika
	movl randomLength, %eax
	shll $2, %eax				#długość w bajtach
	pushl %eax				#argumnet funkcji
	call allocate				#funkcja alokacji
	addl $4, %esp				#zdjęcie argumentu
	movl %eax, denomTempPtr(%ebp)	#wynik funkcji
	#==========================================

	movl denomTempPtr(%ebp), %eax
    movl $2000, 4(%eax)


    #alokacja pamięci dla liczby ikrementowanej
	movl randomLength, %eax
	shll $2, %eax				#długość w bajtach
	pushl %eax				#argumnet funkcji
	call allocate				#funkcja alokacji
	addl $4, %esp				#zdjęcie argumentu
	movl %eax, randomStartPtr(%ebp)	#wynik funkcji
	#==========================================

    

    call srand_vec
    pushl randomLength
	pushl randomStartPtr(%ebp)
    call random_vec
    addl $8, %esp

	pushl randomLength
    pushl randomStartPtr(%ebp)
    pushl randomLength
	pushl restTempPtr(%ebp)
	pushl randomLength
	pushl denomTempPtr(%ebp)
	call bindiv # - tu twoja funkcja
	addl $20, %esp
aft:	
    movl restTempPtr(%ebp), %eax	# reszta z dzielenia jako wynik

func_exit:
    popl %ebx
    popl %esi
    popl %edi

    movl %ebp, %esp			#odtworzenie starego stosu
	popl %ebp
    ret
