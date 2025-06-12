import { Controller } from "@hotwired/stimulus";

export default class extends Controller {

  handleClick(event) {
    Turbo.cache.clear();
  }
}