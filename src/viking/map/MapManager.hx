package viking.map;

/**
 * ...
 * @author Krzysztof Kalinowski
 */
class MapManager 
{

	private static var _instance:MapManager;
	public var map:Map;
	
	public function new() 
	{
		map = new Map();
	}
		
	public static function getInstance():MapManager
	{
		if (_instance == null) _instance = new MapManager();
		return _instance;
	}
	
	
	
}