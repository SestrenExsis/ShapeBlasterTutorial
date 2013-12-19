package
{
	import flash.display.Graphics;
	
	import org.flixel.*;
	
	public class Particle extends Entity
	{
		[Embed(source="../assets/images/Glow.png")] protected static var imgGlow:Class;
		
		public static const NONE:uint = 0;
		public static const ENEMY:uint = 1;
		public static const BULLET:uint = 2;
		public static const IGNORE_GRAVITY:uint = 3;
		
		public static const LOW_SPEED:Number = 720;
		public static const MEDIUM_SPEED:Number = 960;
		public static const HIGH_SPEED:Number = 2160;
		
		public static var index:int = 0;
		public static var activeCount:int = 0;
		public static var max:uint = 0;
		public static var maxLifespan:Number = 3.25;
				
		public var lifespan:Number;
		public var lineScale:Number = 0.06;
		public var lineColor:uint = FlxG.WHITE;
		public var speedDecay:Number = 0.93;
		public var initialSpeed:Number;
		public var maxSpeed:Number;
		public var isGlowing:Boolean = false;

		public function Particle(X:Number = 0, Y:Number = 0)
		{
			super(X, Y);
			max += 1;
			
			angle = 0;
			radius = 0;			
			kill();
			loadGraphic(imgGlow);
			width = height = 20;
			offset.x = offset.y = 10;
			alpha = 1;
		}
		
		override public function update():void
		{			
			super.update();
			if (isGlowing)
			{
				var _lifetime:Number = maxLifespan - lifespan;
				if (_lifetime > 1.25) alpha = 0;
				else alpha = 0.2 * ((1.25 - _lifetime) / 1.25);
			}
			lifespan -= FlxG.elapsed;
			if(lifespan <= 0 || (velocity.x * velocity.x + velocity.y * velocity.y) < 1) kill();
			if(!alive) return;
			
			velocity.x = speedDecay * velocity.x;
			velocity.y = speedDecay * velocity.y;
			
			if (type != IGNORE_GRAVITY)
			{
				for (var i:uint = 0; i < ScreenState.blackholes.length; i++)
				{
					var blackhole:Enemy = ScreenState.blackholes.members[i];
					if (blackhole.alive)
					{
						_point.x = blackhole.position.x - position.x;
						_point.y = blackhole.position.y - position.y;
						
						_point = GameInput.normalize(_point);
						var _distance:Number = GameInput.lengthBeforeNormalize;
						velocity.x += FlxG.elapsed * 600 * (10000 / (_distance * _distance + 10000)) * _point.x;
						velocity.y += FlxG.elapsed * 600 * (10000 / (_distance * _distance + 10000)) * _point.y;
						
						// add tangential acceleration for nearby particles
						if (_distance < 400)
						{
							velocity.x += FlxG.elapsed * 3000 * (100 / (_distance * _distance + 100)) * _point.y;
							velocity.y -= FlxG.elapsed * 3000 * (100 / (_distance * _distance + 100)) * _point.x;
						}
					}
				}
			}
			
			// If colliding with the edges of the screen, bounce off in the other direction
			if (position.x < 0) velocity.x = Math.abs(velocity.x); 
			else if (position.x > FlxG.width) velocity.x = -Math.abs(velocity.x);
			if (position.y < 0) velocity.y = Math.abs(velocity.y); 
			else if (position.y > FlxG.height) velocity.y = -Math.abs(velocity.y);
		}
		
		override public function draw():void
		{
			if (isGlowing) super.draw(); //used for the PlayerShip's exhaust stream
			var gfx:Graphics = FlxG.flashGfx;
			var _startX:Number = position.x - 0.5 * lineScale * velocity.x;
			var _startY:Number = position.y - 0.5 * lineScale * velocity.y;
			var _endX:Number = position.x + 0.5 * lineScale * velocity.x;
			var _endY:Number = position.y + 0.5 * lineScale * velocity.y;
			
			// As a particle's lifespan increases and/or as it slows down, it slowly fades to black
			var _lifespanRatio:Number = (lifespan * lifespan) / Math.pow(maxLifespan, 1.25);
			var _speedRatio:Number = (velocity.x * velocity.x + velocity.y * velocity.y) / Math.pow(initialSpeed, 1.25);
			if (_speedRatio > _lifespanRatio) _speedRatio = _lifespanRatio;
			if (_speedRatio > 1) _speedRatio = 1;
			var _color:uint = Entity.interpolateRGB(0x000000, lineColor, _speedRatio);
			
			gfx.lineStyle(3, _color);
			gfx.moveTo(_startX,_startY);
			gfx.lineTo(_endX,_endY);
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
			isGlowing = false;
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
			initialSpeed = Magnitude;
		}
	}
}