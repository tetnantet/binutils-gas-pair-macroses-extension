/* Macro Extension Support
   Copyright (C) 2023-2025

   Written by Dmytro Tarasiuk,
      DmytroTarasiuk@membrama.com

   This file is part of the GNU Assembler patches.

   Patches is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details. */

/*
        Usage similar to IF-THEN

            ...calculate condition...
            IF <j\condition>
                ...then-code...
            FI


        Usage similar to IF-THEN-ELSE

            ...calculate condition...
            IF <j\condition>
                ...then-code...
            ELSE
                ...else-code...
            FI


        Usage similar to IF-ELSE without THEN

            ...calculate condition...
            IF <j\condition>
            ELSE
                ...else-code...
            FI


        Usage similar to SWITCH/CASE/DEFAULT

            ...calculate condition for case 1...
            IF <j\condition>
                ...code for case 1...

            ELSE
                ...calculate condition for case 2...
            ELIF <j\condition>
                ...code for case 2...

            ELSE
                ...calculate condition for case 3...
            ELIF <j\condition>
                ...code for case 3...

            ELSE
                ...code for default...
            FI


        Usage similar to SWITCH/CASE without DEFAULT

            ...calculate condition for case 1...
            IF <j\condition>
                ...code for case 1...

            ELSE
                ...calculate condition for case 2...
            ELIF <j\condition>
                ...code for case 2...

            ELSE
                ...calculate condition for case 3...
            ELIF <j\condition>
                ...code for case 3...
            FI
 */

        .macro IF cond:req
                j\cond LABEL_IF_THEN\@
                jmp LABEL_IF_ELSE\(++IF)
            LABEL_IF_THEN\@:
        .endm


        .macro ELIF cond:req
                j\cond LABEL_ELIF_THEN\(IF)\(++ELIF)
                jmp LABEL_ELIF_ELSE\(IF)\(ELIF)
            LABEL_ELIF_THEN\(IF)\(ELIF):
        .endm


        .macro WORKADD_LABEL_ELIF_ELSE
            LABEL_ELIF_ELSE\(IF)\(ELIF--):
        .endm

        .macro ELSE
                jmp LABEL_FI\(IF)
                    .ifdef LABEL_ELIF_THEN\(IF)\(ELIF)
                WORKADD_LABEL_ELIF_ELSE
                .exitm
                    .endif
            LABEL_IF_ELSE\(IF):
        .endm


        .macro WORKADD_LABEL_FI
            LABEL_FI\(IF--):
        .endm

        .macro FI
                    .ifdef LABEL_ELIF_THEN\(IF)\(ELIF) /* Is ELIF used previously? */
                WORKADD_LABEL_ELIF_ELSE
                    .endif
                    .ifndef LABEL_IF_ELSE\(IF) /* Is ELSE absent? */
            LABEL_IF_ELSE\(IF):
                    .endif
                WORKADD_LABEL_FI
        .endm
