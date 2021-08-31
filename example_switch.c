#include <stdio.h>

// Create a global variable ibex
int ibex = 12;

int main() {
  switch( ibex ) {
    case 7:
      printf( "Seven!" );
      break;
    case 12:
      printf( "Twelve!" );
      break;
    default:
      printf( "Some other number." );
      break;
  }
  return 1;
}
