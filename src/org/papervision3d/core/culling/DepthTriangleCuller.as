package org.papervision3d.core.culling
{
	import org.papervision3d.core.geom.Vertex2D;
	import org.papervision3d.core.geom.Face3D;

	public class DepthTriangleCuller implements ITriangleCuller
	{
		
		public function DepthTriangleCuller()
		{
			
		}
		
		public function testFace(faceInstance:Face3D, vertex0:Vertex2D, vertex1:Vertex2D, vertex2:Vertex2D):Boolean
		{
			
			return false;
		}
		
	}
}