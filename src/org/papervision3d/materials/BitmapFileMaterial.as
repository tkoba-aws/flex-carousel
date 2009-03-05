/*
 *  PAPER    ON   ERVIS  NPAPER ISION  PE  IS ON  PERVI IO  APER  SI  PA
 *  AP  VI  ONPA  RV  IO PA     SI  PA ER  SI NP PE     ON AP  VI ION AP
 *  PERVI  ON  PE VISIO  APER   IONPA  RV  IO PA  RVIS  NP PE  IS ONPAPE
 *  ER     NPAPER IS     PE     ON  PE  ISIO  AP     IO PA ER  SI NP PER
 *  RV     PA  RV SI     ERVISI NP  ER   IO   PE VISIO  AP  VISI  PA  RV3D
 *  ______________________________________________________________________
 *  papervision3d.org � blog.papervision3d.org � osflash.org/papervision3d
 */

/*
 * Copyright 2006-2007 (c) Carlos Ulloa Matesanz, noventaynueve.com.
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

//  ______________________________________________________________________ BITMAP FILE MATERIAL

package org.papervision3d.materials
{
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.Loader;
import flash.events.*;
import flash.net.URLRequest;
import flash.utils.Dictionary;

import org.papervision3d.Papervision3D;
import org.papervision3d.core.geom.Face3D;
import org.papervision3d.core.geom.Vertex2D;
import org.papervision3d.core.proto.MaterialObject3D;
import org.papervision3d.events.FileLoadEvent;
import org.papervision3d.objects.DisplayObject3D;

/**
* The BitmapFileMaterial class creates a texture by loading a bitmap from an external file.
*
* Materials collect data about how objects appear when rendered.
*/
public class BitmapFileMaterial extends BitmapMaterial
{
	// ___________________________________________________________________ PUBLIC

	/**
	* The URL that has been requested.
	*/
	public var url :String = "";

	/**
	* Whether or not the texture has been loaded.
	*/
	public var loaded :Boolean;

	/**
	* Function to call when the last image has loaded.
	*/
	static public var callback :Function;

	/**
	* The color to use in materials before loading has finished.
	*/
	static public var LOADING_COLOR :int = MaterialObject3D.DEFAULT_COLOR;

	// ___________________________________________________________________ NEW

	/**
	* The BitmapFileMaterial class creates a texture by loading a bitmap from an external file.
	*
	* @param	url					The URL of the requested bitmap file.
	* @param	initObject			[optional] - An object that contains additional properties with which to populate the newly created material.
	*/
	public function BitmapFileMaterial( url :String, initObject :Object=null )
	{
		super( url, initObject );

		this.url = url;

		this.loaded = false;

		// Loading color
		this.fillAlpha = 1;
		this.fillColor = LOADING_COLOR;
	}

	// ___________________________________________________________________ CREATE BITMAP

	/**
	* [internal-use]
	*
	* @param	asset
	* @return
	*/
	protected override function createBitmap( asset:* ):BitmapData
	{
		// Empy string?
		if( asset == "" )
		{
			return null;
		}
		// Already loaded?
		else if( _loadedBitmaps[ asset ] )
		{
			var bitmap:BitmapData = _loadedBitmaps[ asset ];

			this.loadComplete();

			return bitmap;
		}
		else
		{
			queueBitmap( asset );
		}
	
		return null;
	}

	// ___________________________________________________________________ QUEUE BITMAP

	private function queueBitmap( file:String ):void
	{
		// New filename?
		if( ! _subscribedMaterials[ file ] )
		{
			// Queue file
			_waitingBitmaps.push( file );

			// Init subscription
			_subscribedMaterials[ file ] = new Array();
		}

		// Subscribe material
		_subscribedMaterials[ file ].push( this );
		
		// Launch loading if needed
		if( _loadingIdle )
			loadNextBitmap();
	}

	// ___________________________________________________________________ LOAD NEXT BITMAP

	private function loadNextBitmap():void
	{
		// Retrieve next filename in queue
		var file:String = _waitingBitmaps[0];

		var request:URLRequest = new URLRequest( file );
		var bitmapLoader:Loader = new Loader();
		
		bitmapLoader.contentLoaderInfo.addEventListener( ProgressEvent.PROGRESS, loadBitmapProgressHandler );
		bitmapLoader.contentLoaderInfo.addEventListener( Event.COMPLETE, loadBitmapCompleteHandler );

		try
		{
			// Load bitmap
			bitmapLoader.load( request );

			// Save original url
			_loaderUrls[ bitmapLoader ] = file;

			// Busy loading
			_loadingIdle = false;

			Papervision3D.log( "BitmapFileMaterial: Loading bitmap from " + file );
		}
		catch( error:Error )
		{
			// Remove from queue
			_waitingBitmaps.shift();

			// Loading finished
			_loadingIdle = true;

			Papervision3D.log( "[ERROR] BitmapFileMaterial: Unable to load file " + error.message );
		}
	}
	
	// ___________________________________________________________________ LOAD BITMAP PROGRESS HANDLER

	private function loadBitmapProgressHandler( e:ProgressEvent ):void
	{
		var progressEvent:FileLoadEvent = new FileLoadEvent( FileLoadEvent.LOAD_PROGRESS, url, e.bytesLoaded, e.bytesTotal);
		dispatchEvent( progressEvent );
	}

	// ___________________________________________________________________ LOAD BITMAP COMPLETE HANDLER

	private function loadBitmapCompleteHandler( e:Event ):void
	{
		var loader:Loader = Loader( e.target.loader );
		var loadedBitmap:Bitmap = Bitmap( loader.content );

		// Retrieve original url
		var url:String = _loaderUrls[ loader ];

		// Retrieve loaded bitmapdata
		var bitmap:BitmapData = correctBitmap( loadedBitmap.bitmapData, true );

		// Update subscribed materials
		for each( var material:BitmapFileMaterial in _subscribedMaterials[ url ] )
		{
			material.bitmap = bitmap;
			material.maxU = this.maxU;
			material.maxV = this.maxV;
			material.loadComplete();
		}

		// Include in library
		_loadedBitmaps[ url ] = bitmap;

		// Remove from queue
		_waitingBitmaps.shift();

		// Queue finished?
		if( _waitingBitmaps.length > 0 )
		{
			// Continue loading
			loadNextBitmap();
		}
		else
		{
			// Loading finished
			_loadingIdle = true;
			
			if( Boolean( callback ) ) callback();
		}
	}

	// ___________________________________________________________________ LOAD COMPLETE

	private function loadComplete():void
	{
		this.fillAlpha = 0;
		this.fillColor = 0;
		this.loaded = true;

		// Dispatch event
		var fileEvent:FileLoadEvent = new FileLoadEvent( FileLoadEvent.LOAD_COMPLETE, this.url );
		this.dispatchEvent( fileEvent );
	}
	
	/**
	 *  drawFace3D
	 */
	override public function drawFace3D(instance:DisplayObject3D, face3D:Face3D, graphics:Graphics, v0:Vertex2D, v1:Vertex2D, v2:Vertex2D):int
	{
		if(bitmap == null) return 1;
		bitmap.lock();
		var i:int = super.drawFace3D(instance, face3D, graphics, v0, v1, v2);
		bitmap.unlock();
		return i;		
	}

	// ___________________________________________________________________ PRIVATE

	// Filenames in the queue
	static private var _waitingBitmaps :Array = new Array();

	// URLs per loader
	static private var _loaderUrls :Dictionary = new Dictionary();

	// Loaded bitmap library
	static private var _loadedBitmaps :Object = new Object();

	// Materials subscribed  to the loading queue
	static private var _subscribedMaterials :Object = new Object();

	// Loading status
	static private var _loadingIdle :Boolean = true;
}
}