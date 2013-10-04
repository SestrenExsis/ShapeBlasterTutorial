package
{
	
	import flash.geom.Rectangle;
	import flash.display.Graphics;
	import org.flixel.*;
	
	public class Grid
	{
		public var springs:Array;
		public var points:Array;
		public var fixedPoints:Array;
		private var numColumns:uint;
		private var numRows:uint;
		
		public function Grid(GridRectangle:Rectangle, NumColumns:Number, NumRows:Number)
		{
			var springList:Array = new Array();
			numColumns = NumColumns;
			numRows = NumRows;
			
			points = [];
			// these fixed points will be used to anchor the grid to fixed positions on the screen
			fixedPoints = [];
			
			// create the point masses
			var _cellWidth:Number = GridRectangle.width / numColumns;
			var _cellHeight:Number = GridRectangle.height / numRows;
			for (var _y:int = 0; _y <= numRows; _y++)
			{
				for (var _x:int = 0; _x <= numColumns; _x++)
				{
					var _xx:Number = GridRectangle.left + _x * _cellWidth;
					var _yy:Number = GridRectangle.top + _y * _cellHeight;
					points.push(new PointMass(_xx, _yy, 1));
					fixedPoints.push(new PointMass(_xx, _yy, 1));
				}
			}
			
			var _index:uint;
			// link the point masses with springs
			for (_y = 0; _y < numRows; _y++)
			{
				for (_x = 0; _x < numColumns; _x++) 
				{ 
					_index = _y * (numColumns + 1) + _x;
					if (_x == 0 || _y == 0 || _x == numColumns - 1 || _y == numRows - 1) // anchor the border of the grid 
						springList.push(new Spring(fixedPoints[_index], points[_index], 0.1, 0.1)); 
					else if (_x % 3 == 0 && _y % 3 == 0)                                  // loosely anchor 1/9th of the point masses 
						springList.push(new Spring(fixedPoints[_index], points[_index], 0.002, 0.02));
					
					var _stiffness:Number = 0.28; 
					var _damping:Number = 0.06; 
					if (_x > 0)
						springList.push(new Spring(points[_y * (numColumns + 1) + _x - 1], points[_index], _stiffness, _damping));
					if (_y > 0)
						springList.push(new Spring(points[(_y - 1) * (numColumns + 1) + _x], points[_index], _stiffness, _damping));
				}
			}
			springs = springList.concat();
		}
		
		public function update():void
		{
			//for each (var spring:Spring in springs)
			//spring.update();
			
			//for each (var mass:PointMass in points)
			//mass.update();
		}
		
		public function draw():void
		{
			var gfx:Graphics = FlxG.flashGfx;
			
			//Cache line to bitmap
			var _color:uint = 0x01034f; //new Color(30, 30, 139, 85);   // dark blue
			for (var _y:int = 0; _y <= numRows; _y++)
			{
				for (var _x:int = 0; _x <= numColumns; _x++)      
				{
					var _thickness:uint;
					var _startX:Number;
					var _startY:Number;
					var _endX:Number = (points[_y * (numColumns + 1) + _x] as PointMass).position.x;
					var _endY:Number = (points[_y * (numColumns + 1) + _x] as PointMass).position.y;      
					if (_x > 0)
					{
						if (_y % 4 == 0) gfx.lineStyle(3, _color);
						else gfx.lineStyle(1, _color);
						_startX = (points[_y * (numColumns + 1) + _x - 1] as PointMass).position.x;
						_startY = (points[_y * (numColumns + 1) + _x - 1] as PointMass).position.y;
						gfx.moveTo(_startX,_startY);
						gfx.lineTo(_endX,_endY);
						//FlxG.camera.screen.drawLine(_startX, _startY, _endX, _endY, _color, _thickness);
					}
					if (_y > 0)
					{
						if (_x % 4 == 0) gfx.lineStyle(3, _color);
						else gfx.lineStyle(1, _color);
						_startX = (points[(_y - 1) * (numColumns + 1) + _x] as PointMass).position.x;
						_startY = (points[(_y - 1) * (numColumns + 1) + _x] as PointMass).position.y;
						gfx.moveTo(_startX,_startY);
						gfx.lineTo(_endX,_endY);
						//FlxG.camera.screen.drawLine(_startX, _startY, _endX, _endY, _color, _thickness);
					}
				}
			}
			//FlxG.camera.screen.pixels.draw(FlxG.flashGfxSprite);
			//FlxG.camera.screen.dirty = true;
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