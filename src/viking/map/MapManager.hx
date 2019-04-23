package viking.map;
import openfl.display.DisplayObjectContainer;

/**
 * ...
 * @author Krzysztof Kalinowski
 */
class MapManager 
{

	private static var _instance:MapManager;
	
	public var map:Map;
	
	private var _gameContainer:DisplayObjectContainer;
	
	public function new() 
	{
		map = new Map();
	}
		
	public static function getInstance():MapManager
	{
		if (_instance == null) _instance = new MapManager();
		return _instance;
	}
	
	public function init(gameContainer:DisplayObjectContainer)
	{
		_gameContainer = gameContainer;
	}
	
	public function onEnterNewArea():Void
	{
		
	}
	
	
	
}