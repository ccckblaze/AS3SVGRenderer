package com.lorentz.SVG.display.base
{
	import com.lorentz.SVG.data.text.SVGDrawnText;
	import com.lorentz.SVG.data.text.SVGTextToDraw;
	import com.lorentz.SVG.display.foreign.SVGForeignTextArea;
	import com.lorentz.SVG.text.ISVGTextDrawer;
	import com.lorentz.SVG.text.TextFieldSVGTextDrawer;
	import com.lorentz.SVG.utils.SVGColorUtils;
	import com.lorentz.SVG.utils.SVGUtil;
	import com.lorentz.SVG.utils.TextUtils;
	
	import flash.display.DisplayObject;
	import flash.text.TextField;

	public class SVGTextAreaContainer extends SVGGraphicsElement
	{
		private var _svgX:String;
		private var _svgY:String;
		private var _textOwner:SVGForeignTextArea;
		protected var _renderObjects:Vector.<DisplayObject>;
		
		public function SVGTextAreaContainer(tagName:String) {
			super(tagName);
			
			if(this is SVGForeignTextArea)
				_textOwner = this as SVGForeignTextArea;
		}
		
		public function get svgX():String {
			return _svgX;
		}
		public function set svgX(value:String):void {
			if(_svgX != value){
				_svgX = value;
				invalidateRender();
			}
		}
		
		public function get svgY():String {
			return _svgY;
		}
		public function set svgY(value:String):void {
			if(_svgY != value){
				_svgY = value;
				invalidateRender();
			}
		}
		
		protected function get textOwner():SVGForeignTextArea {
			return _textOwner;
		}
		
		override protected function setParentElement(value:SVGElement):void {
			super.setParentElement(value);
			
			if(value is SVGForeignTextArea)
				setTextOwner(value as SVGForeignTextArea);
			else if(value is SVGPContainer)
				setTextOwner((value as SVGTextAreaContainer).textOwner);
			else
				setTextOwner(this as SVGForeignTextArea);
		}
		
		private function setTextOwner(value:SVGForeignTextArea):void {
			if(_textOwner != value){
				_textOwner = value;
				
				for each(var element:Object in _textElements){
					if(element is SVGTextAreaContainer)
						(element as SVGTextAreaContainer).setTextOwner(value);
				}
			}
		}
		
		private var _textElements:Vector.<Object> = new Vector.<Object>();
		public function addTextElement(element:Object):void {
			addTextElementAt(element, numTextElements);
		}
		
		public function addTextElementAt(element:Object, index:int):void {
			_textElements.splice(index, 0, element);
			
			if(element is SVGElement)
				attachElement(element as SVGElement);
			
			invalidateRender();
		}
		
		public function getTextElementAt(index:int):Object {
			return _textElements[index];
		}
		
		public function get numTextElements():int {
			return _textElements.length;
		}
		
		public function removeTextElementAt(index:int):void {
			if(index < 0 || index >= numTextElements)
				return;
						
			var element:Object = _textElements[index];
			if(element is SVGElement)
				detachElement(element as SVGElement);
			
			_textElements.splice(index, 1);
			
			invalidateRender();
		}
		
		override public function invalidateRender():void {
			super.invalidateRender();
			
			if(textOwner && textOwner != this)
				textOwner.invalidateRender();
		}
		
		override protected function onStyleChanged(styleName:String, oldValue:String, newValue:String):void {
			super.onStyleChanged(styleName, oldValue, newValue);
			
			switch(styleName){
				case "color" :
				case "font-size" :
				case "font-family" :
				case "font-weight" :
					invalidateRender();
					break;
			}
		}
		
		public function getTextToDraw(text:String):SVGTextToDraw
		{
			var textToDraw:SVGTextToDraw = new SVGTextToDraw();
			
			textToDraw.text = text;
			
			textToDraw.useEmbeddedFonts = document.useEmbeddedFonts;
			textToDraw.parentFontSize = parentElement ? parentElement.currentFontSize : currentFontSize;
			textToDraw.fontSize = currentFontSize;
			var myPattern:RegExp = /'/g;
			textToDraw.fontFamily = SVGUtil.validFontFamily(finalStyle.getPropertyValue("font-family")) ? finalStyle.getPropertyValue("font-family").replace(myPattern, "") : document.defaultFontName);
			textToDraw.fontWeight = finalStyle.getPropertyValue("font-weight") || "normal";
			textToDraw.fontStyle = finalStyle.getPropertyValue("font-style") || "normal";
			textToDraw.baselineShift = finalStyle.getPropertyValue("baseline-shift") || "baseline";
			
			var letterSpacing:String = finalStyle.getPropertyValue("letter-spacing") || "normal";
			if(letterSpacing && letterSpacing.toLowerCase() != "normal")
				textToDraw.letterSpacing = SVGUtil.getUserUnit(letterSpacing, currentFontSize, viewPortWidth, viewPortHeight, SVGUtil.FONT_SIZE);
			
			if(document.textDrawingInterceptor != null)
				document.textDrawingInterceptor(textToDraw);
			
			//If need to draw in right color, pass color inside format
			if(!hasComplexFill)
				textToDraw.color = getFillColor();
			
			return textToDraw;
		}
		
		protected function createTextSprite(text:String):SVGDrawnText {
			//Gest last bidiLevel considering overrides
			var direction:String = TextUtils.getParagraphDirection(text);
			
			//Patch text adding direction chars, this will ensure spaces around texts will work properly
//			if(direction == "rl")
//				text = String.fromCharCode(0x200F) + text + String.fromCharCode(0x200F);
//			else if(direction == "lr")
//				text = String.fromCharCode(0x200E) + text + String.fromCharCode(0x200E);

			//Setup text format, to pass to the TextDrawer
			var textToDraw:SVGTextToDraw = getTextToDraw(text);
			
			//Use configured textDrawer to draw text on a displayObject
			var drawer:TextFieldSVGTextDrawer = new TextFieldSVGTextDrawer();
			var drawnText:SVGDrawnText = drawer.drawText(textToDraw);
			var textField:TextField = drawnText.displayObject as TextField;
			if(textField){
				textField.embedFonts = false;
				textField.multiline = true;
				textField.wordWrap = true;
				textField.selectable = false;
			}
			
			//Change drawnText alpha if needed
			if(!hasComplexFill){
				if(hasFill)
					drawnText.displayObject.alpha = getFillOpacity();
				else
					drawnText.displayObject.alpha = 0;
			}
			
			//Adds direction to drawnTextInformation
			drawnText.direction = direction;
			
			return drawnText;
		}
		
		protected function get hasComplexFill():Boolean {
			var fill:String = finalStyle.getPropertyValue("fill");
			return fill && fill.indexOf("url") != -1;
		}
		
		private function getFillColor():uint {
			var fill:String = finalStyle.getPropertyValue("color");
			
			if(fill == null || fill.indexOf("url") > -1)
				return 0x000000;
			else
				return SVGColorUtils.parseToUint(fill);
		}
		
		private function getFillOpacity():Number {
			return Number(finalStyle.getPropertyValue("fill-opacity") || 1);
		}
		
		protected function getDirectionFromStyles():String {
			var direction:String = finalStyle.getPropertyValue("direction");
			
			if(direction){
				switch(direction){
					case "ltr" :
						return "lr";
					case "tlr" :
						return "rl";
				}
			}
			
			var writingMode:String = finalStyle.getPropertyValue("writing-mode");
			
			switch(writingMode){
				case "lr" :
				case "lr-tb" :
					return "lr";
				case "rl" :
				case "rl-tb" :
					return "rl";
				case "tb" :
				case "tb-rl" :
					return "tb";
			}
			
			return null;
		}
				
		public function doAnchorAlign(direction:String, textStartX:Number, textEndX:Number):void {
			var textAnchor:String = finalStyle.getPropertyValue("text-anchor") || "start";
			
			var anchorX:Number = getViewPortUserUnit(svgX, SVGUtil.WIDTH);
			
			var offsetX:Number = 0;
			
			if(direction == "lr"){
				if(textAnchor == "start")
					offsetX += anchorX  - textStartX;
				if(textAnchor == "middle")
					offsetX += anchorX  - (textEndX + textStartX)/2;
				else if(textAnchor == "end")
					offsetX += anchorX  - textEndX;
			} else {
				if(textAnchor == "start")
					offsetX += anchorX  - textEndX;
				if(textAnchor == "middle")
					offsetX += anchorX  - (textEndX + textStartX)/2;
				else if(textAnchor == "end")
					offsetX += anchorX  - textStartX;
			}
			
			offset(offsetX);
		}
		
		public function offset(offsetX:Number):void {
			if(_renderObjects == null)
				return;
			
			for each(var renderedText:DisplayObject in _renderObjects)
			{
				if(renderedText is SVGTextAreaContainer){
					var textContainer:SVGTextAreaContainer = renderedText as SVGTextAreaContainer;
					if(!textContainer.svgX)
						textContainer.offset(offsetX);
				} else {
					renderedText.x += offsetX;
				}
			}
		}
		
		public function hasOwnFill():Boolean {
			return style.getPropertyValue("color") != null && style.getPropertyValue("color") != "" && style.getPropertyValue("color") != "none";
		}
		
		override public function clone():Object {
			var c:SVGTextAreaContainer = super.clone() as SVGTextAreaContainer;

			for(var i:int = 0; i < this.numTextElements; i++){
				var textElement:Object = this.getTextElementAt(i);
				if(textElement is SVGElement)
					c.addTextElement((textElement as SVGElement).clone());
				else
					c.addTextElement(textElement);
			}
			
			return c;
		}
	}
}