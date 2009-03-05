package org.papervision3d.core.geom
{
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.core.Number3D;
	
	public class Face3DInstance
	{
		
		public var face:Face3D;
		public var instance:DisplayObject3D;
		public var visible:Boolean = false;
		public var screenZ:Number;
		public var faceNormal:Number3D;
		
		public function Face3DInstance(face:Face3D, instance:DisplayObject3D = null)
		{
			this.face = face;
			this.instance = instance;
		}
		
	}
}