/* Testando um comentário com varias linhas
 e declaração após o fim do comentário
*/ int aux;

int teste (int u, int v) /* testando int, ID, ( , ) e COMMA */
{			 /* testando { */
   if (v == 0) return u; /* testando if, (, ID, ==, NUM, return e ;*/
   else return v;	 /* testando else */
   if (v<=0)  		 /* testando <= junto com ID e NUM*/
   if (v <= 0)		 /* testando <= com espaço*/
   if (v>=u)		 /* testando >= junto com ID e NUM*/
   if( v >= 0)		 /* testando >= com espaço*/
   if (u!=0)		 /* testando != junto com ID e NUM*/
   if (u != 0)		 /* testando != com espaço*/
   if (u ! = 0) 	 /* linha contendo erro: ! */
}

*/   /*testando fechar o comentário espera-se identificar TIMES e OVER*/

void main(void)	/* linha testando void */
{
   int x;
   int y = 5;
   x = 10;
   if (x > y) 		/*testando >*/
   if (x<4)		/*testando <*/
}


