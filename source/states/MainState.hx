package states;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.util.FlxSpriteUtil;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.sound.FlxSound;

import flixel.text.FlxText;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;

import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

import openfl.display.GradientType;
import openfl.geom.Matrix;
import openfl.display.Shape;
import openfl.utils.Assets;

class MainState extends FlxState
{
    public var MainCam:FlxCamera;
    public var music:FlxSound;

    static final NUM_POINTS:Int = 50;
    static final POINT_SIZE:Int = 2;
    static final POINT_SPEED:Float = 100;
    static final CONNECT_DISTANCE:Float = 100;
    static final ATTRACTION_DISTANCE:Float = 150;
    static final ATTRACTION_FORCE:Float = 0.005;
    static final LINE_COLOR:FlxColor = 0x80FFFFFF;
    static final POINT_COLOR:FlxColor = FlxColor.WHITE;
    
    var points:FlxTypedGroup<FlxSprite>;
    var canvas:FlxSprite;

    var welcome:FlxText;

    var start:FlxText;
    var settings:FlxText;
    var credits:FlxText;
    var contribute:FlxText;

    override public function create():Void
    {
        super.create();
        
        MainCam = new FlxCamera();
        MainCam.bgColor.alpha = 0;
        FlxG.cameras.add(MainCam, false);
        FlxG.cameras.setDefaultDrawTarget(MainCam, true);

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
        FlxTween.tween(MainCam, {alpha: 1}, 1, {ease: FlxEase.cubeInOut});

        music = new FlxSound();
        music.loadEmbedded("assets/music/main.ogg", true);
        music.play();
        music.volume = 0;
        FlxTween.tween(music, {volume: 0.2}, 1, {ease: FlxEase.cubeInOut});

        canvas = new FlxSprite();
        canvas.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
        add(canvas);
        canvas.cameras = [MainCam];
        
        points = new FlxTypedGroup<FlxSprite>();
        add(points);
        points.cameras = [MainCam];
        
        for (i in 0...NUM_POINTS)
        {
            var point = new FlxSprite();
            point.makeGraphic(POINT_SIZE, POINT_SIZE, POINT_COLOR);
            point.x = FlxG.random.float(0, FlxG.width - POINT_SIZE);
            point.y = FlxG.random.float(0, FlxG.height - POINT_SIZE);
            
            point.velocity.set(
                FlxG.random.float(-POINT_SPEED, POINT_SPEED),
                FlxG.random.float(-POINT_SPEED, POINT_SPEED)
            );
            
            point.elasticity = 1;
            points.add(point);
        }

        createDecorativeLines();
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        FlxG.autoPause = false;
        
        canvas.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
        
        var mousePos = FlxPoint.get(FlxG.mouse.getViewPosition(MainCam).x, 
                              FlxG.mouse.getViewPosition(MainCam).y);
        
        points.forEachAlive(function(point:FlxSprite)
        {
            if ((point.x <= 0 && point.velocity.x < 0) || 
                (point.x >= FlxG.width - point.width && point.velocity.x > 0))
            {
                point.velocity.x *= -1;
            }
            if ((point.y <= 0 && point.velocity.y < 0) || 
                (point.y >= FlxG.height - point.height && point.velocity.y > 0))
            {
                point.velocity.y *= -1;
            }
            
            var pointCenter = FlxPoint.get(
                point.x + point.width / 2, 
                point.y + point.height / 2
            );
            
            var distance = pointCenter.distanceTo(mousePos);

            if (distance < CONNECT_DISTANCE)
            {
                var alpha = Std.int(255 * (1 - distance / CONNECT_DISTANCE));
                var color = LINE_COLOR;
                color.alphaFloat = alpha / 255;

                FlxSpriteUtil.drawLine(
                    canvas,
                    mousePos.x, 
                    mousePos.y,
                    pointCenter.x,
                    pointCenter.y,
                    {color: color, thickness: 1}
                );
            }
            
            points.forEachAlive(function(otherPoint:FlxSprite)
            {
                if (point != otherPoint)
                {
                    var otherCenter = FlxPoint.get(
                        otherPoint.x + otherPoint.width / 2,
                        otherPoint.y + otherPoint.height / 2
                    );
                    
                    var pointDistance = pointCenter.distanceTo(otherCenter);
                    
                    if (pointDistance < CONNECT_DISTANCE)
                    {
                        var lineAlpha = Std.int(255 * (1 - pointDistance / CONNECT_DISTANCE));
                        var lineColor = LINE_COLOR;
                        lineColor.alphaFloat = lineAlpha / 255;

                        FlxSpriteUtil.drawLine(
                            canvas,
                            pointCenter.x,
                            pointCenter.y,
                            otherCenter.x,
                            otherCenter.y,
                            {color: lineColor, thickness: 1}
                        );
                    }
                    
                    if (pointDistance < ATTRACTION_DISTANCE)
                    {
                        var dx = otherCenter.x - pointCenter.x;
                        var dy = otherCenter.y - pointCenter.y;
                        var force = ATTRACTION_FORCE * (1 - pointDistance / ATTRACTION_DISTANCE);
                        
                        point.velocity.x += dx * force * elapsed;
                        point.velocity.y += dy * force * elapsed;
                    }
                    
                    otherCenter.put();
                }
            });
            
            pointCenter.put();
        });
        
        mousePos.put();
    }

    private function createDecorativeLines():Void 
    {
        var topLine = new FlxSprite(100, 130);
        topLine.makeGraphic(1080, 1, FlxColor.WHITE);
        topLine.alpha = 0.5;
        add(topLine);

        topLine.cameras = [MainCam];
        
        var bottomLine = new FlxSprite(100, 620);
        bottomLine.makeGraphic(1080, 1, FlxColor.WHITE);
        bottomLine.alpha = 0.5;
        add(bottomLine);

        bottomLine.cameras = [MainCam];

        var version1 = new FlxText(930, 668, 0, "Vesper Plume 0.9");
        version1.setFormat("assets/fonts/Main.ttf", 42, 0xFFFFFFFF, FlxTextAlign.RIGHT, FlxTextBorderStyle.OUTLINE);
        version1.borderColor = 0xFF000000;
        version1.borderSize = 1;
        version1.antialiasing = true;
        add(version1);
        version1.cameras = [MainCam];
        version1.scale.x = version1.scale.y = 0.5;
        
        var version2 = new FlxText(1085, 639, 0, "BY MaoPou");
        version2.setFormat("assets/fonts/Main.ttf", 42, 0xFFFFFFFF, FlxTextAlign.RIGHT, FlxTextBorderStyle.OUTLINE);
        version2.borderColor = 0xFF000000;
        version2.borderSize = 1;
        version2.antialiasing = true;
        add(version2);
        version2.cameras = [MainCam];
        version2.scale.x = version2.scale.y = 0.5;

        welcome = new FlxText(0, 0, FlxG.width, "Welcome");
        welcome.setFormat("assets/fonts/Main.ttf", 80, 0xFFFFFFFF, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE);
        welcome.borderColor = 0xFF000000;
        welcome.borderSize = 1;
        welcome.antialiasing = true;
        add(welcome);
        welcome.cameras = [MainCam];
        welcome.alpha = 0;

        start = new FlxText(0, 213, FlxG.width, "Start");
        start.setFormat("assets/fonts/Main.ttf", 80, 0xFFFFFFFF, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE);
        start.borderColor = 0xFF000000;
        start.borderSize = 1;
        start.antialiasing = true;
        add(start);
        start.cameras = [MainCam];
        //start.alpha = 0;
        start.scale.x = start.scale.y = 0.5;
        

        settings = new FlxText(0, 303, FlxG.width, "Settings");
        settings.setFormat("assets/fonts/Main.ttf", 80, 0xFFFFFFFF, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE);
        settings.borderColor = 0xFF000000;
        settings.borderSize = 1;
        settings.antialiasing = true;
        add(settings);
        settings.cameras = [MainCam];
        //settings.alpha = 0;
        settings.scale.x = settings.scale.y = 0.5;

        credits = new FlxText(0, 393, FlxG.width, "Credits");
        credits.setFormat("assets/fonts/Main.ttf", 80, 0xFFFFFFFF, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE);
        credits.borderColor = 0xFF000000;
        credits.borderSize = 1;
        credits.antialiasing = true;
        add(credits);
        credits.cameras = [MainCam];
        //credits.alpha = 0;
        credits.scale.x = credits.scale.y = 0.5;

        contribute = new FlxText(0, 483, FlxG.width, "Contribute");
        contribute.setFormat("assets/fonts/Main.ttf", 80, 0xFFFFFFFF, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE);
        contribute.borderColor = 0xFF000000;
        contribute.borderSize = 1;
        contribute.antialiasing = true;
        add(contribute);
        contribute.cameras = [MainCam];
        //contribute.alpha = 0;
        contribute.scale.x = contribute.scale.y = 0.5;

        FlxTimer.wait(0.5,() -> welcomes());
    }

    function welcomes() {
        FlxTween.tween(welcome, {alpha: 1,y: 29}, 0.7, {ease: FlxEase.circOut});
        FlxTimer.wait(2,() -> {
            welcome.text = "Vesper Plume";
            welcome.y = welcome.alpha = 0;
            FlxTween.tween(welcome, {alpha: 1,y: 22}, 0.7, {ease: FlxEase.circOut});
        });
    }
}