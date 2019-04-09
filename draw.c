#include "stdlib.h"

/*
//code to test to see if it functions:
extern int tower [10][3];
*/
int tower[10][3];
volatile int * tower_ptr = (int *) 0x9cc;

void draw();
void higlight_column();
void setInitialTower();

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

void draw_triangle(int x1, int y1, int width, int colour)
{
	int x, y;
	int height = width / 2;
	
	x = (width / 2) + x1;
	
	for ( y = 0; y < (height); y++)
	{
		draw_line((x-y), (y1 - y), (x + y), (y1 - y), colour); 
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
	
	clear_screen();
	
	int i = 0;
	int j = 0;
	
	int peg_width = 3;
	int disk_height = 12;
	int peg_height = 160;
	int width_mult = 4;
	
	tower_ptr = (int *) 0x9cc;
	
	//draw pegs
	for(i = 0; i < 3; i++){
		draw_rectangle(79*(i+1), 79, peg_width, peg_height, 0xF4A460);
	}
	
	//build tower array using RAM locations
	for(i = 0; i < 10; i++){
		tower[i][0] = *tower_ptr;
		tower_ptr += 1;
	}
	
	//tower_ptr = (int *) 0x738;
	
	for(i = 0; i < 10; i++){
		tower[i][1] = *tower_ptr;
		tower_ptr += 1;
	}
	
	//tower_ptr = (int *) 0x754;
	
	for(i = 0; i < 10; i++){
		tower[i][2] = *tower_ptr;
		tower_ptr += 1;
	}
	
	
	for(i = 0; i < 3; i++){
		for(j = 0; j < 10; j++){
			if(tower[j][i] != 0){
				draw_rectangle(79 * (i+1) - width_mult*tower[j][i], 239 - (10-j)*disk_height, width_mult*(2* tower[j][i])+ peg_width, disk_height, 0x0300 * tower[j][i]+ 0x1000 * tower[j][i] + 0x3 * tower[j][i]);
			}
		}
	}
	
	tower_ptr = (int *) 0x9cc;
	
	//I think this should work. The problem was that we are just accessing a memory location and don't want to change the values.
/* 	for(i = 0; i < 30; i++){
		int j = i % 10;
		if(tower[i] != 0){
			draw_rectangle(79 * ((i/10)+1) - width_mult*tower[i], 239 - (4-j)*disk_height, width_mult*(2* tower[i])+ peg_width, disk_height, 0x0300 * tower[i]+ 0x1000 * tower[i] + 0x3 * tower[i]);
		}
	} */
}

void higlight_column()
{
	tower_ptr = tower_ptr - 2;
	
	int width = 30;
	
	if(*tower_ptr == 1)
	{
		draw_triangle(65, 60, width, 0xFFFFFFFF);
	}
	else if(*tower_ptr == 2)
	{
		draw_triangle(144, 60, width, 0xFFFFFFFF);
	}
	else if(*tower_ptr == 4)
	{
		draw_triangle(223, 60, width, 0xFFFFFFFF);
	}
	
}

/*
void setInitialTower()
{
	int i;
	for i = 0; i < 10; i++){
		tower[i][0] = i+1;
	}

}
*/

// code for subroutines (not shown)

int main(void)
{

	_start();
}