import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  toggle(event) {
    event.stopPropagation()
    const isOpen = this.element.classList.contains('open')
    document
      .querySelectorAll('.dropdown-trigger.open')
      .forEach((el) => el.classList.remove('open'))
    if (!isOpen) this.element.classList.add('open')
  }

  closeOnOutsideClick(event) {
    if (!this.element.contains(event.target)) {
      this.element.classList.remove('open')
    }
  }

  connect() {
    this._outsideClick = this.closeOnOutsideClick.bind(this)
    document.addEventListener('click', this._outsideClick)
  }

  disconnect() {
    document.removeEventListener('click', this._outsideClick)
  }
}
