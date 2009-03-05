package com.carousels
{
	import com.carousels.event.LoadProgressEvent;
	import com.carousels.event.MouseRollOutEvent;
	import com.carousels.event.MouseRollOverEvent;
	import com.popup.LiveStreamPopUp;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.utils.Timer;
	
	import media.CustomImage;
	
	import mx.controls.Image;
	import mx.core.UIComponent;
	import mx.managers.PopUpManager;
	
	import org.papervision3d.cameras.*;
	import org.papervision3d.core.proto.MaterialObject3D;
	import org.papervision3d.materials.*;
	import org.papervision3d.objects.*;
	import org.papervision3d.scenes.*;	
	
	[Event(name="MouseRollOver", type="MouseRollOverEvent")]
	[Event(name="MouseRollOut", type="MouseRollOutEvent")]
	[Event(name="LoadProgress", type="LoadProgressEvent")]
	
	public class ViewerStage extends UIComponent{
				
		public var contentsUrl:String;		
		public var scene     :MovieScene3D;//:Scene3D;
		public var camera    :Camera3D;
		public var target	 :DisplayObject3D;
		public var screenshotArray: Array;//array to store pictures
		public var radius:Number;
		public var image:Image;
		private var mainStage:UIComponent;
		private var mainContainer:Sprite;
		private var loader:URLLoader;
		private var photoXML:XML;
		private	var imgArray:Array = new Array();
		private var numOfPhotos:uint;
		private var pageNum:uint;
		private var loadDoneCounter:uint = 0;
		private var loaderContext:LoaderContext = new LoaderContext();
		private var timer:Timer;
				
		public function ViewerStage(url:String,items:uint = 20,page:uint = 1)
		{
			super();
			contentsUrl = url;
			numOfPhotos = items;
			pageNum = page;
			timer = new Timer( 2000 ); //20 sec
			
			loaderContext.checkPolicyFile = true;
			
			initPapervision();
			
			getPhotoList(contentsUrl);
			// ↑this starts the whole process
		}

		private function initPapervision():void
		{
			mainContainer = new Sprite();
			addChild(mainContainer);
						
			screenshotArray = new Array(numOfPhotos);
			target 		= new DisplayObject3D();
			camera 		= new Camera3D(target);
			scene 		= new MovieScene3D(mainContainer);//new Scene3D(mainStage);

			scene.addChild( target , "center" );
		}

		public function handleImageLoad(event:Event):void
		{
			init3D((CustomImage)(event.target));
		}

		public function init3D(image:CustomImage):void
		{
			loadDoneCounter++;
			
			addScreenshots(image);
						
			if(loadDoneCounter == numOfPhotos){
				camera.y = 100;
				loadingCompleteEvent();
				scene.renderCamera(camera);
			}else{
				loadProgressEvent( loadDoneCounter );
				scene.renderCamera(camera);
			}
		}
		
		private function timerHandler(e:TimerEvent):void{
			//loading image timeout
			trace("times up");
		}
		
		public function loadProgressEvent(data:uint):void{
			var e:LoadProgressEvent = new LoadProgressEvent( LoadProgressEvent.LOAD_PROGRESS );
			e.data = data;
			dispatchEvent( e ); 
		}
		
		public function loadingCompleteEvent():void{
			dispatchEvent( new Event(Event.COMPLETE,true,false) );
		}
		
		public function handleMouseMove(event:MouseEvent):void
		{
			camera.y = Math.max( mainStage.mouseY*5 , -450 );
			scene.renderCamera(camera);
		}
		
		private function getPhotoList(xml_url:String):void{
			var urlRequest:URLRequest = new URLRequest(xml_url);
			loader = new URLLoader(urlRequest);
			loader.addEventListener(Event.COMPLETE,xmlLoaded);
		}
		
		private function xmlLoaded(evtObj:Event):void{
			photoXML = XML(loader.data);
			createPhotosFromXML(photoXML);
		}
		
		public function createPhotosFromXML(images:XML):void{
			var photosrc:String;
			var phototitle:String;

//			for(var i:uint = 0; i < images.item.length(); i++){
//				title = images.item[i].title;
//				src = images.user[i].link;
//				screenname = images.user[i].screen_name;
//				trace(src+' : '+uid);
//				imgArray[i] = createPhoto(src,uid,screenname,i+1,images.user.length());
//			}
			var counter:int = 0;
			for each(var src:XML in images.channel.item){				
				photosrc = src..@url[1];
				//photosrc = photosrc.substring(0,photosrc.lastIndexOf("s"))+"m.jpg"
				phototitle = src.title;
				trace(photosrc+" : "+phototitle);
				createPhoto(photosrc,phototitle,counter);
				counter++;
			}
			
			//mainStage.addEventListener( MouseEvent.MOUSE_MOVE , handleMouseMove);
		}	
		
		
		public function createPhoto(url:String,name:String,curCount:uint):CustomImage{
			var image:CustomImage = new CustomImage();
			image.loaderContext = loaderContext;
			image.source = url;
			image.maintainAspectRatio 	= true;
			image.scaleContent 			= false;
			image.autoLoad 				= false;
			image.addEventListener(Event.COMPLETE, handleImageLoad);
			image.showBusyCursor = true;
			image.load();
			image.loaderContext.checkPolicyFile = true;
			image.name = name;
			image.url = url
			return image;
		}	
		
		public var resultBitmap:Bitmap = new Bitmap(new BitmapData( 1, 1, true, 0 ));
		public var gr:Graphics;
		public var fadeFrom:Number = 0.3;
		public var fadeTo:Number = 0;
		public var fadeCenter:Number = 0.5;
		public var skewX:Number = 0;
		public var scale:Number = 1;
		
		public function drawReflection( image:Image ):BitmapData {
			var resultBitmap:BitmapData;
			var imageWidth:uint = image.content.loaderInfo.width;
			var imageHeight:uint = image.content.loaderInfo.height;

			//draw reflection
			var bitmapData:BitmapData = new BitmapData(imageWidth, imageHeight, true, 0);
			var matrix:Matrix = new Matrix( 1, 0, skewX, -1*scale, 0, imageHeight );
			var rectangle:Rectangle = new Rectangle(0,0,imageWidth,imageHeight*(2-scale));
			var delta:Point = matrix.transformPoint(new Point(0,imageHeight));
			matrix.tx = delta.x*-1;
			matrix.ty = (delta.y-imageHeight)*-1;
			bitmapData.draw(image, matrix, null, null, rectangle, true);
			
			//add fade
			var shape:Shape = new Shape();
			var gradientMatrix:Matrix = new Matrix();
			gradientMatrix.createGradientBox(imageWidth,imageHeight, 0.5*Math.PI);
			shape.graphics.beginGradientFill(GradientType.LINEAR, new Array(0,0,0), new Array(fadeFrom,(fadeFrom-fadeTo)/2,fadeTo), new Array(0,0xFF*fadeCenter,0xFF), gradientMatrix)
			shape.graphics.drawRect(0, 0, imageWidth, imageHeight);
			shape.graphics.endFill();
			bitmapData.draw(shape, null, null, BlendMode.ALPHA);
			
			//apply result
			//resultBitmap.dispose();
			resultBitmap = bitmapData;
			
			 return resultBitmap;
		}
		
		
		
		private var counter:uint = 0;
		
		public function addScreenshots(image:CustomImage):void
		{
			var obj:DisplayObject3D = scene.getChildByName ("center");
			
			radius 		= 500;
			camera.z 	= radius + 50;
			camera.y 	= 50;
			
		
			var texture:BitmapData = new BitmapData(image.content.loaderInfo.width, image.content.loaderInfo.height+60, true);
			var rect:Rectangle = new Rectangle(0,0,image.content.loaderInfo.width,180);
			
			//texture.draw(drawReflection(image));
			texture.draw(image);
			//var reflect:BitmapData = createReflection(image);
			//texture.draw(reflect,null,null,BlendMode.ALPHA,rect);
			//texture.draw(reflect,null,null,BlendMode.DARKEN,null);
			//texture.fillRect(rect, 0x0000FF);
			var matrix:Matrix = new Matrix();
			matrix.translate(0,100);
			texture.draw(drawReflection(image),matrix,null,null,rect,true);
		
			// Create texture with a bitmap from the library
			var materialSpace :MaterialObject3D = new BitmapMaterial(texture);

			materialSpace.doubleSided	= true;
			materialSpace.smooth 		= true;

			screenshotArray[counter] = new Object();
			screenshotArray[counter].plane =  new Plane( materialSpace, image.content.loaderInfo.width, image.content.loaderInfo.height+60, 2, 2 );
			
			// Position plane
			var rotation:Number = (360/numOfPhotos)* counter ;
			var rotationRadians:Number = (rotation-90) * (Math.PI/180);
			screenshotArray[counter].rotation = rotation;

			screenshotArray[counter].plane.z = (radius * Math.cos(rotationRadians) ) * -1;
		    screenshotArray[counter].plane.x = radius * Math.sin(rotationRadians) * -1;
			screenshotArray[counter].plane.y = 100;
			
			screenshotArray[counter].plane.lookAt(obj);
		
			// Add plane to scene	
			var node:DisplayObject3D = scene.addChild( screenshotArray[counter].plane );
		
			// Add Event Handler per plane
			var container:Sprite = scene.getSprite(node);
			container.buttonMode = true;
			container.name = image.name+'&'+image.url;
			container.addEventListener(MouseEvent.CLICK, liveStreamEvent);
			container.addEventListener(MouseEvent.ROLL_OVER, rollOverEvent);
			container.addEventListener(MouseEvent.ROLL_OUT, rollOutEvent);
		
			counter++;				
		}

		private function getName(name:String):String{
			return name.split('&')[0];
		}
				
		private function getUrl(name:String):String{
			var username:String = name.split('&')[1];
			return username;
		}
		
		private function liveStreamEvent(event:MouseEvent):void{
			var liveWindow:LiveStreamPopUp =
					LiveStreamPopUp(PopUpManager.createPopUp(this, LiveStreamPopUp, true));
				liveWindow.addEventListener(Event.REMOVED_FROM_STAGE,liveDoneEventHandler);
				liveWindow.photoname = getName( event.target.name );
				liveWindow.url = getUrl( event.target.name );
				//PopUpManager.centerPopUp(liveWindow);
		}
		
		private function rollOverEvent(event:MouseEvent):void{
			var rollover:MouseRollOverEvent = new MouseRollOverEvent( MouseRollOverEvent.MOUSE_ROLL_OVER, true, false, getName(event.target.name) );
			dispatchEvent( rollover );
		}
		
		private function rollOutEvent(event:MouseEvent):void{
			var rollout:MouseRollOutEvent = new MouseRollOutEvent( MouseRollOutEvent.MOUSE_ROLL_OUT, true, false );
			dispatchEvent( rollout );
		}
		
		private function liveDoneEventHandler(event:Event):void{
			trace("live closed");
		}
		
		public function rightloop3D(event:Event):void {
			var obj:DisplayObject3D = scene.getChildByName ("center");					
			for (var i:Number = 0; i < screenshotArray.length ; i++ ) {
				var rotation:Number = screenshotArray[i].rotation;			
				//rotation += (mainStage.mouseX/50)/(screenshotArray.length/10);
				rotation += (-300/50)/(screenshotArray.length/10);

				var rotationRadians:Number = (rotation-90) * (Math.PI/180);
				screenshotArray[i].rotation = rotation;
				screenshotArray[i].plane.z = (radius * Math.cos(rotationRadians) ) * -1;
			    screenshotArray[i].plane.x = radius * Math.sin(rotationRadians) * -1;
				screenshotArray[i].plane.lookAt(obj);
			}
			//now lets render the scene			
			scene.renderCamera(camera);
		}
		
		public function leftloop3D(event:Event):void {
			var obj:DisplayObject3D = scene.getChildByName ("center");					
			for (var i:Number = 0; i < screenshotArray.length ; i++ ) {
				var rotation:Number = screenshotArray[i].rotation;				
				//rotation += (mainStage.mouseX/50)/(screenshotArray.length/10);
				rotation += (300/50)/(screenshotArray.length/10);
				var rotationRadians:Number = (rotation-90) * (Math.PI/180);
				screenshotArray[i].rotation = rotation;
				screenshotArray[i].plane.z = (radius * Math.cos(rotationRadians) ) * -1;
			    screenshotArray[i].plane.x = radius * Math.sin(rotationRadians) * -1;
				screenshotArray[i].plane.lookAt(obj);
			}
			//now lets render the scene			
			scene.renderCamera(camera);
		}

		public function startRight():void{
			addEventListener( Event.ENTER_FRAME, rightloop3D );			
		}
		
		public function stopRight():void{
			removeEventListener( Event.ENTER_FRAME, rightloop3D );	
		}

		public function startLeft():void{
			addEventListener( Event.ENTER_FRAME, leftloop3D );			
		}

		public function stopLeft():void{
			removeEventListener( Event.ENTER_FRAME, leftloop3D );	
		}

	}
}