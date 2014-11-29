package {

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	import core.scene.Scene3D;
	import core.utils.Device3D;

	public class Samples extends Sprite {
		
		private var scene : Scene3D;
	
		public function Samples() {
			
			stage.scaleMode 	= StageScaleMode.NO_SCALE;
			stage.align		= StageAlign.TOP_LEFT;
						
			scene = new Scene3D(this);
			scene.backgroundColor = 0x123456;
			scene.antialias = 4;
			scene.camera.z = -150;
			scene.camera.y = 250;
			scene.camera.lookAt(0, 0, 0);
			
			var test0 : SceneLoader = new SceneLoader(PathUtil.dirName(this.loaderInfo.url) + "/" + "test0/Test22.scene");
			test0.load();
			scene.addChild(test0);
			
			var test1 : SceneLoader = new SceneLoader(PathUtil.dirName(this.loaderInfo.url) + "/" + "test1/nvhai.scene");
			test1.load();
			scene.addChild(test1);
			
			Device3D.debug = false;
			
			scene.addEventListener(Event.CONTEXT3D_CREATE, onCreate);
		}
		
		protected function onCreate(event:Event) : void {
			scene.context.enableErrorChecking = true;
			trace(scene.context.driverInfo);
		}
		
	}
}
