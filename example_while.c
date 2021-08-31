#include <stdio.h>

// Create a global variable counter
int counter = 1;

int main() {
  while( counter < 10 ) {
    printf( "Count!" );
    counter++;
  }
  return 1;
}
