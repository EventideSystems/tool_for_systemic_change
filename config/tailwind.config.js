const defaultTheme = require('tailwindcss/defaultTheme')
const shadcnConfig = require("./shadcn.tailwind.js");

module.exports = {
  darkMode: 'class',
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/services/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,html}',
    './app/components/**/*.{rb,erb}',
    './vendor/javascript/tailwindcss-animate.js',
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/container-queries'),
    require('../vendor/javascript/tailwindcss--plugin.js'),
  ],
  ...shadcnConfig,
}
