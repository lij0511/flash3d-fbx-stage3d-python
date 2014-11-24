package {

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import flare.basic.Scene3D;
	import flare.basic.Viewer3D;
	import flare.core.Frame3D;
	import flare.core.Mesh3D;
	import flare.core.Pivot3D;
	import flare.core.Surface3D;
	import flare.materials.Shader3D;
	import flare.materials.filters.ColorFilter;
	import flare.primitives.Cube;
	import flare.primitives.Sphere;
	import flare.utils.Matrix3DUtils;
	
	public class FbxParser extends Sprite {
		
//		[Embed(source="teapot_Teapot001.mesh", mimeType="application/octet-stream")]
		[Embed(source="Test2_Teapot001.mesh", mimeType="application/octet-stream")]
		private var MeshData : Class;  
//		[Embed(source="teapot_Teapot001.anim", mimeType="application/octet-stream")]
		[Embed(source="Test2_Teapot001.anim", mimeType="application/octet-stream")]
		private var AnimData : Class;
		[Embed(source="Test22_.camera", mimeType="application/octet-stream")]
		private var CameraData : Class;
		
		private var scene	: Scene3D;
		private var identity	: Pivot3D;     
		  
		public function FbxParser() {   
			  
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			 
			scene = new Viewer3D(this);
			scene.camera.far = 10000;
			scene.camera.z = -100;
			 
			var mesh : Mesh3D = readMesh(new MeshData());
			mesh.frames = readAnim(new AnimData());			// what the fucking bug
			mesh.addEventListener(Pivot3D.ENTER_FRAME_EVENT, onUpdate);
						 
			identity = createIdentity();
			
			parseCamera(new CameraData());
						
			scene.addChild(mesh); 
			scene.addChild(new Trident());
			scene.addChild(new Grid3D(21, 21, 10));
		}
				
		private function parseCamera(bytes : ByteArray) : void {
			bytes.endian = Endian.LITTLE_ENDIAN;
			bytes.uncompress();
			
			var len : int = bytes.readInt();
			var name : String = bytes.readUTFBytes(len);
			
			var w : Number = bytes.readFloat();
			var h : Number = bytes.readFloat();
			var near : Number = bytes.readFloat();
			var far  : Number = bytes.readFloat();
			var fieldOfView : Number = bytes.readFloat();
			
			scene.camera.near = near;
			scene.camera.far  = far;
			scene.camera.fieldOfView = fieldOfView;
			
			var vec : Vector3D = new Vector3D();
			// 读取相机位置
			for (var j:int = 0; j < 3; j++) {
				vec.x = bytes.readFloat();				
				vec.y = bytes.readFloat();	
				vec.z = bytes.readFloat();	
				vec.w = bytes.readFloat();	
				scene.camera.transform.copyRowFrom(j, vec);
			}
			// 读取相机动画          
			len = bytes.readInt();
			scene.camera.frames = new Vector.<Frame3D>();
			identity.frames = new Vector.<Frame3D>();
			for (var i:int = 0; i < len; i++) {
				var frame : Frame3D = new Frame3D();
				for (var n:int = 0; n < 3; n++) {
					vec.x = bytes.readFloat();				
					vec.y = bytes.readFloat();	
					vec.z = bytes.readFloat();	
					vec.w = bytes.readFloat();	
					frame.copyRowFrom(n, vec);
				}
				identity.frames.push(frame);
				scene.camera.frames.push(frame);  
			}
			
			scene.camera.addEventListener(Pivot3D.ENTER_FRAME_EVENT, onCameraUpdate);
		}
		  
		protected function createIdentity() : Pivot3D {
			var cube : Cube = new Cube("", 10, 10, 100);
			var sp : Sphere = new Sphere();
			sp.z = 50;
			cube.addChild(sp);
			var cu : Cube = new Cube();
			cu.y = 10;
			cube.addChild(cu);
			
			return cube;
		}
		
		protected function onCameraUpdate(event:Event) : void {
			scene.camera.currentFrame += 1;		
			if (scene.camera.currentFrame >= scene.camera.frames.length - 1) {
				scene.camera.currentFrame = 0;
			}
		}
		
		protected function onUpdate(event:Event) : void {
			var mesh : Mesh3D = event.target as Mesh3D;
			mesh.currentFrame += 1;
			if (mesh.currentFrame >= mesh.frames.length -1) {
				mesh.currentFrame = 0;
			}
		}
		
		private function readAnim(bytes : ByteArray) : Vector.<Frame3D> {
			bytes.uncompress();
			bytes.endian = Endian.LITTLE_ENDIAN;
			
			var frames : Vector.<Frame3D> = new Vector.<Frame3D>();
			
			var type : int = bytes.readInt();
			var num  : int = bytes.readInt();
			var vec  : Vector3D = new Vector3D();
			var axis : Matrix3D = new Matrix3D();
			Matrix3DUtils.setRotation(axis, 90, 0, 0);
			
			for (var i:int = 0; i < num; i++) {
				var frame : Frame3D = new Frame3D();
				for (var j:int = 0; j < 3; j++) {
					vec.x = bytes.readFloat();				
					vec.y = bytes.readFloat();	
					vec.z = bytes.readFloat();	
					vec.w = bytes.readFloat();	
					frame.copyRowFrom(j, vec);
				}
				frames.push(frame);
			}
			
			return frames;
		}
		    
		private function readMesh(bytes : ByteArray) : Mesh3D {
			var mesh : Mesh3D = new Mesh3D();
			// 小头解压    
			bytes.uncompress(); 
			bytes.endian = Endian.LITTLE_ENDIAN;
			var len : int = 0;
			// 名称
			len = bytes.readInt();
			mesh.name = bytes.readUTFBytes(len);
			// 读取localMatrix
			var vec   : Vector3D = new Vector3D();
			for (var j:int = 0; j < 3; j++) {
				vec.x = bytes.readFloat();				
				vec.y = bytes.readFloat();	
				vec.z = bytes.readFloat();	
				vec.w = bytes.readFloat();	
				mesh.transform.copyRowFrom(j, vec);
			}
			// 顶点
			len = bytes.readInt();
			var vertexBytes : ByteArray = new ByteArray();
			vertexBytes.endian = Endian.LITTLE_ENDIAN;
			bytes.readBytes(vertexBytes, 0, len * 3 * 4);
			// 顶点
			var vertexSurf : Surface3D = new Surface3D();
			vertexSurf.addVertexData(Surface3D.POSITION, 3);
			vertexSurf.vertexBytes = vertexBytes;
			// uv0 
			len = bytes.readInt();
			if (len != 0) {
				var uv0Bytes : ByteArray = new ByteArray();
				uv0Bytes.endian = Endian.LITTLE_ENDIAN;
				bytes.readBytes(uv0Bytes, 0, len * 2 * 4);
				// uv sufr
				var uv0Sufr : Surface3D = new Surface3D();
				uv0Sufr.addVertexData(Surface3D.UV0, 2);
				uv0Sufr.vertexBytes = uv0Bytes;
				vertexSurf.sources[Surface3D.UV0] = uv0Sufr;
			}
			// uv1  
			len = bytes.readInt();
			if (len != 0) {
				bytes.readBytes(new ByteArray(), 0, len * 2 * 4);
			}
			// 法线
			len = bytes.readInt();
			if (len != 0) {
				var normalBytes : ByteArray = new ByteArray();  
				normalBytes.endian = Endian.LITTLE_ENDIAN;
				bytes.readBytes(normalBytes, 0, len * 3 * 4);
				
				var normalSurf : Surface3D = new Surface3D();
				normalSurf.addVertexData(Surface3D.NORMAL, 3);
				normalSurf.vertexBytes = normalBytes;
				vertexSurf.sources[Surface3D.NORMAL] = normalSurf;
			}
			vertexSurf.material = new Shader3D("", [new ColorFilter(0xFF0000)]);
			
			mesh.surfaces.push(vertexSurf);
			
			return mesh;
		}
	}
}
