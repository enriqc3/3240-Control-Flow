#include <stdio.h>

int user_response = 0;

int main() {
  while( 1 ) {
    printf( "===============================\n" );
    printf( "Welcome, here are your options:\n" );
    printf( "1. View employee data\n" );
    printf( "2. View customer data\n" );
    printf( "10. Quit\n" );
    printf( "===============================\n" );
    printf( "Enter your response now:\n" );
    scanf( "%d", &user_response );
  }
  return 1;
}
