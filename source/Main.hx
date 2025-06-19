package;

import states.MainState;

import flixel.FlxGame;
import flixel.FlxSprite;
import flixel.text.FlxText;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		
		FlxSprite.defaultAntialiasing = false;
		addChild(new FlxGame(970, 546, MainState));
	}
}
