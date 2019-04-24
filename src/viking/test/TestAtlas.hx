package viking.test;

import flash.net.URLRequest;
import openfl.display.Bitmap;
import openfl.display.Loader;
import openfl.display.LoaderInfo;
import openfl.display.Sprite;
import openfl.display.Tilemap;
import openfl.display.Tileset;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.geom.Rectangle;
import viking.config.Path;

/**
 * ...
 * @author Krzysiek Kalinowski
 */
class TestAtlas extends Sprite 
{

	public function new() 
	{
		super();
		test();
	}
	
	private function test():Void 
	{
		var loader = new Loader();
		loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
		loader.load(new URLRequest(Path.ASSETS_IMG+"viking_avatar.jpg"));
	}
	
	private function ioErrorHandler(e:IOErrorEvent):Void 
	{
		trace("TestAtlas IOERROR = "+e.text);
	}
	
	private function onLoadComplete(e:Event):Void 
	{
		var bitmap = cast(cast(e.target, LoaderInfo).content, Bitmap);  //190 / 190
		
		var rec_width = bitmap.width / 2;
		var rec_height = bitmap.height / 2;
		
		var rectangles = new Array<Rectangle>();
		rectangles.push(new Rectangle(0, 0, rec_width, rec_height));
		rectangles.push(new Rectangle(rec_width, 0, rec_width, rec_height));
		rectangles.push(new Rectangle(0, rec_height, rec_width, rec_height));
		rectangles.push(new Rectangle(rec_width, rec_height, rec_width, rec_height));
		
		var set:Tileset = new Tileset(bitmap.bitmapData, rectangles);
		
		var tilemap = new Tilemap(50, 50, set, true);
		addChild(tilemap);
		
	}
	
}