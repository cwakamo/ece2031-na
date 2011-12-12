; control.asm (SCOMP assembly)
; This code implements a program that controls an
; AmigoBot for the purposes of wall-following.
; Team NA
; ECE 2031 L05
; 12/07/2011
			ORG 	&H000

Safe_2:  	IN      XIO           	; Don't anything until key pressed again
        	AND     Key3Mask      	; Is the user pressing key 3?
        	JPOS    Safe_2         	; If not, wait

MANUALDETECT: IN 	SWITCHES
			STORE 	CHECK
			AND 	One
			JZERO 	AUTODETECT
			LOAD 	CHECK
			AND 	Two
			JPOS 	SETUP_R
			JUMP 	SETUP_L
        	
AUTODETECT: LOAD	EnSonar0
			OR		EnSonar5
			OUT 	SONAREN
			
			IN		DIST0			;read the left distance
			STORE	LEFTD
			IN		DIST5			;read the right distance
			;STORE	RIGHTD
			SUB		LEFTD
			JPOS	SETUP_L
			JUMP	SETUP_R				
			
SETUP_R:	LOAD	One
			OUT 	LEDS
			LOAD	EnSonar3		;enable the front sonar
			OR		EnSonar5		;enable the side sonar
			OR		EnSonar4		;enable the middle sonar
			OUT		SONAREN			;write to the control register which sonars we want to enable
			
CHECK_FRONT_R: IN	DIST3
			OUT		SEVENSEG
			SUB		MINFRONTTHRESH 	;subtract the front threshold so we can figure out if we're below it.
			JPOS	CHECK_CRASH_R	;it's positive, so we're not too close in the front
			JUMP	INSIDE_TURN_R	;we're within the front threshold, so we need to make an inside turn

CHECK_CRASH_R: IN 	DIST4
			SUB 	MINCRASHTHRESH
			JPOS	CHECK_SIDE_R
			JUMP 	INSIDE_TURN_R

CHECK_SIDE_R: IN	DIST5
			OUT		LCD
			SUB		NOSIDETHRESH	;subtract the threshold at which we think we're no longer next to a wall
			JPOS	OUTSIDE_TURN_R	;since the value is positive after subtracting the no-wall threshold, we need to make an outside turn
			ADD		NOSIDETHRESH	;get back to the value that we initially had
			SUB		MINSIDETHRESH	;subtract the min side threshold so we can figure out if we're below it.
			JNEG	MOVE_AWAY_R		;since it's negative, we're below the threshold so we need to move away from the wall
			ADD		MINSIDETHRESH	;get back to the value that we initially had
			SUB		MAXSIDETHRESH	;subtract the max side threshold so we can figure out if we're above it.
			JPOS	MOVE_TOWARD_R	;since it's positive, we're above the threshold so we need to move toward

			JUMP	MOVE_FORWARD_R	;we're within the thresholds, so we can just move forward

INSIDE_TURN_R: LOAD One
			OUT 	LEDS
			LOAD	QSPEED
			OUT		LVELCMD
			LOAD	HALFSPEED
			OUT		RVELCMD			;here we handle the mechanics necessary to make the inside turn
			JUMP	CHECK_FRONT_R	;after we make changes to complete the turn, we go back and check the front again

OUTSIDE_TURN_R: LOAD Two
			OUT 	LEDS
			LOAD	OSPEED
			OUT		RVELCMD
			LOAD	HALFSPEED
			OUT		LVELCMD
			JUMP	CHECK_FRONT_R		

MOVE_AWAY_R: LOAD 	Three
			OUT 	LEDS			;here we handle the mechanics necessary to move away from the wall
			LOAD	HALFSPEED
			OUT     RVELCMD
			LOAD	ASPEED
			OUT     LVELCMD
			JUMP	CHECK_FRONT_R	;after we make adjustments, we go back to check the front again

MOVE_TOWARD_R: LOAD Four		
			OUT 	LEDS			;here we handle the mechanics necessary to move back toward the wall
			LOAD	ASPEED
			OUT     RVELCMD
			LOAD	HALFSPEED
			OUT     LVELCMD
			JUMP	CHECK_FRONT_R	;after we make adjustments, we go back to check the front again

MOVE_FORWARD_R: LOAD Five
			OUT 	LEDS
			LOAD	HALFSPEED
			OUT     RVELCMD
			OUT     LVELCMD			;here we handle the mechanics necessary to maintain a forward path
			JUMP	CHECK_FRONT_R	;after we make adjustments, we go back to check the front again			

; FOLLOW LEFT
			
SETUP_L:	LOAD	Two
			OUT		LEDS
			LOAD	EnSonar0		;enable the side sonar
			OR		EnSonar1		;enable the crash sonar
			OR		EnSonar2		;enable the front sonar
			OUT		SONAREN			;write to the control register which sonars we want to enable
			
CHECK_FRONT_L: IN	DIST2
			OUT		SEVENSEG
			SUB		MINFRONTTHRESH 	;subtract the front threshold so we can figure out if we're below it.
			JPOS	CHECK_CRASH_L	;it's positive, so we're not too close in the front
			JUMP	INSIDE_TURN_L	;we're within the front threshold, so we need to make an inside turn

CHECK_CRASH_L: IN	DIST1
			SUB 	MINCRASHTHRESH
			JPOS	CHECK_SIDE_L
			JUMP 	INSIDE_TURN_L

CHECK_SIDE_L: IN	DIST0
			OUT		LCD
			SUB		NOSIDETHRESH	;subtract the threshold at which we think we're no longer next to a wall
			JPOS	OUTSIDE_TURN_L	;since the value is positive after subtracting the no-wall threshold, we need to make an outside turn
			ADD		NOSIDETHRESH	;get back to the value that we initially had
			SUB		MINSIDETHRESH	;subtract the min side threshold so we can figure out if we're below it.
			JNEG	MOVE_AWAY_L		;since it's negative, we're below the threshold so we need to move away from the wall
			ADD		MINSIDETHRESH	;get back to the value that we initially had
			SUB		MAXSIDETHRESH	;subtract the max side threshold so we can figure out if we're above it.
			JPOS	MOVE_TOWARD_L	;since it's positive, we're above the threshold so we need to move toward

			JUMP	MOVE_FORWARD_L	;we're within the thresholds, so we can just move forward

INSIDE_TURN_L: LOAD One
			OUT 	LEDS
			LOAD	QSPEED
			OUT		RVELCMD
			LOAD	HALFSPEED
			OUT		LVELCMD			;here we handle the mechanics necessary to make the inside turn
			JUMP	CHECK_FRONT_L	;after we make changes to complete the turn, we go back and check the front again

OUTSIDE_TURN_L: LOAD Two
			OUT 	LEDS
			LOAD	OSPEED
			OUT		LVELCMD
			LOAD	HALFSPEED
			OUT		RVELCMD
			JUMP	CHECK_FRONT_L		

MOVE_AWAY_L: LOAD 	Three
			OUT 	LEDS			;here we handle the mechanics necessary to move away from the wall
			LOAD	HALFSPEED
			OUT     LVELCMD
			LOAD	ASPEED
			OUT     RVELCMD
			JUMP	CHECK_FRONT_L	;after we make adjustments, we go back to check the front again

MOVE_TOWARD_L: LOAD Four		
			OUT 	LEDS			;here we handle the mechanics necessary to move back toward the wall
			LOAD	ASPEED
			OUT     LVELCMD
			LOAD	HALFSPEED
			OUT     RVELCMD
			JUMP	CHECK_FRONT_L	;after we make adjustments, we go back to check the front again

MOVE_FORWARD_L: LOAD Five
			OUT 	LEDS
			LOAD	HALFSPEED
			OUT     LVELCMD
			OUT     RVELCMD			;here we handle the mechanics necessary to maintain a forward path
			JUMP	CHECK_FRONT_L	;after we make adjustments, we go back to check the front again	
			
Zero:        DW    0
One:         DW    1
Two:         DW    2
Three:       DW    3
Four:        DW    4
Five:        DW    5
Six:         DW    6
Seven:       DW    7
Eight:       DW    8
Nine:        DW    9
Ten:         DW    10
MAX:		 DW	   &H0FFF
EnSonar0:    DW    &B00000001
EnSonar1:    DW    &B00000010
EnSonar2:    DW    &B00000100
EnSonar3:    DW    &B00001000
EnSonar4:    DW    &B00010000
EnSonar5:    DW    &B00100000
EnSonar6:    DW    &B01000000
EnSonar7:    DW    &B10000000
RNEG:        DW    0
Key3Mask:    DW    &B00000100
Key2Mask:	 DW	   &B00000010
Key1Mask:    DW    &B00000001

FULLSPEED:   DW    &H007F
LeftVel:     DW    0
RightVel:    DW    0

HALFSPEED:   DW    &H0040
QSPEED:		 DW    &H0004
OSPEED:		 DW	   &H0004
ASPEED:		 DW	   &H0020

CHECK:		DW 0

LEFTD:		DW 0
RIGHTD:		DW 0

MINCRASHTHRESH: DW 200
MINFRONTTHRESH: DW 500
NOSIDETHRESH: DW 1000
MINSIDETHRESH: DW 200
MAXSIDETHRESH: DW 220

; IO address space map
SWITCHES:    EQU   &H00
LEDS:        EQU   &H01
TIMER:       EQU   &H02
XIO:         EQU   &H03
SEVENSEG:    EQU   &H04
LCD:         EQU   &H06
LPOSLOW:     EQU   &H80
LPOSHIGH:    EQU   &H81
LVEL:        EQU   &H82
LVELCMD:     EQU   &H83
RPOSLOW:     EQU   &H88
RPOSHIGH:    EQU   &H89
RVEL:        EQU   &H8A
RVELCMD:     EQU   &H8B
SONAR:       EQU   &HA0  ; base address for more than 16 registers....
DIST0:       EQU   &HA8  ; the eight sonar distance readings
DIST1:       EQU   &HA9  ; ...
DIST2:       EQU   &HAA  ; ...
DIST3:       EQU   &HAB  ; ...
DIST4:       EQU   &HAC  ; ...
DIST5:       EQU   &HAD  ; ...
DIST6:       EQU   &HAE  ; ...
DIST7:       EQU   &HAF  ; ...
SONAREN:     EQU   &HB2  ; register to control which sonars are enabled