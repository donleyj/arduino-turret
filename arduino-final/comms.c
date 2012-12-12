/*
 * arduino-serial-control
 * --------------
 *
 * Utility for controlling basic high-low output to Arduino by keyboard.
 * Based on a very useful utility by Tod Kurt (see below).
 *
 * Compiles on any POSIX-compliant system
 *
 *
 * Original program's license information:
 * Created 5 December 2006
 * Copyleft (c) 2006, Tod E. Kurt, tod@todbot.com
 * http://todbot.com/blog/
 *
 * Original code:
 * http://todbot.com/blog/2006/12/06/arduino-serial-c-code-to-talk-to-arduino/
 *
 * Todo:
 * If there's time, implement unbuffered input:
 *   http://www.smashedstack.cu.cc/unbuffered-input-terminal/
 *
 * stdint.h, errno.h, and sys/ioctl.h (?) appear unnecessary at a glance
 * Maybe they're necessary on older compilers (I'm compiling against gcc4)?
 *
 */

#include <stdio.h>    /* Standard input/output definitions */
#include <stdlib.h>
#include <stdint.h>   /* Standard types */
#include <string.h>   /* String function definitions */
#include <unistd.h>   /* UNIX standard function definitions */
#include <fcntl.h>    /* File control definitions */
#include <errno.h>    /* Error number definitions */
#include <termios.h>  /* POSIX terminal control definitions */
#include <sys/ioctl.h>
#include <getopt.h>
#include <stdbool.h>

void usage(void);
int serialport_init(const char* serialport, int baud);
int serialport_writebyte(int fd, uint8_t b);

/* unused; "write" writes a string to arduino, read_until reads from arduino
 * int serialport_write(int fd, const char* str);
 * int serialport_read_until(int fd, char* buf, char until);
 */

int main(int argc, char *argv[])
{
    int fd = 0;
    FILE * tmpfile = stdin;
    char serialport[256];
    int baudrate = B9600;  /* default */
    unsigned char press;
    bool cxn_established = false;

    if (argc == 1)
    {
        usage();
        return EXIT_SUCCESS;
    }

    /* parse options */
    int option_index = 0, opt;
    static struct option loptions[] = {
        {"help",       no_argument,       0, 'h'},
        {"port",       required_argument, 0, 'p'},
        {"baud",       required_argument, 0, 'b'},
        {"file",       required_argument, 0, 'f'}
    };

    while (1)
    {
        opt = getopt_long (argc, argv, "hp:b:f:",
                           loptions, &option_index);

        if (opt == -1) break;

        switch (opt)
        {
            case '0': break;
            case 'h':
                usage();
                break;
            case 'b':
                if (cxn_established)
                {
                    fputs("Error: baudrate must come before port number", stderr);
                    return EXIT_FAILURE;
                }
                baudrate = strtol(optarg,NULL,10);
                break;
            case 'p':
                strcpy(serialport,optarg);
                fd = serialport_init(optarg, baudrate);
                if (fd == -1) return -1;
                cxn_established = true;
                break;
            case 'f':
                tmpfile = fopen(optarg, "r");
                if (tmpfile == NULL)
                {
                    perror(argv[0]);
                    return EXIT_FAILURE;
                }
                break;
        }
    }

    if (!cxn_established)
    {
        fputs("Error: port number is a required argument", stderr);
        return EXIT_FAILURE;
    }

    if (tmpfile == stdin)
    {
        puts("Press space to exit. l/r to rotate, n to stop, f to fire.");
    }

    while ((press = getc(tmpfile)) != ' ')
    {
        switch (press)
        {
            case 'l':
                puts("Sent a 2");
                serialport_writebyte(fd, (uint8_t)2);
                break;
            case 'n':
                puts("Sent a 0");
                serialport_writebyte(fd, (uint8_t)0);
                break;
            case 'r':
                puts("Sent a 1");
                serialport_writebyte(fd, (uint8_t)1);
                break;
            case 'f':
                puts("Sent a 3");
                serialport_writebyte(fd, (uint8_t)3);
                break;
            case 10: /* newline */
                break;
            case 255: /* eof */
                break;
            default:
                printf("Unrecognized: %i\n", (int)press);
                break;
        }
    }

    return EXIT_SUCCESS;
} /* end main */

int serialport_writebyte( int fd, uint8_t b)
{
    int n = write(fd,&b,1);
    if (n != 1)
        return -1;
    return 0;
}

/* unused; writes a string to arduino
int serialport_write(int fd, const char* str)
{
    int len = strlen(str);
    int n = write(fd, str, len);
    if( n!=len )
        return -1;
    return 0;
}*/

/* unused; reads from arduino
int serialport_read_until(int fd, char* buf, char until)
{
    char b[1];
    int i=0;
    do {
        int n = read(fd, b, 1);  // read a char at a time
        if( n==-1) return -1;    // couldn't read
        if( n==0 ) {
            usleep( 10 * 1000 ); // wait 10 msec try again
            continue;
        }
        buf[i] = b[0]; i++;
    } while( b[0] != until );

    buf[i] = 0;  // null terminate the string
    return 0;
}*/

/* takes the string name of the serial port (e.g. "/dev/tty.usbserial","COM1")
 * and a baud rate (bps) and connects to that port at that speed and 8N1.
 * opens the port in fully raw mode so you can send binary data.
 * returns valid fd, or -1 on error */
int serialport_init(const char* serialport, int baud)
{
    struct termios toptions;
    int fd;

    /*fprintf(stderr,"init_serialport: opening port %s @ %d bps\n",
              serialport,baud);*/

    fd = open(serialport, O_RDWR | O_NOCTTY | O_NDELAY);
    if (fd == -1)  {
        perror("init_serialport: Unable to open port ");
        return -1;
    }

    if (tcgetattr(fd, &toptions) < 0) {
        perror("init_serialport: Couldn't get term attributes");
        return -1;
    }
    speed_t brate = baud; /* let you override switch below if needed*/
    switch(baud) {
    case 4800:   brate=B4800;   break;
    case 9600:   brate=B9600;   break;
#ifdef B14400
    case 14400:  brate=B14400;  break;
#endif
    case 19200:  brate=B19200;  break;
#ifdef B28800
    case 28800:  brate=B28800;  break;
#endif
    case 38400:  brate=B38400;  break;
    case 57600:  brate=B57600;  break;
    case 115200: brate=B115200; break;
    }
    cfsetispeed(&toptions, brate);
    cfsetospeed(&toptions, brate);

    /* 8N1 */
    toptions.c_cflag &= ~PARENB;
    toptions.c_cflag &= ~CSTOPB;
    toptions.c_cflag &= ~CSIZE;
    toptions.c_cflag |= CS8;
    /* no flow control */
    toptions.c_cflag &= ~CRTSCTS;

    toptions.c_cflag |= CREAD | CLOCAL;  /* turn on READ & ignore ctrl lines */
    toptions.c_iflag &= ~(IXON | IXOFF | IXANY); /* turn off s/w flow ctrl */

    toptions.c_lflag &= ~(ICANON | ECHO | ECHOE | ISIG); /* make raw */
    toptions.c_oflag &= ~OPOST; /* make raw */

    /* see: http://unixwiz.net/techtips/termios-vmin-vtime.html */
    toptions.c_cc[VMIN]  = 0;
    toptions.c_cc[VTIME] = 20;

    if (tcsetattr(fd, TCSANOW, &toptions) < 0) {
        perror("init_serialport: Couldn't set term attributes");
        return -1;
    }

    return fd;
}

void usage(void)
{
    printf("Usage: arduino-serial-control [-b <baudrate>] -p <serialport> "
    " [-f <file>]\n"
    "Allows keyboard control of output to Arduino microcontroller board.\n"
    "\n"
    "Options:\n"
    "  -h, --help                   Print this help message\n"
    "  -b, --baud=baudrate          Baudrate (bps) of Arduino\n"
    "  -p, --port=serialport        Serial port Arduino is on (required)\n"
    "  -f, --file                   Take input from a file\n"
    "\n"
    "If using a specific baudrate, provide it before the port number.\n"
    "\n");
}
