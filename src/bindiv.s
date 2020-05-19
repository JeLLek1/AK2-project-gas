# argumenty: dzielnik, dlugosc, zmienna dla ilorazu, dlugosc, zmienna dla reszty, dlugosc
# dzielna brana jest ze zmiennej globalnej, a potem kopiowana do lokalnej zmiennej
# na wyjscie w eax jest zapisane 0 - reszta równa 0 lub 1 - reszta nie równa 0
# argument trzeci i czwarty (iloraz) trzeba podać, ale nie są na razie do niczego używane 
.section .data
.section .text
.global bindiv

.type bindiv, @function
bindiv:

    pushl %ebp
    movl %esp, %ebp
    subl $24, %esp

    pushl %edi              # save local register
    pushl %esi              # save local register
    pushl %ebx              # save local register 

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

# zaalokowanie pomocniczej zmiennej dla reszty
    movl 28(%ebp), %eax
    shll $2, %eax
    pushl %eax
    call allocate
    addl $4, %esp
    movl %eax, -16(%ebp)

# skopiowanie dataStartPtr do lokalnej zmiennej
    movl dataLength, %eax
    shll $2, %eax
    pushl %eax
    call allocate
    addl $4, %esp
    movl %eax, -24(%ebp)
    
    movl dataStartPtr, %eax
    movl -24(%ebp), %ebx
    movl dataLength, %edi
    
copy_start:
    dec %edi
    cmpl $0, %edi
    jl after_copy
    movl (%eax,%edi,4), %ecx
    movl %ecx, (%ebx,%edi,4)
    jmp copy_start

after_copy:   


    movl 28(%ebp), %edi
    dec %edi
    movl %edi, -20(%ebp)
#    movl 24(%ebp), %eax
#    movl (%eax,%edi,4), %eax           # najnizszy doubleword w reszcie
#    movl %eax, -20(%ebp)
    movl -24(%ebp), %ebx
    movl (%ebx), %ecx           # najwyższy doubleword w dzielnej

    movl dataLength, %edi
    dec %edi
    shll $5, %edi
    addl -8(%ebp), %edi 

petla:
    cmpl $0, %edi
    jl dalej
    pushl 28(%ebp)
    pushl 24(%ebp)
    call shiftOneLeft
    #shl $1, %eax                # przesuniecie reszty o 1 w lewo
    and -12(%ebp), %ecx
    
    movl -8(%ebp), %esi
revshiftposition:
    cmpl $0, %esi
    jle afterrevshift
    shrl $1, %ecx
    dec %esi
    jmp revshiftposition    
afterrevshift:
    pushl %ebx
    movl -20(%ebp), %esi            # ustawienie pozycji na ostatnią (dlugosc-1)
 #   movl %edi, -20(%ebp)
 #   movl 28(%ebp), %edi
 #   dec %edi
    movl 24(%ebp), %ebx             # pobranie adresu reszty
    movl (%ebx,%esi,4), %eax        # pobranie najmniej znaczacej czesci reszty
 #   movl -20(%ebp), %edi 
    orl %ecx, %eax                  # dopisanie z prawej strony wybranego bitu z dzielnej
    movl %eax, (%ebx,%esi,4)       # zapisanie najmniej znaczacej czesci do reszty

    pushl %edi
copyit:                             # skopiowanie reszty do pomocniczej zmiennej
    movl (%ebx,%esi,4), %eax
    movl -16(%ebp), %edi
    movl %eax, (%edi,%esi,4)
    dec %esi
    cmpl $0, %esi
    jge copyit

    movl -20(%ebp), %esi            # ustawienie pozycji na ostatnią (dlugosc-1)
    movl 8(%ebp), %edx              # pobranie adresu dzielnika
    clc
    pushf
subTemp:
    movl (%edx,%esi,4), %ecx        # pobranie czesci dzielnika od prawej strony
    movl (%edi,%esi,4), %eax        # pobranie czesci reszty od prawej strony 
    popf
    sbbl %ecx, %eax
    pushf 
    movl %eax, (%edi,%esi,4)
    dec %esi
    cmp $0, %esi
    jge subTemp
    popf

    movl $0, %esi
check_result:
    cmpl -20(%ebp), %esi
    jg after_check 
    movl (%edi,%esi,4), %eax
    inc %esi
    cmpl $0, %eax
    jl waitf
    je check_result

after_check:

    movl $0, %esi
copy2it:                             # skopiowanie pomocniczej zmiennej do reszty
    movl (%edi,%esi,4), %eax
    movl %eax, (%ebx,%esi,4)
    inc %esi
    cmpl -20(%ebp), %esi
    jle copy2it

waitf:
    popl %edi
    popl %ebx

    
#    cmpl %edx, %eax
#    jl pomin 
#    subl %edx, %eax
pomin:
 #   movl 24(%ebp), %ebx
 #   movl -20(%ebp), %esi
 #   movl %eax, (%ebx,%esi,4) # zapisanie reszty (najnizszego doubleword) w zmiennej lokalnej
 #   popl %ebx
    pushl dataLength
    pushl %ebx
    call shiftOneLeft
    addl $8, %esp
    movl (%ebx), %ecx
 #   movl -16(%ebp), %eax
    dec %edi
    jmp petla
 #   cmpl $32, -8(%ebp) 
 #   jge dalej

dalej:
   movl -20(%ebp), %edi
   movl 24(%ebp), %ebx
   movl (%ebx,%edi,4), %ecx
   cmpl $0, %ecx
   je equalzero
   movl $1, %eax
   jmp bindiv_exit

equalzero:
    movl $0, %eax

bindiv_exit:
    popl %ebx
    popl %esi
    popl %edi
    
    movl %ebp, %esp			#odtworzenie starego stosu
	popl %ebp
    ret
