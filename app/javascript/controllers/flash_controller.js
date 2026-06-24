import { Controller } from "@hotwired/stimulus"

// Автоматически прячет flash-сообщение через несколько секунд, чтобы
// не нужно было перезагружать страницу, чтобы оно пропало.
export default class extends Controller {
  static values = { delay: { type: Number, default: 3000 } }

  connect() {
    this.timer = setTimeout(() => this.dismiss(), this.delayValue)
  }

  disconnect() {
    clearTimeout(this.timer)
  }

  dismiss() {
    this.element.classList.add("FlashMessage--hiding")
    setTimeout(() => this.element.remove(), 300)
  }
}
