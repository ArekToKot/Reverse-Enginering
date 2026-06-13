section .data
    message db 'Gwiazda', 0xA, 0  ; Tekst + nowa linia + null
    message2 db 'Ile chcesz gwiazd: ', 0xA, 0 ; Zamiast 0xA można użyć call io_newlin
    message3 db 'Nie lubiesz gwiazd?', 0xA, 0
    message4 db 'Oszalales?', 0xA, 0
    message5 db 'Jeszcze raz? y/n', 0xA, 0
    buffer db 'Gwiazda ', 0x20, 0x30, 0xA, 0 ;Gwozda + znak spacji + znak cyfry + znak nowej lini + null

section .text
global main
extern io_print_string, io_get_dec, io_get_char, Sleep@4 ;deklaracje funkcji

main:
    mov ebp, esp  ; Dla poprawnego debugowania w SASM

    mov eax, message2 ;Wczytanie napisu z pamięci
    call io_print_string ;Funkcja wyświetlenia napisu
    
    call io_get_dec ;Wyłowanie funkcji wprowadzenia liczby
    mov ecx, eax ; Wprowadzoną liczbę przenosimy z, eax do rejestra pętli ecx   
    
    push ecx ;wrzucanie exc na stos by nie zaginął
    call io_get_char ;wczytanie dodatkowego entera
    pop ecx ;przywrócenie ecx
        
    cmp ecx, 0 ;Porównaj wartość ecx oraz 0
    jle skip ;Jeśli wartość jest mniejsza lub równa, przejdź do skip
    cmp ecx, 9 ;porównaj ecx oraz 100
    jg many ;skocz do many jeśli więcej niż 100
    
    mov ebx, 1  ; Licznik gwiazd zaczynamy od 1
    
    loop_tekst:
        push ecx      ; Zachowaj ECX na stosie
        
        mov al, bl ;przenosi dolny bajt z ebx do podrejestru eax
        add al, 0x30 ;konwertujemy na cyfrę ascii
        mov [buffer + 9], al ; zmienia cyfrę w napisie
        
        mov eax, buffer ; wczytuje napis
        call io_print_string ;Funkcja wyświetlenia napisu
        
        inc ebx ; incrementacja ebx czyli dodanie 1
        pop ecx        ; Przywróć ECX ze stosu
        loop loop_tekst ; Zmniejsz ECX i skocz, jeśli ECX != 0
        
    jmp exit ;Po zakończonej pętli skocz do exit

exit:
    
    mov eax, message5
    call io_print_string ;Wyświetla pytanie czy jeszcze raz uruchomić program
    
    call io_get_char
    cmp eax, 'y'
    je main ; jeśli wpisane y program wraca na początek
    
    jmp end ; w każdym innym wypadku skacze do end
    
end:
    push 1000
    call Sleep@4
    xor eax, eax    ;Ustaw kod programu na 0
    ret ;Koniec funkcji main
    
skip:
    mov eax, message3 ;napisz w przypadku 0 lub mniej
    call io_print_string
    jmp exit ;skacze do exit
    
many:
    mov eax, message4 ;napis jeśli będzie za dużo
    call io_print_string
    jmp exit ;skacze do exit