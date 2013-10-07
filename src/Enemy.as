package
{
	import flash.display.BitmapData;
	import flash.utils.getTimer;
	
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
		
		public function Enemy(X:Number = 0, Y:Number = 0, Type:uint = 0)
		{
			super(FlxG.width * FlxG.random(), FlxG.height * FlxG.random());
			
			//_type = WANDERER;
			enemyPixels.push(loadRotatedGraphic(imgSeeker, 360, -1, true, true).pixels);
			enemyPixels.push(loadRotatedGraphic(imgWanderer, 360, -1, true, true).pixels);
			enemyPixels.push(loadRotatedGraphic(imgBlackHole, 360, -1, true, true).pixels);
			_pixels = enemyPixels[SEEKER];
			_type = SEEKER;
			
			radius = 20;
			hitboxRadius = 18;
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
			
			if (type == BLACK_HOLE)
			{
				var _angle:Number = (0.720 * getTimer()) % 360;
				ScreenState.grid.applyImplosiveForce(position, 0.5 * Math.sin(Entity.toRadians(_angle)) * 150 + 300, 200);
				if (cooldownTimer.finished)
				{
					cooldownTimer.stop();
					cooldownTimer.start(0.02 + 0.08 * FlxG.random());
					var _color:uint = 0xff00ff;//Entity.HSVtoRGB(5, 0.5, 0.8); // light purple
					var _speed:Number = 360 + FlxG.random() * 90;
					var _offsetX:Number = 16 * Math.sin(Entity.toRadians(_angle));
					var _offsetY:Number = -16 * Math.cos(Entity.toRadians(_angle));
					ScreenState.makeParticle(Particle.ENEMY, position.x + _offsetX, position.y + _offsetY, _angle, _speed, _color);
				}
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
		
		override public function hurt(Damage:Number):void
		{
			super.hurt(Damage);
			
			if (type == BLACK_HOLE)
			{
				var hue:Number = (0.180 * getTimer()) % 360;
				var _color:uint = Entity.HSVtoRGB(hue, 0.25, 1);
				ScreenState.makeExplosion(Particle.IGNORE_GRAVITY, position.x, position.y, 150, Particle.MEDIUM_SPEED, _color);
			}
		}
		
		override public function kill():void
		{
			if (!alive) return;
			PlayerShip.addPoints(pointValue);
			PlayerShip.increaseMultiplier();
			super.kill();
			GameSound.randomSound(GameSound.sfxExplosion, 0.5);
			
			var _color:uint;
			switch (int(6 * FlxG.random()))
			{
				case 0: _color = 0xff3333; break;
				case 1: _color = 0x33ff33; break;
				case 2: _color = 0x3333ff; break;
				case 3: _color = 0xffffaa; break;
				case 4: _color = 0xff33ff; break;
				case 5: _color = 0x00ffff; break;
				default: _color = 0xffffff; break;
			}
			ScreenState.makeExplosion(Particle.ENEMY, position.x, position.y, 120, Particle.MEDIUM_SPEED, _color, FlxG.WHITE);
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
					radius = 20;
					hitboxRadius = 18;
					break;
				case WANDERER:
					alpha = 0;
					health = 1;
					radius = 20;
					hitboxRadius = 18;
					break;
				case BLACK_HOLE:
					alpha = 1;
					health = 10;
					radius = 250;
					hitboxRadius = 18;
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
						var GravityStrength:Number = Entity.interpolate(60, 0, Math.sqrt(DistanceSquared) / radius);
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