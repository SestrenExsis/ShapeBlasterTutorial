package
{
	
	import flash.geom.Rectangle;
	
	import org.flixel.*;
	//import PointMass;
	
	public class Grid
	{
		public var springs:Array;
		public var points:Array;
		public var fixedPoints:Array;
		
		public function Grid(GridRectangle:Rectangle, SpacingX:Number, SpacingY:Number)
		{
			var springList:Array = new Array();
			var numColumns:int = int(GridRectangle.width / SpacingX) + 1;
			var numRows:int = int(GridRectangle.height / SpacingY) + 1;
			
			points = new Array(numColumns, numRows);
			// these fixed points will be used to anchor the grid to fixed positions on the screen
			fixedPoints = new Array(numColumns, numRows);
			
			// create the point masses
			var _col:int = 0;
			var _row:int = 0;
			for (var _y:int = GridRectangle.top; _y <= GridRectangle.bottom; _y += SpacingY)
			{
				for (var _x:int = GridRectangle.left; _x <= GridRectangle.right; _x += SpacingX)
				{
					points[_col][_row] = new PointMass(_x, _y, 1);
					fixedPoints[_col][_row] = new PointMass(_x, _y, 1);
					_col++;
				}
				_row++;
				_col = 0;
			}
			
			// link the point masses with springs
			for (_y = 0; _y < numRows; _y++)
			{
				for (_x = 0; _x < numColumns; _x++) 
				{ 
					if (_x == 0 || _y == 0 || _x == numColumns - 1 || _y == numRows - 1) // anchor the border of the grid 
						springList.push(new Spring(fixedPoints[_x][_y], points[_x][_y], 0.1, 0.1)); 
					else if (_x % 3 == 0 && _y % 3 == 0)                                  // loosely anchor 1/9th of the point masses 
						springList.push(new Spring(fixedPoints[_x][_y], points[_x][_y], 0.002, 0.02));
					
					var _stiffness:Number = 0.28; 
					var _damping:Number = 0.06; 
					if (_x > 0)
						springList.Add(new Spring(points[_x - 1][_y], points[_x][_y], _stiffness, _damping));
					if (_y > 0)
						springList.Add(new Spring(points[_x][_y - 1], points[_x][_y], _stiffness, _damping));
				}
			}
			springs = springList.concat();
		}
		
		public function update():void
		{
			for each (var spring:Spring in springs)
			spring.update();
			
			for each (var mass:PointMass in points)
			mass.update();
		}
	}
}