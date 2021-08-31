#include <stdio.h>

// Create a global variable badger
int badger = 7;

int main() {
  if ( badger > 10 ) {
    printf( "Badger is greater than ten!" );
  }
  else {
    printf( "Badger is less than or equal to ten" );
  }

  return 1;
}
