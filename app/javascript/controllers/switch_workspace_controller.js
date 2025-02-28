import { Controller } from "@hotwired/stimulus";

export default class extends Controller {

  handleClick(event) {
    debugger
    Turbo.cache.clear();
  }
}