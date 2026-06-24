import { Controller } from "@hotwired/stimulus"

// Moves child layers at different speeds while the user scrolls past the
// section, creating a depth effect. Speed per layer is read from
// data-parallax-speed (negative values move up, positive move down).
export default class extends Controller {
  static targets = ["layer"]

  connect() {
    this.ticking = false
    this.onScroll = this.onScroll.bind(this)
    window.addEventListener("scroll", this.onScroll, { passive: true })
    this.update()
  }

  disconnect() {
    window.removeEventListener("scroll", this.onScroll)
  }

  onScroll() {
    if (this.ticking) return
    this.ticking = true
    requestAnimationFrame(() => {
      this.update()
      this.ticking = false
    })
  }

  update() {
    const rect = this.element.getBoundingClientRect()
    if (rect.bottom < 0 || rect.top > window.innerHeight) return

    const progress = rect.top * -1

    this.layerTargets.forEach((layer) => {
      const speed = parseFloat(layer.dataset.parallaxSpeed || 0)
      layer.style.transform = `translateY(${progress * speed}px)`
    })
  }
}
