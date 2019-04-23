package viking.team;
import openfl.display.Bitmap;
import openfl.display.Loader;
import openfl.display.LoaderInfo;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.URLRequest;
import openfl.text.TextField;
import viking.config.Path;
import viking.core.Disposable;

/**
 * ...
 * @author Krzysztof Kalinowski
 */
class Team extends Sprite implements Disposable
{
	private var _teamModel:TeamModel;
	
	private var _label:TextField;
	
	public function new(teamModel:TeamModel):Void 
	{
		super();
		_teamModel = teamModel;
		init();
	}
	
	public function init()
	{
		loadGraphics();
	}
	
	private function loadGraphics():Void
	{
		var loader = new Loader();
		loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onCompleteHandler);
		loader.load(new URLRequest(Path.ASSETS_IMG+"viking_avatar.jpg"));
	}
	
	private function onCompleteHandler(e:Event):Void 
	{
		var bitmap = cast(cast(e.target, LoaderInfo).content, Bitmap);
		bitmap.width = bitmap.height = 30.0;
		bitmap.x = - bitmap.width / 2;
		bitmap.y = - bitmap.height; 
		addChild(bitmap);
		
		var debugDot = new Sprite();
		debugDot.graphics.beginFill(0xFF0000, 1.0);
		debugDot.graphics.drawCircle(0, 0, 2);
		debugDot.graphics.endFill();
		addChild(debugDot);
		
	}
	
	private function ioErrorHandler(e:IOErrorEvent):Void 
	{
		trace("Team IOERROR = "+e.text);
	}
	
	public function dispose()
	{
		
	}
	
}