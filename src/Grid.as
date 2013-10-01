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
			
			points = [];
			// these fixed points will be used to anchor the grid to fixed positions on the screen
			fixedPoints = [];
			
			// create the point masses
			//var _col:int = 0;
			//var _row:int = 0;
			for (var _y:int = GridRectangle.top; _y <= GridRectangle.bottom; _y += SpacingY)
			{
				//points[_col] = [];
				//fixedPoints[_col] = [];
				for (var _x:int = GridRectangle.left; _x <= GridRectangle.right; _x += SpacingX)
				{
					points.push(new PointMass(_x, _y, 1));
					fixedPoints.push(new PointMass(_x, _y, 1));
					//_col++;
				}
				//_row++;
				//_col = 0;
			}
			
			var _index:uint;
			// link the point masses with springs
			for (_y = 0; _y < numRows; _y++)
			{
				for (_x = 0; _x < numColumns; _x++) 
				{ 
					_index = _y * numColumns + _x;
					if (_x == 0 || _y == 0 || _x == numColumns - 1 || _y == numRows - 1) // anchor the border of the grid 
						springList.push(new Spring(fixedPoints[_index], points[_index], 0.1, 0.1)); 
					else if (_x % 3 == 0 && _y % 3 == 0)                                  // loosely anchor 1/9th of the point masses 
						springList.push(new Spring(fixedPoints[_index], points[_index], 0.002, 0.02));
					
					var _stiffness:Number = 0.28; 
					var _damping:Number = 0.06; 
					if (_x > 0)
						springList.push(new Spring(points[_y * numColumns + _x - 1], points[_index], _stiffness, _damping));
					if (_y > 0)
						springList.push(new Spring(points[(_y - 1) * numColumns + _x], points[_index], _stiffness, _damping));
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
		
		public function draw():void
		{
			
		}
		
		public function applyDirectedForce(Position:FlxPoint, Force:FlxPoint, Radius:Number):void
		{
			var _distance:Number;
			for each (var _mass:PointMass in points)
			{
				_distance = FlxU.getDistance(Position, _mass.position);
				if (_distance < Radius) _mass.applyForce(10 * Force.x / (10 + _distance), 10 * Force.y / (10 + _distance));
			}
		}
		
		public function applyImplosiveForce(Position:FlxPoint, Force:FlxPoint, Radius:Number):void
		{
			var _distance:Number;
			for each (var _mass:PointMass in points)
			{
				_distance = FlxU.getDistance(Position, _mass.position);
				if (_distance < Radius)
				{
					_mass.applyForce(
						10 * Force.x * (Position.x - _mass.position.x) / (100 + _distance * _distance), 
						10 * Force.y * (Position.y - _mass.position.y) / (100 + _distance * _distance));
					_mass.increaseDamping(0.6);
				}
			}
		}
		
		public function applyExplosiveForce(Position:FlxPoint, Force:FlxPoint, Radius:Number):void
		{
			var _distance:Number;
			for each (var _mass:PointMass in points)
			{
				_distance = FlxU.getDistance(Position, _mass.position);
				if (_distance < Radius)
				{
					_mass.applyForce(
						100 * Force.x * (_mass.position.x - Position.x) / (10000 + _distance * _distance),
						100 * Force.y * (_mass.position.y - Position.y) / (10000 + _distance * _distance));
					_mass.increaseDamping(0.6);
				}
			}
		}
	}
}