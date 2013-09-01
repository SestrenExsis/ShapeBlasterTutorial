package
{
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.flixel.*;
	
	public class ScreenState extends FlxState
	{
		[Embed(source="../assets/images/Pointer.png")] protected static var imgPointer:Class;

		private static var entities:FlxGroup;
		private static var cursor:FlxSprite;
		private var _fx:FlxSprite;
		private var blur:BlurFilter;
		private static var inverseSpawnChance:Number = 60;
		private static var _spawnPosition:FlxPoint;
		
		public function ScreenState()
		{
			super();
		}
		
		override public function create():void
		{
			super.create();
			
			entities = new FlxGroup();
			entities.add(new PlayerShip());
			for (var i:uint = 0; i < 50; i++) entities.add(new Bullet());
			for (i = 0; i < 200; i++) entities.add(new Enemy());
			add(entities);
			
			cursor = new FlxSprite(FlxG.mouse.x, FlxG.mouse.x);
			cursor.loadGraphic(imgPointer);
			add(cursor);
			
			_fx = new FlxSprite();
			_fx.makeGraphic(FlxG.width, FlxG.height, 0, true);
			_fx.antialiasing = true;	//Set AA to true for maximum blurry
			_fx.blend = "screen";		//Set blend mode to "screen" to make the blurred copy transparent and brightening
			
			blur = new BlurFilter();
			blur.blurX = 8; 
			blur.blurY = 8; 
			blur.quality = BitmapFilterQuality.HIGH;
		}
		
		override public function update():void
		{	
			GameInput.update();
			
			super.update();
			cursor.x = FlxG.mouse.x;
			cursor.y = FlxG.mouse.y;
			
			if (FlxG.random() < 1 / inverseSpawnChance) makeSeeker();
			if (FlxG.random() < 1 / inverseSpawnChance) makeWanderer();
			if (inverseSpawnChance > 20) inverseSpawnChance -= 0.005;
			
			FlxG.overlap(entities, entities, handleCollision, circularCollision);
		}
		
		override public function draw():void
		{
			super.draw();
			
			_fx.stamp(FlxG.camera.screen);
			FlxG.camera.screen.pixels.applyFilter(FlxG.camera.screen.pixels, new Rectangle(0,0,FlxG.width,FlxG.height), new Point(0,0), blur);
			_fx.draw();
		}
		
		public function handleCollision(Object1:FlxObject, Object2:FlxObject):void
		{
			(Object1 as Entity).collidesWith(Object2);
			(Object2 as Entity).collidesWith(Object1);
		}
		
		public function circularCollision(Object1:FlxObject, Object2:FlxObject):Boolean
		{
			var _distanceFromCenters:Number
			if (Object1 is Entity && Object2 is Entity)
			{
				_distanceFromCenters = FlxU.getDistance((Object1 as Entity).position, (Object2 as Entity).position);
				if (_distanceFromCenters < (Object1 as Entity).radius + (Object2 as Entity).radius) return true;
				else return false;
			}
			else return false;
		}
		
		public static function reset():void
		{
			inverseSpawnChance = 60;
		}
		
		public static function makeBullet(PositionX:Number, PositionY:Number, Angle:Number, Speed:Number):Boolean
		{
			var bullet:Bullet = Bullet(entities.getFirstAvailable(Bullet));
			if (bullet) 
			{
				bullet.reset(PositionX, PositionY);
				bullet.angle = Angle;
				bullet.velocity.x = Speed * Math.cos((Angle / 180) * Math.PI);
				bullet.velocity.y = Speed * Math.sin((Angle / 180) * Math.PI);
				return true;
			}
			else return false;
		}
		
		public static function makeSeeker():Boolean
		{
			var seeker:Enemy = Enemy(entities.getFirstAvailable(Enemy));
			if (seeker) 
			{
				seeker.type = Enemy.SEEKER;
				seeker.position = getSpawnPosition(seeker.position);
				seeker.reset(seeker.position.x, seeker.position.y);
				return true;
			}
			else return false;
		}
		
		public static function makeWanderer():Boolean
		{
			var wanderer:Enemy = Enemy(entities.getFirstAvailable(Enemy));
			if (wanderer)
			{
				wanderer.type = Enemy.WANDERER;
				wanderer.position = getSpawnPosition(wanderer.position);
				wanderer.reset(wanderer.position.x, wanderer.position.y);
				return true;
			}
			else return false;
		}
		
		public static function getSpawnPosition(Source:FlxPoint):FlxPoint
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
			} while (_xDelta * _xDelta + _yDelta * _yDelta < 200 * 200);
			
			Source.x = _x;
			Source.y = _y;
			
			return Source;
		}

	}
}