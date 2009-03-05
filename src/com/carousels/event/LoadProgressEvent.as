package com.carousels.event
{
	import flash.events.Event;

	public class LoadProgressEvent extends Event
	{

		private var _data:Object;	
		
		public static const LOAD_PROGRESS:String = "LoadProgress";				
		
		public function LoadProgressEvent(type:String)
		{
			super(type, bubbles, cancelable);
		}
		
		/**
		 * Data
		 */
		public function get data():Object
		{
			return _data;
		}
		
		public function set data( value:Object ):void
		{
			_data = value;
		}
	}
}