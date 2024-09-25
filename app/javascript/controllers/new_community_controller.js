import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["form"];

  toggleForm() {
    this.formTarget.classList.toggle("hidden");
  }
}
