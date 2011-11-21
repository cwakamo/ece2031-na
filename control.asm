			ORG 	&H000
	
			LOAD 	EnLeftSensor
			LOAD 	EnRightSensor
			OUT 	SONAREN			;enable the left and right sensors
			
			IN		DIST_Left		;read the value from the left sensor
			STORE 	Left			;store the value from the left sensor to memory
			IN		DIST_Right		;read the value from the right sensor
			SUB		Left			;subtract the value from the left sensor
			JPOS 	Follow_Left		;if (right - left > 0) then (right > left) so we should follow the left wall, since it's closer
			JNEG 	Follow_Right	;if (right - left < 0) then (right < left) so we should follow the right wall, since it's closer
			JZERO	Follow_Right	;if (right - left = 0) then (right = left) so we don't know what to do. we'll follow the right wall by default.
	
SETUP:		LOAD	EnFrontSonar	;enable the front sonar
			OR		EnSideSonar		;enable the side sonar
			OUT		SONAREN			;write to the control register which sonars we want to enable

CHECK_FRONT:IN		DIST_Front
			SUB		MIN_FRONT_THRESH;subtract the front threshold so we can figure out if we're below it.
			JPOS	CHECK_SIDE		;it's positive, so we're not too close in the front
			JUMP	INSIDE_TURN		;we're within the front threshold, so we need to make an inside turn

CHECK_SIDE:	IN		DIST_Side
			SUB		NO_SIDE_THRESH	;subtract the threshold at which we think we're no longer next to a wall
			JPOS	OUTSIDE_TURN	;since the value is positive after subtracting the no-wall threshold, we need to make an outside turn
			ADD		NO_SIDE_THRESH	;get back to the value that we initially had
			SUB		MIN_SIDE_THRESH	;subtract the min side threshold so we can figure out if we're below it.
			JNEG	MOVE_AWAY		;since it's negative, we're below the threshold so we need to move away from the wall
			ADD		MIN_SIDE_THRESH	;get back to the value that we initially had
			SUB		MAX_SIDE_THRESH	;subtract the max side threshold so we can figure out if we're above it.
			JPOS	MOVE_TOWARD		;since it's positive, we're above the threshold so we need to move toward

			JUMP	MOVE_FORWARD	;we're within the thresholds, so we can just move forward

INSIDE_TURN:						;here we handle the mechanics necessary to make the inside turn
			JUMP	CHECK_FRONT		;after we make changes to complete the turn, we go back and check the front again

OUTSIDE_TURN:
			JUMP	CHECK_FRONT		

MOVE_AWAY:							;here we handle the mechanics necessary to move away from the wall
			JUMP	CHECK_FRONT		;after we make adjustments, we go back to check the front again

MOVE_TOWARD:						;here we handle the mechanics necessary to move back toward the wall
			JUMP	CHECK_FRONT		;after we make adjustments, we go back to check the front again

MOVE_FORWARD:						;here we handle the mechanics necessary to maintain a forward path
			JUMP	CHECK_FRONT		;after we make adjustments, we go back to check the front again