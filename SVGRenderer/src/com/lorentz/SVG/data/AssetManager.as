package com.lorentz.SVG.data
{
	import com.lorentz.SVG.utils.Base64AsyncDecoder;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import mx.core.FlexGlobals;
	
	import org.assetloader.AssetLoader;
	import org.assetloader.base.AssetType;
	import org.assetloader.base.Param;
	import org.assetloader.core.IAssetLoader;
	import org.assetloader.loaders.BinaryLoader;
	import org.assetloader.signals.LoaderSignal;
	
	public final class AssetManager extends AssetLoader{
		
		private static var _instance:AssetManager;
		
		private var _base64Dict:Dictionary = new Dictionary;		
		
		public function AssetManager(){
			if(!_instance){
				super("AssetManager");
				
				// Child loaders will inherit params.
				this.numConnections = 1;
				//this.setParam(Param.PREVENT_CACHE, _preventCache);
				this.setParam(Param.RETRIES, 3);
				
				// Fail on error flag.
				this.failOnError = true;
								
				_instance = this;
			}
			else{
				throw new Error("Singleton... use getInstance()");
			} 
		}
		
		public static function getInstance():AssetManager{
			if(!_instance){
				new AssetManager();
			} 
			return _instance;
		}
		
		public function requestBase64Asset(content:String, doWithAsset:Function):void{
			var base64String:String = content.replace(/^data:[a-z\/]*;base64,/, '');
			
			var data:ByteArray = _base64Dict[base64String];
			if(data){
				if(doWithAsset != null){
					doWithAsset(data);
				}
			}
			else{
				var makeOnComplete:Function = function(pDoWithAsset:Function):Function{
					var func:Function = function(e:Event):void{
						var decoder:Base64AsyncDecoder = e.currentTarget as Base64AsyncDecoder;
						if(decoder){
							if(decoder.bytes && decoder.bytes.length){
								_base64Dict[base64String] = decoder.bytes;
								
								if(pDoWithAsset != null){
									pDoWithAsset(decoder.bytes);
								}
							}
							//MonsterDebugger.trace(this, "requestAsset onCompelete");
						}
						
						(e.currentTarget as IEventDispatcher).removeEventListener(e.type, func);
					};
					return func;
				};
				
				var _base64AsyncDecoder:Base64AsyncDecoder = new Base64AsyncDecoder(base64String);
				_base64AsyncDecoder.addEventListener(Base64AsyncDecoder.COMPLETE, makeOnComplete(doWithAsset));
				_base64AsyncDecoder.addEventListener(Base64AsyncDecoder.ERROR, makeOnComplete(doWithAsset));
				_base64AsyncDecoder.decode();
			}
		}
		
		private function getFullDomain(fixDev:Boolean = false):String{
			var domain:String = FlexGlobals.topLevelApplication.url;
			var pathArray:Array = domain.split("//");
			pathArray = pathArray[1].split("/");
			domain = domain.substr(0, domain.indexOf("://")) + "://" + String(pathArray[0]);
			if(fixDev){
				var myPattern:RegExp = /dev./;
				domain = domain.replace(myPattern, "www.");
			}
			return domain;
		}
		
		// Add assets to queue.
		public function loadAsset(url:String, type:String = AssetType.BINARY, priority:Number = -1, doWithAsset:Function = null):Boolean{
			if(url){
				try{
					if(!this.hasLoader(url) && !this.hasLoader(url)){
						var name:String = url;
						if(url.indexOf("http") == -1 && url.charAt(0) == "/" && !url.indexOf("//") == 0)
						{
							url = getFullDomain() + url;
						}
						this.addLazy(name, url, type, [new Param(Param.PRIORITY, priority)]);
						if(doWithAsset != null){
							var loader:BinaryLoader = this.getLoader(url) as BinaryLoader;
							if(loader){
								var makeOnComplete:Function = function(pDoWithAsset:Function):Function{
									var func:Function = function(signal:LoaderSignal, data:ByteArray):void{
										if(pDoWithAsset != null){
											pDoWithAsset(data);
										}
										signal.loader.onComplete.remove(func);
										//MonsterDebugger.trace(this, "requestAsset onCompelete");
									};
									return func;
								}
								var onComplete:Function = makeOnComplete(doWithAsset);								
								loader.onComplete.add(onComplete);
								this.start();
							}
						}
					}
				}
				catch(e:Error){
					trace("AssetManager loadAsset error: " + e + " url: " + url);
					return false;
				}
			}
			return true;
		}
		
		// Request Asset
		public function requestAsset(url:String, doWithAsset:Function = null):Number{
			if(url){
				try{
					var asset:ByteArray = this.getAsset(url);
					if(asset){
						asset.position = 0;
						if(doWithAsset != null){
							doWithAsset(asset);
						}
						return 0;
					}
					else{
						var loader:BinaryLoader = this.getLoader(url) as BinaryLoader;
						if(loader){
							var makeOnComplete:Function = function(pDoWithAsset:Function):Function{
								var func:Function = function(signal:LoaderSignal, data:ByteArray):void{
									if(pDoWithAsset != null){
										pDoWithAsset(data);
									}
									signal.loader.onComplete.remove(func);
									//MonsterDebugger.trace(this, "requestAsset onCompelete");
								};
								return func;
							}
							var onComplete:Function = makeOnComplete(doWithAsset);								
							loader.onComplete.add(onComplete);
							
							return 1;
						}
						else{
							//trace("AssetManager requestAsset loader not found! url: " + url);
//							if(doWithAsset != null){
//								doWithAsset(null);
//							}
							// load now
							loadAsset(url, AssetType.BINARY, -1, doWithAsset);
						}
					}
				}
				catch(e:Error){
					trace("requestAsset error:" + e);
				}
			}
			else{
				trace("AssetManager No URL");
				if(doWithAsset != null){
					doWithAsset(null);
				}
			}
			
			return 0;
		}
		
	}
}