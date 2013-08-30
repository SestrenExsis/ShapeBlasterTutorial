package
{
	import org.flixel.*;

	public class Enemy extends Entity
	{
		[Embed(source="../assets/images/Seeker.png")] protected static var imgEnemy:Class;

		public function Enemy(X:Number = 0, Y:Number = 0)
		{
			super(FlxG.width * FlxG.random(), FlxG.height * FlxG.random());
			
			loadRotatedGraphic(imgEnemy, 360, -1, true, true);
			radius = 10;
			
			//kill();
		}
		
		override public function draw():void
		{
			super.draw();
		}
		
		override public function update():void
		{
			super.update();
			
			if (cooldownTimer.finished)
			{
				applyBehaviors();
			}
			else
			{
				color = FlxG.WHITE * (1 - cooldownTimer.timeLeft / 60);
			}
			
			//gradually build up speed
			velocity.x *= 0.8;
			velocity.y *= 0.8;
		}
		
		override public function destroy():void
		{
			super.destroy();
		}
		
		override public function reset(X:Number, Y:Number):void
		{
			super.reset(X, Y);
			
			cooldownTimer.start(1);
		}
		
		private function applyBehaviors():void
		{
			followPlayer(10);//behavior logic goes here
		}
		
		private function followPlayer(Acceleration:Number = 60):void
		{
			if (PlayerShip.instance.alive) 
			{
				acceleration.x = Acceleration * (PlayerShip.instance.position.x - position.x);
				acceleration.y = Acceleration * (PlayerShip.instance.position.y - position.y);
			}
			angle = PlayerShip.angleInDegrees(acceleration);
		}
		
		private function moveRandomly():void
		{
			/*float direction = rand.NextFloat(0, MathHelper.TwoPi);
			
			while (true)
			{
				direction += rand.NextFloat(-0.1f, 0.1f);
				direction = MathHelper.WrapAngle(direction);
				
				for (int i = 0; i < 6; i++)
				{
					Velocity += MathUtil.FromPolar(direction, 0.4f);
					Orientation -= 0.05f;
					
					var bounds = GameRoot.Viewport.Bounds;
					bounds.Inflate(-image.Width / 2 - 1, -image.Height / 2 - 1);
					
					// if the enemy is outside the bounds, make it move away from the edge
					if (!bounds.Contains(Position.ToPoint()))
						direction = (GameRoot.ScreenSize / 2 - Position).ToAngle() + rand.NextFloat(-MathHelper.PiOver2, MathHelper.PiOver2);
					
					yield return 0;
				}
			}*/
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