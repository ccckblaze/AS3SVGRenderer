﻿package com.lorentz.SVG.display.foreign {
	import com.lorentz.SVG.data.text.SVGDrawnText;
	import com.lorentz.SVG.data.text.SVGTextToDraw;
	import com.lorentz.SVG.display.base.SVGPContainer;
	import com.lorentz.SVG.utils.DisplayUtils;
	import com.lorentz.SVG.utils.SVGUtil;
	
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import mx.controls.TextArea;
	
	public class SVGForeignTextArea extends SVGPContainer {				
		public function SVGForeignTextArea(){
			super("textarea");
		}
		
		public var currentX:Number = 0;
		public var currentY:Number = 0;
		public var textContainer:Sprite;
		
		private var _start:Number = 0;
		private var _end:Number = 0;
		private var fillTextsSprite:Sprite;
		
		protected override function render():void {
			super.render();
			
			while(content.numChildren > 0)
				content.removeChildAt(0);
			
			if(this.numTextElements == 0)
				return;
			
			textContainer = content;
			
			document.textDrawer.start();
			
			var direction:String = getDirectionFromStyles() || "lr";
			var textDirection:String = direction;
			
			currentX = getViewPortUserUnit(svgX, SVGUtil.WIDTH);
			currentY = getViewPortUserUnit(svgY, SVGUtil.HEIGHT);
			
			_start = currentX;
			_renderObjects = new Vector.<DisplayObject>();
			
			if(hasComplexFill)
			{
				fillTextsSprite = new Sprite();
				textContainer.addChild(fillTextsSprite);
			} else {
				fillTextsSprite = textContainer;
			}
			
			var drawnText:SVGDrawnText = null;
			
			for(var i:int = 0; i < numTextElements; i++){
				var textElement:Object = getTextElementAt(i);
				
				if(textElement is String){		
					if(!drawnText){
						drawnText = createTextSprite(textElement as String);
						
						// set size
						var parent:SVGForeignObject = parentElement as SVGForeignObject;
						if(parent){						
							drawnText.displayObject.width = getViewPortUserUnit(parent.svgWidth, SVGUtil.WIDTH) + 2;
							drawnText.displayObject.height = getViewPortUserUnit(parent.svgHeight, SVGUtil.HEIGHT) + 2;//Number.MAX_VALUE;
							
//							var mask:Sprite = new Sprite();
//							mask.cacheAsBitmap = true;
//							mask.graphics.beginFill(0x00ff00);
//							mask.graphics.drawRect(0, 0, drawnText.displayObject.width / 2, getViewPortUserUnit(parent.svgHeight, SVGUtil.HEIGHT));
//							mask.graphics.endFill();
//							
//							//mask.startDrag();
//							//mask.filters = [new  BlurFilter(20, 20, BitmapFilterQuality.HIGH)];
//							//mask.blendMode = BlendMode.ERASE;
//							
//							textContainer.cacheAsBitmap = true;
//							//textContainer.blendMode = BlendMode.LAYER;
//							textContainer.addChild(mask);
//							textContainer.mask = mask;
						}
						
						fillTextsSprite.addChild(drawnText.displayObject);
						_renderObjects.push(drawnText.displayObject);
					}
					else{
						var textField:TextField = drawnText.displayObject as TextField;
						if(textField){
							
							textField.appendText(textElement as String);
							//							textField.text += textElement as String;
							//							var a:TextFormat = textField.getTextFormat();
							//							//a.font = "宋体";
							//							trace(a.font);
							//							textField.setTextFormat(a);
						}
					}
					
					
					//					//					if((drawnText.direction || direction) == "lr"){
					//					//						drawnText.displayObject.x = currentX - drawnText.startX;
					//					//						drawnText.displayObject.y = currentY - drawnText.startY - drawnText.baseLineShift;
					//					//						currentX += drawnText.textWidth;
					//					//					} else {
					//					//						drawnText.displayObject.x = currentX - drawnText.textWidth - drawnText.startX;
					//					//						drawnText.displayObject.y = currentY - drawnText.startY - drawnText.baseLineShift;
					//					//						currentX -= drawnText.textWidth;
					//					//					}
					//					
					//					//					drawnText.displayObject.y += currentFontSize;
					//					//					
					//					//					if(drawnText.direction)	
					//					//						textDirection = drawnText.direction;		
				} else if(textElement is SVGPContainer) {
					var tspan:SVGPContainer = textElement as SVGPContainer;
					
					if(tspan.hasOwnFill()) {
						textContainer.addChild(tspan);
					} else
						fillTextsSprite.addChild(tspan);
					
					tspan.invalidateRender();
					tspan.validate();
					
					_renderObjects.push(tspan);
				}
			}
			
			_end = currentX;
			
			doAnchorAlign(textDirection, _start, _end);
			
			document.textDrawer.end();
			
			if(hasComplexFill && fillTextsSprite.numChildren > 0){
				var bounds:Rectangle = DisplayUtils.safeGetBounds(fillTextsSprite, content);
				bounds.inflate(2, 2);
				var fill:Sprite = new Sprite();
				beginFill(fill.graphics);
				fill.graphics.drawRect(bounds.x, bounds.y, bounds.width, bounds.height);
				fill.mask = fillTextsSprite;
				fillTextsSprite.cacheAsBitmap = true;
				fill.cacheAsBitmap = true;
				textContainer.addChildAt(fill, 0);
				
				_renderObjects.push(fill);
			}
			
			dispatchEvent(new Event(Event.CHANGE, true));
		}
		
		override protected function getObjectBounds():Rectangle {
			return content.getBounds(this);
		}
		
		override public function clone():Object {
			var c:SVGForeignTextArea = super.clone() as SVGForeignTextArea;
			c.svgX = svgX;
			c.svgY = svgY;
			
			return c;
		}
	}
}