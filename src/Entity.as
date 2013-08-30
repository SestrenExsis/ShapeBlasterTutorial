package
{
	import org.flixel.*;
	
	public class Entity extends FlxSprite
	{
		public var radius:Number = 0;
		protected var cooldownTimer:FlxTimer;
		protected var _position:FlxPoint;
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
		
		public function get position():FlxPoint
		{
			_position.x = x + radius;
			_position.y = y + radius;
			
			return _position;
		}
	}
}