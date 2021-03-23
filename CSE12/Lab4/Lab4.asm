##########################################################################
# Created by: Quang, Benjamin
# bquang
# 28 November 2020
#
# Assignment: Lab 4: ASCII-risks (Asterisks)
# CMPE 012, Computer Systems and Assembly Language
# UC Santa Cruz, Fall 2020
#
# Description: This the program accepts a number of hexadecimals as 
#              program arguments(up to 8). The program will then convert 
#	       these arguments into integer values, print them out, and 
#              print out the maximum integer out of these values. 
#
# Notes: This program is intended to be run from the MARS IDE.
##########################################################################

# Pseudocode -------
# Initialize values for printing program arguments -
# Set number of arguments 
# Set pointer to 0 (first argument) 
# Set loop counter to 0
#
# print (Program Arguments:)
#
# Program argument - 
# If loop counter = number of arguments, go to Integers
# Else: 
#     print program argument 
#     Increment pointer by 1 (move to next argument) 
#     Add 1 to loop counter 
#     Jump back to Program argument 
#
# print (Integer values:)
# Reset pointer & loop counter
# Set maxval to 0 
#
# Integers - 
# If loop counter = number of arguments, go to Max value
# Else:
#     Calculate length of arg; set as arglen
#     Set n to (arglen - 1)
#     Check each bit & convert to decimal (based on n) 
#     Sum bits and print int
# If int > maxval, set maxval to integer 
#     else, leave maxval as is
#     jump back to Integers 
#
# Max value - 
# print (Maximum value:) 
# print maxval

.data 
# set prompt/error message
argLabel: .asciiz "Program arguments:\n"
intLabel: .asciiz "\nInteger values:\n"
maxLabel: .asciiz "\nMaximum value:\n"
space: .asciiz " "

.text
# REGISTER USAGE
# $t0: loop counter
# $t1: bit counter
# $t2: bit
# $t3: arglength
# $t4: n = arglength - 1
# $t5: sum of bits (the int)
# $t6: bit/loop counter
# $t7: maxval 
# $s0: number of arguments
# $s1: first pointer of arguments
# $s2: second pointer of arguments

# Part A --------------- (Print out program arguments)
# set variables for printing program arguments
la $s0, ($a0) # load in number of arguments into $s0
la $s1, ($a1) # load in first pointer of arguments into $s1
lw $s2, ($s1) # load in second pointer of arguments into $s2
li $t0, 0     # set up loop counter 

Labelarg:
    # Print out program argument label string 
    li $v0, 4        # prep to print string
    la $a0, argLabel # puts string into argument to print
    syscall 

# loop through and print program arguments 
progArgs:
    NOP
    # if loop counter = number of args, jump to integers
    beq $t0, $s0, Labelint 
    NOP
    # Code for printing out the actual arguments
    li $v0, 4      # prep to print program argument 
    la $a0, 0($s2) # puts program argument into argument to print
    syscall 

    li $v0, 4     # prep to print space
    la $a0, space # puts space into argument to print
    syscall 
    
    addi $s1, $s1, 4 # increment address by 4
    lw   $s2, ($s1)  # load incremented address & move to next argument
    
    addi $t0, $t0, 1 # increment loop counter
    
    j progArgs # loop back to progArgs

# Part B ------------------------- (Convert program arguments into integers & find maximum integer)
Labelint:
    # print new line 
    li $v0 11 # prep to print newline
    li $a0 10 # put newline into a0 for printing
    syscall
    
    # Print out integer label string
    li $v0, 4        # prep to print string
    la $a0, intLabel # puts string into argument to print
    syscall 
    
    # reset variables for looping again
    li   $t0, 0        # reset loop counter 
    la   $s1, ($a1)    # reset first pointer
    lw   $s2, ($s1)    # reset second pointer
    addi $t7, $zero, 0 # set max val to 0 

integers:
    # if loop counter = number of args, jump to maxNumber:
    beq $t0, $s0, maxNumber 
    NOP
# arglength calculator
    la $t1, ($s2) # load argument into lengthCount
lengthCount:
    lb   $t2, 2($t1)       # check bit
    beq  $t2, $zero, endlc # check if bit is null; if so, end loop 
    NOP
    addi $t1, $t1, 1       # add 1 to bit counter
    j lengthCount 
endlc:
    la  $t2, ($s2)
    sub $t3, $t1, $t2 #$t3 contains length of argument
    
# ------------------------------------------------------------
# hex to int converter (based on length)
    la   $t1, ($s2)    # load argument into hextodec
    subi $t4, $t3, 1   # set n to length - 1
    addi $t5, $zero, 0 # set sum to 0
    addi $t6, $zero, 0 # set loop counter to 0 
    # hex to int calculation 
hextodec:  
    NOP
# bitchecker - goes through each bit; ends when it hits null
    lb  $t6, 2($t1)         # check bit
    beq $t6, $zero, result # if bit is null jump down to result
    NOP
# converts bit into decimal based on whether it's 0-9 or A-F
    bgt $t6, 57, letter # check if bit is A-F
    NOP
    addi $t2, $t6, -48 # transform bit into decimal (if 0-9)
    j powerOP
letter: # if input is A-F
    addi $t2, $t6, -55 # transform bit into decimal (if A-F)
   
# 16^n * $t2
powerOP:
    addi $t6, $zero, 0 # set $t6 to zero (loop counter)
loop:      
    NOP
    bge $t6, $t4, sum 
    NOP 
    mul $t2, $t2, 16
    addi $t6, $t6, 1 # increase by 1
    j loop    
    
sum: # increments & adding result from conversion into a sum 
    subi $t4, $t4, 1 # decrease n by 1 
      
    add $t5, $t5, $t2 # add to sum 
      
    bgt $t5, $t7, newMax # if most recent integer > max val, change max val
    NOP
    j sameMax # else, max val stays the same
    
newMax: 
    move $t7, $t5  # set max val to most recent integer 
    
sameMax:           # max val stays the same
    addi $t1, $t1, 1 # move to next bit
    j hextodec
    
result:
    move    $a0, $t5
    # using "print character" instead of "print integer"
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    jal intprint
    lw $ra, 0($sp)
    addi $sp, $sp, 4 
    # li      $v0, 1	  
    # syscall

# -----------------------------------------------------------------
# code to loop back 
intIncrement:
    li $v0, 4     # prep to print space
    la $a0, space # puts space into argument to print
    syscall 
    
    addi $s1, $s1, 4 # increment address by 4
    lw   $s2, ($s1)  # load incremented address & move to next argument
    
    addi $t0, $t0, 1 # increment loop counter
    
    j integers # loop back to integers
    
maxNumber:
    # print new line 
    li $v0, 11 # prep to print newline
    li $a0, 10 # put newline into a0 for printing
    syscall
    
    # Print out string for max number label
    li $v0, 4 # prep to print string
    la $a0, maxLabel # puts string into argument to print
    syscall 
    
    # print out max val
    # li $v0, 1
    la $a0, ($t7) 
    # syscall 
    
    # using "print character" instead of "print integer"
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    jal intprint
    lw $ra, 0($sp)
    addi $sp, $sp, 4  
    
    # print new line 
    li $v0, 11 # prep to print newline
    li $a0, 10 # put newline into a0 for printing
    syscall
    
endProgram: 
    li $v0, 10 # ends program
    syscall
    
# ------------------------------------------------
# subroutine for printing int as character
intprint:
    addi $sp, $sp, -8 # preserve registers in stack 
    sw   $ra, 0($sp)
    sw   $s3, 4($sp)
    move $s3, $a0
    ble $s3, 9, output
    NOP
    li $s6, 10        # divide by 10
    div $s3, $s6
    mfhi $s3          # remainder
    mflo $a0          # quotient
    jal intprint      # recursion 
output:
    add $a0, $s3, 48
    li $v0, 11
    syscall
    lw   $ra, 0($sp)  # restore registers from stack
    lw   $s3, 4($sp)
    addi $sp, $sp, 8  # restore stack pointer
    jr $ra
