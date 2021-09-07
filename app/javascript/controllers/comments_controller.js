import Rails from "@rails/ujs";
import { Controller } from "stimulus";

export default class extends Controller {
  static targets = [ 
    "form", "characteristic", "checklistItem", "saveNewBtn", "updateExistingBtn", "removeCurrentBtn" 
  ]

  open(event) {
    event.preventDefault()
    $(this.formTarget).show()
  }

  close(event) {
    event.preventDefault()
    $(this.formTarget).hide()
  }       

  onPostSuccess(event) {
    let status = $(this.formTarget).find('input[name="checklist_item[current_comment_status]"]:checked').val()
    let characteristic_element = $(this.characteristicTarget);

    characteristic_element.removeClass('actual');
    characteristic_element.removeClass('planned');
    characteristic_element.removeClass('suggestion');
    characteristic_element.removeClass('more-information');

    characteristic_element.addClass(status);

    $(this.checklistItemTarget).prop('checked', (status === 'actual') || (status === 'planned'));

    $(this.formTarget).hide()
  }

  saveNew(event) {
    $(updateExistingBtn).prop('disabled', false);
    $(removeCurrentBtn).prop('disabled', false);
  }
  // update() {
  //   Rails.fire(this.element, 'submit');
  // }
}
