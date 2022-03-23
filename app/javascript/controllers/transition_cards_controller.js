import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "filter", "grid", "compactViewBtn" ]

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

  toggleCompactGridView(event) {
    event.preventDefault()

    if ($(this.compactViewBtnTarget).hasClass('btn-outline-secondary') == true) {
      $('#status-filter').prop('disabled', true)
      $('td.focus-area-cell').show()
      $('td.characteristic-cell').hide()
      $(this.compactViewBtnTarget).removeClass('btn-outline-secondary')
      $(this.compactViewBtnTarget).addClass('btn-primary')
    } else {
      $('#status-filter').prop('disabled', false)
      $('td.focus-area-cell').hide()
      $('td.characteristic-cell').show()
      $(this.compactViewBtnTarget).removeClass('btn-primary')
      $(this.compactViewBtnTarget).addClass('btn-outline-secondary')
    }
  }
}
