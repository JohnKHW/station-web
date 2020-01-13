'use strict';

(function () {
	if (document.readyState !== 'loading') return this();
	else return document.addEventListener('DOMContentLoaded', this);
}.call(function () {
	var xhtml = 'http://www.w3.org/1999/xhtml';
	var list_radio = document.querySelectorAll('input[type="radio"]');
	function answered() {
		var button_submit = document.querySelector('input[type="submit"]');
		var button_redo = document.createElementNS(xhtml, 'input');
		button_redo.setAttribute('type', 'button');
		button_redo.setAttribute('value', 'Re-take this Quiz');
		button_redo.addEventListener(
			'click',
			function () {
				for (var i=0; i<list_radio.length; ++i)
					list_radio.item(i).hidden = false;
				button_submit.hidden = false;
				button_redo.parentNode.removeChild(button_redo);
			}
		);
		button_submit.parentNode.insertBefore(button_redo, button_submit);
		for (var i=0; i<list_radio.length; ++i)
			list_radio.item(i).hidden = true;
		button_submit.hidden = true;
	}
	for (var i=0; i<list_radio.length; ++i)
		if (list_radio.item(i).checked)
			return answered();
}));
