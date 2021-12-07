import Rails from "@rails/ujs";
import { Controller } from "stimulus";

export default class extends Controller {
  static targets = [ 
    "form", "newComment", "currentComment", "characteristic", "checklistItem", "saveNewBtn", 
    "updateExistingBtn", "removeCurrentBtn", "missingStatusAlert", "missingCommentAlert" 
  ]

  open(event) {
    event.preventDefault()

    let newStatusElement = $(this.newCommentTarget).find('input[name="checklist_item[new_comment_status]"]:checked')
    let newTextElement = $(this.newCommentTarget).find('textarea[name="checklist_item[new_comment]"]')

    newTextElement.val('')
    newStatusElement.val('')

    $(this.formTarget).show()
  }

  close(event) {
    event.preventDefault()
    $(this.formTarget).hide()
  }

  validateNewComment(event) {
    let status = $(this.newCommentTarget).find('input[name="checklist_item[new_comment_status]"]:checked').val()
    let comment = $(this.newCommentTarget).find('textarea[name="checklist_item[new_comment]"]').val()

    if (status == undefined) {
      event.preventDefault()
      $(this.missingStatusAlertTarget).show()
    } else {
      $(this.missingStatusAlertTarget).hide()
    }

    if (comment == '') {
      event.preventDefault()
      $(this.missingCommentAlertTarget).show()
    } else {
      $(this.missingCommentAlertTarget).hide()
    }

  }

  onUpdateCommentSuccess(event) {
    let status = $(this.currentCommentTarget).find('input[name="checklist_item[current_comment_status]"]:checked').val()

    this.updateCharacteristic(status)
    $(this.formTarget).hide()
  }

  onNewCommentSuccess(event) {

    let newStatusElement = $(this.newCommentTarget).find('input[name="checklist_item[new_comment_status]"]:checked')
    let currentStatusElement = $(this.currentCommentTarget).find('input[name="checklist_item[current_comment_status]"]:checked')

    let newTextElement = $(this.newCommentTarget).find('textarea[name="checklist_item[new_comment]"]')
    let currentTextElement = $(this.currentCommentTarget).find('textarea[name="checklist_item[current_comment]"]')
    
    currentTextElement.val(newTextElement.val())
    currentStatusElement.val([newStatusElement.val()])

    $(this.currentCommentTarget).find('input[name="checklist_item[current_comment_status]"][value="' + newStatusElement.val() + '"]').prop('checked', true)
    $(this.newCommentTarget).find('input[name="checklist_item[new_comment_status]"][value="' + newStatusElement.val() + '"]').prop('checked', false)

    this.updateCharacteristic(newStatusElement.val())
    $(this.formTarget).hide()
    $(this.currentCommentTarget).show()

 
  }

  updateCharacteristic(status) {
    let characteristic_element = $(this.characteristicTarget);

    characteristic_element.removeClass('actual');
    characteristic_element.removeClass('planned');
    characteristic_element.removeClass('suggestion');
    characteristic_element.removeClass('more-information');

    characteristic_element.addClass(status);

    $(this.checklistItemTarget).prop('checked', (status == 'actual' || status == 'planned'));
  }
}
