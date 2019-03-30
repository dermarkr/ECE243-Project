#include "stdlib.h"

//int tower[4][3];

.extern	void draw();

volatile int pixel_buffer_start; // global variable

void plot_pixel(int x, int y, short int line_color)
{
    *(short int *)(pixel_buffer_start + (y << 10) + (x << 1)) = line_color;
}

//draws a line from x1, y1 to x2, y2. Requires plotpixel to run
//assumes math.h not available
void draw_line(int x1, int y1, int x2, int y2, int colour) {
	int is_steep = 0;
	int deltay = y2 - y1;
	int deltax = x2 - x1;
	int error = (-1)*(deltax / 2);

	//checking if deltay is positive
	if (deltay < 0) {
		deltay = deltay * (-1);
	}

	//finds it the slope is greater than 1
	if (((deltax >= 0) && (deltay > deltax)) || ((deltax < 0) && (deltay > (deltax * (-1))))) {
		is_steep = 1;
	}
	
	//if slope greater than one trades variables to switch from y/x to x/y
	if (is_steep) {
		int temp = x1;
		x1 = y1;
		y1 = temp;

		temp = x2;
		x2 = y2;
		y2 = temp;
	}
	
	//ensures x2 is greater than x1
	if (x1 > x2) {
		int temp = x1;
		x1 = x2;
		x2 = temp;

		temp = y1;
		y1 = y2;
		y2 = temp;
	}
	deltay = y2 - y1;
	deltax = x2 - x1;
	error = (-1)*(deltax / 2);
	int y = y1;
	int y_step;

	if (deltay < 0) {
		deltay = deltay * (-1);
	}

	//determines which way to increment y
	if (y1 < y2) {
		y_step = 1;
	}
	else {
		y_step = -1;
	}

	int x = 0;

	//plots all the pixels in the line
	for (x = x1; x <= x2; x++) {
		if (is_steep) {
			plot_pixel(y, x, colour);
		}
		else {
			plot_pixel(x, y, colour);
		}

		error = error + deltay;

		if (error >= 0) {
			y = y + y_step;
			error = error - deltax;
		}
	}	
}

void draw_rectangle(int x1, int y1, int width, int height, int colour) {
	int x;
	
	for (x = x1; x < (width + x1); x++){
		draw_line(x, y1, x, (height + y1), colour);
	}
}

//writes all pixels to black
void clear_screen() {
	int x = 0;
	
	for (x = 0; x < 320; x++) {
		int y = 0;
		
		for (y = 0; y < 240; y++) {
			plot_pixel(x, y, 0);
		}
	}
}

//waits for the S value in the registry to change to 0 indication the frame is drawn
void wait_for_vsync(){
	volatile int *pixel_ctrl_ptr = (int*)0xFF203020;
	register int status;
	
	*pixel_ctrl_ptr = 1;
	
	status = *(pixel_ctrl_ptr + 3);
	while((status & 0x01) != 0){
		status = *(pixel_ctrl_ptr +3);
	}
}

void draw()
{
    volatile int * pixel_ctrl_ptr = (int *)0xFF203020;
    // declare other variables(not shown)
    // initialize location and direction of rectangles(not shown)
	
	pixel_buffer_start = * pixel_ctrl_ptr;
	
	volatile int * tower_ptr = (int *) 0xA0000008;
	
	clear_screen();
	
	int i = 0;
	int j = 0;
	
	int peg_width = 3;
	int disk_height = 6;
	int peg_height = 160;
	int width_mult = 4;
	
	
	//draw pegs
	for(i = 0; i < 3; i++){
		draw_rectangle(79*(i+1), 79, peg_width, peg_height, 0xF4A460);
	}
	
/* 	for(i = 0; i < 3; i++){
		for(j = 0; j < 4; j++){
			if(tower[j][i] != 0){
				draw_rectangle(79 * (i+1) - width_mult*tower[j][i], 239 - (4-j)*disk_height, width_mult*(2* tower[j][i])+ peg_width, disk_height, 0x0300 * tower[j][i]+ 0x1000 * tower[j][i] + 0x3 * tower[j][i]);
			}
		}
	} */
	
	
	//I think this should work. The problem was that we are just accessing a memory location and don't want to change the values.
	for(i = 0; i < 30; i++){
		int j = i % 10;
		if(tower[i] != 0){
			draw_rectangle(79 * ((i/10)+1) - width_mult*tower[i], 239 - (4-j)*disk_height, width_mult*(2* tower[i])+ peg_width, disk_height, 0x0300 * tower[i]+ 0x1000 * tower[i] + 0x3 * tower[i]);
		}
	}
}

// code for subroutines (not shown)

/* int main(void){
	//initialize tower starting conditions 
 	int local_tower[4][3] = { {0, 0, 0},
			{1, 0, 0},
			{2, 0, 0},
				{3, 0, 0}}; 
	int i;
	int j;
	for (i = 0; i < 4; i++){
		for (j = 0; j < 3; j++){
			tower[i][j] = local_tower[i][j];
		}
	}
	draw();
} */