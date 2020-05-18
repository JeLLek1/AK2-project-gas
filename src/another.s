# funkcja zwracajace 0 - gdy dzielna jest podzielna przez dzielnik
#                    1 - gdy dzielna nie jest podzielna przez dzielnik
# dzielna - zapisana w globalnej zmiennej dataStartPtr
# dzielnik podawany jako pierwszy argument funkcji
# drugi argument funkcji to dlugosc (liczba doublewordow) dzielnika - na ten moment niepotrzebne
# dzielnik powinien miec taka sama dlugosc jak dzielna
# moze byc z lewej strony uzupelniony zerami

.section .data
.section .bss
.lcomm data, 4

.section .text

.global divide_by_repeated_subtraction

.type divide_by_repeated_subtraction, @function divide_by_repeated_subtraction:
    pushl %ebp
    movl %esp, %ebp
    subl $16, %esp

    movl dataLength, %eax
	shll $2, %eax				#długość w bajtach
	pushl %eax				#argumnet funkcji
	call allocate				#funkcja alokacji
	addl $4, %esp				#zdjęcie argumentu
	movl %eax, -4(%ebp)		#wynik funkcji

    movl -4(%ebp), %ecx
    movl dataLength, %eax
    movl %eax, -8(%ebp)

    movl dataStartPtr, %eax
    movl $0, %esi
copy:    
    movl (%eax,%esi,4), %ebx
    movl %ebx, (%ecx,%esi,4)
    incl %esi
    cmpl %esi, -8(%ebp)
    jg copy 

    movl 8(%ebp), %ebx

start:
    decl %esi
    cmpl $0, %esi
    jl later

    movl (%ecx,%esi,4), %eax
    movl %eax, -12(%ebp)

    movl (%ebx,%esi,4), %eax
    subl %eax, -12(%ebp)

    movl -12(%ebp), %eax
    movl %eax, (%ecx,%esi,4)

subloop:
    decl %esi
    jz keep_cf    
#    cmpl $0, %esi
#    jl later

    movl (%ecx,%esi,4), %eax
    movl %eax, -12(%ebp)

    movl (%ebx,%esi,4), %eax
    sbbl %eax, -12(%ebp)

    movl -12(%ebp), %eax
    movl %eax, (%ecx,%esi,4)
    jmp subloop

later:
    movl (%ecx), %eax
    cmpl $0, %eax
    jl finish               # wynik negatywny, wiec koniec dzialania
    jg continue

    movl $0, %esi
equal:
    incl %esi
    cmpl %esi, -8(%ebp)
    jle zero
    movl (%ecx,%esi,4), %eax
    cmpl $0, %eax
    jl finish
    jg continue
    je equal 
finish:
    movl $1, %eax
    jmp function_exit
zero:
    movl $0, %eax
    jmp function_exit
continue:
    movl -8(%ebp), %esi
    jmp start 

function_exit:
    movl %ebp, %esp			#odtworzenie starego stosu
	popl %ebp
    ret


keep_cf:
    movl (%ecx,%esi,4), %eax
    movl %eax, -12(%ebp)

    movl (%ebx,%esi,4), %eax
    sbbl %eax, -12(%ebp)

    movl -12(%ebp), %eax
    movl %eax, (%ecx,%esi,4)
    jmp later
