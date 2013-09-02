package
{
	import flash.display.BitmapData;
	
	import org.flixel.*;

	public class Enemy extends Entity
	{
		public static const SEEKER:uint = 0;
		public static const WANDERER:uint = 1;
		
		[Embed(source="../assets/images/Seeker.png")] protected static var imgSeeker:Class;
		[Embed(source="../assets/images/Wanderer.png")] protected static var imgWanderer:Class;
		
		private var enemyPixels:Array = new Array();
		private var pointValue:int = 10;
		protected var _type:uint;

		public function Enemy(X:Number = 0, Y:Number = 0, Type:uint = 0)
		{
			super(FlxG.width * FlxG.random(), FlxG.height * FlxG.random());
			
			_type = WANDERER;
			enemyPixels.push(loadRotatedGraphic(imgSeeker, 360, -1, true, true).pixels);
			enemyPixels.push(loadRotatedGraphic(imgWanderer, 360, -1, true, true).pixels);
			
			radius = 10;
			maxVelocity.x = maxVelocity.y = 600;//384;
			
			alive = false;
			exists = false;
			//have a separate playerCollision radius, a bulletCollision radius, and an enemyCollision radius
		}
		
		override public function draw():void
		{
			super.draw();
		}
		
		override public function update():void
		{
			super.update();
			
			if (!alive) return;
			
			if (alpha >= 1)
			{
				applyBehaviors();
			}
			else
			{
				alpha += FlxG.elapsed;
			}

			//gradually build up speed
			//velocity.x *= 0.8;
			//velocity.y *= 0.8;
		}
		
		override public function postUpdate():void
		{
			super.postUpdate();
			
			hitEdgeOfScreen = clampToScreen();
		}
		
		override public function destroy():void
		{
			super.destroy();
		}
		
		override public function kill():void
		{
			PlayerShip.addPoints(pointValue);
			PlayerShip.increaseMultiplier();
			super.kill();
			GameSound.randomSound(GameSound.sfxExplosion, 0.5);
		}
		
		public function get type():uint
		{
			return _type;
		}
		
		public function set type(Value:uint):void
		{
			var _previousType:uint = _type;
			_type = Value;
			if (_previousType != _type)
			{
				if (_type == SEEKER) _pixels = enemyPixels[SEEKER];
				else if (_type == WANDERER) _pixels = enemyPixels[WANDERER];
				dirty = true;
			}
		}
		
		override public function collidesWith(Object:FlxObject):void
		{
			if (Object is Bullet) kill();
			else if (Object is Enemy)
			{
				var VelocityX:Number = position.x - (Object as Entity).position.x;
				var VelocityY:Number = position.y - (Object as Entity).position.y;
				var DistanceSquared:Number = VelocityX * VelocityX + VelocityY * VelocityY;
				velocity.x += 600 * VelocityX / (DistanceSquared + 1);
				velocity.y += 600 * VelocityY / (DistanceSquared + 1);
			}
		}
		
		override public function reset(X:Number, Y:Number):void
		{
			cooldownTimer.stop();
			alpha = 0;
			acceleration.x = acceleration.y = 0;
			angularVelocity = 0;
			super.reset(X - 0.5 * width, Y - 0.5 * height);
		}
		
		private function applyBehaviors():void
		{
			//behavior logic goes here
			if (type == SEEKER) followPlayer();
			else if (type == WANDERER) moveRandomly();
		}
		
		private function followPlayer(Acceleration:Number = 10):void
		{
			if (PlayerShip.instance.alive) 
			{
				acceleration.x = Acceleration * (PlayerShip.instance.position.x - position.x);
				acceleration.y = Acceleration * (PlayerShip.instance.position.y - position.y);
				angle = PlayerShip.angleInDegrees(acceleration);
			}
		}
		
		private function moveRandomly(Acceleration:Number = 320):void
		{
			var _angle:Number;
			if (hitEdgeOfScreen) 
			{
				cooldownTimer.stop();
				cooldownTimer.start(1);
				_angle = 2 * Math.PI * FlxG.random();
				velocity.x = 0;
				velocity.y = 0;
				acceleration.x = Acceleration * Math.cos(_angle);
				acceleration.y = Acceleration * Math.sin(_angle);
				angularVelocity = 200;
			}
			
			if (!cooldownTimer.finished || hitEdgeOfScreen) return;
			cooldownTimer.stop();
			cooldownTimer.start(1);
			_angle = 2 * Math.PI * FlxG.random();
			acceleration.x = Acceleration * Math.cos(_angle);
			acceleration.y = Acceleration * Math.sin(_angle);
			angularVelocity = 200;
		}
		
		private function moveInASquare():void
		{
			/*const int framesPerSide = 30;
			while (true)
			{
				// move right for 30 frames
				for (int i = 0; i < framesPerSide; i++)
				{
					Velocity = Vector2.UnitX;
					yield return 0;
				}
		
				// move down
				for (int i = 0; i < framesPerSide; i++)
				{
					Velocity = Vector2.UnitY;
					yield return 0;
				}
		
				// move left
				for (int i = 0; i < framesPerSide; i++)
				{
					Velocity = -Vector2.UnitX;
					yield return 0;
				}
		
				// move up
				for (int i = 0; i < framesPerSide; i++)
				{
					Velocity = -Vector2.UnitY;
					yield return 0;
				}
			}*/
		}
	}
}