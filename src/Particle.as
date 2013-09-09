package
{
	import org.flixel.*;
	
	public class Particle extends Entity
	{
		//[Embed(source="../assets/images/Laser.png")] protected static var imgLaser:Class;
		public static const NONE:uint = 0;
		public static const ENEMY:uint = 1;
		public static const BULLET:uint = 2;
		public static const IGNORE_GRAVITY:uint = 3;
		
		public static const MAX_SPEED:Number = 960;
		
		public static var index:int = 0;
		public static var activeCount:int = 0;
		public static var max:uint = 0;
		private var lifespan:Number = 3.125;

		public var lineScale:Number = 0.025;
		public var lineColor:uint = FlxG.WHITE;
		public var speedDecay:Number = 0.97;

		public function Particle(X:Number = 0, Y:Number = 0)
		{
			super(X, Y);
			max += 1;
			
			angle = 0;
			radius = 11;
			width = height = 1;
			kill();
		}
		
		override public function update():void
		{
			super.update();
			
			velocity.x = speedDecay * velocity.x;
			velocity.y = speedDecay * velocity.y;
			
			if(lifespan <= 0) return;
			lifespan -= FlxG.elapsed;
			if(lifespan <= 0 || (!onScreen() && lifespan < 2)) kill();
		}
		
		override public function draw():void
		{
			//super.draw();
			var _startX:Number = position.x;
			var _startY:Number = position.y;
			var _endX:Number = _startX + lineScale * velocity.x;
			var _endY:Number = _startY + lineScale * velocity.y;
			var _speedRatio:Number = 0.7 + 0.3 * ((velocity.x * velocity.x + velocity.y * velocity.y) / (MAX_SPEED * MAX_SPEED));
			var _r:int = linearInterpolate(0x00, 0xff & (lineColor >> 16), _speedRatio);
			var _g:int = linearInterpolate(0x00, 0xff & (lineColor >> 8), _speedRatio);
			var _b:int = linearInterpolate(0x00, 0xff & lineColor, _speedRatio);
			_r = linearInterpolate(0xff, _r, 0.9);
			_g = linearInterpolate(0xff, _g, 0.9);
			_b = linearInterpolate(0xff, _b, 0.9);
			_speedRatio = (_speedRatio - 0.7) / 0.3;
			if (_speedRatio > 0.5) _speedRatio = 3;
			else if (_speedRatio > 0.25) _speedRatio = 2;
			else _speedRatio = 1;
			
			FlxG.camera.screen.drawLine(_startX, _startY, _endX, _endY, (_r << 16) | (_g << 8) | _b, _speedRatio);
		}
		
		override public function kill():void
		{
			activeCount -= 1;
			super.kill();
		}
		
		override public function destroy():void
		{
			super.destroy();
		}
		
		override public function reset(X:Number, Y:Number):void
		{
			super.reset(X, Y);
			lifespan = 3.125;
			if (!alive) activeCount += 1;
		}
		
		override public function collidesWith(Object:Entity, Distance:Number):void
		{
			
		}
		
		public function setVelocity(Angle:Number, Magnitude:Number):void
		{
			velocity.x = Magnitude * Math.cos(Angle);
			velocity.y = Magnitude * Math.sin(Angle);
			//drag.x = Math.abs(speedDecay * velocity.x);
			//drag.y = Math.abs(speedDecay * velocity.y);
		}
	}
}