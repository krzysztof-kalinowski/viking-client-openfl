package viking.map;

import openfl.display.Bitmap;
import openfl.display.Loader;
import openfl.display.LoaderInfo;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.URLRequest;
import viking.config.Path;

/**
 * ...
 * @author Krzysztof Kalinowski
 */
class GroundTile extends Sprite 
{

	@:isVar public var column(get, null):Int;
	@:isVar public var row(get, null):Int;
	
	public function new(map_id:Int, count:Int, row:Int, column:Int) 
	{
		super();
		
		var prefix:String = count < 10 ? "_0" : "_";
		var path:String = Path.AREA + map_id + "/" + map_id + prefix + count+".jpg";
		
		init(path);
	}
	
	private function init(path:String):Void 
	{
		var loader = new Loader();
		loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onCompleteHandler);
		loader.load(new URLRequest(path));
	}
	
	private function onCompleteHandler(e:Event):Void 
	{
		var bitmap = cast(cast(e.target, LoaderInfo).content, Bitmap);
		addChild(bitmap);
	}
	
	private function ioErrorHandler(e:IOErrorEvent):Void 
	{
		trace("GroundTile IOERROR = "+e.text);
	}
	
	public function get_column():Int 
	{
		return column;
	}
	
	public function get_row():Int 
	{
		return row;
	}
	
	
	
}