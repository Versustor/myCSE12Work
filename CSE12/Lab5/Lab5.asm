##########################################################################
# Created by: Quang, Benjamin
# bquang
# 11 December 2020
#
# Assignment: Lab 5: Functions and Graphics
# CMPE 012, Computer Systems and Assembly Language
# UC Santa Cruz, Fall 2020
#
# Description: This the program performs some specific graphics operations
#              on a small simulated display. These include clearing the 
#              entire display to a color and displaying rectangular and 
#              diamond shapes using a memory-mapped bitmap graphics display 
#              tool in MARS. 
#
# Notes: This program is intended to be run from the MARS IDE.
##########################################################################

#Fall 2020 CSE12 Lab5 Template File

## Macro that stores the value in %reg on the stack 
##  and moves the stack pointer.
.macro push(%reg)
	subi $sp $sp 4
	sw %reg 0($sp)
.end_macro 

# Macro takes the value on the top of the stack and 
#  loads it into %reg then moves the stack pointer.
.macro pop(%reg)
	lw %reg 0($sp)
	addi $sp $sp 4	
.end_macro

# Macro that takes as input coordinates in the format
# (0x00XX00YY) and returns 0x000000XX in %x and 
# returns 0x000000YY in %y
#---------------------------------
# Pseudocode:
# getCoordinates(input, x, y)
#     shift input left by 16 & load into y
#     shift y right by 16 
#     shift input right by 16 & load into x
#     output = x, y 
#---------------------------------
.macro getCoordinates(%input %x %y)
        sll %y, %input, 16
	srl %y, %y, 16
	srl %x, %input, 16
.end_macro

# Macro that takes Coordinates in (%x,%y) where
# %x = 0x000000XX and %y= 0x000000YY and
# returns %output = (0x00XX00YY)
#---------------------------------
# Pseudocode:
# formatCoordinates (output, x, y)
#     shift x left by 16 & load into output
#     add y to output
#     output = xy
#---------------------------------
.macro formatCoordinates(%output %x %y)
        sll %output, %x, 16
	add %output, %output, %y
.end_macro 

.data
originAddress: .word 0xFFFF0000

.text
        j done
    
done: nop
	li $v0 10 
	syscall

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  Subroutines defined below
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#*****************************************************
# Clear_bitmap: Given a color, will fill the bitmap display with that color.
#----------------------------------------------------------
# Pseudocode:
# clear_bitmap(color)
#     Load color & Origin & lastPixel
#     Loop:
#         printPixel(color, Origin)
#         Origin++ [move to next pixel]
#         if Origin <= lastPixel, go back to Loop
#         else:
#     End
#----------------------------------------------------------
#   Inputs:
#    $a0 = Color in format (0x00RRGGBB) 
#   Outputs:
#    No register outputs
#    Side-Effects: 
#    Colors the Bitmap display all the same color
#*****************************************************
clear_bitmap: nop
        push($ra)
	push($a0)
	move $t2, $a0			# save the Color from $a0 to $a1, we will need to set $a0 to the BitMap memory location.
	lw   $a0, originAddress   	# set $a0 to BitMap starting location.
	li   $t1, 0xFFFFFFFC		# fill up to the BitMap last location that we defined. 128x128 16,384 pixels.
clear_bitmapCont: nop			
	move $a1, $t2 			# set color to $a1 input parameter for draw_pixel,  $a0 is already has the bitmap memory location.
	sw $a1, ($a0)                   # the RGB color in $a1 set to $a0 bitmap memory location
	add $a0, $a0, 4			# advance to the next pixel.
	ble $a0, $t1, clear_bitmapCont  # loop until the last pixels is filled.		
	pop($a0)
	pop($ra)	
 	jr $ra

#*****************************************************
# draw_pixel:
#  Given a coordinate in $a0, sets corresponding value
#  in memory to the color given by $a1	
#-----------------------------------------------------
# Pseudocode:
# draw_pixel(xy, color)
#     Split xy into x & y
#     Offset = 4((row_size*x) + y) [formula from bitmap array + 4 byte pixel]
#     Load in Origin 
#     newOrigin = Origin + Offset 
#     print_pixel(base_point_x, base_point_y, color) [coordinates from newOrigin]
#-----------------------------------------------------
#   Inputs:
#    $a0 = coordinates of pixel in format (0x00XX00YY)
#    $a1 = color of pixel in format (0x00RRGGBB)
#   Outputs:
#    No register outputs
#*****************************************************
draw_pixel: nop
        push ($t1)
	push ($t2)
        # sets up pixelPosition
        getCoordinates ($a0, $t1, $t2) # split $a0 into x ($t1) & y ($t2)
        mul $t3, $t1, 128              # (row_size*x) 
	add $t3, $t3, $t2              # Offset = (row_size*x) + y
	mul $t3, $t3, 4		       # 4 bytes for each pixel; (Offset*4)
	lw  $t4, originAddress         # add in originAddress
	add $t4, $t4, $t3              # add in Offset to pixelPosition
	la  $a0, ($t4)                 # load in pixelPosition into $a0
	
	# prints pixel with selected color
	sw  $a1, ($a0)                 # the RGB color in $a1 set to $a0 bitmap memory location
	pop ($t2)
	pop ($t1)
	jr $ra
	
#*****************************************************
# get_pixel:
#  Given a coordinate, returns the color of that pixel	
#-----------------------------------------------------
# Pseudocode:
# get_pixel(xy)
#    Split xy into x & y
#    Offset = 4((row_size*x) + y) [formula from bitmap array + 4 byte pixel]
#    Load in Origin 
#    newOrigin = Origin + Offset 
#    Load in newOrigin
#-----------------------------------------------------
#   Inputs:
#    $a0 = coordinates of pixel in format (0x00XX00YY)
#   Outputs:
#    Returns pixel color in $v0 in format (0x00RRGGBB)
#*****************************************************
get_pixel: nop
        getCoordinates ($a0, $t1, $t2) # split $a0 into x ($t1) & y ($t2)
	mul $t3, $t1, 128
 	add $t3, $t3, $t2
	mul $t3, $t3, 4		# 4 bytes for each pixel.
	lw  $t4, originAddress
 	add $t4, $t4, $t3

 	lw $v0, ($t4)
	jr $ra

#*****************************************************
#draw_rect: Draws a rectangle on the bitmap display.
#-----------------------------------------------------
# Pseudocode:
# draw_rect(color, width, height, base_point_x, base_point_y)
#     Store color
#     Set rowHeightCount = 1
#
# rowCount: 
#     Set columnCount = 1
# columnPrint:
#     print_pixel(base_point_x, base_point_y, color)
#     move down 1 
#     columnCount++
# if columnCount <= height, loop back to columnPrint
# else:
#     rowHeightCount++ 
#     move right 1
# if rowHeightCount++ <= width, loop back to rowCount
# else: 
#     Finished
#-----------------------------------------------------
#    Inputs:
#     $a0 = coordinates of top left pixel in format (0x00XX00YY)
#     $a1 = width and height of rectangle in format (0x00WW00HH)
#     $a2 = color in format (0x00RRGGBB) 
#    Outputs:
#     No register outputs
#*****************************************************
draw_rect: nop
	push($ra)			# since this is nested sub-routine call, save the $ra.	
	move $t9, $a2			# save the Color 		
	getCoordinates ($a0, $t1, $t2)  # $t1 has the 0x000000XX; $t2 has the 0x000000YY	
	getCoordinates ($a1, $t5, $t6)	# $t5 has the (Column) Width of the Rectagle, $t6 has the (Row) Height of the Rectagle.
	li $t7, 1			# $t7 is the counter for Row-Height

draw_rectRowCont:	
	push ($t2)
	li $t8, 1			  # $t8 is the counter for Column-Width
draw_rectColumnCont: nop			
	move $a1, $t9 			  # set color to $a1 input parameter for draw_pixel,  $a0 is already has the bitmap memory location.			
	formatCoordinates ($t0, $t1, $t2) # the $t0 has 0x00XX00YY coordinate
	move $a0, $t0
	jal draw_pixel			  # $a0 needs to have 0x00XX00YY, $a1 RGB color.
	add $t2, $t2, 1			  # advance to the next Column - pixel.
	add $t8, $t8, 1			  # increment the Column counter by 1.
	ble $t8, $t6, draw_rectColumnCont # loop until the last pixels is filled.		
	add $t7, $t7, 1			  # increment the Row coounter by 1.
	add $t1, $t1, 1			  # advance to the next row by 1.

	pop($t2)		
	ble $t7, $t5, draw_rectRowCont
	pop($ra)

 	jr $ra

#***********************************************
# draw_diamond:
#  Draw diamond of given height peaking at given point.
#  Note: Assume given height is odd.
#-----------------------------------------------------
# Pseudocode:
# draw_diamond(height, base_point_x, base_point_y)
#     for (dy = 0; dy <= h; dy++)
#         y = base_point_y + dy
#
#     if dy <= h/2
#         x_min = base_point_x - dy
#         x_max = base_point_x + dy
#     else
#         x_min = base_point_x - floor(h/2) + (dy - ceil(h/2)) = base_point_x - h + dy
#         x_max = base_point_x + floor(h/2) - (dy - ceil(h/2)) = base_point_x + h - dy
#
#     for (x=x_min; x<=x_max; x++) 
#         draw_diamond_pixels(x, y)
#-----------------------------------------------------
#   Inputs:
#    $a0 = coordinates of top point of diamond in format (0x00XX00YY)
#    $a1 = height of the diamond (must be odd integer)
#    $a2 = color in format (0x00RRGGBB)
#   Outputs:
#    No register outputs
#***************************************************
draw_diamond: nop
        push($ra)			# since this is nested sub-routine call, save the $ra.	
	move $t9, $a2			# save the Color 		
	getCoordinates ($a0, $t1, $t2)  # split $a0 into x ($t1) & y ($t2)	
	move $t3, $a1		        # $t3 Diamond-Height		
	move $t4, $zero			# $t4 is the dy, initialize to Zero before looping thru.
calLoopCont:	
	add $t5, $t2, $t4		# $t5 is Y = base_point_y + dy
	div $t6, $t3, 2			# $t6 = height / 2. to be compare with dy - $t4
	ble $t4, $t6, calXMinXMax       # if dy <= h/2, j to calXMinXMax
	sub $t7, $t1, $t3		# else part calculate XMin, XMax $t7 has the XMin
	add $t7, $t7, $t4
	
	add $t8, $t1, $t3		# else part calculate XMin, XMax $t8 has the XMax
	sub $t8, $t8, $t4
	
	j finishCalXminXma	
calXMinXMax:	
	sub $t7, $t1, $t4		# if if calculate XMin, XMax  $t7 has the XMin
	add $t8, $t1, $t4		# if if calculate XMin, XMax  $t8 has the XMax
finishCalXminXma:
	# $t7 XMin, $t8 XMax, and $t5 Y.
	# need to have the print this row $t5, from Col $t7 XMin thru Col $t8 xmax.
	move $a1, $t9 			# set color to $a1 input parameter for draw_pixel,  $a0 is already has the bitmap memory location.	
	push ($t4)			# $t4 is being use at draw_pixel, save and restore.
draw_diamondRowCont:		
	push ($t1)                        
	push ($t2)
	move $t1, $t5                     # load in Y
	move $t2, $t7                     # load in X
	formatCoordinates ($t0, $t1, $t2) # the $t0 will have 0x00XX00YY coordinate			
	pop ($t2)
	pop ($t1)
	move $a0, $t0                   # load in coordinate into $a0
	push ($a0)
	move $a1, $t9 			# set color to $a1 input parameter for draw_pixel,  $a0 is already has the bitmap memory location.
	pop ($a0)	
	push ($t3)			# save $t3 which is the height of diamond being change in draw_pixel			
	jal draw_pixel			# $a0 needs to have 0x00XX00YY, $a1 RGB color.		
	pop ($t3)			# restore $t3
	add $t7, $t7, 1			# increment the minX by 1 to be compare with maxX see if we need to continute drawing.
	ble $t7, $t8, draw_diamondRowCont # If XMin <= XMax, loop back
	pop ($t4)			# restore $t4
	add $t4, $t4, 1			# increment the dy counter by 1
	ble $t4, $t3, calLoopCont	# keep looping if the dy is <= height
	pop($ra)
	jr $ra
	
