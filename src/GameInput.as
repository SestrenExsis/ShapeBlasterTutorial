package
{
	import org.flixel.*;
	
	public class GameInput
	{
		protected static var _move:FlxPoint;
		protected static var _aim:FlxPoint;
		protected static var _wasBombButtonPressed:Boolean = false;
		protected static var _mouseLast:FlxPoint;
		protected static var _aimWithMouse:Boolean = false;
		
		public static var lengthBeforeNormalize:Number;
		
		public static function create():void
		{
			_move = new FlxPoint();
			_aim = new FlxPoint();
			_mouseLast = new FlxPoint();
		}
		
		public static function update():void
		{
			//Don't enable aiming with the mouse unless the aiming keys aren't in use and the mouse has moved position
			if (FlxG.mouse.pressed()) _aimWithMouse = true;
			else if (FlxG.keys["LEFT" || "RIGHT" || "UP" || "DOWN"]) _aimWithMouse = false;
			else if ((FlxG.mouse.x == _mouseLast.x) && (FlxG.mouse.y == _mouseLast.y)) _aimWithMouse = false;
			else _aimWithMouse = true;
			
			//store the mouse's position to test for mouse movement next frame
			_mouseLast.x = FlxG.mouse.x;
			_mouseLast.y = FlxG.mouse.y;
		}
		
		public static function normalize(Point:FlxPoint):FlxPoint
		{
			//Normalize the length if the player is aiming diagonally
			lengthBeforeNormalize = Math.sqrt(Point.x * Point.x + Point.y * Point.y);
			if (lengthBeforeNormalize != 0) 
			{
				Point.x /= lengthBeforeNormalize;
				Point.y /= lengthBeforeNormalize;
			}
			
			return Point;
		}
		
		public static function get move():FlxPoint
		{
			_move.x = _move.y = 0;
			
			if (FlxG.keys["A"]) _move.x -= 1;
			if (FlxG.keys["D"]) _move.x += 1;
			if (FlxG.keys["W"]) _move.y -= 1;
			if (FlxG.keys["S"]) _move.y += 1;
			
			return normalize(_move);
		}
		
		public static function get aim():FlxPoint
		{
			_aim.x = _aim.y = 0;
			
			if (_aimWithMouse)
			{
				_aim.x = FlxG.mouse.x;
				_aim.y = FlxG.mouse.y;
				
				return _aim;
			}
			else
			{
				if (FlxG.keys["LEFT"]) _aim.x -= 1;
				if (FlxG.keys["RIGHT"]) _aim.x += 1;
				if (FlxG.keys["UP"]) _aim.y += 1;
				if (FlxG.keys["DOWN"]) _aim.y -= 1;
				
				return normalize(_aim);
			}
			
		}
		
		public static function get wasBombButtonPressed():Boolean
		{
			return FlxG.keys.justPressed("SPACE");
		}
		
		public static function get aimWithMouse():Boolean
		{
			return _aimWithMouse;
		}
	}
}