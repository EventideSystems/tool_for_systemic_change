import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "filter", "grid" ]

  selectFilter(event) {
    $(this.gridTarget).find('.cell').addClass("hidden")
    
    switch(event.target.value)
    {
      case "Actual":
        $(this.gridTarget).find('.cell.actual').removeClass("hidden")
        break;
      case "Planned":
        $(this.gridTarget).find('.cell.planned').removeClass("hidden")
        break;
      case "No Comment":
        $(this.gridTarget).find('.cell.no-comment').removeClass("hidden")
        break;
      case "Gap in Effort":
        $(this.gridTarget).find('.cell.gap').removeClass("hidden")
        break;
    }
  }
}
