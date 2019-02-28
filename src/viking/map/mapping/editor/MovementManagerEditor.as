/**
 * Created by flashdeveloper.pl on 2016-04-28.
 */
package com.taern.editor.mapping {
import com.taern.map.MapManager3D;
import com.taern.map.pathfinding.MovementManager;

public class MovementManagerEditor extends MovementManager {
	public function MovementManagerEditor() {
		super();
	}

	public static function getInstance():MovementManagerEditor {
		return MovementManagerEditor(_instance);
	}


	override public function initMapping(idArea:int = 209):void {
		if(_idArea != idArea) {
			if(_mapping) {
				_mapping = null;
			}

			_idArea = idArea;
			_mapping = MappingEditor.getInstance();
			_mapping.loadMappingData(_idArea);
		}
		else {
			MapManager3D.getInstance().onMappingReady();
		}
	}
}
}
