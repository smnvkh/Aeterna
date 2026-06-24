import { Application } from '@hotwired/stimulus'

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus = application

export { application }

document.addEventListener('turbo:load', () => {
  const menu = document.querySelector('.S_MenuBar')

  if (!menu) return

  const cover = document.querySelector('.Cover')
  const getThreshold = () => (cover ? cover.offsetHeight : 10)

  window.addEventListener('scroll', () => {
    if (window.scrollY > getThreshold()) {
      menu.classList.add('scrolled')
    } else {
      menu.classList.remove('scrolled')
    }
  })
})
