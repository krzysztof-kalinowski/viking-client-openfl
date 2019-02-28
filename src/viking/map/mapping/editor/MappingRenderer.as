/**
 * Created by flashdeveloper.pl on 2016-05-04.
 */
package com.taern.editor.mapping {

import away3d.materials.TextureMaterial;

import com.taern.map.pathfinding.Tile;
import com.taern.utils.settings.Settings;

public class MappingRenderer {

	public static const MAX_TILES_PER_MESH:int = 4000;

	private var mFontMaterial:TextureMaterial;


	public function MappingRenderer(atlasMaterial:TextureMaterial = null) {
		mFontMaterial = atlasMaterial;
	}


	public function fillBatched(data:Vector.<Number>, indices:Vector.<uint>, mappingTilesVector:Vector.<MappingTile>):void {

		data.length = 0;
		indices.length = 0;

		var k:int = 0;
		var indicesCount:int = 0;
		var numChars:int = mappingTilesVector.length;

		for(var i:int = 0; i < numChars; i++) {
			indices[indicesCount++] = i * 4;
			indices[indicesCount++] = i * 4 + 1;
			indices[indicesCount++] = i * 4 + 2;

			indices[indicesCount++] = i * 4;
			indices[indicesCount++] = i * 4 + 2;
			indices[indicesCount++] = i * 4 + 3;

			var mappingTile:MappingTile = mappingTilesVector[i];

			var x:Number = mappingTile.x;
			var y:Number = mappingTile.y;
			var z:Number = mappingTile.z;

			var width:Number = Tile.SIZE * Settings.ORTOGRAPHIC_CONVERSION_FACTOR_WIDTH;
			var height:Number = Tile.SIZE * Settings.ORTOGRAPHIC_CONVERSION_FACTOR_HEIGHT;

			var u1:Number = mappingTile.atlasX / mFontMaterial.texture.width;
			var u2:Number = (mappingTile.atlasX + Tile.SIZE) / mFontMaterial.texture.width;
			var v1:Number = mappingTile.atlasY / mFontMaterial.texture.height;
			var v2:Number = (mappingTile.atlasY + Tile.SIZE) / mFontMaterial.texture.height;


			/**
			 * CompactSubGeometry Updates the vertex data. All vertex properties are contained in a single Vector, and the order is as follows:
			 * 0 - 2: vertex position X, Y, Z
			 * 3 - 5: normal X, Y, Z
			 * 6 - 8: tangent X, Y, Z
			 * 9 - 10: U V
			 * 11 - 12: Secondary U V
			 */

				//1
			data[k++] = x;
			data[k++] = y;
			data[k++] = z + height;
			//n
			data[k++] = 0;
			data[k++] = 0;
			data[k++] = 0;
			//t
			data[k++] = 0;
			data[k++] = 0;
			data[k++] = 0;
			//uv
			data[k++] = u1;
			data[k++] = v1;
			//seconduv
			data[k++] = 0;
			data[k++] = 0;

			//2
			data[k++] = x + width;
			data[k++] = y;
			data[k++] = z + height;
			//n
			data[k++] = 0;
			data[k++] = 0;
			data[k++] = 0;
			//t
			data[k++] = 0;
			data[k++] = 0;
			data[k++] = 0;
			//uv
			data[k++] = u2;
			data[k++] = v1;
			//seconduv
			data[k++] = 0;
			data[k++] = 0;

			//3
			data[k++] = x + width;
			data[k++] = y;
			data[k++] = z;
			//n
			data[k++] = 0;
			data[k++] = 0;
			data[k++] = 0;
			//t
			data[k++] = 0;
			data[k++] = 0;
			data[k++] = 0;
			//uv
			data[k++] = u2;
			data[k++] = v2;
			//seconduv
			data[k++] = 0;
			data[k++] = 0;

			//4
			data[k++] = x;
			data[k++] = y;
			data[k++] = z;
			//n
			data[k++] = 0;
			data[k++] = 0;
			data[k++] = 0;
			//t
			data[k++] = 0;
			data[k++] = 0;
			data[k++] = 0;
			//uv
			data[k++] = u1;
			data[k++] = v2;
			//seconduv
			data[k++] = 0;
			data[k++] = 0;

		}

	}


}
}
