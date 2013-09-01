package
{
	import org.flixel.*;
	
	public class Entity extends FlxSprite
	{
		public var radius:Number = 0;
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
		
		public function collidesWith(Object:FlxObject):void
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
			else if (x + width > FlxG.width) 
			{
				x = FlxG.width - width;
				_wasClamped = true;
			}
			if (y < 0) 
			{
				y = 0;
				_wasClamped = true;
			}
			else if (y + height > FlxG.height) 
			{
				y = FlxG.height - height;
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
	}
}