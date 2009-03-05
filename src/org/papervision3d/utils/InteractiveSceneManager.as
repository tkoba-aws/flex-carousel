/**
* ...
* @author John Grden
* @version 0.1
*/

package org.papervision3d.utils 
{
	import com.blitzagency.xray.logger.XrayLog;
	
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	import org.papervision3d.core.geom.Mesh3D;
	import org.papervision3d.core.proto.CameraObject3D;
	import org.papervision3d.core.proto.SceneObject3D;
	import org.papervision3d.events.InteractiveScene3DEvent;
	import org.papervision3d.objects.DisplayObject3D;
	import flash.events.Event;

	public class InteractiveSceneManager extends EventDispatcher
	{
		public static var DEFAULT_SPRITE_ALPHA						:Number = .0051;
		public static var DEFAULT_FILL_ALPHA						:Number = .0051;
		public static var DEFAULT_FILL_COLOR						:Number = 0xFFFFFF;
		
		public var faceDictionary									:Dictionary = new Dictionary();
		public var containerDictionary								:Dictionary = new Dictionary();
		public var container										:Sprite = new Sprite();
		public var scene											:SceneObject3D;
		
		public var debug											:Boolean = false;
		
		protected var dummy											:DisplayObject3D = DisplayObject3D.ZERO;
		
		protected var log											:XrayLog = new XrayLog();
		
		public function InteractiveSceneManager(p_scene:SceneObject3D):void
		{
			scene = p_scene;
			scene.container.parent.addChild(container);
			container.x = scene.container.x;
			container.y = scene.container.y;
			container.stage.addEventListener(Event.RESIZE, handleResize);
			container.stage.addEventListener(MouseEvent.MOUSE_UP, handleReleaseOutside);
		}
		
		public function addDisplayObject(container3d:DisplayObject3D):void
		{
			if(faceDictionary[container3d] == null) 
			{
				var icd:InteractiveContainerData = faceDictionary[container3d] = new InteractiveContainerData(container3d);
				
				// for reverse lookup when you have the sprite container
				containerDictionary[icd.container] = container3d;
				
				// add mouse events to be captured and passed along
				icd.container.addEventListener(MouseEvent.MOUSE_DOWN, handleMousePress);
				icd.container.addEventListener(MouseEvent.MOUSE_UP, handleMouseRelease);
				icd.container.addEventListener(MouseEvent.CLICK, handleMouseClick);
				icd.container.addEventListener(MouseEvent.MOUSE_OVER, handleMouseOver);
				icd.container.addEventListener(MouseEvent.MOUSE_OUT, handleMouseOut);
				icd.container.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
				
				if(debug) log.debug("addDisplayObject id", container3d.id, container3d.name, DEFAULT_SPRITE_ALPHA);
			}
		}
		
		public function drawFace(container3d:DisplayObject3D, x0:Number, x1:Number, x2:Number, y0:Number, y1:Number, y2:Number ):void
		{
			if(faceDictionary[container3d] == null) addDisplayObject(container3d);
			var drawingContainer:InteractiveContainerData = faceDictionary[container3d];
			
			drawingContainer.container.graphics.beginFill(drawingContainer.color, drawingContainer.fillAlpha);
			drawingContainer.container.graphics.moveTo( x0, y0 );
			drawingContainer.container.graphics.lineTo( x1, y1 );
			drawingContainer.container.graphics.lineTo( x2, y2 );
			drawingContainer.container.graphics.endFill();
			drawingContainer.isDrawn = true;
		}
		
		public function getSprite(container3d:DisplayObject3D):Sprite
		{
			return InteractiveContainerData(faceDictionary[container3d]).container;
		}
		
		public function getDisplayObject3D(sprite:Sprite):DisplayObject3D
		{
			return DisplayObject3D(containerDictionary[sprite]);
		}
		
		public function resizeStage():void
		{
			container.x = scene.container.x;
			container.y = scene.container.y;
		}
		
		public function resetFaces():void
		{			
			// clear all triangles/faces that have been drawn
			for each( var item:InteractiveContainerData in faceDictionary)
			{
				
				item.container.graphics.clear();
				item.sort = item.isDrawn;
				item.isDrawn = false;
			}
			
			// sort the sprite containers
			sortObjects();
		}
		
		protected function sortObjects():void
		{
			var sort:Array = [];
			
			for each( var item:InteractiveContainerData in faceDictionary)
			{
				if(!item.sort) continue;
				var distance:Number = item.displayObject3D.screenZ;
				sort.push({container:item.container, distance:distance});
			}
			
			sort.sortOn("distance", Array.DESCENDING | Array.NUMERIC);
			
			for(var i:Number=0;i<sort.length;i++) container.addChild(sort[i].container);
		}
		
		protected function handleMousePress(e:MouseEvent):void
		{
			if(debug) log.debug("press", DisplayObject3D(containerDictionary[e.target]).name);
			dispatchEvent(new InteractiveScene3DEvent(InteractiveScene3DEvent.OBJECT_PRESS, containerDictionary[e.currentTarget], Sprite(e.currentTarget)));
		}
		
		protected function handleMouseRelease(e:MouseEvent):void
		{
			if(debug) log.debug("release", DisplayObject3D(containerDictionary[e.target]).name);
			dispatchEvent(new InteractiveScene3DEvent(InteractiveScene3DEvent.OBJECT_RELEASE, containerDictionary[e.currentTarget], Sprite(e.currentTarget)));
		}
		
		protected function handleMouseClick(e:MouseEvent):void
		{
			if(debug) log.debug("click", DisplayObject3D(containerDictionary[e.target]).name);
			dispatchEvent(new InteractiveScene3DEvent(InteractiveScene3DEvent.OBJECT_CLICK, containerDictionary[e.currentTarget], Sprite(e.currentTarget)));
		}
		
		protected function handleMouseOver(e:MouseEvent):void
		{
			if(debug) log.debug("Over", DisplayObject3D(containerDictionary[e.target]).name);
			dispatchEvent(new InteractiveScene3DEvent(InteractiveScene3DEvent.OBJECT_OVER, containerDictionary[e.currentTarget], Sprite(e.currentTarget)));
		}
		
		protected function handleMouseOut(e:MouseEvent):void
		{
			if(debug) log.debug("Out", DisplayObject3D(containerDictionary[e.target]).name);
			dispatchEvent(new InteractiveScene3DEvent(InteractiveScene3DEvent.OBJECT_OUT, containerDictionary[e.currentTarget], Sprite(e.currentTarget)));
		}
		
		protected function handleMouseMove(e:MouseEvent):void
		{	
			if(debug) log.debug("Move", DisplayObject3D(containerDictionary[e.target]).name);
			dispatchEvent(new InteractiveScene3DEvent(InteractiveScene3DEvent.OBJECT_MOVE, containerDictionary[e.currentTarget], Sprite(e.currentTarget)));
		}
		
		protected function handleReleaseOutside(e:MouseEvent):void
		{	
			if(debug) log.debug("releaseOutside");
			dispatchEvent(new InteractiveScene3DEvent(InteractiveScene3DEvent.OBJECT_RELEASE_OUTSIDE));
		}
		
		protected function handleResize(e:Event):void
		{
			resizeStage();
		}
	}
}
