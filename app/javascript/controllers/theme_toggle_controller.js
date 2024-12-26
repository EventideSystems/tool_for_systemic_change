import { Controller } from "@hotwired/stimulus"

const DARK_MODE = 'dark';
const LIGHT_MODE = 'light';

export default class extends Controller {
  static targets = ["toggle"]

  connect() {
    this.updateTheme();
  }

  toggle() {
    const currentTheme = localStorage.getItem('color-theme');
    const newTheme = currentTheme === DARK_MODE ? LIGHT_MODE : DARK_MODE;
    this.setTheme(newTheme);
  }

  updateTheme() {
    const prefersDarkScheme = window.matchMedia('(prefers-color-scheme: dark)').matches;
    const storedTheme = localStorage.getItem('color-theme');
    const theme = storedTheme || (prefersDarkScheme ? DARK_MODE : LIGHT_MODE);
    this.setTheme(theme);
  }

  setTheme(theme) {
    const isDarkMode = theme === DARK_MODE;
    this.toggleTarget.innerHTML = isDarkMode ? 'Dark mode &checkmark;' : 'Dark mode';
    localStorage.setItem('color-theme', theme);
    document.documentElement.classList.toggle(DARK_MODE, isDarkMode);
    document.documentElement.classList.toggle(LIGHT_MODE, !isDarkMode);
    document.documentElement.style.colorScheme = theme;
  }
}
