// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

document.addEventListener("turbo:before-stream-render", (event) => {
    const streamElement = event.target
    const stimulusControllers = document.querySelectorAll('[data-controller="like"]')
    stimulusControllers.forEach(controller => {
        if (streamElement.target === controller.id) {
            controller.dispatchEvent(new CustomEvent('like:update', {
                detail: { newContent: streamElement.firstElementChild },
                bubbles: true
            }))
        }
    })
})

document.addEventListener("turbo:before-stream-render", function(event) {
    console.log("Turbo Stream before render:", event.target);
});

document.addEventListener("turbo:after-stream-render", function(event) {
    console.log("Turbo Stream after render:", event.target);
});

document.addEventListener("turbo:frame-render", function(event) {
    console.log("Turbo Frame render:", event.target);
});
