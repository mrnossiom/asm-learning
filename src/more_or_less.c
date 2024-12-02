#include "unistd.h"
#include <stdlib.h>
#include <sys/syscall.h>
#include <sys/time.h>
#include <sys/unistd.h>

void error() {
  char msg[] = "error: quitting\n";
  write(STDOUT_FILENO, &msg, 16);

  exit(1);
}

int random_number(int mod) {
  struct timeval tv;
  struct timezone tz;

  if (gettimeofday(&tv, &tz) != 0) {
    error();
  }

  return tv.tv_usec % mod;
}

int parse_input(char *buf, int len) {
  int acc = 0;

  for (uint index = len; index != 0; index -= 1) {
    char current = buf[index];

    if (current >= '0' && current <= '9') {
      acc = acc * 10 + (current - '0');
    }
  }

  return acc;
}

int main() {
  int rnd = random_number(100);
  char input_buf[10] = {};

  while (1) {
    int len = read(STDIN_FILENO, &input_buf, 10);
    if (len < 0)
      error();

    int user_num = atoi(input_buf);

    if (user_num == rnd) {
      write(STDOUT_FILENO, "You found it\n", 13);
      return 0;
    } else if (user_num > rnd) {
      write(STDOUT_FILENO, "Number is lower\n", 17);
    } else {
      write(STDOUT_FILENO, "Number is higher\n", 18);
    }
  }
}
