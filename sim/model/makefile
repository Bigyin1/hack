all: compile test clean

compile:
	gcc ./test_2d.c ./model.c -o a_2d.out
	gcc ./test_3d.c ./model.c -o a_3d.out

test:
	./a_2d.out
	./a_3d.out

clean:
	rm ./*.out
