// import Rails from "@rails/ujs";
import { Controller } from "@hotwired/stimulus"


export default class extends Controller {

  static targets = ["select"]

  connect() {
    HSSelect.autoInit();

    let selectInstance = HSSelect.getInstance(this.selectTarget);
    let options = selectInstance.dropdown.querySelectorAll('[data-value]');

    let val = Array.from(this.selectTarget.selectedOptions).map(({value})=> value);

    options.forEach((option) => {
      let icon = option.querySelector('[data-icon]');

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
        let icon = option.querySelector('[data-icon]');

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

}
