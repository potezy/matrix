--globals
XRES = 500
YRES = 500
MAX_COLOR = 255

--object to store color
Color = {red = 0, green = 0 , blue = 0}

--constructors 
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

function plot(s , c , x , y)
	 local newy = y
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
	 if (x0>x1) then
	    xt = x0 	   
	    yt = y0
	    x0 = x1
	    y0 = y1
	    x1 = xt
	    y1 = yt
	 end
	 x = x0
	 y = y0
	 A = 2*(y1-y0)
	 B = -2*(x1 - x0)
	    if (math.abs(x1-x0) >= math.abs(y1-y0)) then
	       if (A > 0) then
	       	  D = A + B/2
	       	  while (x <x1) do
	       	     	plot(s,c,x,y)
			if ( D >0) then	
			   y = y +1  
		     	   D = D + B
			end
			x = x +1
			D = D + A
		  end
		  plot(s , c , x , y)
	       else d = A - B/2
	       	    while (x < x1) do
		    	  plot(s,c,x,y)
			  if (D<0) then
			     y = y -1
			     D = D - B
			  end
			  x = x +1
			  D = D + A
		    end
		    plot(s,c,x,y)
	       end
	    else
		if (A > 0) then
		   D = A/2 + B
		   while ( y < y1) do
		   	 plot( s , c , x ,y)
			 if ( D < 0) then
			    x = x + 1
			    D = D + A
	    	   	 end
			 y = y +1
			 D = D + B
		   end
	 	   plot( s , c , x ,y)
		else D = A/2 - B
		     while (y > y1) do
		     	   plot(s,c,x,y)
			   if  (D > 0) then
			       x = x +1
			       D = D + A
			   end
			   y = y -1
			   D = D - B
		     end
		     plot(s,c,x,y)
		end
	
	   end	
	
end



function draw(board, pMatrix)
	 for i = 1 , sizeOf(pMatrix[1]) , 2 do
	     local x1 = pMatrix[1][i]
	     local x2 = pMatrix[1][i+1]
	     local y1 = pMatrix[2][i]
	     local y2 = pMatrix[2][i+1]
	     --print(x1,y1,x2,y2)
	     color = Color:new((x1+x2)%255, (y1+y2)%255, (x1+x2+y1+y2)%255)
	     draw_line(x1,y1,x2,y2,color,board)
	 end
end

--here begins the functions for matrix things

--prints the matrix

function printMatrix(matrix)
	 s = ""
	 for i , v in ipairs(matrix) do
	      for k , r  in ipairs(v) do 
	      	  s = s .. matrix[i][k] .. " "
	      end
	      s = s .. "\n"
	 end
	 print(s) 
end

--returns the number of data entries in a matrix
function sizeOf(matrix)
	 local size = 0
	 for _ in pairs(matrix) do size = size + 1 end
	 return size
end

function scalar(int , matrix)
	 for i , v in ipairs(matrix) do
	     for k , r in ipairs(v) do
	     	 matrix[i][k] = int * matrix[i][k]
             end
	 end
	 return matrix	
end

function identify(matrix)
	 side = sizeOf(matrix)
	 for i = 1, side do
	     for j = 1, side do
	     	 if (i == j) then matrix[i][j] = 1
		 else matrix[i][j] = 0 end     
	     end
	 end
	 return matrix
end

function matrixMult(matrix1 , matrix2)
	 local tempMatrix = {}
	 for i = 1, sizeOf(matrix1) do
	     tempMatrix[i] = {}
	     for k = 1, sizeOf(matrix2[1]) do
	     	 tempMatrix[i][k] = 0
	     end
	 end
	 for i = 1, sizeOf(matrix1) do
	     for k = 1 , sizeOf(matrix2[1]) do
	     	 for j = 1, sizeOf(matrix1[1]) do
		     --print(j)
		     tempMatrix[i][k] =  tempMatrix[i][k] + matrix1[i][j] * matrix2[j][k]
		     end
		  end
	end
	return tempMatrix	 
end

pMatrix = {{},{},{},{}}

function addPoint(pMatrix, x,y,z)
	 table.insert(pMatrix[1],x) 	 
	 table.insert(pMatrix[2],y)
	 table.insert(pMatrix[3],z)
	 table.insert(pMatrix[4],1)
end

function addEdge(pMatrix, x1,y1,z1,x2,y2,z2)
	 addPoint(pMatrix,x1,y1,z1)
	 addPoint(pMatrix,x2,y2,z2)
end


function edgeMaker(matrix)
	 for x = 0, 499 do
	     for y = 0, 499 do
	     	 if((x-250)^2 == y) then addEdge(matrix, 250,250,0,x,y,0) end
       	     end
	end
	addEdge(matrix, 0,0,0,250,500,0)
	addEdge(matrix, 250,250,0,0,500,0)
 	addEdge(matrix,	250,250,0,500,0,0)
	addEdge(matrix, 250,250,0,500,500,0)

	addEdge(matrix, 250,250,0,375,0,0)	
	addEdge(matrix, 250,250,0,375,500,0)
	addEdge(matrix, 250,250,0,500,375,0)
	addEdge(matrix, 250,250,0,0,375,0)
end

matrix1 = {{1,2,3},{4,5,6}}
matrix2 = {{7,8},{9,10},{11,12}}
matrix3 = matrixMult(matrix1, matrix2)

print("matrix1 is:\n")
printMatrix(matrix1, "\n")
print("matrix2 is:\n")
printMatrix(matrix2, "\n")
print("the matrix resulting from matrix1 x matrix2, matrix3, is:\n")
printMatrix(matrix3)
print("the matrix resulting from 2 x matrix3 is:\n")
printMatrix(scalar(2,matrix3))
print("now, to convert matrix3 into the identity matrix:\n")
matrix3 = identify(matrix3)
printMatrix(matrix3)


function main()
	 clear_screen(board)
	 edgeMaker(pMatrix)
	 draw(board, pMatrix)
	 save_ppm(board)
end
main()
print("file is saved as line.ppm\n")