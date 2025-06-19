package;

import states.MainState;

import flixel.FlxGame;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.system.FlxSplash;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		
		FlxSprite.defaultAntialiasing = false;
		addChild(new FlxGame(1280, 720, MainState, 120 , 120, true));
	}
}
