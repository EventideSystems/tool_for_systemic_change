import { Controller } from "@hotwired/stimulus"

const DARK_MODE = 'dark';
const LIGHT_MODE = 'light';

export default class extends Controller {

  connect() {
    this.updateTheme();

    document.addEventListener("turbo:load", this.updateTheme.bind(this))
    document.addEventListener("DOMContentLoaded", this.updateTheme.bind(this))
  }

  disconnect() {
    document.removeEventListener("turbo:load", this.updateTheme.bind(this))
    document.removeEventListener("DOMContentLoaded", this.updateTheme.bind(this))
  }

  updateTheme() {
    const prefersDarkScheme = window.matchMedia('(prefers-color-scheme: dark)').matches;
    const storedTheme = localStorage.getItem('color-theme');
    const theme = storedTheme || (prefersDarkScheme ? DARK_MODE : LIGHT_MODE);
    this.setTheme(theme);
  }

  setTheme(theme) {
    const isDarkMode = theme === DARK_MODE;
    localStorage.setItem('color-theme', theme);
    document.documentElement.classList.toggle(DARK_MODE, isDarkMode);
    document.documentElement.classList.toggle(LIGHT_MODE, !isDarkMode);
    document.documentElement.style.colorScheme = theme;
  }
}
