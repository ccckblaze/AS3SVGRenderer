/**
* WeakProxyReference by Grant Skinner. June 4, 2006
* Visit www.gskinner.com/blog for documentation, updates and more free code.
*
* You may distribute this class freely, provided it is not modified in any way (including
* removing this header or changing the package path).
*
* Please contact info@gskinner.com prior to distributing modified versions of this class.
*/

package com.gskinner.utils {
	import flash.utils.Dictionary;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	
	public namespace weak_proxy_reference = "http://gskinner.com/flash/namespaces/weak_proxy_reference/";
	
	dynamic public class WeakProxyReference extends Proxy {
		protected var dictionary:Dictionary;
		
		public function WeakProxyReference(p_object:Object) {
			dictionary = new Dictionary(true);
			dictionary[p_object] = null;
		}
		
		weak_proxy_reference function get():Object {
			for (var n:Object in dictionary) { return n; }
			return null;
		}
		
		private function getObject():Object {
			for (var n:Object in dictionary) { return n; }
			throw new ReferenceError("Reference Error: Object is no longer available through WeakProxyReference, it may have been removed from memory.");
			return null;
		}
		
		flash_proxy override function callProperty(p_methodName:*, ...p_args):* {
			var funct:* = getObject()[p_methodName];
			if (!(funct is Function)) {
				throw new TypeError("TypeError: Cannot call "+p_methodName.toString()+" through WeakProxyReference, it is not a function.");
			} else {
				return funct.apply(null,p_args);
			}
		}
		
		flash_proxy override function getProperty(p_propertyName:*):* {
			return getObject()[p_propertyName];
		}
		
		flash_proxy override function setProperty(p_propertyName:*,p_value:*):void {
			getObject()[p_propertyName] = p_value;
		}
		
		flash_proxy override function deleteProperty(p_propertyName:*):Boolean {
			return delete(getObject()[p_propertyName]);
		}
	}
}