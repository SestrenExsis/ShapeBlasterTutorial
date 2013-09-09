package
{
	import flash.display.BitmapData;
	
	import org.flixel.*;

	public class Enemy extends Entity
	{
		public static const SEEKER:uint = 0;
		public static const WANDERER:uint = 1;
		public static const BLACK_HOLE:uint = 2;
		
		[Embed(source="../assets/images/Seeker.png")] protected static var imgSeeker:Class;
		[Embed(source="../assets/images/Wanderer.png")] protected static var imgWanderer:Class;
		[Embed(source="../assets/images/Black Hole.png")] protected static var imgBlackHole:Class;
		
		private var enemyPixels:Array = new Array();
		private var pointValue:int = 10;
		
		public static var blackHoles:int = 0;

		public function Enemy(X:Number = 0, Y:Number = 0, Type:uint = 0)
		{
			super(FlxG.width * FlxG.random(), FlxG.height * FlxG.random());
			
			//_type = WANDERER;
			enemyPixels.push(loadRotatedGraphic(imgSeeker, 360, -1, true, true).pixels);
			enemyPixels.push(loadRotatedGraphic(imgWanderer, 360, -1, true, true).pixels);
			enemyPixels.push(loadRotatedGraphic(imgBlackHole, 360, -1, true, true).pixels);
			_pixels = enemyPixels[SEEKER];
			_type = SEEKER;
			
			radius = 10;
			hitboxRadius = 10;
			maxVelocity.x = maxVelocity.y = 300;//384;
			
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
			
			if (type != BLACK_HOLE) hitEdgeOfScreen = clampToScreen();
		}
		
		override public function destroy():void
		{
			super.destroy();
		}
		
		override public function kill():void
		{
			if (!alive) return;
			if (type == BLACK_HOLE) blackHoles -= 1;
			PlayerShip.addPoints(pointValue);
			PlayerShip.increaseMultiplier();
			super.kill();
			GameSound.randomSound(GameSound.sfxExplosion, 0.5);
			ScreenState.makeExplosion(position.x, position.y);
		}
		
		override public function set type(Value:uint):void
		{
			var _previousType:uint = _type;
			_type = Value;
			if (_previousType != _type)
			{
				_pixels = enemyPixels[_type];
				dirty = true;
			}
			switch (_type)
			{
				case SEEKER:
					alpha = 0;
					health = 1;
					radius = 10;
					hitboxRadius = 10;
					break;
				case WANDERER:
					alpha = 0;
					health = 1;
					radius = 10;
					hitboxRadius = 10;
					break;
				case BLACK_HOLE:
					alpha = 1;
					health = 10;
					radius = 250;
					hitboxRadius = 10;
					break;
			}
			width = height = 2 * Math.max(radius, hitboxRadius);
			centerOffsets();
		}
		
		override public function collidesWith(Object:Entity, DistanceSquared:Number):void
		{
			var CombinedHitBoxRadius:Number = hitboxRadius + Object.hitboxRadius;
			var IsHitBoxCollision:Boolean = (CombinedHitBoxRadius * CombinedHitBoxRadius) >= DistanceSquared;
			var AngleFromCenters:Number = Entity.toRadians(FlxU.getAngle(position, Object.position));
			if (Object is Bullet) 
			{
				if (IsHitBoxCollision) 
				{
					Object.kill();
					hurt(1);
				}
				else
				{
					if (type == BLACK_HOLE)
					{
						
						Object.velocity.x -= 18 * Math.cos(AngleFromCenters);
						Object.velocity.y -= 18 * Math.sin(AngleFromCenters);
					}
				}
			}
			else if (Object is Enemy)
			{
				var IsBlackHole:Boolean = (type == BLACK_HOLE);
				if (IsBlackHole && (Object as Enemy).type == BLACK_HOLE) return;
				
				if (IsHitBoxCollision) 
				{
					if (IsBlackHole) Object.kill();
				}
				else
				{
					if (IsBlackHole)
					{
						var GravityStrength:Number = Entity.linearInterpolate(60, 0, Math.sqrt(DistanceSquared) / radius);
						Object.velocity.x += GravityStrength * Math.cos(AngleFromCenters);
						Object.velocity.y += GravityStrength * Math.sin(AngleFromCenters);
					}
					else
					{
						var XDistance:Number = position.x - Object.position.x;
						var YDistance:Number = position.y - Object.position.y;
						velocity.x += 600 * XDistance / (DistanceSquared + 1);
						velocity.y += 600 * YDistance / (DistanceSquared + 1);
					}
				}
			}
			else if (Object is PlayerShip)
			{
				if (IsHitBoxCollision) Object.kill();
			}
		}
		
		override public function reset(X:Number, Y:Number):void
		{
			cooldownTimer.stop();
			alpha = 0;
			acceleration.x = acceleration.y = 0;
			angularVelocity = 0;
			super.reset(X - 0.5 * width, Y - 0.5 * height);
			if (type == BLACK_HOLE) blackHoles += 1;
		}
		
		private function applyBehaviors():void
		{
			//behavior logic goes here
			if (type == SEEKER) followPlayer();
			else if (type == WANDERER) moveRandomly();
			else if (type == BLACK_HOLE) applyGravity();
		}
		
		private function followPlayer(Acceleration:Number = 5):void
		{
			if (PlayerShip.instance.alive) 
			{
				acceleration.x = Acceleration * (PlayerShip.instance.position.x - position.x);
				acceleration.y = Acceleration * (PlayerShip.instance.position.y - position.y);
				angle = Entity.angleInDegrees(acceleration);
			}
			else moveRandomly();
		}
		
		private function moveRandomly(Acceleration:Number = 320):void
		{
			var Angle:Number;
			if (hitEdgeOfScreen) 
			{
				cooldownTimer.stop();
				cooldownTimer.start(1);
				Angle = 2 * Math.PI * FlxG.random();
				velocity.x = 0;
				velocity.y = 0;
				acceleration.x = Acceleration * Math.cos(Angle);
				acceleration.y = Acceleration * Math.sin(Angle);
				angularVelocity = 200;
			}
			
			if (!cooldownTimer.finished || hitEdgeOfScreen) return;
			cooldownTimer.stop();
			cooldownTimer.start(1);
			Angle = 2 * Math.PI * FlxG.random();
			acceleration.x = Acceleration * Math.cos(Angle);
			acceleration.y = Acceleration * Math.sin(Angle);
			angularVelocity = 200;
		}
		
		private function applyGravity(Acceleration:Number = 320):void
		{
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