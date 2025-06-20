package objects;

import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.events.Event;

class FpsCounter extends Sprite
{
    var textField:TextField;
    var lastTime:Float = 0;
    var frameCount:Int = 0;
    var fps:Float = 0;

    public function new(x:Float = 10, y:Float = 10)
    {
        super();
        this.x = x;
        this.y = y;

        textField = new TextField();
        textField.defaultTextFormat = new TextFormat("assets/fonts/Main.ttf", 16, 0xFFFFFF);
        textField.width = 120;
        textField.height = 24;
        textField.selectable = false;
        textField.text = "FPS: 0";
        addChild(textField);

        lastTime = haxe.Timer.stamp();
        addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    private function onEnterFrame(e:Event):Void
    {
        frameCount++;
        var now = haxe.Timer.stamp();
        var delta = now - lastTime;
        if (delta >= 1)
        {
            fps = frameCount / delta;
            textField.text = "FPS: " + Std.int(fps);
            frameCount = 0;
            lastTime = now;
        }
    }
}