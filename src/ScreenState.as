package
{
	import flash.display.Sprite;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.flixel.*;
	
	public class ScreenState extends FlxState
	{
		[Embed(source="../assets/images/Pointer.png")] protected static var imgPointer:Class;
		//[Embed(source="http://fonts.googleapis.com/css?family=Nova+Square", fontFamily="Nova Square", embedAsCFF="false")] public var fntNovaSquare:String;
		private var _fx:FlxSprite;
		private var blur:BlurFilter;
		
		//public static var canvas:Sprite;
		private static var entities:FlxGroup;
		private static var particles:FlxGroup;
		private static var cursor:FlxSprite;
		private static var displayText:FlxText;
		private static var inverseSpawnChance:Number = 60;
		private static var _spawnPosition:FlxPoint;
		
		public function ScreenState()
		{
			super();
		}
		
		override public function create():void
		{
			super.create();
			GameInput.create();
			GameSound.create();
						
			entities = new FlxGroup();
			entities.add(new PlayerShip());
			for (var i:uint = 0; i < 100; i++) entities.add(new Bullet());
			for (i = 0; i < 200; i++) entities.add(new Enemy());
			add(entities);
			
			particles = new FlxGroup();
			for (i = 0; i < 2000; i++) particles.add(new Particle());
			add(particles);
			
			cursor = new FlxSprite(FlxG.mouse.x, FlxG.mouse.x);
			cursor.loadGraphic(imgPointer);
			add(cursor);
			
			displayText = new FlxText(0, 0, FlxG.width, "");
			displayText.setFormat(null, 16, 0xffffff, "right");
			add(displayText);
			
			_fx = new FlxSprite();
			_fx.makeGraphic(FlxG.width, FlxG.height, 0, true);
			_fx.antialiasing = true;
			_fx.blend = "screen";
			//canvas = FlxG.camera.getContainerSprite();
			
			blur = new BlurFilter(8, 8, BitmapFilterQuality.HIGH);
			FlxG.watch(Enemy, "blackHoles");
		}
		
		override public function update():void
		{	
			GameInput.update();
			
			super.update();
			cursor.x = FlxG.mouse.x;
			cursor.y = FlxG.mouse.y;
			
			if (FlxG.random() < 1 / inverseSpawnChance) makeEnemy(Enemy.SEEKER);
			if (FlxG.random() < 1 / inverseSpawnChance) makeEnemy(Enemy.WANDERER);
			if (Enemy.blackHoles < 2) if (FlxG.random() < 1 / (inverseSpawnChance * 10)) makeEnemy(Enemy.BLACK_HOLE);
			if (inverseSpawnChance > 20) inverseSpawnChance -= 0.005;
			
			FlxG.overlap(entities, entities, handleCollision);
			
			if (PlayerShip.isGameOver) displayText.text = "Game Over\n" + "Your Score: " + 
				PlayerShip.score + "\n" + "High Score: " + PlayerShip.highScore;
			else displayText.text = "Lives: " + PlayerShip.lives + "\t\tScore: " + 
				PlayerShip.score + "\t\tMultiplier: " + PlayerShip.multiplier;
		}
		
		override public function draw():void
		{
			//canvas.graphics.clear();
			super.draw();
			//FlxG.camera.screen.pixels.draw(canvas);
			
			_fx.stamp(FlxG.camera.screen);
			FlxG.camera.screen.pixels.applyFilter(FlxG.camera.screen.pixels, new Rectangle(0,0,FlxG.width,FlxG.height), new Point(0,0), blur);
			_fx.draw();
		}
		
		public function handleCollision(Object1:FlxObject, Object2:FlxObject):void
		{
			var DistanceSquared:Number = 0;
			var Collided:Boolean = false;
			if (Object1 is Entity && Object2 is Entity)
			{
				var DX:Number = (Object1 as Entity).position.x - (Object2 as Entity).position.x;
				var DY:Number = (Object1 as Entity).position.y - (Object2 as Entity).position.y;
				var CombinedRadius:Number = (Object1 as Entity).radius + (Object2 as Entity).radius;
				
				DistanceSquared = DX * DX + DY * DY; //FlxU.getDistance((Object1 as Entity).position, (Object2 as Entity).position);
				if (DistanceSquared <= CombinedRadius * CombinedRadius) Collided = true;
				else Collided = false;
			}
			if (!Collided) return;
			(Object1 as Entity).collidesWith(Object2 as Entity, DistanceSquared);
			(Object2 as Entity).collidesWith(Object1 as Entity, DistanceSquared);
		}
		
		/*public function circularCollision(Object1:FlxObject, Object2:FlxObject):Boolean
		{
			var _distanceFromCenters:Number
			if (Object1 is Entity && Object2 is Entity)
			{
				_distanceFromCenters = FlxU.getDistance((Object1 as Entity).position, (Object2 as Entity).position);
				if (_distanceFromCenters < (Object1 as Entity).radius + (Object2 as Entity).radius) return true;
				else return false;
			}
			else return false;
		}*/
		
		public static function reset():void
		{
			inverseSpawnChance = 60;
		}
		
		public static function makeBullet(PositionX:Number, PositionY:Number, Angle:Number, Speed:Number):Boolean
		{
			var _bullet:Bullet = Bullet(entities.getFirstAvailable(Bullet));
			if (_bullet) 
			{
				(_bullet as Bullet).reset(PositionX, PositionY);
				_bullet.angle = Angle;
				_bullet.velocity.x = Speed * Math.cos((Angle / 180) * Math.PI);
				_bullet.velocity.y = Speed * Math.sin((Angle / 180) * Math.PI);
				return true;
			}
			else return false;
		}
		
		public static function makeEnemy(Type:uint):Boolean
		{
			var _enemy:Enemy = Enemy(entities.getFirstAvailable(Enemy));
			if (_enemy) 
			{
				var MinimumDistanceFromPlayer:Number;
				if (Type == Enemy.BLACK_HOLE) MinimumDistanceFromPlayer = 20;
				else MinimumDistanceFromPlayer = 150;
				_enemy.type = Type;
				_enemy.position = getSpawnPosition(_enemy.position, MinimumDistanceFromPlayer);
				_enemy.reset(_enemy.position.x, _enemy.position.y);
				return true;
			}
			else return false;
		}
		
		public static function makeParticle(PositionX:Number, PositionY:Number, Angle:Number, Speed:Number, Color:uint = FlxG.WHITE):Boolean
		{
			Particle.index += 1;
			if (Particle.index >= Particle.max) Particle.index = 0;
			var _overwritten:Boolean = false;
			var _particle:Particle = particles.members[Particle.index];
			if (_particle.exists) _overwritten = true;

			_particle.reset(PositionX, PositionY);
			//_particle.moveSpeed = Speed;
			//_particle.angle = Angle;
			_particle.lineColor = Color;
			_particle.setVelocity((Angle * Math.PI) / 180, Speed);
			return _overwritten;
		}
		
		public static function makeExplosion(PositionX:Number, PositionY:Number, NumberOfParticles:uint = 120, Color:uint = FlxG.GREEN):void
		{
			for (var i:uint = 0; i < NumberOfParticles; i++)
			{
				makeParticle(PositionX, PositionY, 360 * FlxG.random(), Particle.MAX_SPEED * (1 - 0.25 * FlxG.random()), Color);
			}
		}
		
		public static function getSpawnPosition(Source:FlxPoint, MinimumDistanceFromPlayer:Number):FlxPoint
		{
			var _x:int;
			var _y:int;
			var _xDelta:Number;
			var _yDelta:Number;
			
			do
			{
				_x = int(FlxG.random() * FlxG.width);
				_y = int(FlxG.random() * FlxG.height);
				_xDelta = PlayerShip.instance.position.x - _x;
				_yDelta = PlayerShip.instance.position.y - _y;
			} while (_xDelta * _xDelta + _yDelta * _yDelta < MinimumDistanceFromPlayer * MinimumDistanceFromPlayer);
			
			Source.x = _x;
			Source.y = _y;
			
			return Source;
		}

	}
}