#Funkcja wykonująca dzielenie
#Wyjscie równe 1 oznacza liczbę pierwszą, 0 - liczbę niebędącą pierwszą, inne liczbę poza zakresu

.section .data
.section .text

.global division

.type division, @function
division:
    pushl %ebp
    movl %esp, %ebp

    #sprawdzenie, czy dzielna jest liczbą mieszczącą się na 8 bajtach
    movl dataLength, %edi
    cmpl $2, %edi
    jg too_big

    movl rootStartPtr, %eax
    movl (%eax), %ecx          #pobranie pierwiastka

    cmpl $2, %ecx
    jl too_low

    movl $1, %ebx

    #pętla dzieląca dzielną przez kolejne liczby od 2 do pierwiastka
loop:
    inc %ebx
    
    cmpl %ecx, %ebx
    jg end_of_loop
    movl $0, %edx               #nadpisanie ilorazu
    movl dataStartPtr, %esi     #pobranie adresu
    movl (%esi), %eax           #pobranie liczby spod danego adresu
    cmpl $2, %edi
    cmove 4(%esi), %edx         #jeśli dzielna zawiera się na czterech bajtach to nie potrzeba pobierać kolejnych 4
    divl %ebx                   #dzielenie edx:eax przez ebx, wynik w edx
    cmpl $0, %edx               #jeśli reszta to zero to liczba nie jest pierwsza
    je end_of_loop

end_of_loop:
    movl %edx, %eax
    jmp function_exit

    #2,3 - liczby pierwsze. 0,1 - liczby niebędące pierwszymi
too_low:


    #do zrobienia obsluga liczb wiekszych niz mieszczące się na 8 bajtach
too_big:


function_exit:
    movl %ebp, %esp			#odtworzenie starego stosu
	popl %ebp
    ret
    