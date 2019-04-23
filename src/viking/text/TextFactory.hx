package viking.text;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;

/**
 * ...
 * @author Krzysiek Kalinowski
 */
class TextFactory 
{
	private static var _instance;
	
	private var _nameFormat:TextFormat;
	private var _boldFormat:TextFormat;
	private var _italicFormat:TextFormat;
	private var _underlineFormat:TextFormat;
	
	private var _nameLeftFormat:TextFormat;
	private var _boldLeftFormat:TextFormat;
	private var _italicLeftFormat:TextFormat;
	private var _underlineLeftFormat:TextFormat;
	
	private var _nameRightFormat:TextFormat;
	private var _boldRightFormat:TextFormat;
	private var _italicRightFormat:TextFormat;
	private var _underlineRightFormat:TextFormat;
	
	

	public function new() 
	{
		init();
	}
	
	public static function getInstance():TextFactory
	{
		if (_instance == null) _instance = new TextFactory();
		return _instance;
	}
	
	private function init()
	{
		var fontSize:Int = 12;
		var font:String = "Arial";
		
		_nameFormat = new TextFormat(font, fontSize, 0xFF0000, null, null, null, null, null, TextFormatAlign.CENTER, null, null, null, null); 
		_boldFormat = new TextFormat(font, fontSize, 0xFF0000, true, null, null, null, null, TextFormatAlign.CENTER, null, null, null, null); 
		_italicFormat = new TextFormat(font, fontSize, 0xFF0000, null, true, null, null, null, TextFormatAlign.CENTER, null, null, null, null); 
		_underlineFormat = new TextFormat(font, fontSize, 0xFF0000, null, null, true, null, null, TextFormatAlign.CENTER, null, null, null, null); 
		
		_nameLeftFormat = new TextFormat(font, fontSize, 0xFF0000, null, null, null, null, null, TextFormatAlign.LEFT, null, null, null, null); 
		_boldLeftFormat = new TextFormat(font, fontSize, 0xFF0000, true, null, null, null, null, TextFormatAlign.LEFT, null, null, null, null); 
		_italicLeftFormat = new TextFormat(font, fontSize, 0xFF0000, null, true, null, null, null, TextFormatAlign.LEFT, null, null, null, null); 
		_underlineLeftFormat = new TextFormat(font, fontSize, 0xFF0000, null, null, true, null, null, TextFormatAlign.LEFT, null, null, null, null); 
		
		_nameRightFormat = new TextFormat(font, fontSize, 0xFF0000, null, null, null, null, null, TextFormatAlign.RIGHT, null, null, null, null); 
		_boldRightFormat = new TextFormat(font, fontSize, 0xFF0000, true, null, null, null, null, TextFormatAlign.RIGHT, null, null, null, null); 
		_italicRightFormat = new TextFormat(font, fontSize, 0xFF0000, null, true, null, null, null, TextFormatAlign.RIGHT, null, null, null, null); 
		_underlineRightFormat = new TextFormat(font, fontSize, 0xFF0000, null, null, true, null, null, TextFormatAlign.RIGHT, null, null, null, null); 

	}
	
	public function getTextField(style:String):TextField
	{
		var text:TextField = new TextField();
		switch (style) 
		{
			case TextFieldStyle.NAME:
				text.defaultTextFormat = _nameFormat;
			case TextFieldStyle.NAME_LEFT:
				text.defaultTextFormat = _nameLeftFormat;
			case TextFieldStyle.NAME_RIGHT:
				text.defaultTextFormat = _nameRightFormat;
			
			case TextFieldStyle.BOLD:
				text.defaultTextFormat = _boldFormat;
			case TextFieldStyle.BOLD_LEFT:
				text.defaultTextFormat = _boldLeftFormat;
			case TextFieldStyle.BOLD_RIGHT:
				text.defaultTextFormat = _boldRightFormat;
				
			case TextFieldStyle.ITALIC:
				text.defaultTextFormat = _italicFormat;
			case TextFieldStyle.ITALIC_LEFT:
				text.defaultTextFormat = _italicLeftFormat;
			case TextFieldStyle.ITALIC_RIGHT:
				text.defaultTextFormat = _italicRightFormat;
				
			case TextFieldStyle.UNDERLINE:
				text.defaultTextFormat = _underlineFormat;
			case TextFieldStyle.UNDERLINE_LEFT:
				text.defaultTextFormat = _underlineLeftFormat;
			case TextFieldStyle.UNDERLINE_RIGHT:
				text.defaultTextFormat = _underlineRightFormat;
				
			default:
				text = getTextField(TextFieldStyle.NAME);
		}
		
		return text;
	}
	
}