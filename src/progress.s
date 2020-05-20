#Wyświetlanie postępu
#
#Dane:
# rootStartPtr - początek obszaru pamięci dla pierwiastka sprawdzanej liczby
# dataLength - długość danych * 4 bajty
#
#Stałe tekstowe:
# msg_slash - tekst oddzielający
# msg_endline - tekst końca linii
#
#stałe:
# SYS_WRITE - kod wywołania systemowego zapisu do pliku
# STD_OUT - kod wyjścia terminala podczas zapisu
# MSG_SLASH_L - długość tekstu oddzielającego
# MSG_ENDLINE_L - długość tekstu końca linii
#
#Argumenty 
# actualPtr - początek obszaru pamięci wyświetlanej
# startIndex - od którego indeksu ma zacząć
#

.section .data
	.equ SYS_WRITE, 4
	.equ STD_OUT, 1
	.equ actualPtr, 8
	.equ startIndex, -4
.section .text
msg_slash:
	.ascii " / "
	.equ MSG_SLASH_L, . - msg_slash
msg_endline:
	.ascii " postep\n"
	.equ MSG_ENDLINE_L, . - msg_endline
.global progress

.type progress, @function
progress:
	pushl %ebp
	movl %esp, %ebp				#prolog funkcji (jakby trzeba bylo korzystac z argumentow
	subl $8, %esp				#miejsce na zmienne lokalne

	movl dataLength, %eax
	movl %eax, startIndex(%ebp)
	decl startIndex(%ebp)			#indeks zmniejszony o 1 (do przedostatniej pozycji będzie wyświetlane) 
	#wyświetlanie aktualnej liczby
	movl $0, %esi				#początek danych do wyświetlenia
actualCheck:
	cmpl startIndex(%ebp), %esi		#dopóki indeks nie będzie równy ostatniemu do wyświetlenia
	je actualCheckSkip
	pushl %esi				#przechowanie na stosie indeksu
	movl actualPtr(%ebp), %eax
	pushl (%eax,%esi,4)			#liczba do wyświetlenia
	call displayNumber
	addl $4, %esp				#zdjęcie argumentów ze stosu
	popl %esi				#zdjęcie ze stosu indeksu
	incl %esi				#zmniejszenie indeksu
	jmp actualCheck
actualCheckSkip:
	#=============================
	#wypisanie w terminalu msg_slash
	movl $SYS_WRITE, %eax
	movl $STD_OUT, %ebx
	movl $msg_slash, %ecx
	movl $MSG_SLASH_L, %edx
	int $0x80
	#=========================================

	#wyświetlanie wszystkich iteracji
	movl $0, %esi			#początek danych do wyświetlenia
actualCheck1:
	cmpl startIndex(%ebp), %esi		#dopóki indeks nie będzie równy ostatniemu do wyświetlenia
	je actualCheckSkip1
	pushl %esi				#przechowanie na stosie indeksu
	movl rootStartPtr, %eax
	pushl (%eax,%esi,4)			#liczba do wyświetlenia
	call displayNumber
	addl $4, %esp				#zdjęcie argumentów ze stosu
	popl %esi				#zdjęcie ze stosu indeksu
	incl %esi				#zmniejszenie indeksu
	jmp actualCheck1
actualCheckSkip1:
	#=============================

	#wypisanie w terminalu msg_endline
	movl $SYS_WRITE, %eax
	movl $STD_OUT, %ebx
	movl $msg_endline, %ecx
	movl $MSG_ENDLINE_L, %edx
	int $0x80
	#=========================================

	movl %ebp, %esp			#odtworzenie starego stosu
	popl %ebp
	ret
