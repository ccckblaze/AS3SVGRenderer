package com.lorentz.SVG.text
{
	import com.lorentz.SVG.data.text.SVGDrawnText;
	import com.lorentz.SVG.data.text.SVGTextToDraw;
	import flash.display.DisplayObject;

	public interface ISVGTextDrawer
	{
		function start():void;
		
		function drawText(data:SVGTextToDraw, textSprite:DisplayObject = null):SVGDrawnText;
		
		function end():void;
	}
}