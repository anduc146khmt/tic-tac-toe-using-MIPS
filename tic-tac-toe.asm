.data
    board: .word 0 0 0 0 0 0 0 0 0
    end_line: .asciiz "\n"
    h_border: .asciiz " -------------\n"
    v_border: .asciiz " | "
    x_symbol: .asciiz "X"
    o_symbol: .asciiz "O"
    blank: .asciiz " "
    input_again_prompt: .asciiz "Invalid input, please try again?\n"
    x_turn_prompt: .asciiz "X turn, please choose a number: "
    o_turn_prompt: .asciiz "O turn, please choose a number: "
    x_win_prompt: .asciiz "X win!\n"
    o_win_prompt: .asciiz "O win!\n"
    draw_prompt: .asciiz "DRAW\n"
    again_prompt: .asciiz "Input 0 to play again, otherwise to stop\n"
.text
    main:
    	# reset board
    	la $s0, board
    	sw $zero, 0($s0)
    	sw $zero, 4($s0)
    	sw $zero, 8($s0)
    	sw $zero, 12($s0)
    	sw $zero, 16($s0)
    	sw $zero, 20($s0)
    	sw $zero, 24($s0)
    	sw $zero, 28($s0)
    	sw $zero, 32($s0)
    	
    	addi $s7, $zero, 0 # s7 is result_variable, s7 = 1 -> x win, s7 = -1 -> o win, s7 = 0 draw
       	jal print_board
       	addi $s1, $zero, 1
    	main_while:
    		bgt $s1, 9, main_exit
    		andi $a1, $s1, 1  # s0 even -> $a1 = 0, s0 odd -> a1 = 1
    		# change s0 even -> $a1 = -1
    		
    		bne $a1, 0, even_exit
    		addi $a1, $a1, -1
    		#Prompt for O
    		la $a0, o_turn_prompt
    		jal print_string
    		j prompt_exit
    		even_exit:
    		# Prompt for X
    		la $a0, x_turn_prompt
    		jal print_string
    		prompt_exit:
    		
    		jal get_user
        	jal print_board
    		addi $s1, $s1, 1
    		
			jal check_win
    		bne $s7, 0, end
    		j main_while 
    	main_exit:

			
		
		la $a0, draw_prompt
		jal print_string
		
		end:
		la $a0, again_prompt
		jal print_string
		
		jal get_integer
		beq $v0, 0, main
		
		
        li $v0, 10
        syscall
        
        
   	get_user:
   		addi $sp, $sp, -4
   		sw $ra, 0($sp)
   		
   		get_user_while:
   			jal get_integer
   			move $t0, $v0
   			addi $t0, $t0, -1 # user count from 1
   			sll $t1, $t0, 2
   			lw $t2, board($t1)
   			beq $t2, 0, get_user_exit
   			la $a0 input_again_prompt
   			jal print_string
   			j get_user_while
   		
   		get_user_exit:
   			add $t2, $t2, $a1
   			sw $t2, board($t1)
   			lw $ra, 0($sp)
   			jr $ra
   			
   		

    print_board:
        addi $sp, $sp, -12
        sw $ra, 0($sp)
        sw $s0, 4($sp)
        sw $s1, 8($sp)

        # Print top border
        la $a0, h_border
        jal print_string

        # Print board content
        # Traverse array
        addi $s0, $zero, 0 # row
        # row loop
        board_row_while:
            bgt $s0, 2, board_row_exit
            addi $s1, $zero, 0 #col
            la $a0, v_border
            jal print_string
            # col loop
            board_col_while:
                bgt $s1, 2, board_col_exit
                # get index for col and row, t0 -> index
                add $t0, $s1, $s0 
                add $t0, $t0, $s0 
                add $t0, $t0, $s0 
                # t1 = t0 * 4
                sll $t1, $t0, 2
                # t2 is a value of board
                lw $t2, board($t1)
             	bne $t2, $zero, marked
				addi $t0, $t0, 1
                move $a0, $t0
                jal print_integer
                j board_if_exit
                marked:
                	blt $t2, $zero, o_marked
                	la $a0, x_symbol
                	jal print_string
                	j board_if_exit
                o_marked:
                	la $a0, o_symbol
                	jal print_string
                board_if_exit:

                la $a0, v_border
                jal print_string

                addi $s1, $s1, 1
                j board_col_while
            board_col_exit:
            la $a0, end_line
			jal print_string

            la $a0, h_border
            jal print_string

            addi $s0, $s0, 1
            j board_row_while 
        board_row_exit:

        lw $ra, 0($sp)
        lw $s0, 4($sp)
        lw $s1, 8($sp)
        jr $ra

    check_win:
    	addi $sp, $sp, -8
    	sw $ra, 0($sp)
    	sw $s0, 4($sp)
    	
    	la $s0, board
    	# Check row
		lw $a1, 0($s0)
		lw $a2, 4($s0)
		lw $a3, 8($s0)
		jal sum_3_integers
		move $t0, $v1
		beq $t0, 3, x_win
		beq $t0, -3, o_win
		
		lw $a1, 12($s0)
		lw $a2, 16($s0)
		lw $a3, 20($s0)
		jal sum_3_integers
		move $t0, $v1
		beq $t0, 3, x_win
		beq $t0, -3, o_win
		
		lw $a1, 24($s0)
		lw $a2, 28($s0)
		lw $a3, 32($s0)
		jal sum_3_integers
		move $t0, $v1
		beq $t0, 3, x_win
		beq $t0, -3, o_win
		
		# Check col
		lw $a1, 0($s0)
		lw $a2, 12($s0)
		lw $a3, 24($s0)
		jal sum_3_integers
		move $t0, $v1
		beq $t0, 3, x_win
		beq $t0, -3, o_win	
		
		lw $a1, 4($s0)
		lw $a2, 16($s0)
		lw $a3, 28($s0)
		jal sum_3_integers
		move $t0, $v1
		beq $t0, 3, x_win
		beq $t0, -3, o_win	
		
		lw $a1, 8($s0)
		lw $a2, 20($s0)
		lw $a3, 32($s0)
		jal sum_3_integers
		move $t0, $v1
		beq $t0, 3, x_win
		beq $t0, -3, o_win
		
		# check diagonal
		lw $a1, 0($s0)
		lw $a2, 16($s0)
		lw $a3, 32($s0)
		jal sum_3_integers
		move $t0, $v1
		beq $t0, 3, x_win
		beq $t0, -3, o_win
		
		lw $a1, 8($s0)
		lw $a2, 16($s0)
		lw $a3, 24($s0)
		jal sum_3_integers
		move $t0, $v1
		beq $t0, 3, x_win
		beq $t0, -3, o_win
		    	
    	lw $ra, 0($sp)
    	lw $s0, 4($sp)
    	jr $ra
    	
    	x_win:
    		addi $s7, $zero, 1
    		la $a0, x_win_prompt
    		jal print_string
			lw $ra, 0($sp)
    		lw $s0, 4($sp)
    		jr $ra
    	
    	o_win:
    		addi $s7, $zero, -1
    		la $a0, o_win_prompt
    		jal print_string
			lw $ra, 0($sp)
    		lw $s0, 4($sp)
    		jr $ra

    # Utilities function
    print_string:
        li $v0, 4
        syscall
        jr $ra

    print_integer:
        li $v0, 1
        syscall
        jr $ra
        
    get_integer:
    	li $v0, 5
    	syscall
    	jr $ra
    	
    sum_3_integers:
    	addi $v1, $zero, 0
    	add $v1, $a1, $a2
    	add $v1, $v1, $a3
    	jr $ra
        

