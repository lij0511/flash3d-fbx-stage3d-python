package bloom {

	import com.adobe.utils.AGALMiniAssembler;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.Program3D;
	
	import flare.basic.Scene3D;
	import flare.core.Pivot3D;
	import flare.core.Surface3D;
	import flare.core.Texture3D;
	import flare.materials.Material3D;
	import flare.system.Device3D;

	public class BloomShader extends Material3D {
		
		private var bias			    : Vector.<Number> = Vector.<Number>([0, 0, 0, 0]);
		private var v0123			: Vector.<Number> = Vector.<Number>([0, 1, 2, 3]);
		private var _originTexture 	: Texture3D;
		private var _bloomTetxure  	: Texture3D;
		private var _program : Program3D;
		
		public function BloomShader(originTexture : Texture3D, bloomTexture : Texture3D, intensity : Number) {
			super("BloomShader");
			this._originTexture 	= originTexture;
			this._bloomTetxure	= bloomTexture;
			this.bias[0] 		= intensity;
		}
		
		override public function dispose():void {
			super.dispose();
			this._originTexture.dispose();
			this._originTexture = null;
			this._bloomTetxure.dispose();
			this._bloomTetxure = null;
		}
		
		override public function download():void {
			super.download();
			this._originTexture.download();
			this._bloomTetxure.download();
			this._program.dispose();
			this._program = null;
		}
		
		override public function draw(pivot:Pivot3D, surf:Surface3D, firstIndex:int=0, count:int=-1):void {
			if (this.scene == null) {
				upload(pivot.scene);
			}
			
			var context : Context3D = this.scene.context;
			context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
			context.setDepthTest(true, Context3DCompareMode.LESS_EQUAL);
			context.setCulling(Context3DTriangleFace.BACK);
			context.setProgram(_program);
			// 顶点buffer
			context.setVertexBufferAt(0, surf.vertexBuffer, surf.offset[Surface3D.POSITION], surf.format[Surface3D.POSITION]);
			context.setVertexBufferAt(1, surf.vertexBuffer, surf.offset[Surface3D.UV0], surf.format[Surface3D.UV0]);
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, Device3D.worldViewProj, true);
			// fragment
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, bias,    1);
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, v0123,   1);
			context.setTextureAt(0, _originTexture.texture);
			context.setTextureAt(1, _bloomTetxure.texture);
			context.drawTriangles(surf.indexBuffer, firstIndex, count);
			context.setVertexBufferAt(0, null);
			context.setVertexBufferAt(1, null);
			context.setTextureAt(0, null);
			context.setTextureAt(1, null);
			
			Device3D.drawCalls ++;
			Device3D.trianglesDrawn += count;
		}
		
		override public function upload(scene:Scene3D):void {
			super.upload(scene);
			
			if (_program != null) {
				return;
			}
			
			var vertexCode : String = 
				"m44 op, va0, vc0\n" +	
				"mov v0, va1\n";
			
			var fragCode : String =
				"mov ft0.xyzw, fc0.xxxy \n" +
				"tex ft1, v0, fs0 <2d, linear, miplinear, repeat> \n" +
				"tex ft2, v0, fs1 <2d, linear, miplinear, repeat> \n" +
				"mul ft2, ft2, fc1.x \n" +
				"add ft1, ft1, ft2\n" +
				"mov ft0, ft1 \n" +
				"mov oc, ft0 \n";
			
			this._program = scene.context.createProgram();
			var vertAgal : AGALMiniAssembler = new AGALMiniAssembler();
			vertAgal.assemble(Context3DProgramType.VERTEX, vertexCode);
			var fragagal : AGALMiniAssembler = new AGALMiniAssembler();
			fragagal.assemble(Context3DProgramType.FRAGMENT, fragCode);
			this._program.upload(vertAgal.agalcode, fragagal.agalcode);
		}
		
	}
}
