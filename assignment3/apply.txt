L_code_ptr_bin_apply:
        enter 0, 0
        ;finding the list's length
        xor rcx, rcx ;0
        mov rax, qword [rbp + 8 * 0] ;rax = num_of_args
        mov rax, qword [rbp + 8 * rax] ;TODO: rax = address of pair list
        mov rbx ,SOB_PAIR_CAR(rax) ;node val
        my_loop1:
                cmp rbx, sob_nil ;if nill
                je my_loop_end1 ;jmp end
                inc rcx 
                push rbx ;insrting val to stack
                mov rax, qword [SOB_PAIR_CDR(rax)] ;next node
                mov rbx ,SOB_PAIR_CAR(rax) ;next val
        my_loop_end1:

        ;make values in the opposite order:
        ;1.pushing all argument one more time in the right order
        mov rsi, rcx ;count-up
        mov rcx, 1 
        mov rdx, rsp ;marking the begining of the second pushing
        my_loop2:
                cmp rcx, rsi ; if rcx = n
                je my_loop_end2 ;then: jump to the end
                mov rax, qword [rdx + 8 * rcx] ;else: rax = next arg in correct order
                push rax
                inc rcx
        my_loop_end2:
        ;2.overwriting element above by element below but in correct order
        mov rcx, 1
        my_loop3:
                cmp rcx, rsi ;if rcx = n
                je my_loop_end3 ;then: jump to the end
                mov rax, qword [rsp + 8 * 1] ;else: get next arg in correct order
                lea rbx, [rsp + 8 * rsi] ;address of arg that needs to be over written
                mov [rbx], rax ;over writing arg in false order by arg with correct order
                add rsp, 8 ;pop arg we used
                inc rcx 
        my_loop_end3:
        ;3.pushing number of arguments
        push rcx
        mov rax, qword [rbp + 8 * 1] ;address of function to apply
        call rax ;apply the function
        leave
	ret

