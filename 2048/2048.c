#include "mikeos.h"
#include "textio.h"

int brd_w = 4;
int brd_h = 4;

typedef int board[4][4];

void init_display();
void reset_game();
void play_game();

void display_board(board *b);
void reset_board(board *b);
void add_tile(board *b);
board *dup_board(board *b);
int cmp_board(board *a, board *b);

int can_move_up(board *b);
void merge_up(board *b);
void shift_up(board *b);

int can_move_down(board *b);
void merge_down(board *b);
void shift_down(board *b);

int can_move_left(board *b);
void merge_left(board *b);
void shift_left(board *b);

int can_move_right(board *b);
void merge_right(board *b);
void shift_right(board *b);

int game_is_lost();
void end_program();

void add_big_int(struct longint *value, struct longint *to_add);
void set_big_int(struct longint *value, int new_val);



board grid;
int alt_video_page = 0;

struct longint score;
struct longint merge_score;

char conv_buffer[10];


char *seperator = "+-----+-----+-----+-----+";

int main()
{
	int key;

	init_display();

	play_again:
	reset_game();
	display_board(&grid);
	play_game();

	movecur(15, 9 + brd_h * 2);
	textcolour(12);
	strout("Game Over! Press ESCAPE to exit or ENTER to play again.");

	do {
		key = os_wait_for_key();
	} while (key != ESC_KEY && key != ENTER_KEY);

	if (key == ENTER_KEY) goto play_again;
	end_program();
}

void reset_game()
{
	int x, y;
	board *b = grid;

	set_big_int(&score, 0);

	reset_board(b);

	/* Add two tiles with the value two. */
	/* Do not use add_tile() as this can generate fours as well. */
	(*b)[os_get_random(0, 1)][os_get_random(0, 3)] = 2;
	(*b)[os_get_random(2, 3)][os_get_random(0, 3)] = 2;
}

void reset_board(board *b)
{
	int x, y;

	for (y = 0; y < brd_h; y++) {
		for (x = 0; x < brd_w; x++) {
			(*b)[y][x] = 0;
		}
	}
}

void init_display()
{
	os_hide_cursor();
	textio_init();
	viewpage(2);
	outpage(2);
	clearscr();
}

void play_game()
{
	board *b = &grid;

	do {

		switch (os_wait_for_key()) {
			case ESC_KEY:
				return;

			case UP_KEY:
				if (can_move_up(b)) {
					shift_up(b);
					merge_up(b);
					shift_up(b);
					add_big_int(&score, &merge_score);
					break;
				} else {
					continue;
				}

			case DOWN_KEY:
				if (can_move_down(b)) {
					shift_down(b);
					merge_down(b);
					shift_down(b);
					add_big_int(&score, &merge_score);
					break;
				} else {
					continue;
				}

			case LEFT_KEY:
				if (can_move_left(b)) {
					shift_left(b);
					merge_left(b);
					shift_left(b);
					add_big_int(&score, &merge_score);
					break;
				} else {
					continue;
				}

			case RIGHT_KEY:
				if (can_move_right(b)) {
					shift_right(b);
					merge_right(b);
					shift_right(b);
					add_big_int(&score, &merge_score);
					break;
				} else {
					continue;
				}

			default:
				continue;
		}

		add_tile(b);
		display_board(b);

	} while (!game_is_lost());
}


void display_board(board *b)
{
	int x, y;

	if (alt_video_page) {
		outpage(2);
	} else {
		outpage(4);
	}

	textcolour(7);
	clearscr();

	movecur(30, 7);
	os_long_int_to_string(&score, 10, conv_buffer);
	strout("Score: ");
	strout(conv_buffer);

	for (y = 0; y < brd_h; y++) {
		movecur(30, y * 2 + 8);
		strout(seperator);
		movecur(30, y * 2 + 9);

		for (x = 0; x < brd_w; x++) {
			charout('|');

			if ((*b)[y][x] < 10000) charout(' ');
			if ((*b)[y][x] < 1000) charout(' ');
			if ((*b)[y][x] < 100) charout(' ');
			if ((*b)[y][x] < 10) charout(' ');

			if ((*b)[y][x] == 0) {
				charout(' ');
			} else {
				strout(os_int_to_string((*b)[y][x]));
			}
		}

		charout('|');
	}
	
	movecur(30, 16);
	strout(seperator);

	if (alt_video_page) {
		viewpage(2);
		alt_video_page = 0;
	} else {
		viewpage(4);
		alt_video_page = 1;
	}
}

void add_tile(board *b)
{
	int x, y, fill_pos;
	int empty = 0;

	for (y = 0; y < brd_h; y++) {
		for (x = 0; x < brd_w; x++) {
			if ((*b)[y][x] == 0) empty++;
		}
	}

	if (empty == 0) return;

	fill_pos = os_get_random(1, empty);

	for (y = 0; y < brd_h; y++) {
		for (x = 0; x < brd_w; x++) {
			if ((*b)[y][x] == 0) fill_pos--;
			if (fill_pos == 0) {
				if (os_get_random(0, 9) == 0) {
					(*b)[y][x] = 4;
				} else {
					(*b)[y][x] = 2;
				}

				return;
			}
		}
	}
}

int can_move_up(board *b)
{
	board *tmp;

	/* Create a copy of the board and simulate up action. */
	tmp = dup_board(b);

	shift_up(tmp);
	merge_up(tmp);
	shift_up(tmp);

	/* If the board is the same, the action is not possible. */
	if (cmp_board(b, tmp)) {
		free(tmp);
		return 0;
	} else {
		free(tmp);
		return 1;
	}
}


void merge_up(board *b)
{
	int x, y;
	struct longint tmp;

	set_big_int(&merge_score, 0);

	for (x = 0; x < brd_w; x++) {
		for (y = 0; y < brd_h - 1; y++) {
			if ((*b)[y][x] > 0 && (*b)[y][x] == (*b)[y + 1][x]) {
				(*b)[y][x] <<= 1;
				(*b)[y + 1][x] = 0;
				set_big_int(&tmp, (*b)[y][x]);
				add_big_int(&merge_score, &tmp);
			}
		}
	}
}


void shift_up(board *b)
{
	int x, y, lastpos;

	for (x = 0; x < brd_w; x++) {
		lastpos = 0;
		for (y = 0; y < brd_h; y++) {
			if ((*b)[y][x] != 0) {
				(*b)[lastpos][x] = (*b)[y][x];
				if (lastpos++ != y) {
					(*b)[y][x] = 0;
				}
			}
		}
	}
}

int can_move_down(board *b)
{
	board *tmp;

	tmp = dup_board(b);

	shift_down(tmp);
	merge_down(tmp);
	shift_down(tmp);

	if (cmp_board(b, tmp)) {
		free(tmp);
		return 0;
	} else {
		free(tmp);
		return 1;
	}
}


void merge_down(board *b)
{
	int x, y;
	struct longint tmp;

	set_big_int(&merge_score, 0);

	for (x = 0; x < brd_w; x++) {
		for (y = 3; y > 0; y--) {
			if ((*b)[y][x] > 0 && (*b)[y][x] == (*b)[y - 1][x]) {
				(*b)[y][x] <<= 1;
				(*b)[y - 1][x] = 0;
				set_big_int(&tmp, (*b)[x][y]);
				add_big_int(&merge_score, &tmp);

			}
		}
	}
}


void shift_down(board *b)
{
	int x, y, lastpos;

	for (x = 0; x < brd_w; x++) {
		lastpos = 3;
		for (y = 3; y >= 0; y--) {
			if ((*b)[y][x] != 0) {
				(*b)[lastpos][x] = (*b)[y][x];
				if (lastpos-- != y) {
					(*b)[y][x] = 0;
				}
			}
		}
	}
}


int can_move_left(board *b)
{
	board *tmp;

	tmp = dup_board(b);

	shift_left(tmp);
	merge_left(tmp);
	shift_left(tmp);

	if (cmp_board(b, tmp)) {
		free(tmp);
		return 0;
	} else {
		free(tmp);
		return 1;
	}
}


void merge_left(board *b)
{
	int x, y;
	struct longint tmp;

	set_big_int(&merge_score, 0);

	for (y = 0; y < brd_h; y++) {
		for (x = 0; x < brd_w - 1; x++) {
			if ((*b)[y][x] > 0 && (*b)[y][x] == (*b)[y][x + 1]) {
				(*b)[y][x] <<= 1;
				(*b)[y][x + 1] = 0;
				set_big_int(&tmp, (*b)[y][x]);
				add_big_int(&merge_score, &tmp);
			}
		}
	}
}


void shift_left(board *b)
{
	int x, y, lastpos;

	for (y = 0; y < brd_h; y++) {
		lastpos = 0;
		for (x = 0; x < brd_w; x++) {
			if ((*b)[y][x] != 0) {
				(*b)[y][lastpos] = (*b)[y][x];
				if (lastpos++ != x) {
					(*b)[y][x] = 0;
				}
			}
		}
	}
}


int can_move_right(board *b)
{
	board *tmp;

	tmp = dup_board(b);

	shift_right(tmp);
	merge_right(tmp);
	shift_right(tmp);

	if (cmp_board(b, tmp)) {
		free(tmp);
		return 0;
	} else {
		free(tmp);
		return 1;
	}
}


void merge_right(board *b)
{
	int x, y;
	struct longint tmp;

	set_big_int(&merge_score, 0);

	for (y = 0; y < brd_h; y++) {
		for (x = 3; x > 0; x--) {
			if ((*b)[y][x] > 0 && (*b)[y][x] == (*b)[y][x - 1]) {
				(*b)[y][x] <<= 1;
				(*b)[y][x - 1] = 0;
				set_big_int(&tmp, (*b)[y][x]);
				add_big_int(&merge_score, &tmp);
			}
		}
	}
}


void shift_right(board *b)
{
	int x, y, lastpos;

	for (y = 0; y < brd_h; y++) {
		lastpos = 3;
		for (x = 3; x >= 0; x--) {
			if ((*b)[y][x] != 0) {
				(*b)[y][lastpos] = (*b)[y][x];
				if (lastpos-- != x) {
					(*b)[y][x] = 0;
				}
			}
		}
	}
}


int game_is_lost()
{
	if (can_move_left(&grid) || can_move_right(&grid) || 
			can_move_up(&grid) || can_move_down(&grid)) {
		return 0;
	} else {
		return 1;
	}
}

	
void end_program()
{
	viewpage(0);
	os_show_cursor();
	exit(0);
}

board *dup_board(board *src, board *dest)
{
	int x, y;

	board *dest;
	
	dest = malloc(sizeof(*dest));

	if (!dest) {
		end_program();
	}

	for (y = 0; y < brd_h; y++) {
		for (x = 0; x < brd_w; x++) {
			(*dest)[y][x] = (*src)[y][x];
		}
	}

	return dest;
}

int cmp_board(board *a, board *b)
{
	int x, y;

	for (y = 0; y < brd_h; y++) {
		for (x = 0; x < brd_w; x++) {
			if ((*a)[y][x] != (*b)[y][x]) return 0;
		}
	}
}


void add_big_int(struct longint *value, struct longint *to_add)
{
	int old_val;

	old_val = value->lower;

	value->lower += to_add->lower;

	if (value->lower < to_add->lower) value->upper++;

	value->upper += to_add->upper;
}

void set_big_int(struct longint *value, int new_val)
{
	value->upper = 0;
	value->lower = new_val;
}


