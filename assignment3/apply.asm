L_code_ptr_bin_apply:
        enter 0, 0
        ;finding the list's length
        xor rcx, rcx ;0
        mov rax, qword [rbp + 8 * 3] ;rax = num_of_args
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

        ;TODO: ecx = 0 ?

        ;make values in the opposite order:
        ;1.pushing all argument one more time in the right order
        mov rbx, rcx ;count-up
        mov rcx, 0 
        mov rdx, rsp ;marking the begining of the second pushing
        my_loop2:
                cmp rcx, rbx ; if rcx = n
                je my_loop_end2 ;then: jump to the end
                mov rax, qword [rdx + 8 * rcx] ;else: rax = next arg in correct order
                push rax
                inc rcx
        my_loop_end2:
        ;2.overwriting element above by element below but in correct order
        lea rdx, [8 * (rbx + 6)] ;nubmer of bytes we need to skip
        mov rsi, qword [rbp + 8 * 0] ; save old rbp
        mov rdi, qword [rbp + 8 * 1] ; save return address
        mov r8, qword [rbp + 8 * 4]  ; save function to apply
        mov rcx, 0
        my_loop3:
                cmp rcx, rbx ;if rcx = n
                je my_loop_end3 ;then: jump to the end
                mov rax, qword [rsp + 8 * 0] ;else: get next arg in correct order
                lea r9, [rsp + rdx] ;address of arg that needs to be over written
                mov [r9], rax ;over writing arg in false order by arg with correct order
                add rsp, 8 ;pop arg we used
                inc rcx 
        my_loop_end3:
        lea rsp, [rsp + 8 * rcx];pop all 1st time pushed args
        add rsp, 8 * 3 ; pop old-rbp, return-address, le-ap
        push rcx ;push number of arguments
        
        mov rax, qword [rbp + 8 * 1] ;address of function to apply
        call rax ;apply the function
        mov rsp, rbp; the part of leave we need
