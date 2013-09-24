package
{
	import org.flixel.*;
	import flash.utils.getTimer;
	
	public class PlayerShip extends Entity
	{
		[Embed(source="../assets/images/Player.png")] protected static var imgPlayer:Class;
		
		private static const MULTIPLIER_EXPIRY_TIME:Number = 0.8; // amount of time it takes, in seconds, for a multiplier to expire.
		private static const MULTIPLIER_MAX:int = 20;
		
		public static var lives:int;
		public static var score:int;
		public static var highScore:int;
		public static var multiplier:int;
		public static var isGameOver:Boolean = false;
		
		private static var multiplierTimeLeft:Number; // time until the current multiplier expires
		private static var scoreForExtraLife:int; // score required to gain an extra life
		
		public var bulletSpeed:Number = 660;
		protected var aim:FlxPoint;
		
		public static var instance:PlayerShip;

		public function PlayerShip()
		{
			super(0.5 * FlxG.width, 0.5 * FlxG.height);
			
			moveSpeed = 480;
			loadRotatedGraphic(imgPlayer, 8, -1, true, true);
			radius = 20;
			hitboxRadius = 18;
			aim = new FlxPoint();
			instance = this;
			UserSettings.load();
		}
		
		override public function draw():void
		{
			super.draw();
		}
		
		override public function update():void
		{
			super.update();
			
			if (multiplier > 1)
			{
				// update the multiplier timer
				if ((multiplierTimeLeft -= FlxG.elapsed) <= 0)
				{
					multiplierTimeLeft = MULTIPLIER_EXPIRY_TIME;
					resetMultiplier();
				}
			}
			
			velocity = GameInput.move;
			velocity.x *= moveSpeed;
			velocity.y *= moveSpeed;
			if (velocity.x != 0 || velocity.y != 0) angle = angleInDegrees(velocity);
			
			aim = GameInput.aim;
			if (cooldownTimer.finished && (aim.x != 0 || aim.y != 0)) shoot(aim);
		}
		
		override public function postUpdate():void
		{
			super.postUpdate();
			
			clampToScreen();
		}
		
		override public function destroy():void
		{
			super.destroy();
		}
		
		override public function kill():void
		{
			super.kill();
			ScreenState.makeExplosion(Particle.NONE, position.x, position.y, 1200, Particle.HIGH_SPEED, 0xffff00, 0xffffff);
			cooldownTimer.stop();
			if (lives-- < 0) 
			{
				isGameOver = true;
				cooldownTimer.start(5, 1, onTimerRestart);
			}
			else cooldownTimer.start(2, 1, onTimerReset);
		}
		
		public function onTimerRestart(Timer:FlxTimer):void
		{
			restart();
			ScreenState.reset();
			isGameOver = false;
		}
		
		public function onTimerReset(Timer:FlxTimer):void
		{
			reset(0.5 * FlxG.width, 0.5 * FlxG.height);
			ScreenState.reset();
		}
		
		override public function reset(X:Number, Y:Number):void
		{
			super.reset(X - 0.5 * width, Y - 0.5 * height);
			
			cooldownTimer.stop();
			cooldownTimer.finished = true;
		}
		
		public function restart():void
		{
			reset(0.5 *FlxG.width, 0.5 *FlxG.height);
			
			if (score > UserSettings.highScore) UserSettings.highScore = score;
			score = 0;
			multiplier = 1;
			lives = 4;
			scoreForExtraLife = 2000;
			multiplierTimeLeft = 0;
		}
		
		override public function collidesWith(Object:Entity, Distance:Number):void
		{
			
		}
		
		public function shoot(Aim:FlxPoint):void
		{
			cooldownTimer.stop();
			cooldownTimer.start(cooldown);
			
			var RandomSpread:Number = 4.58366236 * (FlxG.random() + FlxG.random()) - 4.58366236;
			
			if (GameInput.aimWithMouse)
			{
				Aim.x -= x;
				Aim.y -= y;
				Aim.y *= -1;
			}
			
			FlxU.rotatePoint(Aim.x, Aim.y, 0, 0, RandomSpread, Aim);
			
			var Angle:Number = angleInDegrees(Aim);
			FlxU.rotatePoint(8, 25, 0, 0, Angle + 90, _point);
			var PositionX:Number = _point.x + position.x;
			var PositionY:Number = _point.y + position.y;
			ScreenState.makeBullet(PositionX, PositionY, Angle, bulletSpeed);
			
			FlxU.rotatePoint(-8, 25, 0, 0, Angle + 90, _point);
			PositionX = _point.x + position.x;
			PositionY = _point.y + position.y;
			ScreenState.makeBullet(PositionX, PositionY, Angle, bulletSpeed);
			
			GameSound.randomSound(GameSound.sfxShoot, 0.4);
		}
		
		private function exhaust():void
		{
			if (velocity.x > 0 || velocity.y > 0)
			{
				// set up some variables
				//Orientation = Velocity.ToAngle();
				//Quaternion rot = Quaternion.CreateFromYawPitchRoll(0f, 0f, Orientation);
				
				var t:Number = getTimer();
				// The primary velocity of the particles is 3 pixels/frame in the direction opposite to which the ship is travelling.
				_point = GameInput.normalize(velocity);
				var _velocityX:Number = -3 * _point.x;
				var _velocityY:Number = -3 * _point.y;
				// Calculate the sideways velocity for the two side streams. The direction is perpendicular to the ship's velocity and the
				// magnitude varies sinusoidally.
				var _perpVelocityX:Number = (0.6 * Math.sin(10 * t)) * _velocityY;
				var _perpVelocityY:Number = (0.6 * Math.sin(10 * t)) * -_velocityX;
				var sideColor:uint = 0xc82609; // deep red
				var midColor:uint = 0xffbb1e; // orange-yellow
				var _exhaustX:Number = position.x + (25 / 480) * _velocityX;
				var _exhaustY:Number = position.y + (25 / 480) * _velocityY;
				var _alpha:Number = 0.7;
				
				// middle particle stream
				ScreenState.makeParticle(Particle.ENEMY, _exhaustX, _exhaustY, angle + 180, 3 * moveSpeed);
				//Vector2 velMid = baseVel + rand.NextVector2(0, 1);
				//GameRoot.ParticleManager.CreateParticle(Art.LineParticle, pos, Color.White * alpha, 60f, new Vector2(0.5f, 1),
				//	new ParticleState(velMid, ParticleType.Enemy));
				//GameRoot.ParticleManager.CreateParticle(Art.Glow, pos, midColor * alpha, 60f, new Vector2(0.5f, 1),
				//	new ParticleState(velMid, ParticleType.Enemy));
				
				// side particle streams
				/*Vector2 vel1 = baseVel + _perpVelocity + rand.NextVector2(0, 0.3f);
				Vector2 vel2 = baseVel - _perpVelocity + rand.NextVector2(0, 0.3f);
				GameRoot.ParticleManager.CreateParticle(Art.LineParticle, pos, Color.White * alpha, 60f, new Vector2(0.5f, 1),
					new ParticleState(vel1, ParticleType.Enemy));
				GameRoot.ParticleManager.CreateParticle(Art.LineParticle, pos, Color.White * alpha, 60f, new Vector2(0.5f, 1),
					new ParticleState(vel2, ParticleType.Enemy));
				
				GameRoot.ParticleManager.CreateParticle(Art.Glow, pos, sideColor * alpha, 60f, new Vector2(0.5f, 1),
					new ParticleState(vel1, ParticleType.Enemy));
				GameRoot.ParticleManager.CreateParticle(Art.Glow, pos, sideColor * alpha, 60f, new Vector2(0.5f, 1),
					new ParticleState(vel2, ParticleType.Enemy));*/
			}
		}
		
		public function resetMultiplier():void
		{
			multiplier = 1;
		}
		
		public static function addPoints(BasePoints:int):void
		{
			if (!instance.alive) return;
			
			score += BasePoints * multiplier;
			while (score >= scoreForExtraLife)
			{
				scoreForExtraLife += 2000;
				lives++;
			}
		}
		
		public static function increaseMultiplier():void
		{
			if (!instance.alive) return;
			
			multiplierTimeLeft = MULTIPLIER_EXPIRY_TIME;
			if (multiplier < MULTIPLIER_MAX) multiplier++;
		}
	}
}