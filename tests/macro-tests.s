                .code64
#-------------------------------------------------------------------------------
.include "Def.DO-WHILE-DONE_WHEN.s"
.include "Def.IF-ELSE-ELIF-FI.s"
#-------------------------------------------------------------------------------

                .set STDOUT, 1
                .set __NR_write, 1
                .set __NR_exit, 60
                .set EXIT_SUCCESS, 0

                .global _start
                .global main
    _start:
    main:
                mov %rsp, %rbp                  /* For correct debugging */

                .data
    OK:         .ascii " OK "
    FAIL:       .ascii "FAIL"
                .text

/* Test 235: usage as IF-THEN */

                xor %dx, %dx
                mov $5, %ax

                test $1, %ax
                IF nz
                    mov $1, %dl
                FI

                mov FAIL, %eax
                cmp $1, %dl
                jne 235f
                mov OK, %eax
    235:
                mov %eax, res235
                .data
    info235:    .ascii "Test 235: "
    res235:     .ascii "???? while usage as IF-THEN\n"
                .set info235_sz, . - info235
                .text
                /* Printing message */
                mov $__NR_write, %rax
                mov $STDOUT, %rdi
                mov $info235, %rsi
                mov $info235_sz, %rdx
                syscall

/* Test 523: usage as IF-ELSE */

                xor %dx, %dx
                mov $5, %ax

                test $1, %ax
                IF z
                ELSE
                    mov $1, %dl
                FI

                mov FAIL, %eax
                cmp $1, %dl
                jne 523f
                mov OK, %eax
    523:
                mov %eax, res523
                .data
    info523:    .ascii "Test 523: "
    res523:     .ascii "???? while usage as IF-ELSE\n"
                .set info523_sz, . - info523
                .text
                /* Printing message */
                mov $__NR_write, %rax
                mov $STDOUT, %rdi
                mov $info523, %rsi
                mov $info523_sz, %rdx
                syscall

/* Test 325: usage as IF-THEN-ELSE */

                xor %dx, %dx
                mov $5, %ax

                test $1, %ax
                IF z
                    mov $1, %dl
                ELSE
                    mov $2, %dl
                FI

                test $2, %ax
                IF z
                    mov $1, %dh
                ELSE
                    mov $2, %dh
                FI

                mov FAIL, %eax
                cmp $2, %dl
                jne 325f
                cmp $1, %dh
                jne 325f
                mov OK, %eax
    325:
                mov %eax, res325
                .data
    info325:    .ascii "Test 325: "
    res325:     .ascii "???? while usage as IF-THEN-ELSE\n"
                .set info325_sz, . - info325
                .text
                /* Printing message */
                mov $__NR_write, %rax
                mov $STDOUT, %rdi
                mov $info325, %rsi
                mov $info325_sz, %rdx
                syscall

/* Test 532: usage as SWITCH/CASE/DEFAULT */

                xor %dx, %dx
                mov $5, %ax

                test $8, %ax            /* condition 1 */
                IF nz
                    mov $1, %dl         /* case 1 */
                ELSE
                    test $4, %ax        /* condition 2 */
                ELIF nz
                    mov $2, %dl         /* case 2 - must be OK */
                ELSE
                    test $2, %ax        /* condition 3 */
                ELIF nz
                    mov $3, %dl         /* case 3 */
                ELSE
                    mov $4, %dl         /* default */
                FI

                test $8, %ax            /* condition 1 */
                IF nz
                    mov $1, %dh         /* case 1 */
                ELSE
                    test $10, %ax       /* condition 2 */
                ELIF nz
                    mov $2, %dh         /* case 2 */
                ELSE
                    test $16, %ax       /* condition 3 */
                ELIF nz
                    mov $3, %dh         /* case 3 */
                ELSE
                    mov $4, %dh         /* default - must be OK */
                FI

                mov FAIL, %eax
                cmp $2, %dl
                jne 532f
                cmp $4, %dh
                jne 532f
                mov OK, %eax
    532:
                mov %eax, res532
                .data
    info532:    .ascii "Test 532: "
    res532:     .ascii "???? while usage as SWITCH/CASE/DEFAULT\n"
                .set info532_sz, . - info532
                .text
                /* Printing message */
                mov $__NR_write, %rax
                mov $STDOUT, %rdi
                mov $info532, %rsi
                mov $info532_sz, %rdx
                syscall

/* Test 352: usage as SWITCH/CASE without DEFAULT */

                xor %dx, %dx
                mov $5, %ax

                test $8, %ax            /* condition 1 */
                IF nz
                    mov $1, %dl         /* case 1 */
                ELSE
                    test $10, %ax       /* condition 2 */
                ELIF nz
                    mov $2, %dl         /* case 2 */
                ELSE
                    test $16, %ax       /* condition 3 */
                ELIF nz
                    mov $3, %dl         /* case 3 */
                FI

                test $1, %ax            /* condition 1 */
                IF nz
                    mov $1, %dh         /* case 1 - must be OK */
                ELSE
                    test $4, %ax        /* condition 2 */
                ELIF nz
                    mov $2, %dh         /* case 2 */
                ELSE
                    test $5, %ax        /* condition 3 */
                ELIF nz
                    mov $3, %dh         /* case 3 */
                FI

                mov FAIL, %eax
                cmp $0, %dl
                jne 352f
                cmp $1, %dh
                jne 352f
                mov OK, %eax
    352:
                mov %eax, res352
                .data
    info352:    .ascii "Test 352: "
    res352:     .ascii "???? while usage as SWITCH/CASE without DEFAULT\n"
                .set info352_sz, . - info352
                .text
                /* Printing message */
                mov $__NR_write, %rax
                mov $STDOUT, %rdi
                mov $info352, %rsi
                mov $info352_sz, %rdx
                syscall

/* Test 253: usage as SWITCH/CASE without DEFAULT */

                xor %dx, %dx
                mov $5, %ax

                test $1, %ax
                IF nz
                    test $10, %ax
                    IF nz
                        mov $4, %dl
                    ELSE
                        mov $5, %dl /* OK */
                    FI

                    test $10, %ax
                    IF z
                        inc %dl /* OK */
                    ELSE
                        dec %dl
                    FI
                ELSE
                    test $4, %ax
                ELIF nz
                    mov $2, %dl
                ELSE
                    test $5, %ax
                ELIF nz
                    mov $3, %dl
                FI

                test $1, %ax
                IF nz
                    test $2, %ax
                    IF nz
                    ELSE
                        test $8, %ax
                        IF nz
                            mov $9, %dh
                        ELSE
                            test $10, %ax
                        ELIF nz
                            mov $8, %dh
                        ELSE
                            test $4, %ax
                        ELIF nz
                            test $13, %ax
                            IF nz
                                mov $7, %dh /* OK */
                            ELSE
                                mov $6, %dh
                            FI
                        ELSE
                            mov $6, %dh
                        FI
                    FI
                ELSE
                    test $10, %ax
                ELIF nz
                    mov $2, %dh
                ELSE
                    test $16, %ax
                ELIF nz
                    mov $3, %dh
                FI

                mov FAIL, %eax
                cmp $6, %dl
                jne 253f
                cmp $7, %dh
                jne 253f
                mov OK, %eax
    253:
                mov %eax, res253
                .data
    info253:    .ascii "Test 253: "
    res253:     .ascii "???? while usage nested IF/THEN/ELSE/SWITCH/CASE/DEFAULT\n"
                .set info253_sz, . - info253
                .text
                /* Printing message */
                mov $__NR_write, %rax
                mov $STDOUT, %rdi
                mov $info253, %rsi
                mov $info253_sz, %rdx
                syscall

/* Test 971: usage as DO/DO_WHILE/DONE/DONE_WHEN */

                .data
    info971:    .ascii "Test 971: "
                .ascii "     while usage nested DO/DONE_WHEN/IF/ELSE/ELIF/FI\n"
                .ascii "        Below must be printed styled triangle:\n"
                .set info971_sz, . - info971
                .text
                /* Printing message */
                mov $__NR_write, %rax
                mov $STDOUT, %rdi
                mov $info971, %rsi
                mov $info971_sz, %rdx
                syscall

                .set MAX_WIDTH, 11
/*
321.987654321         Column CC for ','
_***********, 6  ((MAX_WIDTH+3) >> 1)-6=1
__*********,_ 5  ((MAX_WIDTH+3) >> 1)-5=2
___*******,__ 4  ((MAX_WIDTH+3) >> 1)-4=3
____*****,___ 3  ((MAX_WIDTH+3) >> 1)-3=4
_____***,____ 2  ((MAX_WIDTH+3) >> 1)-2=5
______*,_____ 1  ((MAX_WIDTH+3) >> 1)-1=6

If (column_counter == CC) then print ','
else
If (column_counter < CC || ((MAX_WIDTH+3) >> 1)+row_counter <= column_counter) then print '_'
else
print '*'
*/

                .bss
    row_counter:    .space 2
    column_counter: .space 2
    fill_char:      .space 1
                .text
                mov $MAX_WIDTH+2, %ax
                shr $1, %ax
                mov %ax, row_counter
                DO /* ... by rows */
                    mov $MAX_WIDTH+2, %ax
                    mov %ax, column_counter
                    DO /* ... by columns */
                        mov $MAX_WIDTH+3, %bx
                        shr $1, %bx
                        mov %bx, %dx /* (MAX_WIDTH+3) >> 1 */
                        sub row_counter, %bx /* CC */

                        cmp %bx, %ax
                        IF e /* prepare print ',' */
                            movb $',, fill_char #'
                        ELSE
                        ELIF l /* column_counter < CC, %ax < %bx */
                            movb $'_, fill_char #'
                        ELSE
                            add row_counter, %dx
                            cmp %ax, %dx
                        ELIF le /*((MAX_WIDTH+3) >> 1)+row_counter <= column_counter */
                            movb $'_, fill_char #'
                        ELSE
                            movb $'*, fill_char #'
                        FI

                        /* Printing fill_char */
                        mov $__NR_write, %rax
                        mov $STDOUT, %rdi
                        mov $fill_char, %rsi
                        mov $1, %rdx
                        syscall

                        mov column_counter, %ax
                        dec %ax
                        mov %ax, column_counter
                    DONE_WHEN ng

                    .data
    new_line:       .ascii "\n"
                    .text
                    /* Printing new line char */
                    mov $__NR_write, %rax
                    mov $STDOUT, %rdi
                    mov $new_line, %rsi
                    mov $1, %rdx
                    syscall

                    decw row_counter
                DONE_WHEN ng /* Exit when row_counter <= 0 */


/* ---------------------------------------------------------------- */

                /* Exit from program */
                mov $__NR_exit, %rax
                mov $EXIT_SUCCESS, %rdi
                syscall
