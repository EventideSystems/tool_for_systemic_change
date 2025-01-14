// Source: https://stackoverflow.com/questions/70994322/how-to-call-confirm-prompt-using-button-to-in-rails-with-turbo
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { message: String };

  confirm(event) {
    if (!(window.confirm(this.messageValue))) {
      event.preventDefault();
      event.stopImmediatePropagation();
    };
  };
}
