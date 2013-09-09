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
		
		public static const MAX_SPEED:Number = 480;
		
		public static var index:int = 0;
		public static var activeCount:int = 0;
		public static var max:uint = 2000;
		private var lifespan:Number = 3.125;

		public var lineScale:Number = 0.025;
		public var lineColor:uint = FlxG.WHITE;
		public var speedDecay:Number = 1;

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
			
			//drag.x = speedDecay * velocity.x;
			//drag.y = speedDecay * velocity.y;
			
			if(lifespan <= 0) return;
			lifespan -= FlxG.elapsed;
			if(lifespan <= 0) kill();
		}
		
		override public function draw():void
		{
			//super.draw();
			var _startX:Number = position.x;
			var _startY:Number = position.y;
			var _endX:Number = _startX + lineScale * velocity.x;
			var _endY:Number = _startY + lineScale * velocity.y;
			var _speedRatio:Number = (velocity.x * velocity.x + velocity.y * velocity.y) / (MAX_SPEED * MAX_SPEED);
			var _r:int = linearInterpolate(0x000000, lineColor >> 16, _speedRatio);
			var _g:int = linearInterpolate(0x000000, 0xff & (lineColor >> 8), _speedRatio);
			var _b:int = linearInterpolate(0x000000, 0xff & lineColor, _speedRatio);
			
			FlxG.camera.screen.drawLine(_startX, _startY, _endX, _endY, (_r << 16) | (_g << 8) | _b, 2);
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
			drag.x = Math.abs(speedDecay * velocity.x);
			drag.y = Math.abs(speedDecay * velocity.y);
		}
	}
}