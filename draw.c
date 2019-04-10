#include "stdlib.h"


//code to test to see if it functions:
//gets the value stored in assembly location COLUMN0
extern int COLUMN0;

//gets the value stored in assembly location COLUMN1
extern int COLUMN1;

//gets the value stored in assembly location COLUMN2
extern int COLUMN2;

//gets the current value of the (FPGA) buttons
extern int BUTTONS;	//may need to be volatile

extern int KB_MAKE_VALUE;

extern int BUTTONS_OFFSET;

//gets the location of COLUMN0
const int* column0_ptr = &COLUMN0;

//gets the location of COLUMN1
const int* column1_ptr = &COLUMN1;

//gets the location of COLUMN2
const int* column2_ptr = &COLUMN2;

const int* button_ptr = &BUTTONS;

//ps2 port address
volatile int* PS2_ptr = (int *) 0xFF200100;

int tower[10][3];
//volatile int * tower_ptr = (int *) 0x9cc;
//volatile int * column0_ptr = (int *)COLUMN0;
void draw();
void highlight_column();
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
	//create a variable that starts at the location of COLUMN0, and use it to iterate through the first column to initialize the C array
	int* local_tower_ptr;
	local_tower_ptr = column0_ptr;
	
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
	
	
	//draw pegs
	for(i = 0; i < 3; i++){
		draw_rectangle(79*(i+1), 79, peg_width, peg_height, 0xF4A460);
	}
	
	//build tower array using RAM locations
	for(i = 0; i < 10; i++){

		//tower[i][0] = *tower_ptr;
		//tower_ptr += 1;
		tower[i][0] = *local_tower_ptr;
		local_tower_ptr += 1;
	}
	
	//set local_tower_ptr to column 1's location
	local_tower_ptr = column1_ptr;
	//tower_ptr = (int *) 0x738;
	
	for(i = 0; i < 10; i++){
		tower[i][1] = *local_tower_ptr;
		local_tower_ptr += 1;
	}
	
	//set local_tower_ptr to column 2's location
	local_tower_ptr = column2_ptr;
	//tower_ptr = (int *) 0x754;
	
	for(i = 0; i < 10; i++){
		tower[i][2] = *local_tower_ptr;
		local_tower_ptr += 1;
	}
	
	
	for(i = 0; i < 3; i++){
		for(j = 0; j < 10; j++){
			if(tower[j][i] != 0){
				draw_rectangle(79 * (i+1) - width_mult*tower[j][i], 239 - (10-j)*disk_height, width_mult*(2* tower[j][i])+ peg_width, disk_height, 0x0300 * tower[j][i]+ 0x1000 * tower[j][i] + 0x3 * tower[j][i]);
			}
		}
	}
	
	
	//I think this should work. The problem was that we are just accessing a memory location and don't want to change the values.
/* 	for(i = 0; i < 30; i++){
		int j = i % 10;
		if(tower[i] != 0){
			draw_rectangle(79 * ((i/10)+1) - width_mult*tower[i], 239 - (4-j)*disk_height, width_mult*(2* tower[i])+ peg_width, disk_height, 0x0300 * tower[i]+ 0x1000 * tower[i] + 0x3 * tower[i]);
		}
	} */
}


//depending on the current value of the buttons, draw an arrow above the corresponding column that has just been selected
void highlight_column()
{
	
	int width = 30;
	int* local_buttons_ptr = button_ptr;
	int localButtons = *(local_buttons_ptr + BUTTONS_OFFSET);
	
	if(KB_MAKE_VALUE == 0x29)
	{
		if(localButtons == 1)
		{
			draw_triangle(65, 60, width, 0xFE00);
		}
		else if(localButtons == 2)
		{
			draw_triangle(144, 60, width, 0xFE00);
		}
		else if(localButtons == 4)
		{
			draw_triangle(223, 60, width, 0xFE00);
		}
	}
	else if (KB_MAKE_VALUE == 0x74)				//check for right arrow key press
	{
		if(localButtons == 4)
		{
			draw_triangle(144, 60, width, 0x00000000);	//draw black triangle over middle
			draw_triangle(223, 60, width, 0xFFFFFFFF);	//draw white triangle over right hand peg
			
		}
		else if (localButtons == 2)
		{
			draw_triangle(65, 60, width, 0x00000000);	//draw black triangle over first peg
			draw_triangle(144, 60, width, 0xFFFFFFFF);	//draw white triangle over middle
		}
			
	}
	else if (KB_MAKE_VALUE == 0x6B)			//check for left arrow key press
	{
		if(localButtons == 1)
		{
			draw_triangle(65, 60, width, 0xFFFFFFFF);	//draw white triangle over first peg
			draw_triangle(144, 60, width, 0x00000000);	//draw black triangle over middle	
		}
		else if (localButtons == 2)
		{	
			draw_triangle(144, 60, width, 0xFFFFFFFF);	//draw white triangle over middle
			draw_triangle(223, 60, width, 0x00000000);	//draw black triangle over right hand peg
		}
	}
	else if (localButtons == 1)
	{
		draw_triangle(65, 60, width, 0xFFFFFFFF);	//draw white triangle over first peg
	}
	
}



// code for subroutines (not shown)

int main(void)
{

	_start();
}