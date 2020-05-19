# przesuniecie liczby o jeden bajt w lewo
# na potrzeby bindiv
# argumenty: liczba do przesuniecia, dlugosc (liczba doublewordów)

.section .data
.section .text
.global shiftOneLeft

.type shiftOneLeft, @function
shiftOneLeft:
    pushl %ebp
    movl %esp, %ebp
    pushl %edi              # save local register
    pushl %esi              # save local register
    pushl %ebx              # save local register 
    
    movl 8(%ebp), %eax
    movl 12(%ebp), %edi
    dec %edi
    movl $0, %esi
    
shiftloop:
    movl (%eax,%edi,4), %ebx
    shl $1, %ebx
#    or %esi, %ebx
#    movl %ebx, (%eax,%edi,4)
    jc carryone
    jnc carryzero
slnext:
    dec %edi
    cmpl $0, %edi
    jge shiftloop
    jmp dalej

carryone:
    or %esi, %ebx
    movl %ebx, (%eax,%edi,4)
    movl $1, %esi
    jmp slnext

carryzero:
    or %esi, %ebx
    movl %ebx, (%eax,%edi,4)
    movl $0, %esi
    jmp slnext

dalej:

function_exit:
    popl %ebx
    popl %esi
    popl %edi
    
    movl %ebp, %esp			#odtworzenie starego stosu
	popl %ebp
    ret
