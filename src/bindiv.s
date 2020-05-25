# argumenty: dzielnik, dlugosc, zmienna dla reszty, dlugosc
# dzielna brana jest ze zmiennej globalnej
# na wyjscie w eax jest zapisane 0 - reszta równa 0 lub 1 - reszta nie równa 0
.section .data
	.equ msb, -8
    .equ lsb, -4
    .equ fullmsb, -12
    .equ mask, -16
    .equ tempRemainder, -20
    .equ numerator, 0
    .equ denominator, 8
    .equ denominatorLength, 12
    .equ remainder, 16
    .equ remainderLength, 20
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
    movl %edi, msb(%ebp)
next:    
    shr $1, %eax
    inc %edi
    cmpl $32, %edi
    jl start

    movl %ecx, lsb(%ebp)
# koniec sprawdzania pozycji msb, wynik w -8(ebp), lsb w -4(ebp)
    movl remainder(%ebp), %ecx         # reszta

# zerowanie ilorazu i reszty
    movl $0, %edi
zeror:
    movl (%ecx,%edi,4), %eax
    xorl %eax, %eax
    movl %eax, (%ecx,%edi,4)
    inc %edi
    cmpl remainderLength(%ebp), %edi
    jl zeror

before_div:

# wyznaczenie maski
    movl $1, %eax
    movl $0, %edi
find_mask:
    cmp msb(%ebp), %edi
    je found_mask
    shl $1, %eax
    inc %edi 
    jmp find_mask
found_mask:
    movl %eax, mask(%ebp)

# zaalokowanie pomocniczej zmiennej dla reszty
    movl remainderLength(%ebp), %eax
    shll $2, %eax
    pushl %eax
    call allocate
    addl $4, %esp
    movl %eax, tempRemainder(%ebp)

# okreslenie liczby petli
    movl dataLength, %eax
    dec %eax
    shl $5, %eax
    addl msb(%ebp), %eax
    movl %eax, fullmsb(%ebp)
    movl %eax, %edi
    movl $0, %esi # zerowy dword do rozpatrzenia

divloop:
    cmp $0, %edi
    pushl %edi
    jl longdiv_exit

    pushl remainderLength(%ebp)
    pushl remainder(%ebp)
    call shiftOneLeft
    addl $8, %esp

    movl dataStartPtr, %eax
    movl (%eax,%esi,4), %eax
    and mask(%ebp), %eax

    movl remainder(%ebp), %ebx
    movl remainderLength(%ebp), %ecx
    dec %ecx
    movl (%ebx,%ecx,4), %edx

    cmp $0, %eax
    je zerotor
    movl $1, %eax
    
masked_cont:
    or %eax, %edx
    movl %edx, (%ebx,%ecx,4)
    movl mask(%ebp), %eax
    shr $1, %eax
    cmp $0, %eax
    movl %eax, mask(%ebp)
    jne changed_cont

    inc %esi
    movl $0x80000000, mask(%ebp)

changed_cont:

# porównanie reszty z dzielnikiem, jeśli większa to zmniejsz resztę o dzielnik
# skopiowanie reszty do pomocniczej zmiennej
    movl remainderLength(%ebp), %edi
    movl remainder(%ebp), %eax
    movl tempRemainder(%ebp), %ebx
copy_rem:
    dec %edi
    cmp $0, %edi
    jl after_copy
    movl (%eax,%edi,4), %ecx
    movl %ecx, (%ebx,%edi,4)
    jmp copy_rem
after_copy:
# odjecie od pomocniczej reszty dzielnika
    movl denominator(%ebp), %eax

    movl remainderLength(%ebp), %edi
    clc
    pushf
subTemp:
    dec %edi
    movl (%eax,%edi,4), %ecx        # pobranie czesci dzielnika od prawej strony
    movl (%ebx,%edi,4), %edx        # pobranie czesci reszty od prawej strony 
    popf
    sbbl %ecx, %edx
    pushf 
    movl %edx, (%ebx,%edi,4)
    cmp $0, %edi
    jg subTemp
    popf

# sprawdzenie, czy wynik jest wiekszy lub rowny 0
    movl $0, %edi
check_sub:
    cmp remainderLength(%ebp), %edi
    jge after_check
    movl (%ebx,%edi,4), %eax
    inc %edi
    cmp $0, %eax
    jl omit_sub

after_check:
    movl remainder(%ebp), %eax
    movl remainderLength(%ebp), %edi
copy_temp:
    dec %edi
    cmp $0, %edi
    jl after_copy_t
    movl (%ebx,%edi,4), %ecx
    movl %ecx, (%eax,%edi,4)
    jmp copy_temp
after_copy_t:

omit_sub:
    popl %edi
    dec %edi
    jmp divloop

longdiv_exit:
    movl $0, %edi
    movl remainder(%ebp), %edx
lastcheck:
    cmp remainderLength(%ebp), %edi
    jge zeroexit
    movl (%edx,%edi,4), %ecx
    inc %edi
    cmp $0, %ecx
    je lastcheck
    movl $1, %eax 
    jmp lexit

zeroexit:
    movl $0, %eax

lexit:
    popl %ebx
    popl %esi
    popl %edi
    
    movl %ebp, %esp			#odtworzenie starego stosu
	popl %ebp
    ret
    
zerotor:
    movl $0, %eax
    jmp masked_cont
