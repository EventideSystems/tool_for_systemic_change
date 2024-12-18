import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "toggle" ]

  connect() {
    if (localStorage.getItem('color-theme') === 'dark' || (!('color-theme' in localStorage) && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
      this.toggleTarget.innerHTML = 'Dark mode &checkmark;'
      localStorage.setItem('color-theme', 'dark');
      document.documentElement.classList.add('dark');
      document.documentElement.classList.remove('light');
      window.document.documentElement.style.colorScheme = 'dark'
    } else {
      this.toggleTarget.innerHTML = 'Dark mode';
      localStorage.setItem('color-theme', 'light');
      document.documentElement.classList.add('light');
      document.documentElement.classList.remove('dark');
      window.document.documentElement.style.colorScheme = 'light'
    }


  }

  toggle() {
    this.toggleTarget.innerHTML = this.toggleTarget.innerHTML === 'Dark mode' ? 'Dark mode &checkmark;' : 'Dark mode';

    if (this.toggleTarget.innerHTML === 'Dark mode') {
      localStorage.setItem('color-theme', 'light');
      document.documentElement.classList.add('light');
      document.documentElement.classList.remove('dark');
      window.document.documentElement.style.colorScheme = "light"
    } else {
      localStorage.setItem('color-theme', 'dark');
      document.documentElement.classList.add('dark');
      document.documentElement.classList.remove('light');
      window.document.documentElement.style.colorScheme = "dark"
    }
  }
}
