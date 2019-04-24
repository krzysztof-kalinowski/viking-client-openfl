package viking.test;
import openfl.display.Sprite;
import openfl.text.TextField;
import viking.text.TextFactory;
import viking.text.TextFieldStyle;

/**
 * ...
 * @author Krzysiek Kalinowski
 */
class TestFonts extends Sprite 
{

	public function new() 
	{
		super();
		testTextFields();
	}
	
	private function testTextFields():Void 
	{
		var text_width:Float = 400.0;
		
		var baseX:Float = 100.0;
		var baseY:Float = 100.0;
		var dY:Float = 45.0;
		var dX:Float = 15.0;
		
		var previous:TextField = null;
		var counter:Int = 0;
		var counter_max:Int = 6;
		
		for (str in TextFieldStyle.allStyles) 
		{
			var text:TextField = TextFactory.getInstance().getTextField(str);
			text.width = text_width;
			addChild(text);
			
			if (previous == null) {
				text.y = baseY;
			} else {
				text.y = previous.y + dY;
			}
			text.x = baseX;
			
			text.text = str + ": ĄŚĆŃÓŁąśćńó123!@#$%^&*()[]";
			text.textColor = 0xDDDDDD;
			
			previous = text;
			
			counter++;
			if (counter >= counter_max)
			{
				counter = 0;
				baseX += text_width + dX;
				previous = null;
			}
			
		}
		
	}
	
}