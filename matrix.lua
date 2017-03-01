--globals
XRES = 500
YRES = 500
MAX_COLOR = 255

--object to store color
Color = {red = 0, green = 0 , blue = 0}

--constructor
function Color:new ( r , g ,b )
	 local color = {}
	 setmetatable(color , self)
	 self.__index = self 
	 self.red = r 
	 self.green = g
	 self.blue = b
	 return color
end

--create the array to store pixels 
board = {}
for i = 0, XRES-1 do
    board[i] = {}
    for k = 0, YRES -1 do
    	board[i][k] = Color:new(0,0,0)
    end
end

--reset the screen
function clear_screen(s)
	 for i = 0 , XRES-1 do
	     for k = 0 , YRES -1 do
	     	 s[i][k].red = 0
		 s[i][k].green = 0
		 s[i][k].blue = 0
	     end
	 end
end

--plot with 0,0 at top left, plots starting from bottom left
function plot(s , c , x , y)
	 local newy = YRES - 1 - y
	 if(x >=0 and x<XRES and newy >=0 and newy<YRES) then
	      s[x][newy].red = c.red
	      s[x][newy].green = c.green
	      s[x][newy].blue = c.blue
	 end
end

--creates the ppm file
function save_ppm(s)
	 file = io.open("line.ppm" , "w")
	 file:write("P3\n" , XRES , "\n" , YRES , "\n" , MAX_COLOR, "\n")
	 for x = 0, XRES - 1 do
	     for y = 0 , YRES - 1 do
	     	 file:write(s[x][y].red, " " ,s[x][y].green," ",s[x][y].blue ," ")
	     end
	     file:write("\n")
	 end 
	 io.close(file)
end

--does the line algorithm

function oct_check(x0 , y0, x1 , y1)
	 local A , B , oct , A1 , B1
	 oct = 0 -- oct is which octant the line is in
	 A = y1 - y0
	 B = x1 - x0
	 A1 = y0 - y1
	 B1 = x0 - x1
	 --octant 1
	 if (B > 0 and A >0) then
	    if (B >= A) then
	       oct = 1
	    end
         end
	 --octant 2
	 if (B >0 and A > 0) then
	    if (A > B) then
	       oct = 2
	    end
	 end
	 --octant 8
	 if (A1 > 0 and B>0) then
	    if (B>=A1) then
	       oct = 8
	    end
   	 end
	 --octant 7
	 if (A1 > 0 and B>0) then
	    if (A1>B) then
	       oct = 7
	    end
	 end
	 --horizontak=l line
	 if (B ==0 ) then
	    oct = 9
	 end
	 if (A == 0) then
	    oct =10
	 end
	 return oct
end	      

--function to draw line
function draw_line(x0 , y0 , x1, y1 , c , s)
	 x = x0
	 y = y0
	 oct = oct_check(x0, y0 , x1, y1)
	 if (oct == 0) then draw_line(x1,y1,x0,y0,c,s) end
	 if (oct == 9) then
	    if (y1 > y) then
	       while (y1 > y) do
	       	     plot(s,c,x,y)
		     y = y +1
	       end
	    else 
	    	 while (y>y1) do
		       plot(s,c,x,y)
		       y = y-1
		 end
	    end
	 end
	 if (oct == 10) then
	    if ( x1 > x) then
	       while ( x1 > x) do
	       	     plot(s , c , x , y)
		     x = x + 1
	      end
	    else
		while (x > x1) do
		      plot(s , c , x , y)
		      x = x -1
		end
	    end
	 end   	     
	 if (oct == 1) then --line is in octant 1
	    A = y1 - y
	    B = -1 * (x1 - x)
	    D = 2*A + B
	    while(x <= x1) do
	    	    plot(s , c , x , y)
		    if( D>0) then
		    	y = y+1
			D = D + 2*B
		    end
		    x = x +1
		    D = D + 2*A

 	    end
	 end
	 if (oct == 2) then --line is in octant 2
	    A = y1 - y
	    B = -1  * (x1-x)
	    D = 2*B + A
	    while( y < y1) do
	    	   plot(s , c , x ,y)
		   if (D < 0) then
		      x = x +1
		      D = D + 2*A
		   end
		   y = y +1
		   D = D + 2*B
            end
	 end
	 if (oct == 8) then --line is in octant 8
	    A = y1 -y
	    B = -1 * (x1 - x)
	    D = 2*A -B
	    while(x < x1) do
	    	    plot(s , c , x , y )
		    if ( D < 0) then
		       y = y -1
		       D = D + 2*B
		    end
		    x = x+1
		    D = D + 2*A
	    end 
	 end 
	 
	 if (oct == 7 ) then --line is in octant 7
	    A = y1 - y
	    B = -1 * ( x1 - x)
	    D = A - 2*B
	    while( y > y1) do
	    	   plot(s , c , x , y)
		   if (D > 0) then
		      x = x +1
		      D = D + 2*A
		   end
		   y = y -1
		   D = D -2*B
	    end
	 end	    
end



function draw(s)
	 for i = 0 , 499  do
	     for k = 0, 499 do
	     	 if(k==(i-250)^2) then
			local pixel = Color:new(i%256 , k%256 , 100)
		 	draw_line(0 , 0 , i , k , pixel , s)
			draw_line(0,0,k,i,pixel,s)
		 end
	      end
	 end
end

function main()
	 clear_screen(board)
	 draw(board)
	 save_ppm(board)
end
main()
--[[
pixel = Color:new(100,50,10)
clear_screen(board)
draw_line(100,100,100,150,pixel, board)
draw_line(100,100,200,100,pixel,board)
draw_line(0,0,200,100,pixel,board)
draw_line(250,250,400,300,pixel,board)
draw_line(250,250,300,400,pixel,board)
draw_line(250,250,200,400,pixel,board)
draw_line(250,250, 250,400,pixel,board)
draw_line(250,250,100,200,pixel,board)
draw_line(250,250,200,100,pixel,board)
draw_line(250,250,300,100,pixel,board)
draw_line(250,250,400,200,pixel,board)
draw_line(20,50,300,490,pixel,board)
draw_line(0,0,0,400,pixel,board)
draw_line(150,0,150,450,pixel,board)
draw_line(250,250,300,200,pixel,board)
draw_line(250,250,400,140,pixel,board)
save_ppm(board)
]]--
print("file is saved as line.ppm\n")