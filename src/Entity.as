package
{
	import org.flixel.*;
	
	public class Entity extends FlxSprite
	{
		public var radius:Number = 0;
		public var hitboxRadius:Number = 0;
		protected var cooldownTimer:FlxTimer;
		protected var _position:FlxPoint;
		protected var hitEdgeOfScreen:Boolean = false;
		public var cooldown:Number = 0.075;
		
		public function Entity(X:Number = 0, Y:Number = 0)
		{
			super(X, Y);
			_position = new FlxPoint();
			
			blend = "screen";
			cooldownTimer = new FlxTimer();
			cooldownTimer.finished = true;
		}
		
		override public function draw():void
		{
			super.draw();
		}
		
		override public function update():void
		{
			super.update();
		}
		
		override public function destroy():void
		{
			super.destroy();
		}
		
		public function collidesWith(Object:Entity, Distance:Number):void
		{
			
		}
		
		public function clampToScreen():Boolean
		{
			var _wasClamped:Boolean = false;
			//clamp the position to be within the bounds of the screen
			if (x < 0) 
			{
				x = 0;
				_wasClamped = true;
			}
			else if (x + 2 * hitboxRadius > FlxG.width) 
			{
				x = FlxG.width - 2 * hitboxRadius;
				_wasClamped = true;
			}
			if (y < 0) 
			{
				y = 0;
				_wasClamped = true;
			}
			else if (y + 2 * hitboxRadius > FlxG.height) 
			{
				y = FlxG.height - 2 * hitboxRadius;
				_wasClamped = true;
			}
			return _wasClamped;
		}
		
		public function get position():FlxPoint
		{
			_position.x = x + radius;
			_position.y = y + radius;
			
			return _position;
		}
		
		public function set position(Value:FlxPoint):void
		{
			x = Value.x - radius;
			y = Value.y - radius;
			
			_position.x = Value.x;
			_position.y = Value.y;
		}
		
		public static function toRadians(AngleInDegrees:Number):Number
		{
			return (AngleInDegrees * Math.PI) / 180;
		}
		
		public static function toDegrees(AngleInRadians:Number):Number
		{
			return (AngleInRadians * 180) / Math.PI;
		}
		
		public static function angleInDegrees(Vector:FlxPoint):Number
		{
			var _angleInRadians:Number = Math.atan2(Vector.y, Vector.x);
			return (_angleInRadians / Math.PI) * 180;
		}
		
		public static function angleInRadians(Vector:FlxPoint):Number
		{
			return Math.atan2(Vector.y, Vector.x);
		}
		
		public static function linearInterpolate(Value1:Number, Value2:Number, WeightOfValue2:Number):Number
		{
			return Value1 + (Value2 - Value1) * WeightOfValue2;
		}
	}
}