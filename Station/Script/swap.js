'use strict';

(function (run) {
	if (document.readyState !== 'loading') return this();
	else return document.addEventListener('DOMContentLoaded', this);
}.call(function () {
    var swap = document.querySelector('input[type="checkbox"][name="swap"]');
    var swapItem = document.querySelector('.content');
    function update() {
        if (swap.checked)
            swapItem.classList.add('ctn_swaped');
        else
            swapItem.classList.remove('ctn_swaped');
    }
    if (swap !== null) {
        swap.addEventListener('input', update);
        return update();
    }
}));