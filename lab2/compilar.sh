bison -d c_minus.y
flex c_minus.l
gcc -c *.c
gcc -o c_minus *.o -ll -lfl