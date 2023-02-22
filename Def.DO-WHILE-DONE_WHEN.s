/* Macro Extension Support
   Copyright (C) 2023-2025

   Written by Dmytro Tarasiuk,
      DmytroTarasiuk@membrama.com

   This file is part of the GNU Assembler patches.

   Patches is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details. */

    /* DO ... DONE_WHEN
     * DO ... DO_WHILE ... [DO_WHILE] ... DONE
     * DO ... DO_WHILE ... [DO_WHILE ...] DONE_WHEN
     */


    .macro DO
        LABEL_DO\(++DO)_start:
    .endm


    .macro DO_WHILE cond:req
            j\cond LABEL_DO_WHILE\@continue
            jmp LABEL_DONE\(DO)_end
        LABEL_DO_WHILE\@continue:
    .endm


    .macro WORKADD_LABEL_DONE_end
        LABEL_DONE\(DO--)_end:
    .endm

    .macro DONE_WHEN cond:req
            j\cond LABEL_DONE\(DO)_end
            jmp LABEL_DO\(DO)_start
            WORKADD_LABEL_DONE_end
    .endm


    .macro DONE
            jmp LABEL_DO\(DO)_start
            WORKADD_LABEL_DONE_end
    .endm
