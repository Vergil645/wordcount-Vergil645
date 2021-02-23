                section         .text
                global          _start
				
_start:
; rbx -- счётчик слов
; rsi -- адрес начала буфера
; r8 = 1, если предыдущий символ является буквой
;      0, иначе
                xor             rbx, rbx
                sub             rsp, buf_size
                mov             rsi, rsp
                xor             r8, r8

read:
                xor             rax, rax
                xor             rdi, rdi
                mov             rdx, buf_size
                syscall
				
; rax -- количество введённых символов
                test            rax, rax
                jz              check_last_word
                js              read_error
; rcx -- индекс текущего символа в буфере
                xor             rcx, rcx
				
check_char:
                cmp             rcx, rax
                je              read
				
                mov             r9, 1
				
				mov             r10b, byte[rsi + rcx]
                cmp             r10b, 32
                je              space
                cmp             r10b, 9
                jb              skip
                cmp             r10b, 13
                ja              skip
				
space:
                xor             r9, r9		
                test            r8, r8
                jz              skip
				
                inc             rbx

skip:
                mov             r8, r9
                inc             rcx
                jmp             check_char
				
check_last_word:
                test            r8, r8
                jz              quit
				
                inc             rbx
				
quit:
                mov             rax, rbx
                call            print_int
				
                mov             rax, sys_exit
                xor             rdi, rdi
                syscall
				
print_int:
                mov             rsi, rsp
                mov             rbx, 10
                dec             rsi
                mov             byte [rsi], 0x0a
				
next_digit:
                xor             rdx, rdx
                div             rbx
                add             dl, '0'
                dec             rsi
                mov             byte [rsi], dl
                test            rax, rax
                jnz             next_digit
				
                mov             rax, 1
                mov             rdi, 1
                mov             rdx, rsp
                sub             rdx, rsi
                syscall
				
                ret
				
read_error:
; rax = 1 -- sys_write
; rdi = 2 -- stderr
                mov             rax, 1
                mov             rdi, 2
                mov             rsi, read_error_msg
                mov             rdx, read_error_len
                syscall

; rax = 60 -- sys_exit
; rdi != 0 -- программа завершилась ошибкой
                mov             rax, sys_exit
                mov             rdi, 1
                syscall

                section         .rodata

sys_exit        equ             60
buf_size:       equ             8192
read_error_msg: db              "read failure", 0x0a
read_error_len: equ             $ - read_error_msg
