package com.lorentz.SVG.display {
	import com.lorentz.SVG.data.AssetManager;
	import com.lorentz.SVG.display.base.ISVGViewPort;
	import com.lorentz.SVG.display.base.SVGElement;
	import com.lorentz.SVG.utils.SVGUtil;
	import com.worlize.gif.GIFPlayerLagacy;
	import com.worlize.gif.events.AsyncDecodeErrorEvent;
	import com.worlize.gif.events.GIFPlayerEvent;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	public class SVGImage extends SVGElement implements ISVGViewPort {
		private var _svgHrefChanged:Boolean = false;
		private var _svgHref:String;
		private var _assetManager:AssetManager = AssetManager.getInstance();
		
		private var source:ByteArray;
		private var _loader:Loader;
		
		public function get svgPreserveAspectRatio():String {
			return getAttribute("preserveAspectRatio") as String;
		}
		public function set svgPreserveAspectRatio(value:String):void {
			setAttribute("preserveAspectRatio", value);
		}
		
		public function get svgX():String {
			return getAttribute("x") as String;
		}
		public function set svgX(value:String):void {
			setAttribute("x", value);
		}
		
		public function get svgY():String {
			return getAttribute("y") as String;
		}
		public function set svgY(value:String):void {
			setAttribute("y", value);
		}
		
		public function get svgWidth():String {
			return getAttribute("width") as String;
		}
		public function set svgWidth(value:String):void {
			setAttribute("width", value);
		}
		
		public function get svgHeight():String {
			return getAttribute("height") as String;
		}
		public function set svgHeight(value:String):void {
			setAttribute("height", value);
		}
		
		public function get svgOverflow():String {
			return getAttribute("overflow") as String;
		}
		public function set svgOverflow(value:String):void {
			setAttribute("overflow", value);
		}		
		
		public function get svgHref():String {
			return _svgHref;
		}
		public function set svgHref(value:String):void {
			if(_svgHref != value){
				_svgHref = value;
				_svgHrefChanged = true;
				invalidateProperties();
			}
		}
		
		public function SVGImage() {
			super("image");
		}
		
		public function loadURL(url:String):void {
			_assetManager.requestAsset(url, loadBytes);
			
			//			if(url!=null){
			//				_loader = new Loader();
			//				_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
			//				_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadError);
			//				_loader.load(new URLRequest(/*url*/"http://f1.img4399.com/yxh~diy/66159738/2015/08/11/23/2808_Q3KHkF.png" + (Math.random() * 10000)), new LoaderContext(true));
			//				content.addChild(_loader);
			//			}
			//			else if(_loader != null){
			//				content.removeChild(_loader);
			//				_loader = null;
			//			}
		}
		
		public function loadEmpty():void {
			var spaceHolder:Sprite = new Sprite;
			spaceHolder.graphics.beginFill(0x000000, 0);
			spaceHolder.graphics.drawRect(0, 0, getViewPortUserUnit(svgWidth, SVGUtil.WIDTH), getViewPortUserUnit(svgHeight, SVGUtil.HEIGHT));
			spaceHolder.graphics.endFill();
			content.addChild(spaceHolder);
		}
		
		//Thanks to youzi530, for coding base64 embed image support
		public function loadBase64(content:String):void
		{
			_assetManager.requestBase64Asset(content, loadBytes);
		}
		
		public function loadBytes(byteArray:ByteArray, valid:Boolean = true):void {
			if(source != byteArray){
				if(byteArray != null){
					_loader = new Loader();
					if(valid){
						beginASyncValidation("loadImage");
					}
					var gifPlayer:GIFPlayerLagacy = new GIFPlayerLagacy;
					var makeOnError:Function = function(pLoader:Loader):Function{
						var func:Function = function(e:Event):void{
							pLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
							pLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadError);
							pLoader.loadBytes(byteArray);
							(e.currentTarget as EventDispatcher).removeEventListener(e.type, func);
						};
						return func;
					};
					var makeOnComplete:Function = function(pContent:Sprite, pValid:Boolean):Function{ 
						var func:Function = function(e:Event):void{
							var player:GIFPlayerLagacy = e.currentTarget as GIFPlayerLagacy;
							if(player){
								pContent.removeChildren();
								pContent.graphics.beginFill(0x000000, 0);
								pContent.graphics.drawRect(0, 0, player.width, player.height);
								pContent.graphics.endFill();
								pContent.addChild(player);
								if(pValid){
									endASyncValidation("loadImage");
								}
							}
							(e.currentTarget as EventDispatcher).removeEventListener(e.type, func);
						};
						return func;
					};
					gifPlayer.addEventListener(AsyncDecodeErrorEvent.ASYNC_DECODE_ERROR, makeOnError(_loader));
					gifPlayer.addEventListener(GIFPlayerEvent.COMPLETE, makeOnComplete(content, valid));
					gifPlayer.source = byteArray;
				}
				else if(_loader != null){
					content.removeChildren();
					_loader = null;
				}
				
				source = byteArray;
			}
		}
		
		override protected function commitProperties():void {
			super.commitProperties();
			
			if(_svgHrefChanged)
			{
				_svgHrefChanged = false;
				
				if(svgHref != null && svgHref != ""){
					if(svgHref.match(/^data:[a-z\/]*;base64,/)){
						loadBase64(svgHref);
						
						beginASyncValidation("loadImage");
					} else {
						loadURL(document.resolveURL(svgHref));
						
						beginASyncValidation("loadImage");
					}
				}
				else{
					loadEmpty();
				}
			}
		}
		
		private function loadComplete(e:Event):void {
			var cLoaderInfo:LoaderInfo = e.currentTarget as LoaderInfo;
			if(cLoaderInfo){
				if(cLoaderInfo.loader == _loader){
					content.removeChildren();
					content.addChild(cLoaderInfo.loader);
					
					var bitmap:Bitmap = cLoaderInfo.loader.content as Bitmap;
					if(bitmap){
						bitmap.smoothing = true;
					}
					endASyncValidation("loadImage");
				}
			}
			(e.currentTarget as EventDispatcher).removeEventListener(e.type, loadComplete);
		}
		
		private function loadError(e:IOErrorEvent):void {
			trace("loadError, Failed to load image" + e.text);
			
			endASyncValidation("loadImage");
			
			(e.currentTarget as EventDispatcher).removeEventListener(e.type, loadComplete);
		}
		
		override protected function getContentBox():Rectangle {
			return new Rectangle(0, 0, content.width, content.height);
		}
		
		override public function clone():Object {
			var c:SVGImage = super.clone() as SVGImage;
			c.svgHref = svgHref;
			return c;
		}
	}
}