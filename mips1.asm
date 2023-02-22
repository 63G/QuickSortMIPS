# Title: Filename:
# Author: Date:
# Description:
# Input:
# Output:
################# Data segment #####################
.data
fileName: .asciiz "data.txt" # here we are assuming that our file name is static as given per assignment
fileContent: .space 10000 # size of file contents is 10000 characters 
errMsg: .asciiz "The file does not exist or not in the same directory as MARS"
Letters: .asciiz "Letters = "
Digits: .asciiz "\nDigits = "
Words: .asciiz "\nWords = "
Numbers: .asciiz "\nNumbers = "
################# Code segment #####################
.text

.globl main
main: # main program entry
li $t0 ,0 # this is for the number of letters
li $t1, 0 # this is for our number of digits
li $t2, 0# this is for our number of words
li $t3, 0 # this is for our number of numbers  
# goal: just count when a new word, digit, number occur other than that no need. (digits inside numbers and letters is inside words)
# first we open the file and safe the descriptor
li $v0, 13
la $a0, fileName
syscall
move $s0, $v0 # our descriptor
bltz $s0, error
# then we read its contents and store it.
li $v0, 14
move $a0, $s0
la $a1, fileContent
la $a2, 10000
syscall
move $s1,$v0 # represent number of characters read
bltz $s1, error # cannot read it 
beqz $s1, printResults # empty file
la $s3, fileContent # this holds our file contents
# now we use $t5 for our byte holder when we read
li $t4, 0 # this is to stop after 10000 characters
readFileContents: 
bge $t4, 10000, printResults
lb $t5, 0($s3)
# lets check if it is a letter
## time to check for the codition 
blt $t5, 65, checkDigit # ignoring special characters
bgt $t5, 90, checkLower # ignoring special characters
# both false means it is an upper char Hence a word and an UPPER
j isWord
checkLower: 
blt $t5, 97, skip
bgt $t5 , 122, skip
# false means its a lower case char
j isWord
checkDigit: 
blt $t5, 48, skip
bgt $t5, 57, skip
# both false means it is a digit
j isNumber

isWord:
addiu $t0, $t0, 1 # increment letters
addiu $t2, $t2, 1 # increment words
# now we check again if it is an upper or lower:
isLetter:
addiu $s3, $s3, 1 
addiu $t4, $t4, 1 
lb $t5, 0($s3)
blt $t5, 65, checkDigit # ignoring special characters # BUG: this is not working for some reason?
bgt $t5, 90, checkLower1 # ignoring special characters
# both false means it is an upper char Hence a letter
addiu $t0, $t0, 1 # add a letter
j isLetter 
checkLower1: 
blt $t5, 97, readFileContents
bgt $t5 , 122, readFileContents
addiu $t0, $t0, 1
j isLetter
# false means its a lower case char
# lets check if it is a digit
# here we know that what we are reading is a word, hence following should be letters unless it is not
# then we loop back to the main readFile, 
isNumber: 
addiu $t1, $t1, 1 # increment digits # 
addiu $t3, $t3, 1 # increment numbers
isDigit:
addiu $s3, $s3, 1 # increment our byte and check if it is also a digit or not
addiu $t4, $t4, 1
lb $t5, 0($s3)
blt $t5, 48, readFileContents
bgt $t5, 57, readFileContents
# both false means it is a digit otherwise we go back to check it in the main loop
addiu $t1, $t1, 1
j isDigit


skip:
addiu $s3, $s3, 1
addiu $t4, $t4, 1
j readFileContents 
outLoop:
printResults: 
# now we print our results that we found. 
printLetters: 
li $v0, 4
la $a0, Letters
syscall
li $v0, 1
move $a0, $t0
syscall
printDigits:
li $v0, 4
la $a0, Digits
syscall
li $v0, 1
move $a0, $t1
syscall
printWords:
li $v0, 4
la $a0, Words
syscall
li $v0, 1
move $a0, $t2
syscall
printNumbers:
li $v0, 4
la $a0, Numbers
syscall
li $v0, 1
move $a0, $t3
syscall
j end
error: 
li $v0, 4
la $a0, errMsg
syscall

end: 
li $v0, 16 # to close our file
move $a0, $s0
syscall 
li $v0, 10 # Exit program
syscall