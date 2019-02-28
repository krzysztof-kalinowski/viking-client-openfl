/**
 * Created by flashdeveloper.pl on 2016-05-04.
 */
package com.taern.editor.mapping {

import away3d.core.base.CompactSubGeometry;
import away3d.core.base.Geometry;
import away3d.entities.Mesh;
import away3d.materials.TextureMaterial;

public class MappingMesh extends Mesh {

	private var vertexData:Vector.<Number> = new Vector.<Number>();
	private var indexData:Vector.<uint> = new Vector.<uint>();

	private var _subGeometry:CompactSubGeometry;
	private var _mappingRenderer:MappingRenderer;

	public function MappingMesh(atlasMaterial:TextureMaterial) {
		super(new Geometry(), atlasMaterial);

		_subGeometry = new CompactSubGeometry();
		_subGeometry.autoDeriveVertexNormals = true;
		_subGeometry.autoDeriveVertexTangents = true;
		geometry.addSubGeometry(_subGeometry);

		this.castsShadows = false;

		_mappingRenderer = new MappingRenderer(atlasMaterial);
	}

	public function updateMapping(mapingTilesVector:Vector.<MappingTile>):void {
		_mappingRenderer.fillBatched(vertexData, indexData, mapingTilesVector);

		_subGeometry.updateData(vertexData);
		_subGeometry.updateIndexData(indexData);
	}


}
}
