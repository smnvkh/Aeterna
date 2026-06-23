import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['toast']

  copy(event) {
    const text = event.currentTarget.dataset.copyText
    if (!text) return

    navigator.clipboard.writeText(text)
    this.showToast()
  }

  showToast() {
    if (!this.hasToastTarget) return
    if (this.hideTimeout) clearTimeout(this.hideTimeout)

    this.toastTarget.classList.add('CopyToast--visible')

    this.hideTimeout = setTimeout(() => {
      this.toastTarget.classList.remove('CopyToast--visible')
    }, 2000)
  }
}
