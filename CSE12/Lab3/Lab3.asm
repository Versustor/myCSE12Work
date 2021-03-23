##########################################################################
# Created by: Quang, Benjamin
# bquang
# 18 November 2020
#
# Assignment: Lab 3: ASCII-risks (Asterisks)
# CMPE 012, Computer Systems and Assembly Language
# UC Santa Cruz, Fall 2020
#
# Description: This program prints out a pattern using 
# 	       numbers and stars based on the number 
#	       inputted to the screen.
#
# Notes: This program is intended to be run from the MARS IDE.
##########################################################################

# Pseudocode -------
# def triangle(n):
#     int = 1
#     int2 = 1
#     int3 = 1
#     num = 1
#     star = 2*n-3
#
#     if int > n:
#         end program
#     else:
#         while int2 < n: 
#               print(tab)
#               int2 += 1
#         else: 
#               print(value)
#               value += 1
#               if int = 1: 
#                    print(newline)
#                    int += 1
#               else:
#                   while int3 < star:
#                         print(tab)
#                         print(*)
#                         int3 += 1
#                   else: 
#                         print(tab)
#                         print(num)
#                         num += 1 
#
# while True:
#     height = input("Enter the height of the pattern (must be greater than 0):")
#     try:
#         val = int(height)
#         if val > 0:
#             n = int(height)
#             triangle(n)
#             break;
#         else:
#             print("Invalid Entry!")
#     except ValueError:
#         print("Invalid Entry!")

.data 
# set prompt/error message
input:        .asciiz "Enter the height of the pattern (must be greater than 0):	"
errorMessage: .asciiz "Invalid Entry!\n"

.text
prompt:
    # Prompt the user to enter input. 
    li $v0, 4 # prep to print string
    la $a0, input # puts input into argument to print
    syscall 
    
    # Get the user's input
    li $v0, 5 # prep to read integer
    syscall 
    
    # Store the result in $s0 
    move $s0, $v0 # moves inputted integer into $s0
    
# Error message for invalid input 
invalidCheck:
    # if userInput > 0, move to printing pattern code
    bgt $s0, $zero, triangle 
    NOP
    
    # else, print Invalid Entry!
    li $v0, 4 # prep to print string
    la $a0, errorMessage # puts errorMessage into argument to print
    syscall
    
    # loop back to prompt 
    j prompt

# Prints out triangle pattern based off of input
triangle: 
# intialize values 
    # Height = user’s input
    li $t0, 1 # Row begins at 1
    li $t1, 1 # Value begins at 1 
    subi $t2, $t0, 1 # Num_tabs = height - row
    addi $t5, $t5, 0 # printed_tabs 
    addi $t6, $t6, 0 # printed_inner_tabs
    #--------------------
#    mul $t3, $t0, 2 # put (2 * row) into $t3
#    subi $t4, $t3, 3 # set $t4 as num_stars = (2 * row) - 3

    # begin row 1 
    # print tabs
    beq $s0, 1, height1 # if height = 1, jump to height 1
    
tab1:
    li $v0 11 # prep to print character
    li $a0 9 # put TAB into a0 for printing
    syscall # print tab
    beq $t5, $t2, height1 # jump to height 1
    addi $t5, $t5, 1 # increment printed_tabs by 1
    j tab1 # keep looping back until tabs have been printed
    
height1:   
    li $v0, 1 # prep to print integer
    move $a0, $t1 # puts input into argument to print
    syscall # print value
    addi $t1, $t1, 1 # increment value by 1
    
    li $v0 11 # prep to print character
    li $a0 10 # put newline into a0 for printing
    syscall # print newline
    
    beq $s0, 1, endProgram # Check height = 1 (end program)
    j nextRow

checkRow: 
    bgt $t0, $s0, endProgram # Check row > height (if so, end program)
    
tabs:
    beq $t2, 0, firstvalue # jump to first value if no tabs
    li $v0 11 # prep to print character
    li $a0 9 # put TAB into a0 for printing
    syscall # print tab
    addi $t5, $t5, 1 # add 1 to printed tabs
    beq $t5, $t2 tabs # keep looping until correct number of tabs have been printed
    
firstvalue:
    li $v0, 1 # prep to print integer
    move $a0, $t1 # puts input into argument to print
    syscall # print value
    addi $t1, $t1, 1 # increment value by 1

innertabs:
    mul $t3, $t0, 2 # put (2 * row) into $t3
    subi $t4, $t3, 3 # set $t4 as num_stars = (2 * row) - 3
    li $v0 11 # prep to print character
    li $a0 9 # put TAB into a0 for printing
    syscall # print tab

    li $v0 11 # prep to print character
    li $a0 42 # put * into a0 for printing
    syscall
    
    addi $t6, $t6, 1 # increment by 1 added inner tabs
    beq $t4, $t6 secondvalue
    j innertabs


secondvalue:
    li $v0 11 # prep to print character
    li $a0 9 # put TAB into a0 for printing
    syscall # print tab
    
    li $v0, 1 # prep to print integer
    move $a0, $t1 # puts input into argument to print
    syscall # print value
    addi $t1, $t1, 1 # increment value by 1
    
    li $v0 11 # prep to print character
    li $a0 10 # put newline into a0 for printing
    syscall # print newline
    
nextRow: 
    addi $t0, $t0, 1 # increment Row by 1
    j checkRow # loop back up to checkRow
     
endProgram: 
    li $v0, 10 # ends program
    syscall






