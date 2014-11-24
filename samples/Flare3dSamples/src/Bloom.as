package {
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	
	import bloom.BloomExtractShader;
	import bloom.BloomShader;
	import bloom.BlurShader;
	
	import flare.basic.Scene3D;
	import flare.core.Texture3D;
	import flare.materials.Shader3D;
	import flare.materials.filters.LightFilter;
	import flare.materials.filters.TextureMapFilter;
	import flare.primitives.Quad;

	public class Bloom extends Sprite {

		private var scene : Scene3D;
		
		/** 原图Texture */
		private var originalTexture 	: Texture3D;
		private var originalQuad 	: Quad;
		/** 高亮Texture */
		private var brightnessTexture: Texture3D;
		private var brightnessQuad	: Quad;
		/** hblue */
		private var hblurTexture	: Texture3D;
		private var hblurQuad	: Quad;
		/** vblur */
		private var vblurTexture	: Texture3D;
		private var vblurQuad	: Quad;
		/** final */
		private var finalTexture	: Texture3D;
		private var finalQuad	: Quad;
		
		public function Bloom() {

			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			var textField : TextField = new TextField();
			textField.htmlText = "<font size='16' color='#ff0000'>1:close\n2:open</font>";
			addChild(textField);

			scene = new Scene3D(this);
			scene.showLogo = false;
			
			scene.camera.setPosition(0, 0, -10);
			scene.camera.lookAt(0, 0, 0);
			scene.camera.far = 30000;
			scene.lights.techniqueName = LightFilter.NO_LIGHTS;
			
			scene.addChildFromFile("car.f3d");
			
			originalTexture 	= new Texture3D(new Point(1024, 1024), true);
			originalQuad		= new Quad("", 0, 0, 0, 0, true, new Shader3D("", [new TextureMapFilter(originalTexture)]));
			
			brightnessTexture  	= new Texture3D(new Point(256, 256), true);
			brightnessQuad    	= new Quad("", 0, 0, 0, 0, true, new BloomExtractShader(brightnessTexture, 1.0 / stage.stageWidth, 1.0 / stage.stageHeight)); 
			
			// hblur
			hblurTexture	= new Texture3D(new Point(256, 256), true);
			hblurQuad	= new Quad("", 0, 0, 0, 0, true, new BlurShader(hblurTexture, 4 / stage.stageWidth, 0));
			// vblue
			vblurTexture	= new Texture3D(new Point(256, 256), true);
			vblurQuad	= new Quad("", 0, 0, 0, 0, true, new BlurShader(vblurTexture, 0, 4 / stage.stageHeight));
			
			finalTexture	= new Texture3D(new Point(1024, 1024), true);
			finalQuad	= new Quad("", 0, 0, 0, 0, true, new BloomShader(originalTexture, finalTexture, 6.0));
			
			scene.addEventListener(Scene3D.POSTRENDER_EVENT, onRender);
			scene.addEventListener(Event.CONTEXT3D_CREATE,   checkError);
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		protected function onKeyDown(event:KeyboardEvent) : void {
			if (event.keyCode == Keyboard.NUMBER_1) {
				scene.removeEventListener(Scene3D.POSTRENDER_EVENT, onRender);
			} else if (event.keyCode == Keyboard.NUMBER_2) {
				scene.addEventListener(Scene3D.POSTRENDER_EVENT, onRender);
			}
		}
		
		protected function checkError(event:Event) : void {
			scene.context.enableErrorChecking = true;			
		}
		
		protected function onRender(event:Event) : void {
			
			hblurTexture.upload(scene);
			vblurTexture.upload(scene);
			finalTexture.upload(scene);
			originalTexture.upload(scene);
			brightnessTexture.upload(scene);
			
			scene.context.setRenderToTexture(originalTexture.texture, true, scene.antialias);
			scene.context.clear(0, 0, 0, 1);
			scene.render();
			scene.context.setRenderToBackBuffer();
			
			scene.context.setRenderToTexture(brightnessTexture.texture, true, scene.antialias);
			scene.context.clear(0, 0, 0, 1.0);
			originalQuad.draw();
			scene.context.setRenderToBackBuffer();
			
			scene.context.setRenderToTexture(hblurTexture.texture, true, scene.antialias);
			scene.context.clear(0, 0, 0, 1);
			brightnessQuad.draw();
			scene.context.setRenderToBackBuffer();
			
			scene.context.setRenderToTexture(vblurTexture.texture, true, scene.antialias);
			scene.context.clear(0, 0, 0, 1);
			hblurQuad.draw();
			scene.context.setRenderToBackBuffer();
			
			scene.context.setRenderToTexture(finalTexture.texture, true, scene.antialias);
			scene.context.clear(0, 0, 0, 1);
			vblurQuad.draw();
			scene.context.setRenderToBackBuffer();
			
			finalQuad.draw();
		}
	}
}
