var navCont;

window.addEventListener("load", function(){
    navCont = document.querySelector('.menu-content');
}, false);

function toggNavBar(self){
    self.classList.toggle('change');
    navCont.classList.toggle('openNav');
}