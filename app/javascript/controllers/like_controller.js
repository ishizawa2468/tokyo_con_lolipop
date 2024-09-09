import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [ "heart", "count" ]

    connect() {
        console.log("Like controller connected")
    }

    toggle(event) {
        event.preventDefault()
        const form = this.element

        fetch(form.action, {
            method: form.method,
            headers: {
                "Accept": "text/vnd.turbo-stream.html",
                "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
            },
            body: new FormData(form)
        })
            .then(response => response.text())
            .then(html => {
                Turbo.renderStreamMessage(html)
            })
            .catch(error => console.error('Error:', error))
    }

    updateUI(event) {
        const fragment = event.detail?.newContent
        if (fragment) {
            const newHeart = fragment.querySelector('[data-like-target="heart"]')
            const newCount = fragment.querySelector('[data-like-target="count"]')

            if (newHeart) this.heartTarget.className = newHeart.className
            if (newCount) this.countTarget.textContent = newCount.textContent
        }
    }
}
