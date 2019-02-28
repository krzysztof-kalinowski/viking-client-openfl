/**
 * Created by flashdeveloper.pl on 2016-05-04.
 */
package com.taern.editor.mapping {
public class MappingTile {
	private var _x:Number;
	private var _y:Number;
	private var _z:Number;

	private var _atlasX:Number;
	private var _atlasY:Number;

	public function MappingTile() {
	}

	public function get x():Number {
		return _x;
	}

	public function set x(value:Number):void {
		_x = value;
	}

	public function get y():Number {
		return _y;
	}

	public function set y(value:Number):void {
		_y = value;
	}

	public function get z():Number {
		return _z;
	}

	public function set z(value:Number):void {
		_z = value;
	}


	public function get atlasX():Number {
		return _atlasX;
	}

	public function set atlasX(value:Number):void {
		_atlasX = value;
	}

	public function get atlasY():Number {
		return _atlasY;
	}

	public function set atlasY(value:Number):void {
		_atlasY = value;
	}

}
}
