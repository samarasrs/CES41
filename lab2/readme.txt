
 bison -d tiny.y
 flex tiny.l
 gcc -c *.c
 gcc -o tiny *.o -ly -lfl
