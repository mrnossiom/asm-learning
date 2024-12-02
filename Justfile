_default:
	@just --list --unsorted --list-heading '' --list-prefix '—— '

# Builds the specified project with debug symbols
build SPROJ:
	nasm -g -f elf64 src/{{SPROJ}}.asm
	ld -o src/{{SPROJ}} src/{{SPROJ}}.o

watch SPROJ:
	@echo src/{{SPROJ}}.asm | entr just build {{SPROJ}}

# Run the specified project
run SPROJ: (build SPROJ)
	@src/{{SPROJ}}

# Run the specified project
buildc SPROJ:
	clang -Wall -Wextra -Wno-unused-result src/{{SPROJ}}.c -o src/{{SPROJ}} 

# Run the specified project
runc SPROJ: (buildc SPROJ)
	@src/{{SPROJ}}
