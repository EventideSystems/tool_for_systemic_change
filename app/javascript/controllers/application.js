import { Application } from "@hotwired/stimulus"
import '@preline/select'

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

function startFrontController(event) {
  document.removeEventListener('DOMContentLoaded', startFrontController)
  new FrontController().start()
}

function updateControls() {
  // Initialize custom select elements
  HSSelect.autoInit()

  // Ensure native controls use the correct color theme
  // Retrieve the color theme from localStorage
  let colorTheme = localStorage.getItem('color-theme');

  // If the color theme is not set, default to 'light' and store it in localStorage
  if (!colorTheme) {
    colorTheme = 'light';
    localStorage.setItem('color-theme', colorTheme);
  }

  // Apply the color theme to the document
  document.documentElement.style.colorScheme = colorTheme;
}

document.addEventListener("turbo:load", updateControls)
document.addEventListener("DOMContentLoaded", updateControls)

export { application }

