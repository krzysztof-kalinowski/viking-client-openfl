package com.taern.map.pathfinding {
public class Region {


	private var _id:int;
	private var _id_region:int;
	private var _name:String;
	private var _pk:Number;
	private var _action:Number;
	private var _background:Number;


	public function Region(msg:String = "") {
		if(msg != "") {
			var tab:Array = msg.split("$");
			_id_region = parseInt(tab[0]);
			_name = tab[1];
			_pk = parseInt(tab[2]);
			_id = parseInt(tab[3]);
			_action = parseInt(tab[4]);
			_background = parseInt(tab[5]);
		}

	}

	public function getDescription():String {
		switch(_pk) {
			case 0:
				return _name;
			case 1:
				return "<font color='#cc0000'>" + _name + "</font>";
			case 2:
				return "<font color='#00cc00'>" + _name + "</font>";
			case 3:
				return "<font color='#990099'>" + _name + "</font>";
			default:
				return _name;
		}
	}


	public function get id_region():int {
		return _id_region;
	}

	public function set id_region(value:int):void {
		_id_region = value;
	}

	public function get name():String {
		return _name;
	}

	public function set name(value:String):void {
		_name = value;
	}

	public function get pk():Number {
		return _pk;
	}

	public function set pk(value:Number):void {
		_pk = value;
	}

	public function get action():Number {
		return _action;
	}

	public function set action(value:Number):void {
		_action = value;
	}

	public function get background():Number {
		return _background;
	}

	public function set background(value:Number):void {
		_background = value;
	}

	public function get id():int {
		return _id;
	}

	public function set id(value:int):void {
		_id = value;
	}
}
}
