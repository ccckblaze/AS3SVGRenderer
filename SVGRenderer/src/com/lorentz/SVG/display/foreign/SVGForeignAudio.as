package com.lorentz.SVG.display.foreign {
	import com.lorentz.SVG.data.AssetManager;
	import com.lorentz.SVG.display.base.SVGElement;
	
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.utils.ByteArray;
	
	public class SVGForeignAudio extends SVGElement {	
		public function SVGForeignAudio(){
			super("audio");
		}

		private var _audioChannel:SoundChannel = new SoundChannel;
		private var _assetManager:AssetManager = AssetManager.getInstance();
		
		private var _svgSrcChanged:Boolean = false;
		private var _src:String;
		public function get src():String {
			return _src;
		}
		public function set src(value:String):void {
			if(_src != value){
				_src = value;
				_svgSrcChanged = true;
				invalidateProperties();
			}
		}
		
		private var _volume:String;
		public function get volume():String {
			return _volume;
		}
		public function set volume(value:String):void {
			if(_volume != value){
				_volume = value;
			}
		}
		
		public function play():void{
			if(src){
				_assetManager.requestAsset(src, function(data:ByteArray):void{
					var audio:Sound = new Sound;
					audio.loadCompressedDataFromByteArray(data, data.length);
					_audioChannel = audio.play();
					_audioChannel.soundTransform = new SoundTransform(Number(volume));
				});
			}
		}
		
		public function stop():void{
			if(src){
				_audioChannel.stop();
			}
		}
		
		override protected function commitProperties():void {
			super.commitProperties();
			
			if(_svgSrcChanged)
			{
				_svgSrcChanged = false;
				
				if(src != null && src != ""){
					beginASyncValidation("loadAudio");
					_assetManager.requestAsset(src, function(data:ByteArray):void{
						endASyncValidation("loadAudio");
					});
				}
			}
		}
		
		override public function clone():Object {
			var c:SVGForeignAudio = super.clone() as SVGForeignAudio;
			c.src = src;
			c.volume = volume;
			return c;
		}
	}
}

