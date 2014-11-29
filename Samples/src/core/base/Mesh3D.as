package core.base {

	import flash.geom.Vector3D;
	
	import core.render.DefaultRender;
	import core.render.FrameRender;
	import core.scene.Scene3D;
	import core.shader.Shader3D;
	import core.utils.Device3D;

	/**
	 * mesh3d，所有可绘制模型均继承于他或者由它构建。
	 * @author neil
	 */
	public class Mesh3D extends Pivot3D {

		private static const CLICK 		: int = 1 << 6;
		private static const MOUSE_DOWN 	: int = 1 << 7;
		private static const MOUSE_MOVE 	: int = 1 << 8;
		private static const MOUSE_OUT 	: int = 1 << 9;
		private static const MOUSE_OVER 	: int = 1 << 10;
		private static const MOUSE_UP 	: int = 1 << 11;
		private static const MOUSE_WHELL	: int = 1 << 12;
		
		private static var refaultRender	: DefaultRender = new DefaultRender();
		private static var boundsScale	: Vector3D = new Vector3D();
		private static var boundsCenter	: Vector3D = new Vector3D();
		private static var boundsRawData	: Vector.<Number> = new Vector.<Number>(16, true);
		
		public var geometries			: Vector.<Geometry3D>;		// 子mesh
		public var mouseEnabled			: Boolean = true;			// 启用鼠标
		
		protected var _render 			: DefaultRender;				// 渲染器
		protected var _bounds 			: Bounds3D;					// bounds
		protected var _inViewAlways 		: Boolean = false;			// 总是显示
		
		private var _inView 				: Boolean = false;			// inview
		private var _boundsCenter 		: Vector3D;					// 包围盒中心点
		private var _boundsRadius 		: Number = 1;				// 包围盒半径
		private var _updateBoundsScale 	: Boolean = true;			// 是否更新包围盒
		
		public function Mesh3D(name : String = "") {
			super(name);
			this.geometries		= new Vector.<Geometry3D>();
			this._boundsCenter 	= new Vector3D();
			this._render 		= refaultRender;
		}
		
		public function get render() : DefaultRender {
			return _render;
		}
		
		public function set render(value : DefaultRender) : void {
			if (value == null) {
				return;
			}
			_render = value;
			if (value is FrameRender) {
				var fr : FrameRender = value as FrameRender;
				this.frames = fr.frames;
			} else if (value is SkeletonRender) {
				var sr : SkeletonRender = value as SkeletonRender;
				this.frames = new Vector.<Frame3D>();
				for (var i:int = 0; i < sr.totalFrames; i++) {
					this.frames.push(new Frame3D(null, Frame3D.TYPE_NULL));
				}
			}
		}
		
		override public function dispose() : void {
			this._bounds = null;
			this._render = null;
			var i : int  = 0;
			while (i < this.geometries.length) {
				if (this.geometries[i] != null) {
					this.geometries[i].dispose();
				}
				i++;
			}
			this.geometries = null;
			super.dispose();
		}
				
		/**
		 * 上传
		 * @param scene
		 * @param includeChildren
		 *
		 */
		override public function upload(scene : Scene3D, includeChildren : Boolean = true) : void {
			super.upload(scene, includeChildren);
			for each (var geo : Geometry3D in this.geometries) {
				geo.upload(scene);
			}
		}
		
		/**
		 * 卸载
		 * @param includeChildren
		 *
		 */
		override public function download(includeChildren : Boolean = true) : void {
			super.download();
			for each (var geo : Geometry3D in this.geometries) {
				geo.download();
			}
		}
		
		/**
		 *  更新bounds
		 */		
		public function updateBoundings() : void {
			this._bounds = null;
			this._bounds = this.bounds;
		}
		
		public function get bounds() : Bounds3D {
			return this._bounds;
		}
		
		public function set bounds(value : Bounds3D) : void {
			this._bounds = value;
		}
		
		override public function updateTransforms(includeChildren : Boolean = false) : void {
			super.updateTransforms(includeChildren);
			this._updateBoundsScale = true;
		}
		
		public function set alwaysInview(value : Boolean) : void {
			this._inViewAlways = value;
		}
		
		public function get alwaysInview() : Boolean {
			return this._inViewAlways;
		}

		override public function draw(includeChildren : Boolean = true, shaderBase : Shader3D = null) : void {
			if (this._scene == null) {
				this._scene = Device3D.scene;
			}
			this._render.draw(this, shaderBase);
			if (includeChildren) {
				var i : int = children.length - 1;
				while (i >= 0) {
					children[i].draw(true, shaderBase);
					i--;
				}
			}
		}
	}
}
