package  {

	import flare.core.Pivot3D;
	import flare.materials.Shader3D;
	import flare.materials.filters.ColorFilter;
	import flare.primitives.Cone;
	import flare.primitives.Cube;

	public class Trident extends Pivot3D {
		public function Trident(name : String = "Trident") {
			super(name);
			
			var xcube : Cube = new Cube('xAxis', 100, 1, 1, 1, new Shader3D('',[new ColorFilter(0xff0000)]));
			xcube.x = 50;
//			xcube.shader.depthWrite = false;
			var xCone : Cone = new Cone('xCone', 5, 0, 10, 12, new Shader3D('',[new ColorFilter(0xff0000)]));
			xCone.x = 100;
			xCone.rotateZ(-90);
//			xCone.shader.depthWrite = false;
			addChild(xCone);
			addChild(xcube);
			
			var ycube : Cube = new Cube('xAxis', 1, 100, 1, 1, new Shader3D('',[new ColorFilter(0x00ff00)]));
			ycube.y = 50;
//			ycube.shader.depthWrite = false;
			var yCone : Cone = new Cone('xCone', 5, 0, 10, 12, new Shader3D('',[new ColorFilter(0x00ff00)]));
			yCone.y = 100;
//			yCone.shader.depthWrite = false;
			addChild(ycube);
			addChild(yCone);
			
			var zcube : Cube = new Cube('xAxis', 1, 1, 100, 1, new Shader3D('',[new ColorFilter(0x0000ff)]));
			zcube.z = 50;
//			zcube.shader.depthWrite = false;
			var zCone : Cone = new Cone('xCone', 5, 0, 10, 12, new Shader3D('',[new ColorFilter(0x0000ff)]));
			zCone.z = 100;
//			zCone.shader.depthWrite = false;
			zCone.rotateX(90);
			addChild(zcube);
			addChild(zCone);
		}
	}
}
