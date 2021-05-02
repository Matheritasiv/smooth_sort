NAME := $(shell basename `pwd`)

all: $(NAME)

core.o: $(NAME).asm
	nasm -felf64 "$<" -o $@

main.o: $(NAME).c
	clang -c -O0 "$<" -o $@

$(NAME): core.o main.o
	ld -s -dynamic-linker /lib64/ld-linux-x86-64.so.2 -z noexecstack\
		/lib/crt{1,i,n}.o $^ -o $@ -lc

edit: $(NAME).asm
	vim -c 'set nu et fdm=marker bg=dark' "$<"

edit_main: $(NAME).c
	vim -c 'set nu et fdm=marker bg=dark' "$<"

clean:
	rm -rf *.o "$(NAME)"

.PHONY: all edit edit_main clean
