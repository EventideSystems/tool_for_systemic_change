import jQuery from 'jquery'
import Turbolinks from 'turbolinks'

export default function () {
  const { defer, dispatch } = Turbolinks

  const handleEvent = function handleEvent(eventName, handler) {
    document.addEventListener(eventName, handler, false)
  }

  const translateEvent = function translateEvent({ from, to }) {
    const handler = (event) => {
      const dispatchedEvent = dispatch(to, { target: event.target, cancelable: event.cancelable, data: event.data })
      if (dispatchedEvent.defaultPrevented) dispatchedEvent.preventDefault()
    }
    handleEvent(from, handler)
  }

  translateEvent({ from: 'turbolinks:click', to: 'page:before-change' })
  translateEvent({ from: 'turbolinks:request-start', to: 'page:fetch' })
  translateEvent({ from: 'turbolinks:request-end', to: 'page:receive' })
  translateEvent({ from: 'turbolinks:before-cache', to: 'page:before-unload' })
  translateEvent({ from: 'turbolinks:render', to: 'page:update' })
  translateEvent({ from: 'turbolinks:load', to: 'page:change' })
  translateEvent({ from: 'turbolinks:load', to: 'page:update' })

  let loaded = false
  handleEvent('DOMContentLoaded', () => {
    defer(() => {
      loaded = true
    })
  })
  handleEvent('turbolinks:load', () => {
    if (loaded) dispatch('page:load')
  })

  if (jQuery.document) {
    jQuery.document.on('ajaxSuccess', (event, xhr, settings) => {
      if (jQuery.trim(xhr.responseText).length > 0) {
        dispatch('page:update')
      }
    })
  }
}