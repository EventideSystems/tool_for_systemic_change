import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["tag", "editForm"];

  connect() {
    this.resetBackgrounds();

    this.tagTargets.filter(tag => tag.dataset.active === 'true').forEach(tag => {
      tag.classList.add("bg-blue-500");
    })
  }

  highlight(event) {
    this.resetBackgrounds();
    this.resetActiveTags();
    const tag = event.currentTarget.closest("[data-tags-target='tag']");
    if (tag) {
      tag.classList.add("bg-blue-500");
      tag.dataset.active = "true";
    }

    const editUrl = event.currentTarget.getAttribute("href");
    this.loadEditForm(editUrl);
    event.preventDefault(); // Prevent the default link behavior
  }

  resetActiveTags() {
    // Function to reset all tags to inactive
    this.tagTargets.forEach(tag => {
      tag.dataset.active = "false";
    });
  }

  resetBackgrounds() {
    this.tagTargets.forEach(tag => {
      tag.classList.remove("bg-blue-500");
    });
  }

  loadEditForm(url) {
    const frame = this.editFormTarget;
    frame.src = url;
  }



}
