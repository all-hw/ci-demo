/*----------------------------------------------------------------------------
 * Name:    main.c
 *----------------------------------------------------------------------------*/

#include "unity.h"
#include <stdio.h>

extern void stdio_init (void);
extern int stdin_getchar(void);
//extern int stdout_putchar (int);

char buf[1000];

int main(void) {
  // read characters from UART0 until we meet a newline.
  // Echo the characters and return their number as a result code.
  stdio_init();

  int count = 0;
  while(1)
  {
	  int ret = stdin_getchar();
	  if (EOF == ret)
		  break;
	  char ch = ret;
	  buf[count++] = ch;
	  //stdout_putchar(ch);
	  if ('\n' == ch || '\r' == ch)
		  break;
  }
  buf[count]=0;
  printf("Input data:\n");
  printf("%s\n", buf);
  printf("Finished, exit code %d\nCI_end_task\n", count);

  return count;
}
