/* Copyright (c) 2008, 2009 Red Hat Incorporated.
   All rights reserved.

   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions
   are met: 

     Redistributions of source code must retain the above copyright 
     notice, this list of conditions and the following disclaimer.

     Redistributions in binary form must reproduce the above copyright
     notice, this list of conditions and the following disclaimer in the
     documentation and/or other materials provided with the distribution.

     The name of Red Hat Incorporated may not be used to endorse 
     or promote products derived from this software without specific 
     prior written permission.

   This software is provided by the copyright holders and contributors
   "AS IS" and any express or implied warranties, including, but not
   limited to, the implied warranties of merchantability and fitness for
   a particular purpose are disclaimed.  In no event shall Red Hat
   incorporated be liable for any direct, indirect, incidental, special,
   exemplary, or consequential damages (including, but not limited to,
   procurement of substitute goods or services; loss of use, data, or
   profits; or business interruption) however caused and on any theory of
   liability, whether in contract, strict liability, or tort (including
   negligence or otherwise) arising in any way out of the use of this
   software, even if advised of the possibility of such damage.  */

	.text

	.extern	__isr_vectors
	.extern _tn_startup_hardware_init
	.extern _tn_startup
	
	.global _start
_start:
.LFB2:
	mvtc	#0, psw
	/* Enable the DN bit - this should have been done for us by
           the CPU reset, but it is best to make sure for ourselves.  */	
	mvtc    #0x100, fpsw
	mov	#__stack, r0
	mvtc	#__isr_vectors, intb

	bsr	_tn_startup_hardware_init

	mov	#__datastart, r1
	mov	#__romdatastart, r2
	mov	#__romdatacopysize, r3
	smovf

	mov	#__bssstart, r1
	mov	#0, r2
	mov	#__bsssize, r3
	sstr.l

	/* Initialise the small data area pointer.
	   The register used here must agree with the definition of
	   GP_BASE_REGNUM in gcc/config/rx/rx.h.  */
	mov	#__gp, r13

	bsr	_tn_startup

	mov	#0, r1 /* argc */
	mov	#0, r2 /* argv */
	mov	#0, r3 /* envv */
	bsr	_main
.LFE2:

	bsr	_exit

        .section .sdata
        .balign 4
        .global __gp
	.weak   __gp
__gp:   

	.section .data
	.global ___dso_handle
	.weak   ___dso_handle
___dso_handle:
	.long	0

;;; Provide Dwarf unwinding information that will help GDB stop
;;; backtraces at the right place.  This is stolen from assembly
;;; code generated by GCC with -dA.
	.section	.debug_frame,"",@progbits
.Lframe0:
	.4byte	.LECIE0-.LSCIE0	; Length of Common Information Entry
.LSCIE0:
	.4byte	0xffffffff	; CIE Identifier Tag
	.byte	0x1	; CIE Version
	.ascii "\0"	; CIE Augmentation
	.uleb128 0x1	; CIE Code Alignment Factor
	.sleb128 -1	; CIE Data Alignment Factor
	.byte	0xd	; CIE RA Column
	.byte	0xc	; DW_CFA_def_cfa
	.uleb128 0xc
	.uleb128 0x3
	.byte	0x8d	; DW_CFA_offset, column 0xd
	.uleb128 0x3
	.p2align 2
.LECIE0:
.LSFDE0:
	.4byte	.LEFDE0-.LASFDE0	; FDE Length
.LASFDE0:
	.4byte	.Lframe0	; FDE CIE offset
	.4byte	.LFB2		; FDE initial location
	.4byte	.LFE2-.LFB2	; FDE address range
	.byte   0xf     	; DW_CFA_def_cfa_expression
	.uleb128 1		; length of expression
	.byte 	0x30		; DW_OP_lit0
	.p2align 2
.LEFDE0:

	.text
