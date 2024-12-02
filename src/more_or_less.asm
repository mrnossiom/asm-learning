; FOR	: x86_64-unknown-linux
; BY	: mrnossiom

; order of register arguments are
; %rdi %rsi %rdx %rcx %r8 %r9 +stack
; return in %rax

; I use ip_<current-proc>_foo for inter-procedure jumps

; https://www.cs.uaf.edu/2017/fall/cs301/reference/x86_64.html
; http://unixwiz.net/techtips/x86-jumps.html
; https://www.felixcloutier.com/x86/jcc

	;; file descriptors
	fd_stdin	equ 0
	fd_stdout	equ 1
	fd_stderr	equ 2

	;; ret:%rax	(0:%rdi)	(1:%rsi)	(2:%rdx)

	; ssize_t	int		char		size_t
	; count read	fd		*buf		count
	sys_read		equ 0

	; ssize_t       int		char[]		size_t
	; count wrote	fd 		*buf		count
	sys_write		equ 1

	; 		error_code
	; [[noreturn]]	int
	sys_exit		equ 60

	; success	timeval		timezone
	; int		struct		struct
	sys_gettimeofday	equ 96

	; success	*buf		count		flags
	; int		char[]		size_t		unsized int
	sys_getrandom		equ 318

section .text
	; code sec
	
	global _start

_start:
main:
	; entry point of program
	; ARGS ( 0 ) : (  )
	; RETURN     : *IGNORE RETURN*

	mov rax, $sys_write
	mov rdi, $fd_stdout
	mov rsi, $welcome_msg
	mov rdx, $welcome_msg_len
	syscall

	; random_num = random_number(1000)
	mov rdi, 1000
	call random_number
	push rax	; save random_num

	ip_main_prompt:
	; num = prompt()
	call prompt_number

	pop r9
	sub rax, r9
	jg ip_main_num_below
	jb ip_main_num_above
	jmp ip_main_win	; default equal case is win

	ip_main_num_above:
	push r9
	mov rax, $sys_write
	mov rdi, $fd_stdout
	mov rsi, $number_above_msg
	mov rdx, $number_above_msg_len
	syscall

	jmp ip_main_prompt

	ip_main_num_below:
	push r9
	mov rax, $sys_write
	mov rdi, $fd_stdout
	mov rsi, $number_below_msg
	mov rdx, $number_below_msg_len
	syscall

	jmp ip_main_prompt

	ip_main_win:
	mov rax, $sys_write
	mov rdi, $fd_stdout
	mov rsi, $won_msg
	mov rdx, $won_msg_len
	syscall

	; exit()
	call exit

random_number:
	; uses current time of day to generate a pseudo-random number
	; between specified bounds
	;
	; ARGS	: (int upper_bound)
	; RET	: (int random_num)

	push rbp	; preserve previous stack frame address
	mov rbp, rsp	; save current stack frame address
	; from now on, rsp is what you offset from to access the function stack

	; TODO: try to save and retrive on the stack
	mov r8, rdi	; save upper_bound

	; reserve space for timeval {int seconds, int microseconds}
	sub rsp, 2*4
	; gettimeofday(&rbp, &rbp[2*4])
	mov rax, $sys_gettimeofday
	mov rdi, rsp
	mov rsi, 0	; ignore tz
	syscall

	mov rax, [rsp+4]
	mov rdx, 0
	mov rdi, r8	; retrive upper_bound
	div rdi		; a = bq+r → q:rax, r:rdx

	mov rax, rdx

	add rax, 1	; (0..upper_bound-1) -> (1..upper_bound)

	mov rsp, rbp
	pop rbp
	ret

prompt_number:
	; writes string to stdout point of program
	; ARGS	: (  )
	; RET	: int user_number (<0 is error case)
	
	push rbp

	; written_buffer_len = read(fd_stdin, &read_buffer, read_buffer_len)
	mov rax, $sys_read
	mov rdi, $fd_stdin
	mov rsi, $read_buffer
	mov rdx, $read_buffer_len
	syscall

	; parse_number(&read_buffer, written_buffer_len)
	mov rdi, read_buffer
	mov rsi, rax		; save written buffer length
	call parse_number

	; return rax from parse_number

	pop rbp
	ret

parse_number:
	; writes string to stdout point of program
	; ARGS	: (char *buffer, usize len)
	; RET	: int len (<0 is error case)

	push rbp

	dec rsi		; ignore newline at the end

	mov r9, 0	; index
	mov r8, 0	; result

	ip_parse_number_loop:
	mov bl, byte [rdi+r9]

	; '0' = 48, '9' = 57
	sub rbx, 48
	jb ip_parse_number_error	; jump err if char is below '0'
	; TODO: case number is upper

	; rax = r8 * 10 + rax
	mov rax, r8
	mov rcx, 10
	mul rcx		; rax * rcx = rdx:rax (rdx contains upper result bits)
	add rax, rbx

	mov r8, rax

	inc r9		; increment loop index
	
	mov rax, r9
	sub rax, rsi	; compare to read len
	jne ip_parse_number_loop

	mov rax, r8

 	pop rbp
	ret

	ip_parse_number_error:
	mov rax, -1

	pop rbp
	ret

exit:
	; end of program
	; ARGS	: (  )
	; RET	: *IGNORE RETURN*

	mov rdi, 0		; exit code for this program's process
	mov rax, $sys_exit
	syscall
	nop

section .data
	; init'd data sec
	
	welcome_msg	db 'Welcome to more or less, the most original game in the far west!', 0x0A
	welcome_msg_len	equ $-welcome_msg

	number_above_msg	db 'Number is higher', 0x0A
	number_above_msg_len	equ $-number_above_msg
	number_below_msg	db 'Number is lower', 0x0A
	number_below_msg_len	equ $-number_below_msg

	won_msg	db 'You won! pew pew pew', 0x0A
	won_msg_len	equ $-won_msg

section .bss
	; uinit'd data sec

	read_buffer	resb 20
	read_buffer_len	equ $-read_buffer
