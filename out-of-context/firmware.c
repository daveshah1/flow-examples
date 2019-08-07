#include <stdint.h>
#include "chars.h"

#define LED (*(volatile uint32_t*)0x03000000)
#define DISP  (*(volatile uint32_t*)0x03000004)

#define reg_uart_clkdiv (*(volatile uint32_t*)0x02000004)
#define reg_uart_data (*(volatile uint32_t*)0x02000008)

void putchar(char c)
{
    if (c == '\n')
        putchar('\r');
    reg_uart_data = c;
}

void print(const char *p)
{
    while (*p)
        putchar(*(p++));
}

const char hexdigits[16] = "0123456789ABCDEF";

void printhex8(uint8_t value)
{
    putchar(hexdigits[value >> 4]);
    putchar(hexdigits[value & 0xF]);
}

void printhex32(uint32_t value)
{
    for (int i = 7; i >= 0; i--)
        putchar(hexdigits[(value >> (4 * i)) & 0xF]);
}


void delay()
{
    for (volatile int i = 0; i < 250000; i++)
        ;
}

char char_buf[80];
int char_buf_ptr;

void disp_14seg(const char *p)
{
    while (*p) {
        DISP = char_14seg[*(p++) & 0x7F];
        delay();
        DISP = 0;
        delay();
    }
}

void process_message(const char * buf)
{
    print("Displaying \"");
    print(char_buf);
    print("\".\n");
    disp_14seg(buf);
    print("> ");
}

void process_char(uint8_t c)
{
    if (c == 0xFF)
        return;
    putchar(c);
    if ((c == '\r') || (c == '\n')) {
        char_buf[char_buf_ptr] = '\0';
        process_message(char_buf);
        char_buf_ptr = 0;
    } else if (char_buf_ptr < 79) {
        char_buf[char_buf_ptr++] = c;
    }
}

int main() {
    // 9600 baud at 48MHz
    reg_uart_clkdiv = 5000;
    uint32_t count = 0;
    char_buf_ptr = 0;
    print("> ");
    while (1) {
        ++count;
        if ((count & 0x3FFFF) == 0)
            LED = (count >> 18);
        process_char(reg_uart_data);
    }
}
