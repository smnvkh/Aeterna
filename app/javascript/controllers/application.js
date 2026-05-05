import { Application } from '@hotwired/stimulus'

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus = application

export { application }

document.addEventListener('turbo:load', () => {
  const menu = document.querySelector('.S_MenuBar')

  if (!menu) return

  window.addEventListener('scroll', () => {
    if (window.scrollY > 10) {
      menu.classList.add('scrolled')
    } else {
      menu.classList.remove('scrolled')
    }
  })
})
