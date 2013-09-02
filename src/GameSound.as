package
{
	import org.flixel.*;
	
	public class GameSound
	{
		[Embed(source="../assets/sounds/Music.mp3")] public static var sfxMusic:Class;
		
		[Embed(source="../assets/sounds/explosion-01.mp3")] public static var sfxExplosion01:Class;
		[Embed(source="../assets/sounds/explosion-02.mp3")] public static var sfxExplosion02:Class;
		[Embed(source="../assets/sounds/explosion-03.mp3")] public static var sfxExplosion03:Class;
		[Embed(source="../assets/sounds/explosion-04.mp3")] public static var sfxExplosion04:Class;
		[Embed(source="../assets/sounds/explosion-05.mp3")] public static var sfxExplosion05:Class;
		[Embed(source="../assets/sounds/explosion-06.mp3")] public static var sfxExplosion06:Class;
		[Embed(source="../assets/sounds/explosion-07.mp3")] public static var sfxExplosion07:Class;
		[Embed(source="../assets/sounds/explosion-08.mp3")] public static var sfxExplosion08:Class;
		public static var sfxExplosion:Array = [
			sfxExplosion01, sfxExplosion02, sfxExplosion03, sfxExplosion04, 
			sfxExplosion05, sfxExplosion06, sfxExplosion07, sfxExplosion08];
		
		[Embed(source="../assets/sounds/shoot-01.mp3")] public static var sfxShoot01:Class;
		[Embed(source="../assets/sounds/shoot-02.mp3")] public static var sfxShoot02:Class;
		[Embed(source="../assets/sounds/shoot-03.mp3")] public static var sfxShoot03:Class;
		[Embed(source="../assets/sounds/shoot-04.mp3")] public static var sfxShoot04:Class;
		public static var sfxShoot:Array = [sfxShoot01, sfxShoot02, sfxShoot03, sfxShoot04];
		
		[Embed(source="../assets/sounds/spawn-01.mp3")] public static var sfxSpawn01:Class;
		[Embed(source="../assets/sounds/spawn-02.mp3")] public static var sfxSpawn02:Class;
		[Embed(source="../assets/sounds/spawn-03.mp3")] public static var sfxSpawn03:Class;
		[Embed(source="../assets/sounds/spawn-04.mp3")] public static var sfxSpawn04:Class;
		[Embed(source="../assets/sounds/spawn-05.mp3")] public static var sfxSpawn05:Class;
		[Embed(source="../assets/sounds/spawn-06.mp3")] public static var sfxSpawn06:Class;
		[Embed(source="../assets/sounds/spawn-07.mp3")] public static var sfxSpawn07:Class;
		[Embed(source="../assets/sounds/spawn-08.mp3")] public static var sfxSpawn08:Class;
		public static var sfxSpawn:Array = [
			sfxSpawn01, sfxSpawn02, sfxSpawn03, sfxSpawn04, 
			sfxSpawn05, sfxSpawn06, sfxSpawn07, sfxSpawn08];
		
		public static function create():void
		{
			FlxG.playMusic(sfxMusic, 0.6);
		}
		
		public static function randomSound(Sounds:Array, VolumeMultiplier:Number = 1.0):void
		{
			var _seed:Number = Math.floor(Sounds.length * Math.random());
			FlxG.play(Sounds[_seed], VolumeMultiplier, false, false);
		}
	}
}