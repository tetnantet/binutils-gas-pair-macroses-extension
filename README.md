# binutils-gas-pair-macroses

* What is it?

This is patches for gnu macro assembler from binutils package.
The current release without patches can be downloaded from
https://ftp.gnu.org/gnu/binutils.

* Why GNU assembler?

Because GNU assembler supports lots of wide spread modern
architectures. See
https://en.wikipedia.org/wiki/Comparison_of_assemblers

* What is this patch for?

Anyone can create the following macroses:

    .macro DO
        LABEL_DO\(++DO)_start:
    .endm

    .macro DO_WHILE cond
            j\cond LABEL_DO_WHILE\@continue
            jmp LABEL_DONE\(DO)_end
        LABEL_DO_WHILE\@continue:
    .endm

    .macro DONE_WHEN cond
            j\cond LABEL_DONE\(DO)_end
            jmp LABEL_DO\(DO)_start
        LABEL_DONE\(DO--)_end:
    .endm

    .macro DONE
            jmp LABEL_DO\(DO)_start
        LABEL_DONE\(DO--)_end:
    .endm

Using the macros above (which don't compile at all without patching),
anyone can write a program like the one below:

                .set STDOUT, 1
                .set __NR_write, 1
                .set __NR_exit, 60
                .set MAX_WIDTH, 11
                DO
                    .data
    row_length:     .long MAX_WIDTH
                    .text
                    mov row_length, %eax
                    sub $MAX_WIDTH, %eax
                    neg %eax
                    shr $1, %eax
                    .data
    space_counter:
    star_counter:   .long 0
                    .text
                    mov %eax, space_counter

                    DO
                        cmpb $0, space_counter
                        DO_WHILE g
                        .data
    space:              .ascii " "
                        .text
                        /* Printing the space char */
                        mov $__NR_write, %rax
                        mov $STDOUT, %rdi
                        mov $space, %rsi
                        mov $1, %rdx
                        syscall
                        decl space_counter
                    DONE

                    mov row_length, %eax
                    mov %eax, star_counter
                    DO
                        cmpb $0, star_counter
                        DO_WHILE g
                        .data
    star:               .ascii "*"
                        .text
                        /* Printing the star char */
                        mov $__NR_write, %rax
                        mov $STDOUT, %rdi
                        mov $star, %rsi
                        mov $1, %rdx
                        syscall
                        decl star_counter
                    DONE

                    .data
    new_line:       .ascii "\n"
                    .text
                    /* Printing the new line char */
                    mov $__NR_write, %rax
                    mov $STDOUT, %rdi
                    mov $new_line, %rsi
                    mov $1, %rdx
                    syscall

                    decl row_length
                    decl row_length
                DONE_WHEN le

This code prints to stdout the following triangle:

    ***********
     *********
      *******
       *****
        ***
         *

Gas does not allow such deep nested construction without patching:

      18  DO <---------------------\
              [...]                |
      32      DO <-------------\   |
                  [...]        |   |
      34          DO_WHILE ----|   |
                  [...]        |   |
      40      DONE <-----------/   |
              [...]                |
      44      DO <-------------\   |
                  [...]        |   |
      46          DO_WHILE ----|   |
                  [...]        |   |
      53      DONE <-----------/   |
              [...]                |
      61  DONE_WHEN <--------------/

Above is shown the couple of pair (open/close) connected with one another
macroses (DO ... DONE) which are nested into another pair (open/close)
connected with one another macroses (DO .. DONE_WHEN). To work correctly
each cycle pair macroses must be managed with 2 parameters: one for the
sequential pairs and one for the nested pairs in each sequential one.
These parameters allow generating unique labels (see "LABEL_DO_2x1_start"
below, etc) in each pair. Current macro language including .altmacro
features looks weak to be happy with it.

The corresponded listing can be the following:

      18              	                DO
      18              	>  LABEL_DO_1x0_start:
    
      32              	                    DO
      32              	>  LABEL_DO_2x0_start:
    
      34              	                        DO_WHILE g
      34 0020 7F02     	>  jg LABEL_DO_WHILE2continue
      34 0022 EB27     	>  jmp LABEL_DONE_2x0_end
      34              	>  LABEL_DO_WHILE2continue:
    
      40              	                    DONE
      40 0049 EBCD     	>  jmp LABEL_DO_2x0_start
      40              	>  LABEL_DONE_2x0_end:
    
      44              	                    DO
      44              	>  LABEL_DO_2x1_start:
    
      46              	                        DO_WHILE g
      46 0061 7F02     	>  jg LABEL_DO_WHILE6continue
      46 0063 EB27     	>  jmp LABEL_DONE_2x1_end
      46              	>  LABEL_DO_WHILE6continue:

      52              	                    DONE
      52 008a EBCD     	>  jmp LABEL_DO_2x1_start
      52              	>  LABEL_DONE_2x1_end:
    
      61              	                DONE_WHEN le
      61 00b8 7E05     	>  jle LABEL_DONE_1x0_end
      61 00ba E944FFFF 	>  jmp LABEL_DO_1x0_start
      61      FF
      61              	>  LABEL_DONE_1x0_end:

* How to apply patches?

Select directory for the downloaded binutils version,
copy patch files

    macro.h.diff
    macro.c.diff

to the local binutils directory near correspoded files

    macro.h
    macro.c

and apply patches:

    $ patch macro.h < macro.h.diff
    $ patch macro.c < macro.c.diff

Now it is possible to (re-)build binutils as usual:

    $ cd <bunutils_dir>
    $ ./configure --prefix ../binutils-usr
    $ make && make install

When all is correct it is possible to translate your .s programs
by using as from ../binutils-usr/bin/as utility.

* What advantages does it provide?

The possible answers:

1. This makes it possible to significantly reduce the number of labels.
Each label is first and foremost a name that should be catchy. Coming
up with such names sometimes takes up a significant portion of the
program writing time.

2. If there is code that needs to be closer to the system architecture
than the C compiler or other high-level language allows, and at the same
time needs to be easily portable between different architectures, then
creating macros for some of your "virtual" machine is the solution, if
the macros are powerful enough for this, and the assembler supports
these architectures.

* If it's so good, why hasn't it been implemented yet?

Features of the construction of the translator create a difference
between expectation and reality when writing macros that interact with
each other. If there are conditional blocks of translation in the macro,
then the parser can see the macro nesting change construction in the
name of the label, for example "LABEL\\(IF--)_END", and calculate it
prematurely, affecting the previous labels use. As a workaround in this
cases, labels or instructions with such labels should be placed in
separate macros. This is a serious and important drawback. Fortunately,
the need for such macros is not great.
