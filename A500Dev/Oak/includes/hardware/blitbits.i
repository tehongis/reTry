
	IFND	ADDITIONALINCLUDES_HARDWARE_BLITBITS_I
ADDITIONALINCLUDES_HARDWARE_BLITBITS_I	SET	1

BLTCON0B_ASH3	=	15
BLTCON0B_ASH2	=	14
BLTCON0B_ASH1	=	13
BLTCON0B_ASH0	=	12
BLTCON0B_USEA	=	11
BLTCON0B_USEB	=	10
BLTCON0B_USEC	=	9
BLTCON0B_USED	=	8
BLTCON0B_LF7	=	7
BLTCON0B_LF6	=	6
BLTCON0B_LF5	=	5
BLTCON0B_LF4	=	4
BLTCON0B_LF3	=	3
BLTCON0B_LF2	=	2
BLTCON0B_LF1	=	1
BLTCON0B_LF0	=	0

BLTCON0F_ASH3	=	1<<BLTCON0B_ASH3
BLTCON0F_ASH2	=	1<<BLTCON0B_ASH2
BLTCON0F_ASH1	=	1<<BLTCON0B_ASH1
BLTCON0F_ASH0	=	1<<BLTCON0B_ASH0
BLTCON0F_USEA	=	1<<BLTCON0B_USEA
BLTCON0F_USEB	=	1<<BLTCON0B_USEB
BLTCON0F_USEC	=	1<<BLTCON0B_USEC
BLTCON0F_USED	=	1<<BLTCON0B_USED
BLTCON0F_LF7	=	1<<BLTCON0B_LF7
BLTCON0F_LF6	=	1<<BLTCON0B_LF6
BLTCON0F_LF5	=	1<<BLTCON0B_LF5
BLTCON0F_LF4	=	1<<BLTCON0B_LF4
BLTCON0F_LF3	=	1<<BLTCON0B_LF3
BLTCON0F_LF2	=	1<<BLTCON0B_LF2
BLTCON0F_LF1	=	1<<BLTCON0B_LF1
BLTCON0F_LF0	=	1<<BLTCON0B_LF0


BLTCON1B_BSH3	=	15
BLTCON1B_BSH2	=	14
BLTCON1B_BSH1	=	13
BLTCON1B_BSH0	=	12
; in Area mode
BLTCON1B_DOFF	=	7
BLTCON1B_EFE	=	4
BLTCON1B_IFE	=	3
BLTCON1B_FCI	=	2
BLTCON1B_DESC	=	1
BLTCON1B_LINE	=	0
; in Fill mode
BLTCON1B_DPFF	=	7
BLTCON1B_SIGN	=	6
BLTCON1B_OVF	=	5
BLTCON1B_SUD	=	4
BLTCON1B_SUL	=	3
BLTCON1B_AUL	=	2
BLTCON1B_SING	=	1
;BLTCON1B_LINE	=	0

BLTCON1F_BSH3	=	1<<BLTCON1B_BSH3
BLTCON1F_BSH2	=	1<<BLTCON1B_BSH2
BLTCON1F_BSH1	=	1<<BLTCON1B_BSH1
BLTCON1F_BSH0	=	1<<BLTCON1B_BSH0
; in Area mode
BLTCON1F_DOFF	=	1<<BLTCON1B_DOFF
BLTCON1F_EFE	=	1<<BLTCON1B_EFE
BLTCON1F_IFE	=	1<<BLTCON1B_IFE
BLTCON1F_FCI	=	1<<BLTCON1B_FCI
BLTCON1F_DESC	=	1<<BLTCON1B_DESC
BLTCON1F_LINE	=	1<<BLTCON1B_LINE
; in Fill mode
BLTCON1F_DPFF	=	1<<BLTCON1B_DPFF
BLTCON1F_SIGN	=	1<<BLTCON1B_SIGN
BLTCON1F_OVF	=	1<<BLTCON1B_OVF
BLTCON1F_SUD	=	1<<BLTCON1B_SUD
BLTCON1F_SUL	=	1<<BLTCON1B_SUL
BLTCON1F_AUL	=	1<<BLTCON1B_AUL
BLTCON1F_SING	=	1<<BLTCON1B_SING
;BLTCON1F_LINE	=	1<<BLTCON1B_LINE


	ENDC	; ADDITIONALINCLUDES_HARDWARE_BLITBITS_I