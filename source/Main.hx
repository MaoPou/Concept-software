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


import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.util.FlxColor;

import haxe.Json;
import haxe.zip.Uncompress;
import haxe.zip.Reader;
import haxe.io.Bytes;
import haxe.crypto.BaseCode;
import sys.io.File;

class Main extends Sprite
{
	public var fps:Int = 0;
	public function new()
	{
		super();

		FlxSprite.defaultAntialiasing = false;

		addChild(new FlxGame(1280, 720, MainState, 240 , 240, true));
		updateGitAction();

		openfl.Lib.current.stage.addChild(new FpsCounter());
	}

	var httpAPI:Int = 0;
	var APIadvice:Array<String> = ["https://rak3ffdi.cloud.tds1.tapapis.cn/1.1/classes/_GameSave","https://phi.iris.al/api/v1/b19"];
	function updateGitAction():Void
	{
		try
		{
			var http = new haxe.Http(APIadvice[httpAPI]);
			if (httpAPI == 0){
				http.setHeader("User-Agent", "LeanCloud-CSharp-SDK/1.0.3");
				http.setHeader("Accept", "application/json");
				http.setHeader("X-LC-Id", "rAK3FfdieFob2Nn8Am");
				http.setHeader("X-LC-Key", "Qr9AEqtuoSVS3zeD6iVbM4ZC0AtkJcQ89tywVyi0");
				http.setHeader("X-LC-Session", "60x72qdgthm106qa9vlj59azf");
			}else if(httpAPI == 1){
				http.setHeader("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.5735.196 Safari/537.36");
				var data = '{"session":"60x72qdgthm106qa9vlj59azf"}';
				http.setPostData(data);
			}

			http.onData = function(data:String)
			{
				var Jsonsa = Json.parse(data);
				if (httpAPI == 0){
					var https = new haxe.Http(Jsonsa.results[0].gameFile.url);
					
					https.onBytes = function(data:Bytes) {
					try {
						var fileName = "save"; // 或从URL提取文件名
						var saveDir = "downloads"; // 相对路径更安全
						
						// 创建目录（如果不存在）
						if(!sys.FileSystem.exists(saveDir)) {
							sys.FileSystem.createDirectory(saveDir);
						}
						
						var filePath = '$saveDir/$fileName';
						var file = sys.io.File.write(filePath, true);
						file.write(data);

						file.close();
						
						trace('文件成功保存到: $filePath');

						var zipBytes = sys.io.File.getBytes(filePath);
						var input = new haxe.io.BytesInput(zipBytes);
						
						// 2. 解析ZIP（明确指定返回类型）
						var entries:List<haxe.zip.Entry> = Reader.readZip(input);
						
						// 3. 创建解压目录
						var extractDir = "extracted";
						if (!sys.FileSystem.exists(extractDir)) {
							sys.FileSystem.createDirectory(extractDir);
						}
						
						// 4. 遍历并解压
						for (entry in entries) {
							var fileName = entry.fileName;
							var compressedData = entry.data;
							
							// 5. 解压数据
							var uncompressedData;
							if (entry.compressed) {
								var uncompress = new Uncompress(-15);
								var out = Bytes.alloc(entry.fileSize); // 预分配空间
								uncompress.execute(compressedData, 0, out, 0);
								uncompressedData = out;
								uncompress.close();
							} else {
								uncompressedData = compressedData;
							}
							
							// 6. 转为Base64
							var base64 = haxe.crypto.Base64.encode(uncompressedData);

							sys.io.File.saveBytes('$extractDir/$fileName', uncompressedData);

							//var yuanshi = BaseCode.decodeBase65(base64).toString();

							//var files = FileOutput.open("download/$fileName.txt");
							//files.writeBytes(yuanshi, 0,yuanshi.length);
							//files.close();
						}
					} catch(e:Dynamic) {
						trace('保存失败: $e');
					}
				};

				https.onError = function(error) {
					trace("下载错误: " + error);
				};

				https.request(false);
				}
			};

			http.onError = function(error)
			{

				trace('error: $error');
			};

			http.request();
		}
		catch (e:Dynamic)
		{
			trace('exception: $e');
		}
	}
}
