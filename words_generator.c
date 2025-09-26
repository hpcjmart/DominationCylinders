#include<stdio.h>
#include<string.h>
#include "_generate.h"


/*
Function: search
Searches for the pattern 'pat' in the text 'txt'.
If the pattern is found, sets *exit to 1 and *where to the position (1-based) where the pattern starts.
Otherwise, *exit remains 0. */ 
void search(char *pat, char *txt, int *exit, int *where)
{
    int M = strlen((const char *)pat);
    int N = strlen((const char *)txt);
    int i,j;
    int x;
    
    *exit=0;
    *where=0;
    // Slide the pattern over text one by one 
    for (i = 0; i <= N-M+1; i++) 
    {
        // Check for pattern match at current position
        for (j = 0; j < M; j++)
        {
              if (txt[i+j] != pat[j])
              break;
        }
 
        if (j == M) 
        {
         *exit=1;
         *where=i+1;
         break; 
        }
 
    }
}
 
int main() { 
  
char m = 3; // Maximum number of each symbol in the word 
char n = 12; // Length of the word 
char txt[] = "000000000000"; // Initial word

// Patterns to be excluded from the output
char pat1[] = "20";
char pat2[] = "02";
char pat3[] = "00";

int gen_result;
unsigned int set_counter;
int x;

set_counter = 0;
// Initialize the word generator with the given parameters
gen_result = gen_vari_rep_lex_init(txt, m, n);

if (gen_result == GEN_EMPTY)
{
    set_counter++;
}

int exit = 0;
int where = 0;

// Generate all valid words and print those that do not contain the excluded patterns
while (gen_result == GEN_NEXT)
{
    set_counter++;

    // Skip words containing any of the forbidden patterns
    search(pat1, txt, &exit, &where);
    if (exit == 1) {
        gen_result = gen_vari_rep_lex_next(txt, m, n);
        continue;
    }
    search(pat2, txt, &exit, &where);
    if (exit == 1) {
        gen_result = gen_vari_rep_lex_next(txt, m, n);
        continue;
    }
    search(pat3, txt, &exit, &where);
    if (exit == 1) {
        gen_result = gen_vari_rep_lex_next(txt, m, n);
        continue;
    }

    // Print the valid word
    for (x = 0; x < n; x++) printf("%c ", txt[x]);
    printf("\n");

    // Generate the next word
    gen_result = gen_vari_rep_lex_next(txt, m, n);
}

return 0;
}
