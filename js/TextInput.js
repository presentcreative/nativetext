import ui.View as View;
import ui.TextView as TextView;
import lib.Enum as Enum;
import device;
import animate;

var InputPrompt = device.get('InputPrompt');

var currentTextInput;

exports = Class(TextView, function (supr) {

	var defaults = {
		prompt: '',
		autoShowKeyboard: false,
		isPassword: false
	};

	this.init = function (opts) {
		this._opts = merge(opts, defaults)

		supr(this, 'init', [this._opts]);
		
		this._keyboardOn = false;
		
		//If keyboard is not defined, assign it the default keybaord
		var keyboard = opts.keyboard === undefined ? "DEFAULT" : opts.keyboard;
		this.setKeyboard(keyboard);
		
		this.txtBG = new View({
			width: this.style.width,
			height: this.style.height,
			x: 0,
			y: 0,
			backgroundColor:"#ffffff",
			opacity:0.2,
			visible:false,
			superview: this
		});
		
		this.on("InputSelect", bind(this,function(){
			this.showKeyboard();
		}));		
		
		GLOBAL.textInputs.push(this);
	};

	this.showPrompt = function() {
		this.showKeyboard();
	}
		
	this.showKeyboard = function() {
		if(this._keyboardOn !== true) {
			this._keyboardOn = true;
			
			this.setText("");
			
			var e = {id: this.uid, keyboardType: this._keyboard, showText: this._text, method:"showKeyboard"}
			NATIVE.plugins.sendEvent("NativeText", "onRequest", JSON.stringify(e));
			currentTextInput = this;
		}
	}

	this.setKeyboard = function(keyboard) {
		var key = this.KEYBOARDS[keyboard];
		
		if(!key) {
			key = this.KEYBOARDS.DEFAULT;
		};
		
		this._keyboard = key;
	}
	
	this.receiveText = function(txt) {
		console.log("{nativeText} received text");
		this.setText(txt);
		this.publish('Change', txt);
	}
	
	this.hideKeyboard = function() {
		this._keyboardOn = false;
		this.txtBG.hide();
//		currentTextInput = undefined;
	}
	
	this.KEYBOARDS = Enum(
		"DEFAULT",
		"EMAIL",
		"URL",
		"PHONE"
	);
	
	NATIVE.events.registerHandler('nativeText', function(e) {
		console.log("{nativeText} received return event");
		if (e.method == "textChanged") {
			console.log("{nativeText} text "+e.uid+" changed to "+e.showText);
			currentTextInput.receiveText(e.showText);
		}else if (e.method == "hideKeyboard") {
			console.log("{nativeText} hid keyboard");
			currentTextInput.hideKeyboard();
			animate(GC.app.view).now({y:0});
		}else if (e.method == "keyboardShown") {
			console.log("{nativeText} Keyboard Shown JS return");
			var currentTextInputPosition = currentTextInput.getPosition();
			var keyboardHeight = e.keyboardHeight*2/GC.app.gameConfig.scaleFactor;
			currentTextInput.txtBG.show();
			//console.log("{Text Pos.y}"+currentTextInputPosition.y);
			//console.log("{Text Pos.height}"+currentTextInputPosition.height);
			//console.log("{Top View.height}"+GC.app.view.style.height);
			//console.log("{keyboardHeight}"+e.keyboardHeight);
 			if(currentTextInputPosition.y + currentTextInputPosition.height 
 							>= GC.app.view.style.height - keyboardHeight) {
				var moveNeeded = (GC.app.view.style.height - keyboardHeight) 
								- (currentTextInputPosition.y + currentTextInputPosition.height) 
								- 50;
				animate(GC.app.view).now({y:moveNeeded}); 
 			}
		}
	});
});