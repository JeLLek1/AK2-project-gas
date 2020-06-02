#sprawdzanie czy liczby są równe
#
#argumenty funkcji
# numbera - wskaźnik pierwszej liczby
# numberb - wskaźnik drugiej liczby
#
#wynik
# 0 - różne
# 1 - równe

.section .data
	.equ numbera, 8
	.equ numberb, 12
.section .text

.global isEqual

.type isEqual, @function
isEqual:
	push %ebp
	mov %esp, %ebp			#nowa ramka call
	subl $4, %esp			#miejsce na zmienne lokalne

	pushl %ebx
   	pushl %esi

	movl numbera(%ebp), %eax		#wskaźnik na numbera do rejestru
	movl numberb(%ebp), %edx		#wskaźnik na numberb do rejestru
	movl $0, %esi
testIfEqual:
	movl (%edx, %esi, 4), %ebx		#przeniesienie numberb do rejestru
	cmpl %ebx, (%eax, %esi, 4)
	jne testIfEqualSkip			#jeżeli rózne od numbera to koniec testu
	incl %esi				#zwiększenie indeksu
	cmpl dataLength, %esi
	jb testIfEqual 				#dopóki indeks mniejszy od length
	movl $1, %eax				#jeżeli wszystkie równe to eax = 1
	jmp endTest
testIfEqualSkip:
	movl $0, %eax				#jeżeli różne to 0

endTest:
	popl %ebx
   	popl %esi

	movl %ebp, %esp
	popl %ebp			#Przwywrócenie starej ramki call
	ret
