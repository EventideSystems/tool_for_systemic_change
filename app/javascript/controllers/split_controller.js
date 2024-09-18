import { Controller } from "@hotwired/stimulus"
import Split from "split.js"

export default class extends Controller {
  static targets = ['split']

  connect() {
    Split(this.splitTarget.children, {
      // sizes: [50, 50],
      minSize: 200,
      gutterSize: 3,
      cursor: 'cursor-ew-resize'
    });
  }

  disconnect() {
  }
}
