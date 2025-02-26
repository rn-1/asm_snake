LDFLAGS = -lSystem -syslibroot `xcrun -sdk macosx --show-sdk-path` -e _start

snake: main.o read.o
	as -g -o main.o main.s
	as -g -o read.o read.s
	as -g -o random.o random.s
	ld -o snake main.o read.o random.o ${LDFLAGS} -arch arm64

clean:
	rm -f snake main.o read.o random.o


