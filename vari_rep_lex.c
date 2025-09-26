#include<string.h>
#include<stdio.h>
#include "_generate.h"

int gen_vari_rep_lex_init(char *vector, const char m, const char n)
{
int j; //index

//test for special cases
if(m == 0 || n == 0)
 return(GEN_EMPTY);

//initialize: vector[0, ..., n - 1] are zero
for(j = 0; j < n; j++){
 vector[j] = '0';
}
printf("\n");

return(GEN_NEXT);
}

int gen_vari_rep_lex_next(char *vector, const char m, const char n)
{
int j; //index

//easy case, increase rightmost element
if(vector[n - 1] < '2')
 {
 vector[n - 1]++;
 return(GEN_NEXT);
 }

//find rightmost element to increase and reset right-hand elements
for(j = n - 2; j >= 0; j--)
 {
 vector[j + 1] = '0';

 if(vector[j] < '2')
  break;
 }

//terminate if all elements are m - 1
if(j < 0)
 return(GEN_TERM);

//increase
vector[j]++;

return(GEN_NEXT);
}
