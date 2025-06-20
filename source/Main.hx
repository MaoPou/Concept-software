package;

import states.MainState;

import flixel.FlxGame;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.system.FlxSplash;
import flixel.FlxG;

import openfl.display.Sprite;

import objects.FpsCounter;

import openfl.Assets;

class Main extends Sprite
{
	public var fps:Int = 0;
	public function new()
	{
		super();

		FlxSprite.defaultAntialiasing = false;

		addChild(new FlxGame(1280, 720, MainState, 120 , 120, true));

		openfl.Lib.current.stage.addChild(new FpsCounter());
	}
}
