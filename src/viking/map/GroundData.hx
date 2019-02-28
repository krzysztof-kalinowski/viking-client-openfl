package viking.map;

/**
 * ...
 * @author Krzysztof Kalinowski
 */
class GroundData 
{
	@:isVar private var groundWidth(get, set):Float;
	@:isVar private var groundHeight(get, set):Float;

	@:isVar private var idArea(get, set):Int;
	@:isVar private var nameArea(get, set):String;

	@:isVar private var offsetX2D(get, set):Float;
	@:isVar private var offsetY2D(get, set):Float;
	
	public function new() 
	{
		
	}
	
	function get_groundWidth():Float 
	{
		return groundWidth;
	}
	
	function set_groundWidth(value:Float):Float 
	{
		return groundWidth = value;
	}
	
	function get_groundHeight():Float 
	{
		return groundHeight;
	}
	
	function set_groundHeight(value:Float):Float 
	{
		return groundHeight = value;
	}
	
	function get_idArea():Int 
	{
		return idArea;
	}
	
	function set_idArea(value:Int):Int 
	{
		return idArea = value;
	}
	
	function get_nameArea():String 
	{
		return nameArea;
	}
	
	function set_nameArea(value:String):String 
	{
		return nameArea = value;
	}
	
	function get_offsetX2D():Float 
	{
		return offsetX2D;
	}
	
	function set_offsetX2D(value:Float):Float 
	{
		return offsetX2D = value;
	}
	
	function get_offsetY2D():Float 
	{
		return offsetY2D;
	}
	
	function set_offsetY2D(value:Float):Float 
	{
		return offsetY2D = value;
	}
	
}