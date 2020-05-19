# argumenty: dzielnik, dlugosc, zmienna dla ilorazu, dlugosc, zmienna dla reszty, dlugosc
# na wyjscie w eax jest zapisana reszta z dzielenia 
.section .data
.section .text
.global bindiv

.type bindiv, @function
bindiv:

    pushl %ebp
    movl %esp, %ebp
    subl $16, %esp

# sprawdzenie pozycji msb 
    movl dataStartPtr, %eax
    movl (%eax), %eax

# %ecx - lsb, -8(%ebp) - msb, %edi - pozycja
    movl $0, %edi
    movl $32, %ecx

start:
    movl %eax, %ebx
    and $0x1, %ebx
    jz next
    cmpl %ecx, %edi
    cmovl %edi, %ecx
    movl %edi, -8(%ebp)
next:    
    shr $1, %eax
    inc %edi
    cmpl $32, %edi
    jl start

    movl %ecx, -4(%ebp)
# koniec sprawdzania pozycji msb, wynik w -8(ebp), lsb w -4(ebp)

    movl 16(%ebp), %edx         # iloraz
    movl 24(%ebp), %ecx         # reszta

# zerowanie ilorazu i reszty
    movl $0, %edi
zeroq:
    movl (%edx,%edi,4), %eax
    xorl %eax, %eax
    movl %eax, (%edx,%edi,4)
    inc %edi
    cmpl 20(%ebp), %edi
    jl zeroq

    movl $0, %edi
zeror:
    movl (%ecx,%edi,4), %eax
    xorl %eax, %eax
    movl %eax, (%ecx,%edi,4)
    inc %edi
    cmpl 28(%ebp), %edi
    jl zeror

# long division
    movl $0x1, -12(%ebp)         
    movl -8(%ebp), %esi         # pozycja msb

shiftposition:
    cmpl $0, %esi
    jle aftershift
    shll $1, -12(%ebp)
    dec %esi
    jmp shiftposition
aftershift:
    
    movl 28(%ebp), %edi
    dec %edi
    movl 24(%ebp), %ecx
    movl (%ecx,%edi,4), %eax           # najnizszy doubleword w reszcie
    movl dataStartPtr, %ebx
    movl (%ebx), %ecx           # najwyższy doubleword w dzielnej
    
    movl dataLength, %edi
    dec %edi
    shll $5, %edi
    addl -8(%ebp), %edi 

petla:
    cmpl $0, %edi
    jl dalej
    shl $1, %eax                # przesuniecie reszty o 1 w lewo
    and -12(%ebp), %ecx
    
    movl -8(%ebp), %esi
revshiftposition:
    cmpl $0, %esi
    jle afterrevshift
    shrl $1, %ecx
    dec %esi
    jmp revshiftposition    
afterrevshift:

    orl %ecx, %eax

    movl 8(%ebp), %edx
    movl (%edx), %edx
    cmpl %edx, %eax
    jl pomin 
    subl %edx, %eax
pomin:
    movl %eax, -16(%ebp) # zapisanie reszty (najnizszego doubleword) w zmiennej lokalnej
    pushl dataLength
    pushl %ebx
    call shiftOneLeft
    addl $8, %esp
    movl (%ebx), %ecx
    movl -16(%ebp), %eax
    dec %edi
    jmp petla
 #   cmpl $32, -8(%ebp) 
 #   jge dalej

dalej:
    movl -16(%ebp), %eax

function_exit:
    movl %ebp, %esp			#odtworzenie starego stosu
	popl %ebp
    ret
