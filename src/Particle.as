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
		public static var maxLifespan:Number = 3.25;
		
		public var lifespan:Number;
		public var lineScale:Number = 0.025;
		public var lineColor:uint = FlxG.WHITE;
		public var speedDecay:Number = 0.94;

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
			
			lifespan -= FlxG.elapsed;
			if(lifespan <= 0) kill();
			if(lifespan <= 0) return;
			
			velocity.x = speedDecay * velocity.x;
			velocity.y = speedDecay * velocity.y;
			
			if (type != IGNORE_GRAVITY)
			{
				for (var i:uint = 0; i < ScreenState.blackholes.length; i++) //each (var blackhole:Enemy in ScreenState.blackholes)
				{
					var blackhole:Enemy = ScreenState.blackholes.members[i];
					if (blackhole.alive)
					{
						_point.x = blackhole.position.x - position.x;
						_point.y = blackhole.position.y - position.y;
						
						var _distance:Number = Math.sqrt(_point.x * _point.x + _point.y * _point.y);
						if (_distance < 300)
						{
							_point = GameInput.normalize(_point);
							velocity.x += 10 * _point.x;//10000 * _point.x / (_distance * _distance + 10000);
							velocity.y += 10 * _point.y;//10000 * _point.y / (_distance * _distance + 10000);
							
							// add tangential acceleration for nearby particles
							if (_distance < 400)
							{
								velocity.x += 8 * _point.y;// / _distance;//45 * _point.y / (_distance + 100);
								velocity.y -= 8 * _point.x;// / _distance;//-45 * _point.x / (_distance + 100);
							}
						}
					}
				}
			}
			
			// collide with the edges of the screen
			if (position.x < 0) velocity.x = Math.abs(velocity.x); 
			else if (position.x > FlxG.width) velocity.x = -Math.abs(velocity.x);
			
			if (position.y < 0) velocity.y = Math.abs(velocity.y); 
			else if (position.y > FlxG.height) velocity.y = -Math.abs(velocity.y);
		}
		
		override public function draw():void
		{
			var _minSpeedRatio:Number = 0.8;
			//super.draw();
			var _startX:Number = position.x;
			var _startY:Number = position.y;
			var _endX:Number = _startX + lineScale * velocity.x;
			var _endY:Number = _startY + lineScale * velocity.y;
			var _speedRatio:Number = _minSpeedRatio + (1 - _minSpeedRatio) * ((velocity.x * velocity.x + velocity.y * velocity.y) / (MAX_SPEED * MAX_SPEED));
			var _lifespanRatio:Number = lifespan / maxLifespan;
			var _r:int = interpolate(0x00, 0xff & (lineColor >> 16), _lifespanRatio);
			var _g:int = interpolate(0x00, 0xff & (lineColor >> 8), _lifespanRatio);
			var _b:int = interpolate(0x00, 0xff & lineColor, _lifespanRatio);
			_r = interpolate(0xff, _r, 0.9);
			_g = interpolate(0xff, _g, 0.9);
			_b = interpolate(0xff, _b, 0.9);
			_speedRatio = (_speedRatio - _minSpeedRatio) / (1 - _minSpeedRatio);
			//if (_speedRatio > 0.5) _speedRatio = 3;
			//else if (_speedRatio > 0.25) _speedRatio = 2;
			//else _speedRatio = 1;
			
			FlxG.camera.screen.drawLine(_startX, _startY, _endX, _endY, (_r << 16) | (_g << 8) | _b, 2);
		}
		
		override public function kill():void
		{
			if (alive) activeCount -= 1;
			super.kill();
			visible = false;
		}
		
		override public function destroy():void
		{
			super.destroy();
		}
		
		override public function reset(X:Number, Y:Number):void
		{
			super.reset(X, Y);
			lifespan = maxLifespan;
			if (!alive) activeCount += 1;
			visible = true;
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