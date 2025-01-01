// import Rails from "@rails/ujs";
import { Controller } from "@hotwired/stimulus"


export default class extends Controller {

  static targets = ["select", "clear"]

  connect() {
    HSSelect.autoInit();

    this.clearTarget.addEventListener("click", this.clear.bind(this))

    let selectInstance = HSSelect.getInstance(this.selectTarget);

    let options = selectInstance.dropdown.querySelectorAll('[data-value]');

    let val = Array.from(this.selectTarget.selectedOptions).map(({value})=> value);

    options.forEach((option) => {
      let icon = option.querySelector('[data-select-icon]');

      if (icon) {
        if (icon && val.includes(option.dataset.value)) {
          icon.classList.remove('hidden');
        }
        else {
          icon.classList.add('hidden');
        }
      }
    });


    selectInstance.on('change', (val) => {
      let options = selectInstance.dropdown.querySelectorAll('[data-value]');
      options.forEach((option) => {
        let icon = option.querySelector('[data-select-icon]');

        if (icon) {
          if (icon && val.includes(option.dataset.value)) {
            icon.classList.remove('hidden');
          }
          else {
            icon.classList.add('hidden');
          }
        }
      });

      var event = new Event('change');
      this.selectTarget.dispatchEvent(event);
    });
  }

  disconnect() {
    HSSelect.getInstance(this.selectTarget).destroy()
  }

  clear() {
    let selectInstance = HSSelect.getInstance(this.selectTarget);
    let options = selectInstance.dropdown.querySelectorAll('[data-value]');
    options.forEach((option) => {
      let icon = option.querySelector('[data-select-icon]');
      icon.classList.add('hidden');
    });
    selectInstance.setValue([]);

    var event = new Event('change');
    this.selectTarget.dispatchEvent(event);
  }

}
