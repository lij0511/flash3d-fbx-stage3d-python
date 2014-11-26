package {
	
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import L3D.core.base.Bounds3D;
	import L3D.core.base.Geometry3D;
	import L3D.core.entities.Mesh3D;
	import L3D.core.light.DirectionalLight;
	import L3D.core.materials.Shader3D;
	import L3D.core.materials.filters.ColorFilter;
	import L3D.core.materials.filters.SkeletonFilterQuat;
	import L3D.core.materials.filters.light.DirectionalLightFilter;
	import L3D.core.render.DefaultRender;
	import L3D.core.render.SkeletonRenderFast;

	/**
	 * 模型工具 
	 * @author Neil
	 * 
	 */	
	public class Mesh3DUtils {
		
		public function Mesh3DUtils() {
			throw new Error("无法实例化MeshUtils");	
		}
		
		/**
		 * 读取Mesh 
		 * @param bytes
		 * @return 
		 * 
		 */		
		public static function readMesh(bytes : ByteArray) : Mesh3D {
			
			bytes.endian = Endian.LITTLE_ENDIAN;
			bytes.uncompress();
			
			var mesh : Mesh3D = new Mesh3D();
			// 读取Mesh名称
			var size : int = bytes.readInt();
			mesh.name = bytes.readUTFBytes(size);
			// 读取坐标
			var vec   : Vector3D = new Vector3D();
			for (var j:int = 0; j < 3; j++) { 
				vec.x = bytes.readFloat();		 		
				vec.y = bytes.readFloat();	 
				vec.z = bytes.readFloat();	 
				vec.w = bytes.readFloat();	 
				mesh.transform.copyRowFrom(j, vec);
			}  
			// 读取SubMesh数量
			var subCount : int = bytes.readInt();
			for (var subIdx : int = 0; subIdx < subCount; subIdx++) {
				// 读取顶点长度
				var len : int = bytes.readInt();
				var vertBytes : ByteArray = new ByteArray();
				vertBytes.endian = Endian.LITTLE_ENDIAN;
				bytes.readBytes(vertBytes, 0, len * 12);
				// 顶点geometry
				var subGeometry : Geometry3D = new Geometry3D();
				subGeometry.setVertexDataType(Geometry3D.POSITION, 3);
				subGeometry.vertexBytes = vertBytes;
				// uv0
				len = bytes.readInt();
				if (len > 0) {
					var uv0Bytes : ByteArray = new ByteArray();
					uv0Bytes.endian = Endian.LITTLE_ENDIAN;
					bytes.readBytes(uv0Bytes, 0, len * 8);
					subGeometry.sources[Geometry3D.UV0] = new Geometry3D();
					subGeometry.sources[Geometry3D.UV0].setVertexDataType(Geometry3D.UV0, 2);
					subGeometry.sources[Geometry3D.UV0].vertexBytes = uv0Bytes;
				}
				// uv1
				len = bytes.readInt();
				if (len > 0) {
					var uv1Bytes : ByteArray = new ByteArray();
					uv1Bytes.endian = Endian.LITTLE_ENDIAN;
					bytes.readBytes(uv1Bytes, 0, len * 8);
					subGeometry.sources[Geometry3D.UV1] = new Geometry3D();
					subGeometry.sources[Geometry3D.UV1].setVertexDataType(Geometry3D.UV1, 2);
					subGeometry.sources[Geometry3D.UV1].vertexBytes = uv1Bytes; 
				}
				// normal
				len = bytes.readInt();
				if (len > 0) {
					var normalBytes : ByteArray = new ByteArray();  
					normalBytes.endian = Endian.LITTLE_ENDIAN;
					bytes.readBytes(normalBytes, 0, len * 12);
					subGeometry.sources[Geometry3D.NORMAL] = new Geometry3D();
					subGeometry.sources[Geometry3D.NORMAL].setVertexDataType(Geometry3D.NORMAL, 3);
					subGeometry.sources[Geometry3D.NORMAL].vertexBytes = normalBytes; 
				}
				// 权重数据
				len = bytes.readInt();
				if (len > 0) {
					var weightBytes : ByteArray = new ByteArray();
					weightBytes.endian = Endian.LITTLE_ENDIAN;
					bytes.readBytes(weightBytes, 0, len * 16);
					subGeometry.sources[Geometry3D.SKIN_WEIGHTS] = new Geometry3D();
					subGeometry.sources[Geometry3D.SKIN_WEIGHTS].setVertexDataType(Geometry3D.SKIN_WEIGHTS, 4);
					subGeometry.sources[Geometry3D.SKIN_WEIGHTS].vertexBytes = weightBytes;
				}
				// 骨骼索引
				len = bytes.readInt();
				if (len > 0) {
					var indicesBytes : ByteArray = new ByteArray();
					indicesBytes.endian = Endian.LITTLE_ENDIAN;
					bytes.readBytes(indicesBytes, 0, len * 16);
					subGeometry.sources[Geometry3D.SKIN_INDICES] = new Geometry3D();
					subGeometry.sources[Geometry3D.SKIN_INDICES].setVertexDataType(Geometry3D.SKIN_INDICES, 4);
					subGeometry.sources[Geometry3D.SKIN_INDICES].vertexBytes = indicesBytes;
				}
				
				subGeometry.shader = new Shader3D("", [new ColorFilter(0xFF0000), new SkeletonFilterQuat(), new DirectionalLightFilter(new DirectionalLight())]);
//				subGeometry.shader = new Shader3D("", [new ColorFilter(0xFF0000), new DirectionalLightFilter(new DirectionalLight())]);
				
				// submesh
				mesh.geometries.push(subGeometry);
			}
			
			var bounds : Bounds3D = new Bounds3D();
			bounds.min.x = bytes.readFloat();
			bounds.min.y = bytes.readFloat();
			bounds.min.z = bytes.readFloat();
			bounds.max.x = bytes.readFloat();
			bounds.max.y = bytes.readFloat();
			bounds.max.z = bytes.readFloat();
			
			for each (var geo : Geometry3D in mesh.geometries) {
				geo.bounds = bounds;
			}
			
			return mesh;
		}
		
		/**
		 * 读取动画 
		 * @param bytes
		 * @return 
		 * 
		 */		
		public static function readAnim(bytes : ByteArray) : DefaultRender {
			bytes.uncompress();
			bytes.endian = Endian.LITTLE_ENDIAN;
			
			var render : SkeletonRenderFast = new SkeletonRenderFast();
			
			var type : int = bytes.readInt();
			var num  : int = bytes.readInt();
			
			for (var i:int = 0; i < num; i++) {
				render.skinData[i] = [];
				var frameCount : int = bytes.readInt();
				var boneNum    : int = bytes.readInt();
				render.totalFrames = frameCount;
				render.quat = type == 2;
				render.skinBoneNum[i] = Math.ceil(render.quat ? boneNum * 1 : boneNum * 1.5);
				
				var tempVec : Vector3D = new Vector3D();
				var tempMat : Matrix3D = new Matrix3D();
				
				for (var j:int = 0; j < frameCount; j++) {
					var frameData : Vector.<Number> = null;
					if (render.quat) {
						frameData = new Vector.<Number>(boneNum * 8, true);
					} else {
						frameData = new Vector.<Number>(boneNum * 12, true);
					}
					for (var k:int = 0; k < boneNum; k++) {
						if (render.quat) {
							frameData[k * 8 + 0] = bytes.readFloat();
							frameData[k * 8 + 1] = bytes.readFloat();
							frameData[k * 8 + 2] = bytes.readFloat();
							frameData[k * 8 + 3] = bytes.readFloat();
							frameData[k * 8 + 4] = bytes.readFloat();
							frameData[k * 8 + 5] = bytes.readFloat();
							frameData[k * 8 + 6] = bytes.readFloat();
							frameData[k * 8 + 7] = bytes.readFloat();
						} else {
							for (var m:int = 0; m < 3; m++) {
								tempVec.x = bytes.readFloat();				
								tempVec.y = bytes.readFloat();	
								tempVec.z = bytes.readFloat();	 
								tempVec.w = bytes.readFloat();	
								tempMat.copyRowFrom(m, tempVec);  
							}
							frameData[k * 12 + 0] = tempMat.rawData[0];
							frameData[k * 12 + 1] = tempMat.rawData[4];
							frameData[k * 12 + 2] = tempMat.rawData[8];
							frameData[k * 12 + 3] = tempMat.rawData[12];
							
							frameData[k * 12 + 4] = tempMat.rawData[1];
							frameData[k * 12 + 5] = tempMat.rawData[5];
							frameData[k * 12 + 6] = tempMat.rawData[9];
							frameData[k * 12 + 7] = tempMat.rawData[13];
							
							frameData[k * 12 + 8] = tempMat.rawData[2];
							frameData[k * 12 + 9] = tempMat.rawData[6];
							frameData[k * 12 + 10] = tempMat.rawData[10];
							frameData[k * 12 + 11] = tempMat.rawData[14];
						}
					}
					render.skinData[i][j] = frameData;
				}
				
			}
			
			return render;
		}
	}
}
