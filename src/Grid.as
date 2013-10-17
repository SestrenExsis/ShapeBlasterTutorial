package
{
	
	import flash.display.Graphics;
	import flash.display.GraphicsPathCommand;
	import flash.geom.Rectangle;
	
	import org.flixel.*;
	
	public class Grid
	{
		public var springs:Array;
		public var points:Array;
		public var fixedPoints:Array;
		private var numColumns:uint;
		private var numRows:uint;
		private var majorGridSize:int;
		private var _pt:FlxPoint;
		
		private var lineCommands:Vector.<int>;
		private var lineData:Vector.<Number>;
		private var useDrawPath:Boolean = true;
		private var renderGrid:Boolean = true;
		
		public function Grid(GridRectangle:Rectangle, NumColumns:Number, NumRows:Number, MajorGridSize:int = 4)
		{
			_pt = new FlxPoint();
			springs = [];
			numColumns = NumColumns;
			numRows = NumRows;
			majorGridSize = MajorGridSize;
			var _n:uint = (numColumns + 1) * (numRows + 1);
			
			var _index:uint;
			lineCommands = new Vector.<int>(2 * (1 + numColumns) * (1 + numRows), true);
			lineData = new Vector.<Number>(2 * lineCommands.length, true);
			for (var _y:int = 0; _y <= numRows; _y++)
			{
				for (var _x:int = 0; _x <= numColumns; _x++)
				{
					_index = _y * (numColumns + 1) + _x;
					if (_x == 0) lineCommands[_index] = GraphicsPathCommand.MOVE_TO;
					else lineCommands[_index] = GraphicsPathCommand.LINE_TO;
					
					lineData[2 * _index] = _x * (FlxG.width / numColumns);
					lineData[2 * _index + 1] = _y * (FlxG.height / numRows);
				}
			}
			
			for (_x = 0; _x <= numColumns; _x++)
			{
				for (_y = 0; _y <= numRows; _y++)
				{
					_index = _x * (numRows + 1) + _y;
					if (_y == 0) lineCommands[_index + _n] = GraphicsPathCommand.MOVE_TO;
					else lineCommands[_index + _n] = GraphicsPathCommand.LINE_TO;
					
					lineData[2 * _index + 2 * _n] = _x * (FlxG.width / numColumns);
					lineData[2 * _index + 2 * _n + 1] = _y * (FlxG.height / numRows);
				}
			}
			
			points = [];
			// these fixed points will be used to anchor the grid to fixed positions on the screen
			fixedPoints = [];
			
			// create the point masses
			var _cellWidth:Number = GridRectangle.width / numColumns;
			var _cellHeight:Number = GridRectangle.height / numRows;
			for (_y = 0; _y <= numRows; _y++)
			{
				for (_x = 0; _x <= numColumns; _x++)
				{
					var _xx:Number = GridRectangle.left + _x * _cellWidth;
					var _yy:Number = GridRectangle.top + _y * _cellHeight;
					points.push(new PointMass(_xx, _yy, 1));
					fixedPoints.push(new PointMass(_xx, _yy, 1));
				}
			}
			
			// link the point masses with springs
			for (_y = 0; _y <= numRows; _y++)
			{
				for (_x = 0; _x <= numColumns; _x++) 
				{ 
					_index = _y * (numColumns + 1) + _x;
					if (_x == 0 || _y == 0 || _x == numColumns || _y == numRows) // anchor the border of the grid 
						springs.push(new Spring(fixedPoints[_index], points[_index], 0.9, 0.9)); 
					else if (_x % 4 == 0 && _y % 4 == 0) // loosely anchor 1/16th of the point masses 
						springs.push(new Spring(fixedPoints[_index], points[_index], 0.02, 0.2));
					
					var _stiffness:Number = 0.95;//0.28;
					var _damping:Number = 0.12;//0.06;
					if (_x < numColumns)
						springs.push(new Spring(points[_index + 1], points[_index], _stiffness, _damping));
					if (_y < numRows)
						springs.push(new Spring(points[_index + (numColumns + 1)], points[_index], _stiffness, _damping));
				}
			}
			//springs = springList.concat();
		}
		
		public function update():void
		{	
			if (FlxG.keys.justPressed("P")) useDrawPath = !useDrawPath;
			if (FlxG.keys.justPressed("U")) renderGrid = !renderGrid;
			
			for each (var spring:Spring in springs) spring.update();
			for each (var mass:PointMass in points) mass.update();
			
			if (useDrawPath)
			{
				var _n:uint = (numColumns + 1) * (numRows + 1);
				var _index:uint;
				var _indexTranspose:uint;
				for (var _y:int = 0; _y <= numRows; _y++)
				{
					for (var _x:int = 0; _x <= numColumns; _x++)
					{
						_index = _y * (numColumns + 1) + _x;
						_indexTranspose = _x * (numRows + 1) + _y;
						
						_pt = (points[_index] as PointMass).position;
						
						lineData[2 * _index] = _pt.x;
						lineData[2 * _index + 1] = _pt.y;
						
						lineData[2 * _indexTranspose + 2 * _n] = _pt.x;
						lineData[2 * _indexTranspose + 2 * _n + 1] = _pt.y;
					}
				}
			}
		}
		
		public function draw():void
		{
			var gfx:Graphics = FlxG.flashGfx;
			gfx.clear();
			
			//Cache line to bitmap
			var _thickness:uint;
			var _color:uint = 0x01034f;
			var _index:uint;
			var _upperLeftX:Number;
			var _upperLeftY:Number;
			var _upperRightX:Number;
			var _upperRightY:Number;
			var _lowerLeftX:Number;
			var _lowerLeftY:Number;
			var _lowerRightX:Number;
			var _lowerRightY:Number;
			
			gfx.lineStyle(1, _color);
			if (renderGrid) gfx.drawPath(lineCommands, lineData);
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
		
		public function applyImplosiveForce(Position:FlxPoint, Force:Number, Radius:Number):void
		{
			var _distance:Number;
			for each (var _mass:PointMass in points)
			{
				_distance = FlxU.getDistance(Position, _mass.position);
				if (_distance < Radius)
				{
					_mass.applyForce(
						10 * Force * (Position.x - _mass.position.x) / (100 + _distance * _distance), 
						10 * Force * (Position.y - _mass.position.y) / (100 + _distance * _distance));
					_mass.increaseDamping(0.6);
				}
			}
		}
		
		public function applyExplosiveForce(Position:FlxPoint, Force:Number, Radius:Number):void
		{
			var _distance:Number;
			for each (var _mass:PointMass in points)
			{
				_distance = FlxU.getDistance(Position, _mass.position);
				if (_distance < Radius)
				{
					_mass.applyForce(
						100 * Force * (_mass.position.x - Position.x) / (10000 + _distance * _distance),
						100 * Force * (_mass.position.y - Position.y) / (10000 + _distance * _distance));
					_mass.increaseDamping(0.6);
				}
			}
		}
		
		/* 
		* Calculates 2D cubic Catmull-Rom spline.
		* @see http://www.mvps.org/directx/articles/catmull/ 
		*/ 
		public function spline(Pt0:FlxPoint, Pt1:FlxPoint, Pt2:FlxPoint, Pt3:FlxPoint, t:Number):FlxPoint 
		{
			_pt.x = 0.5 * ((2 * Pt1.x) + t * ((-Pt0.x + Pt2.x) +
					t * ((2 * Pt0.x - 5 * Pt1.x + 4 * Pt2.x - Pt3.x) + t * (-Pt0.x + 3 * Pt1.x - 3 * Pt2.x + Pt3.x))));
			_pt.y = 0.5 * ((2 * Pt1.y) + t * (( -Pt0.y + Pt2.y) +
					t * ((2 * Pt0.y - 5 * Pt1.y + 4 * Pt2.y - Pt3.y) + t * (-Pt0.y + 3 * Pt1.y - 3 * Pt2.y + Pt3.y))));
			return _pt;			
		}
	}
}