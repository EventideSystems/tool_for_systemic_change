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

// Example Usage:

// <div class="grow" data-controller="split tags">
//
//   <div class="flex" data-split-target="split">
//     <!-- List Container -->
//     <div class="w-2/3 p-4 overflow-auto max-h-screen scrollbar-red">
//       <!-- List -->
//     </div>
//
//     <div class="w-1/3 p-4 overflow-auto max-h-screen" id="edit-form-container">
//      <!-- Details -->
//     </div>
//   </div>
// </div>
