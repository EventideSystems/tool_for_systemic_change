import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source", "button"]

  connect() {

  }

  copy() {
    const text = this.sourceTarget.textContent || this.sourceTarget.value;

    navigator.clipboard.writeText(text.trim()).then(() => {
      this.buttonTarget.textContent = 'Copied!';
    }).catch(err => {
      this.buttonTarget.textContent = 'Failed to copy';
    });
  }

}
