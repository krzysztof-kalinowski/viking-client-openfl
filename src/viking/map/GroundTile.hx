package viking.map;

import openfl.display.Bitmap;
import openfl.display.Loader;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.URLRequest;
import viking.config.Path;
import viking.core.Disposable;

/**
 * ...
 * @author Krzysztof Kalinowski
 */
class GroundTile extends Sprite implements Disposable
{

	@:isVar public var column(get, null):Int;
	@:isVar public var row(get, null):Int;
	
	private var _loader:Loader;
	private var _bitmap:Bitmap;
	
	public function new(map_id:Int, count:Int, row:Int, column:Int) 
	{
		super();
		
		var prefix:String = count < 10 ? "_0" : "_";
		var path:String = Path.AREA + map_id + "/" + map_id + prefix + count+".jpg";
		
		load(path);
	}
	
	private function load(path:String):Void 
	{
		_loader = new Loader();
		_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
		_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onCompleteHandler);
		_loader.load(new URLRequest(path));
	}	
	
	private function onCompleteHandler(e:Event):Void 
	{
		_bitmap = cast(_loader.content, Bitmap);
		addChild(_bitmap);
		disposeLoader();
	}
	
	private function ioErrorHandler(e:IOErrorEvent):Void 
	{
		disposeLoader();
		trace("GroundTile IOERROR = "+e.text);
	}
	
	private function disposeLoader():Void
	{
		_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
		_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onCompleteHandler);
		_loader.unload();
		_loader = null;
	}
	
	public function dispose()
	{
		if (_loader != null) {
			disposeLoader();
		}
		
		if (_bitmap != null) {
			removeChild(_bitmap);
			_bitmap = null;
		}
		
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