package core.render {

	import flash.utils.ByteArray;
	
	import core.base.Geometry3D;
	import core.base.Mesh3D;
	import core.shader.Shader3D;
	import core.utils.Device3D;

	public class SkeletonRender extends DefaultRender {
		
		public var quat : Boolean;
		public var skinData 		: Vector.<Array> = new Vector.<Array>();
		public var skinBoneNum 	: Vector.<int> 	= new Vector.<int>();
		public var totalFrames:int;
		
		public function SkeletonRender() {
			super();
		}
		
		override public function draw(mesh:Mesh3D, shader:Shader3D=null):void {
			
			Device3D.world.copyFrom(mesh.world);
			Device3D.worldViewProj.copyFrom(Device3D.world);
			Device3D.worldViewProj.append(Device3D.viewProj);
			Device3D.objectsDrawn++;
			
			for (var i:int = 0; i < mesh.geometries.length; i++) {
				var geometry : Geometry3D = mesh.geometries[i];
				Device3D.boneNum = skinBoneNum[i];
				Device3D.bonesMatrices = skinData[i][int(mesh.currentFrame)];
				var retShader : Shader3D = (shader == null ? geometry.shader : shader);
				retShader.draw(mesh, geometry, geometry.firstIndex, geometry.numTriangles);
			}
			
		}
		
	}
}
