#include "screen.h"
#include "ports.h"

// Declaration of private functions
int get_cursor_offset();
void set_cursor_offset(int offset);
int print_char(char c, int col, int row, char attr);
int get_offset(int col, int row);
int get_offset_row(int offset);
int get_offset_col(int offset);

/*******************************************
 * Public Kernel API functions             *
 ******************************************/

// Print a message on the specified location
// If col, row, are negative, we will use the current offset
void kprint_at(char *message, int col, int row) {
  int offset;
  if (col >= 0 && row >= 0) {
    offset = get_offset(col, row);
  } else {
    offset = get_cursor_offset();
    row = get_offset_row(offset);
    col = get_offset_col(offset);
  }

  int i = 0;
  while (message[i] != 0) {
    offset = print_char(message[i++], col, row, WHITE_ON_BLACK);
    row = get_offset_row(offset);
    col = get_offset_col(offset);
  }
}

void kprint(char *message) {
  kprint_at(message, -1, -1);
}

/*******************************************
 * Private Kernel functions                *
 ******************************************/

// Innermost print function for the kernel, directly accesses the video memory
int print_char(char c, int col, int row, char attr) {
  unsigned char *vidmem = (unsigned char*) VIDEO_ADDRESS;
  // If attribute not specified, set it to white on black
  if (!attr) attr = WHITE_ON_BLACK;

  // Print error if the coords aren't correct
  if (col >= MAX_COLS || row >= MAX_ROWS) {
   vidmem[2 * (MAX_COLS) * (MAX_ROWS) - 2] = 'E';
   vidmem[2 * (MAX_COLS) * (MAX_ROWS) - 1] = RED_ON_WHITE;
   return get_offset(col, row); 
  }

  int offset;
  // Check if col,row arent negative. If they are, use current offset
  if (col >= 0 && row >= 0) offset = get_offset(col, row);
  else offset = get_cursor_offset();

  if (c == '\n') {
    // If c is the newline character, move to the next row
    row = get_offset_row(offset);
    offset = get_offset(0, row + 1);
  } else {
    // Else, print the current char and inc the offset by 2
    vidmem[offset] = c;
    vidmem[offset + 1] = attr;
    offset += 2;
  }

  // Check if the offset is over screen size and scroll
  if (offset >= MAX_ROWS * MAX_COLS * 2) {
    int i;
    for (i = 1; i < MAX_ROWS; i++) {
      memory_copy(get_offset(0, i) + VIDEO_ADDRESS, get_offset(0, i-1) + VIDEO_ADDRESS, MAX_COLS * 2);
    }

    char *last_line = get_offset(0, MAX_ROWS-1) + VIDEO_ADDRESS;
    for (i = 0; i < MAX_COLS * 2; i++) last_line[i] = 0;

    offset -= 2 * MAX_COLS;
  }

  set_cursor_offset(offset);
  return offset;
}

int get_cursor_offset() {
  // Use VGA ports to get the cursor position

  port_byte_out(REG_SCREEN_CTRL, 14);
  int offset = port_byte_in(REG_SCREEN_DATA) << 8;
  port_byte_out(REG_SCREEN_CTRL, 15);
  offset += port_byte_in(REG_SCREEN_DATA);

  // Position multiplied by size of cell (char + attr)
  return offset * 2;
}

void set_cursor_offset(int offset) {
  // Similar to get_cursor_offset, but we're writing data
  // Account for size of cell (char + attr)
  offset /= 2;

  port_byte_out(REG_SCREEN_CTRL, 14);
  port_byte_out(REG_SCREEN_DATA, (unsigned char)(offset >> 8));
  port_byte_out(REG_SCREEN_CTRL, 15);
  // AND the offset with 0xff, masks the high bit
  port_byte_out(REG_SCREEN_DATA, (unsigned char)(offset & 0xff));
}

void clear_screen() {
  int screen_size = MAX_COLS * MAX_ROWS;
  int i;
  char *screen = VIDEO_ADDRESS;

  for (i = 0; i < screen_size; i++) {
    screen[i*2] = ' ';
    screen[i*2+1] = WHITE_ON_BLACK;
  }

  set_cursor_offset(get_offset(0, 0));
}

int get_offset(int col, int row) {
  return 2 * (row * MAX_COLS + col);
}

int get_offset_row(int offset) {
  return offset / (2 * MAX_COLS);
}

int get_offset_col(int offset) {
  return (offset - (get_offset_row(offset) * 2 * MAX_COLS)) / 2;
}