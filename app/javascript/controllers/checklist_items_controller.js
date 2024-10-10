import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["newCommentForm"]

  showNewCommentForm(event) {
    debugger
    event.preventDefault()

    this.newCommentFormTarget.classList.remove("hidden")
  }

}
