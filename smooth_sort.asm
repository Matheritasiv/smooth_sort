;{{{ Leonardo index
section .rodata
        leonardo dq 0x0000000000000001, 0x0000000000000001, 0x0000000000000003,\
                0x0000000000000005, 0x0000000000000009, 0x000000000000000F,\
                0x0000000000000019, 0x0000000000000029, 0x0000000000000043,\
                0x000000000000006D, 0x00000000000000B1, 0x000000000000011F,\
                0x00000000000001D1, 0x00000000000002F1, 0x00000000000004C3,\
                0x00000000000007B5, 0x0000000000000C79, 0x000000000000142F,\
                0x00000000000020A9, 0x00000000000034D9, 0x0000000000005583,\
                0x0000000000008A5D, 0x000000000000DFE1, 0x0000000000016A3F,\
                0x0000000000024A21, 0x000000000003B461, 0x000000000005FE83,\
                0x000000000009B2E5, 0x00000000000FB169, 0x000000000019644F,\
                0x00000000002915B9, 0x0000000000427A09, 0x00000000006B8FC3,\
                0x0000000000AE09CD, 0x0000000001199991, 0x0000000001C7A35F,\
                0x0000000002E13CF1, 0x0000000004A8E051, 0x00000000078A1D43,\
                0x000000000C32FD95, 0x0000000013BD1AD9, 0x000000001FF0186F,\
                0x0000000033AD3349, 0x00000000539D4BB9, 0x00000000874A7F03,\
                0x00000000DAE7CABD, 0x00000001623249C1, 0x000000023D1A147F,\
                0x000000039F4C5E41, 0x00000005DC6672C1, 0x000000097BB2D103,\
                0x0000000F581943C5, 0x00000018D3CC14C9, 0x000000282BE5588F,\
                0x00000040FFB16D59, 0x000000692B96C5E9, 0x000000AA2B483343,\
                0x0000011356DEF92D, 0x000001BD82272C71, 0x000002D0D906259F,\
                0x0000048E5B2D5211, 0x0000075F343377B1, 0x00000BED8F60C9C3,\
                0x0000134CC3944175, 0x00001F3A52F50B39, 0x0000328716894CAF,\
                0x000051C1697E57E9, 0x000084488007A499, 0x0000D609E985FC83,\
                0x00015A52698DA11D, 0x0002305C53139DA1, 0x00038AAEBCA13EBF,\
                0x0005BB0B0FB4DC61, 0x000945B9CC561B21, 0x000F00C4DC0AF783,\
                0x0018467EA86112A5, 0x00274743846C0A29, 0x003F8DC22CCD1CCF,\
                0x0066D505B13926F9, 0x00A662C7DE0643C9, 0x010D37CD8F3F6AC3,\
                0x01B39A956D45AE8D, 0x02C0D262FC851951, 0x04746CF869CAC7DF,\
                0x07353F5B664FE131, 0x0BA9AC53D01AA911, 0x12DEEBAF366A8A43,\
                0x1E88980306853355, 0x316783B23CEFBD99, 0x4FF01BB54374F0EF,\
                0x81579F678064AE89, 0xD147BB1CC3D99F79
;}}}

section .text
global smooth_sort
;{{{ Smooth sort algorithm
;;  Input: rdi, rsi
smooth_sort:
        test    rsi, -2
        jz      __ss_ret
        push    rbp
        mov     r13, rsi
        xor     r8, r8
        xor     r9, r9
        xor     r10d, r10d
        xor     rsi, rsi
__ss_loop_ha:
        call    _heap_add
        cmp     rsi, r13
        jb      __ss_loop_ha
__ss_loop_hr:
        call    _heap_remove
        test    rsi, rsi
        jnz     __ss_loop_hr
        pop     rbp
__ss_ret:
        ret
;}}}

;{{{ Get left and right child of a Leonardo tree
;;  Input: rdi, esi
;; Output: r11, r12
;; Mutate: r11, r12, r15
_get_child:
        lea     r12, [rdi-8]
        mov     r11, r12
        mov     r15, [leonardo+8*(esi-2)]
        shl     r15, 3
        sub     r11, r15
        ret
;}}}
;{{{ Rebalance a Leonardo tree
;;  Input: rdi, esi
;; Output: mem
;; Mutate: rdx, rdi, esi, r11, r12, r15
__rb_loop_0:
        mov     [r12], r11
        mov     [rdi], rdx
        mov     rdi, r12
_rebalance:
        test    esi, -2
        jz      __rb_ret_0
        call    _get_child
        mov     rdx, [r11]
        cmp     rdx, [r12]
        cmovge  r12, r11
        jge     __rb_cont_0
        mov     rdx, [r12]
        dec     esi
__rb_cont_0:
        dec     esi
        mov     r11, [rdi]
        cmp     rdx, r11
        jg      __rb_loop_0
__rb_ret_0:
        ret
;}}}
;{{{ Rectify the Leonardo heap
;;    Input: rdi, rsi, r8, r9, r10d
;;   Output: mem
;; Immutate: rax, rbp, r13
_rectify:
        mov     rbx, rsi
        lea     rdx, [8*(rsi-1)]
        add     rdi, rdx
__rt_loop_0:
        mov     r14, [leonardo+8*r10d]
        cmp     rbx, r14
        jz      __rt_cont_0
        sub     rbx, r14
        cmp     r10d, 2
        jb      __rt_cont_1
        mov     esi, r10d
        call    _get_child
        mov     rdx, [r11]
        cmp     rdx, [r12]
        cmovge  r12, r11
        mov     rdx, [r12]
        cmp     rdx, [rdi]
__rt_cont_1:
        cmovl   r12, rdi
        mov     rdx, [r12]
        shl     r14, 3
        neg     r14
        add     r14, rdi
        mov     r15, [r14]
        cmp     rdx, r15
        jge     __rt_cont_0
        mov     [r12], r15
        mov     [r14], rdx
        mov     esi, r10d
        call    _rebalance
        mov     rdi, r14
        and     r8, -2
        bsf     rcx, r8
        jz      __rt_check_high
        add     r10d, ecx
        mov     r15, r9
        shr     r8, cl
        shr     r9, cl
        neg     cl
        and     cl, 0x3F
        shl     r15, cl
        or      r8, r15
        jmp     __rt_loop_0
__rt_check_high:
        bsf     rcx, r9
        mov     r8, r9
        shr     r8, cl
        xor     r9, r9
        or      rcx, 0x40
        add     r10d, ecx
        jmp     __rt_loop_0
__rt_cont_0:
        mov     esi, r10d
        call    _rebalance
        ret
;}}}
;{{{ Add an element to the Leonardo heap
;;  Input: rdi, rsi, r8, r9, r10d, r13
;; Output: mem, rsi, r8, r9, r10d
_heap_add:
        inc     rsi
        test    r8, 1
        jnz     __ha_else_0
        or      r8, 1
        inc     r10d
        jmp     __ha_cont_0
__ha_else_0:
        test    r8, 2
        jz      __ha_else_1
        clc
        rcr     r9, 1
        rcr     r8, 1
        clc
        rcr     r9, 1
        rcr     r8, 1
        or      r8, 1
        inc     r10d
        inc     r10d
        jmp     __ha_cont_0
__ha_else_1:
        cmp     r10d, 1
        jnz     __ha_else_2
        stc
        rcl     r8, 1
        rcl     r9, 1
        xor     r10d, r10d
        jmp     __ha_cont_0
__ha_else_2:
        lea     ecx, [r10d-1]
        mov     r15, r8
        shl     r9, cl
        shl     r8, cl
        neg     cl
        and     cl, 0x3F
        shr     r15, cl
        or      r9, r15
        or      r8, 1
        xor     r10d, r10d
        inc     r10d
__ha_cont_0:
        test    r10d, r10d
        jnz     __ha_else_3
        cmp     rsi, r13
        jmp     __ha_cont_1
__ha_else_3:
        cmp     r10d, 1
        jnz     __ha_else_4
        cmp     rsi, r13
        jz      __ha_cont_1
        lea     r15, [rsi+1]
        cmp     r15, r13
        jnz     __ha_cont_1
        test    r10d, 2
        jmp     __ha_cont_1
__ha_else_4:
        xor     rax, rax
        mov     r15, r13
        sub     r15, rsi
        cmp     r15, [leonardo+8*(r10d-1)]
        cmovbe  r15, rax
        test    r15, r15
__ha_cont_1:
        mov     rax, rdi
        mov     rbp, rsi
        jz      __ha_rt
        lea     rsi, [8*(rsi-1)]
        add     rdi, rsi
        mov     esi, r10d
        call    _rebalance
        jmp     __ha_ret
__ha_rt:
        shl     r9, 0x20
        or      r10, r9
        push    r8
        push    r10
        call    _rectify
        pop     r10
        pop     r8
        mov     r9, r10
        shr     r9, 0x20
        mov     r10d, r10d
__ha_ret:
        mov     rsi, rbp
        mov     rdi, rax
        ret
;}}}
;{{{ Remove an element from the Leonardo heap
;;  Input: rdi, rsi, r8, r9, r10d
;; Output: mem, rsi, r8, r9, r10d
_heap_remove:
        test    rsi, rsi
        jz      __hr_ret_0
        test    r10d, -2
        jnz     __hr_cont_0
        and     r8, -2
        bsf     rcx, r8
        jz      __hr_check_high
        add     r10d, ecx
        mov     r15, r9
        shr     r8, cl
        shr     r9, cl
        neg     cl
        and     cl, 0x3F
        shl     r15, cl
        or      r8, r15
        jmp     __hr_ret
__hr_check_high:
        bsf     rcx, r9
        jz      __hr_ret
        mov     r8, r9
        shr     r8, cl
        xor     r9, r9
        or      rcx, 0x40
        add     r10d, ecx
        jmp     __hr_ret
__hr_cont_0:
        mov     rax, rdi
        push    rsi
        lea     rsi, [8*(rsi-1)]
        add     rdi, rsi
        mov     esi, r10d
        call    _get_child
        and     r8, -2
        stc
        rcl     r8, 1
        rcl     r9, 1
        dec     r10d
        mov     rbp, r8
        mov     r13d, r9d
        shl     r13, 0x20
        or      r13, r10
        mov     rdi, rax
        mov     rsi, r11
        sub     rsi, rdi
        shr     rsi, 3
        inc     rsi
        call    _rectify
        mov     r10d, r13d
        shr     r13, 0x20
        mov     r9d, r13d
        mov     r8, rbp
        mov     rsi, [rsp]
        stc
        rcl     r8, 1
        rcl     r9, 1
        dec     r10d
        mov     rbp, r8
        mov     r13d, r9d
        shl     r13, 0x20
        or      r13, r10
        mov     rdi, rax
        dec     rsi
        call    _rectify
        mov     r10d, r13d
        shr     r13, 0x20
        mov     r9d, r13d
        mov     r8, rbp
        pop     rsi
        mov     rdi, rax
__hr_ret:
        dec     rsi
__hr_ret_0:
        ret
;}}}
