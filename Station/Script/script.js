var navCont;
var slides = document.getElementsByClassName('slide');
var btnSlides = document.getElementsByClassName('btn-slide');
var subjectCourses = document.getElementsByClassName('content');
var slideIndex = 0;
var t;
window.onload = function() {
    navCont = document.querySelector('.menu-content');
    setShowImgIndex(slideIndex);
};
function toggNavBar(self){
    self.classList.toggle('change');
    navCont.classList.toggle('openNav');
}
function setShowImgIndex(index){
    btnSlides[slideIndex].style.background = "transparent";
    slides[slideIndex].style.display = "none";
    btnSlides[index].style.background = "white";
    slides[index].style.display = "block";
    slideIndex = index;
    var nextSlide = (index+1) % slides.length;
    stopAutoSlide();
    t = setTimeout('setShowImgIndex('+nextSlide+')', 3000);
}
function contineSlide(){
    setShowImgIndex(slideIndex);
}
function stopAutoSlide(){ // stop the auto slide show
    clearTimeout(t);
    t=0;
}
function switchSubject(index){
    subjectCourses[index].style.display = "block";
}