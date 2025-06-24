package states;

import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.group.FlxGroup;

import openfl.display.GradientType;
import openfl.geom.Matrix;
import openfl.display.Shape;

class SettingState extends FlxState{
    private var settingsGroup:FlxGroup;
    public var MainCam:FlxCamera;
    public function new(){
        super();
        MainCam = new FlxCamera();
        MainCam.bgColor.alpha = 0;
        FlxG.cameras.add(MainCam, false);

        settingsGroup = new FlxGroup();
        add(settingsGroup);

        var bg = new FlxSprite();
        bg.makeGraphic(1280, 720, 0x00000000, true);
        
        var shape = new Shape();
        var matrix = new Matrix();
        matrix.createGradientBox(1280, 720, Math.PI / 4);
        
        var colors:Array<Int> = [0xFF0A0A1A, 0xFF1A1A3A];
        var alphas:Array<Float> = [1.0, 1.0];
        var ratios:Array<Int> = [0, 255];
        
        shape.graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matrix);
        shape.graphics.drawRect(0, 0, 1280, 720);
        shape.graphics.endFill();
        
        bg.pixels.draw(shape);
        add(bg);
        bg.cameras = [MainCam];

        MainCam.alpha = 0;
        FlxTween.tween(MainCam, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
    }
}