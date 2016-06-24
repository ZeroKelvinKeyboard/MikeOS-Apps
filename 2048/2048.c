#include "mikeos.h"
#include "textio.h"

void init_display();
void reset_grid();
void play_game();
void display_board();
void add_tile();
void merge_up();
void shift_up();
void merge_down();
void shift_down();
void merge_left();
void shift_left();
void merge_right();
void shift_right();
int game_is_lost();
void end_program();


unsigned int grid[4][4];

char *seperator = "+-----+-----+-----+-----+";

int main()
{
	init_display();
	reset_grid();
	display_board();
	play_game();
}

void reset_grid()
{
	int x, y;

	for (y = 0; y < 4; y++) {
		for (x = 0; x < 4; x++) {
			grid[y][x] = 0;
		}
	}

	grid[os_get_random(0, 1)][os_get_random(0, 3)] = 2;
	grid[os_get_random(2, 3)][os_get_random(0, 3)] = 2;
}

void init_display()
{
	textio_init();
	textio_set_visible_page(2);
	textio_set_output_page(2);
	textio_clear_screen();
}

void play_game()
{
	do {

		switch (os_wait_for_key()) {
			case ESC_KEY:
				end_program();

			case UP_KEY:
				shift_up();
				merge_up();
				shift_up();
				break;

			case DOWN_KEY:
				shift_down();
				merge_down();
				shift_down();
				break;

			case LEFT_KEY:
				shift_left();
				merge_left();
				shift_left();
				break;

			case RIGHT_KEY:
				shift_right();
				merge_right();
				shift_right();
				break;

			default:
				continue;
		}

		add_tile();
		display_board();

	} while (!game_is_lost());

	textio_set_cursor(7, 30);
	textio_set_text_colour(12);
	textio_print_string("Game Over! Press ESCAPE to exit.");
	while (os_wait_for_key() != ESC_KEY);
	end_program();
}


void display_board()
{
	int x, y;

	
	textio_clear_screen();

	for (y = 0; y < 4; y++) {
		textio_set_cursor(y * 2 + 8, 30);

		for (x = 0; y < 4; x++) {
			textio_write_char('|');

			if (grid[y][x] < 10000) textio_write_char(' ');
			if (grid[y][x] < 1000) textio_write_char(' ');
			if (grid[y][x] < 100) textio_write_char(' ');
			if (grid[y][x] < 10) textio_write_char(' ');

			if (grid[y][x] == 0) {
				textio_write_char(' ');
			} else {
				textio_print_string(os_int_to_string(grid[y][x]));
			}
		}

		textio_write_char('|');
		textio_set_cursor(y * 2 + 9, 30);
		textio_print_string(seperator);
	}
	
	textio_set_cursor(16, 30);
	textio_print_string(seperator);
}

void add_tile()
{
	int x, y, fill_pos;
	int empty = 0;

	for (y = 0; y < 4; y++) {
		for (x = 0; x < 4; x++) {
			if (grid[y][x] == 0) empty++;
		}
	}

	if (empty == 0) return;

	fill_pos = os_get_random(1, empty);

	for (y = 0; y < 4; y++) {
		for (x = 0; x < 4; x++) {
			if (grid[y][x] == 0) fill_pos--;
			if (fill_pos == 0) {
				if (os_get_random(0, 9) == 0) {
					grid[y][x] = 4;
				} else {
					grid[y][x] = 2;
				}

				return;
			}
		}
	}
}

void merge_up()
{
	int x, y;

	for (x = 0; x < 4; x++) {
		for (y = 0; y < 3; y++) {
			if (grid[y][x] > 0 && grid[y][x] == grid[y + 1][x]) {
				grid[y][x] <<= 1;
				grid[y + 1][x] = 0;
			}
		}
	}
}

void shift_up()
{
	int x, y, lastpos;

	for (x = 0; x < 4; x++) {
		lastpos = 0;
		for (y = 0; y < 4; y++) {
			if (grid[y][x] != 0) {
				grid[lastpos++][x] = grid[y][x];
			}
		}
	}
}

void merge_down()
{
	int x, y;

	for (x = 0; x < 4; x++) {
		for (y = 3; y > 0; y--) {
			if (grid[y][x] > 0 && grid[y][x] == grid[y - 1][x]) {
				grid[y][x] <<= 1;
				grid[y - 1][x] = 0;
			}
		}
	}
}

void shift_down()
{
	int x, y, lastpos;

	for (x = 0; x < 4; x++) {
		lastpos = 3;
		for (y = 3; y >= 0; y--) {
			if (grid[y][x] != 0) {
				grid[lastpos--][x] = grid[y][x];
			}
		}
	}
}


void merge_left()
{
	int x, y;

	for (y = 0; y < 4; y++) {
		for (x = 0; x < 3; x++) {
			if (grid[y][x] > 0 && grid[y][x] == grid[y][x + 1]) {
				grid[y][x] <<= 1;
				grid[y][x + 1] = 0;
			}
		}
	}
}


void shift_left()
{
	int x, y, lastpos;

	for (y = 0; y < 4; y++) {
		lastpos = 0;
		for (x = 0; x < 4; x++) {
			if (grid[y][x] != 0) {
				grid[y][lastpos++] = grid[y][x];
			}
		}
	}
}


void merge_right()
{
	int x, y;

	for (y = 0; y < 4; y++) {
		for (x = 3; x > 0; x--) {
			if (grid[y][x] > 0 && grid[y][x] == grid[y][x - 1]) {
				grid[y][x] <<= 1;
				grid[y][x - 1] = 0;
			}
		}
	}
}


void shift_right()
{
	int x, y, lastpos;

	for (y = 0; y < 4; y++) {
		lastpos = 3;
		for (x = 3; x >= 0; x--) {
			if (grid[y][x] != 0) {
				grid[y][lastpos--] = grid[y][x];
			}
		}
	}
}


int game_is_lost()
{
	int x, y;

	for (y = 0; y < 4; y++) {
		for (x = 0; x < 4; x++) {
			if (grid[y][x] == 0) return 0;
			if (y != 3 && grid[y][x] == grid[y + 1][x]) return 0;
			if (x != 3 && grid[y][x] == grid[y][x + 1]) return 0;
		}
	}

	return 1;
}

	
void end_program()
{
	textio_set_visible_page(0);
	exit(1);
}

		
