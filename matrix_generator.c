#include<stdio.h>
#include<string.h>
#include<stdlib.h>
#include<math.h>

/*
 * Function nd:
 * Calculates a custom value based on the comparison of two character arrays q and p
 * between indices i (inclusive) and j (exclusive).
 * The logic assigns different weights depending on the values of q[x] and p[x].
 */
int nd(int i,int j,char q[],char p[])
{
    int x;
    int contador=0;
    
    for(x=i;x<j;x++){
        if((q[x]=='2')&&(p[x]=='0')){contador=contador+3;continue;}
        if((q[x]=='2')&&(p[x]=='1')){contador=contador+1;continue;}
        if((q[x]=='1')&&(p[x]=='0')){contador=contador+2;continue;}
        if((q[x]=='1')&&(p[x]=='1')){contador=contador+1;continue;}
    }

    // Add 1 if the last or first element of p is '0'
    if(p[j-1]=='0'){contador=contador+1;}
    if(p[0]=='0'){contador=contador+1;}
  
    return contador;
}

/*
 * Main program:
 * Reads two files with sequences, compares them according to specific rules,
 * and prints a matrix of computed values or 9999 if the pair is invalid.
 * Usage: ./matrix_generator <input_file> <limit> <string_length>
 */
int main(int argc, char *argv[]){

   FILE *f;
   FILE *f1;

   int x;
   char p[]  =  "000000000000"; // Buffer for one sequence
   char q[]  =  "000000000000"; // Buffer for another sequence

   int m1=0,m2=0,hasta=atoi(argv[2]);
   int numero_ceros=0;

   int entera=floor(hasta/32);
   int mas=(entera+1)*32;

   int longitud_cadena=atoi(argv[3]);

   int noinfinito=0;

   int i,j; 
   i=1;j=longitud_cadena-1;
   int posicion;
   int siguiente;

   // Open the input file twice for reading
   f = fopen(argv[1],"r");
   f1 = fopen(argv[1],"r");

   // Loop over all possible pairs of sequences
   for(m1=0;m1<mas;m1++){

     // If m1 is out of range, fill the row with 9999
     if(m1>hasta) {
                  for(m2=0;m2<mas;m2++)printf("%d\n",9999);
                  continue;
                  }

     // Read the m1-th sequence into q
     fscanf(f, "%c %c %c %c %c %c %c %c %c %c %c %c\n", &q[0],&q[1],&q[2],&q[3],&q[4],&q[5],&q[6],&q[7],&q[8],&q[9],&q[10],&q[11]);
     rewind(f1);

     for(m2=0;m2<mas;m2++){
 
        // If m2 is out of range, print 9999
        if(m2>hasta) {printf("%d\n",9999);continue;}

        // Read the m2-th sequence into p
        fscanf(f1, "%c %c %c %c %c %c %c %c %c %c %c %c\n", &p[0],&p[1],&p[2],&p[3],&p[4],&p[5],&p[6],&p[7],&p[8],&p[9],&p[10],&p[11]);
  
        siguiente=0;

        // Check the first position

        if(q[0]=='0'){
               if(p[0]=='2') {printf("%d\n",9999);continue;}
            }

        if(q[0]=='0'){
               if(p[0]=='0') {printf("%d\n",9999);continue;}
            }

        if(q[0]=='1'){
               if((p[0]=='1')&&(p[1]=='1')) {printf("%d\n",9999);continue;}
               if((p[0]=='1')&&(p[1]=='2')) {printf("%d\n",9999);continue;}
            }

        if(q[0]=='2'){
               if((p[0]=='1')&&(p[1]=='1')) {printf("%d\n",9999);continue;}
               if((p[0]=='1')&&(p[1]=='2')) {printf("%d\n",9999);continue;}
            }

        // Check the last position

        if(q[j]=='0'){
               if(p[j]=='2') {printf("%d\n",9999);continue;}
            }

        if(q[j]=='0'){
               if(p[j]=='0') {printf("%d\n",9999);continue;}
            }

        if(q[j]=='1'){
               if((p[j-1]=='1')&&(p[j]=='1')) {printf("%d\n",9999);continue;}
               if((p[j-1]=='2')&&(p[j]=='1')) {printf("%d\n",9999);continue;}
            }

        if(q[j]=='2'){
               if((p[j-1]=='1')&&(p[j]=='1')) {printf("%d\n",9999);continue;}
               if((p[j-1]=='2')&&(p[j]=='1')) {printf("%d\n",9999);continue;}
            }

         // Check the middle positions

        for(posicion=i;posicion<j;posicion++) {

            if(q[posicion]=='0'){
               if(p[posicion]=='2'){siguiente=1;break;}
            }
            if(q[posicion]=='0'){
               if(p[posicion]=='0'){siguiente=1;break;}
            }
            if(q[posicion]=='1'){
               if((p[posicion-1]=='1')&&(p[posicion]=='1')&&(p[posicion+1]=='1')) {siguiente=1;break;}
               if((p[posicion-1]=='2')&&(p[posicion]=='1')&&(p[posicion+1]=='1')) {siguiente=1;break;}
               if((p[posicion-1]=='1')&&(p[posicion]=='1')&&(p[posicion+1]=='2')) {siguiente=1;break;}
               if((p[posicion-1]=='2')&&(p[posicion]=='1')&&(p[posicion+1]=='2')) {siguiente=1;break;}
            }
            if(q[posicion]=='2'){
               if(p[posicion]=='1') {siguiente=1;break;}
               if(p[posicion]=='2') {siguiente=1;break;}
            }

       }
       if(siguiente==0){
         // Calculate the number of '0's in p
         numero_ceros=0;
         for(x=0;x<longitud_cadena;x++){
             if(p[x]=='0') numero_ceros++;
         }
         printf("%d\n",(5*numero_ceros)-nd(0,longitud_cadena,q,p));
       }else printf("%d\n",9999);


     }

   }

   fclose(f);
   fclose(f1);

   return 0;
}