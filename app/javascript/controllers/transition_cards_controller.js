import { Controller } from "stimulus"


export default class extends Controller {
  static targets = [ "filter", "grid" ]

  connect() {
    // Source: https://github.com/pascallaliberte/stimulus-turbolinks-select2/blob/master/_assets/controllers/multi-select_controller.js
    this.select2mount()

    document.addEventListener("turbolinks:before-cache", () => {
      this.select2unmount()
    }, { once: true })
  }

  applyFilter(selected) {
    $(this.gridTarget).find('.cell').addClass("hidden")

    if (selected.indexOf('Actual') !== -1) {
      $(this.gridTarget).find('.cell.actual').removeClass("hidden")
    }

    if (selected.indexOf('Planned') !== -1) {
      $(this.gridTarget).find('.cell.planned').removeClass("hidden")
    }

    if (selected.indexOf('No Comment') !== -1) {
      $(this.gridTarget).find('.cell.no-comment').removeClass("hidden")
    }

    if (selected.indexOf('Gap in Effort') !== -1) {
      $(this.gridTarget).find('.cell.gap').removeClass("hidden")
    }
  }

  select2mount() {
    var context = this

    $(this.filterTarget).select2({
      dropdownAutoWidth: true,
      multiple: true
    }).on('select2:select select2:unselect', function (e) {
      var selected = $(e.target).select2('data').map(function(v) { return v['text']})
      context.applyFilter(selected)
    });
  }

  select2unmount() {
    $(this.filterTarget).select2('destroy');
  }
}
