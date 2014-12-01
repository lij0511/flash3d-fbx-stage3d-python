package {

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	import core.base.Mesh3D;
	import core.loader.SceneLoader;
	import core.scene.Scene3D;
	import core.utils.Device3D;

	public class Samples extends Sprite {
		
		private var scene : Scene3D;
		
		public function Samples() {
			
			stage.scaleMode 	= StageScaleMode.NO_SCALE;
			stage.align		= StageAlign.TOP_LEFT;
			stage.frameRate	= 60;
			
			addChild(new L3DStats());
			
			scene = new Scene3D(this);
			scene.backgroundColor = 0x123456;
			scene.antialias = 4;
			scene.camera.z = -1500;
			scene.camera.y = 1500;
			scene.camera.lookAt(0, 0, 0);
			
			var test0 : SceneLoader = new SceneLoader(PathUtil.dirName(this.loaderInfo.url) + "/" + "test0/Test22.scene");
			test0.addEventListener("CameraEvent", onLoadCamera);
			test0.load();
			scene.addChild(test0);
			
			var test1 : SceneLoader = new SceneLoader(PathUtil.dirName(this.loaderInfo.url) + "/" + "test1/akali.scene");
			test1.addEventListener("MeshEvent", onSkeMeshComplete);
			test1.load();
			scene.addChild(test1);
			
			Device3D.debug = false; 
			
			scene.addEventListener(Event.CONTEXT3D_CREATE, onCreate);
		}
		
		protected function onSkeMeshComplete(event:MeshEvent) : void {
			var mesh : Mesh3D = 	event.mesh;
			var num  : int = 50;
			for (var i:int = 0; i < num; i++) {
				for (var j:int = 0; j < num; j++) {
					var clone : Mesh3D = mesh.clone();
					clone.x = (i - num / 2) * 100;
					clone.z = (j - num / 2) * 100;
					scene.addChild(clone);
					clone.play();
				}
			}
			
		}
		
		protected function onLoadCamera(event:CameraEvent) : void {
			trace(event.camera.frames.length);
			event.camera.play();
			scene.addChild(event.camera);
//			scene.camera = event.camera;
		}
		
		protected function onCreate(event:Event) : void {
			scene.context.enableErrorChecking = true;
			trace(scene.context.driverInfo);
		}
		
	}
}
