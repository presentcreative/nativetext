import animate;

if(GLOBAL.textInputs === undefined) {
	//initialize GLOBAL.textInputs as an array
	GLOBAL.textInputs = [];
}

NATIVE.events.registerHandler('keyboardShown', function(e) {
	//checks to see if main view needs to slide up with keyboard or not
	if(!e.failed) {
		for(var i in GLOBAL.textInputs) {
			if(GLOBAL.textInputs[i]._id === e.id) {
				if(GLOBAL.textInputs[i].style.y >= GC.app.view.style.height - e.keyboardHeight) {
					animate(GC.app.view).now({y:0-e.keyboardHeight}); 
				}
			}
		}
	}
});

NATIVE.events.registerHandler('textChanged', function(e) {
	//relays new text string to desired TextView
	if(!e.failed) {
		for(var i in GLOBAL.textInputs) {
			if(GLOBAL.textInputs[i]._id === e.id) {
				GLOBAL.textInputs[i].receiveText(e.showText);
			}
		}
	}
});

NATIVE.events.registerHandler('hideKeyboard', function(e) {
	//resets keyboard parameters
	if(!e.failed) {
		for(var i in GLOBAL.textInputs) {
			if(GLOBAL.textInputs[i]._id === e.id) {
				GLOBAL.textInputs[i].hideKeyboard();
			}
		}
	}
	animate(GC.app.view).now({y:0});
});
