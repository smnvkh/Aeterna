import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "zoom", "zoomTrack", "zoomTick", "grid"]

  submitForm() {
    this.formTarget.requestSubmit()
  }

  incrementZoom() {
    this.setZoom(this.currentZoom + 1)
    this.submitForm()
  }

  decrementZoom() {
    this.setZoom(this.currentZoom - 1)
    this.submitForm()
  }

  startDrag(event) {
    event.preventDefault()
    this.updateFromPointer(event)

    this.onDragMove = (e) => this.updateFromPointer(e)
    this.onDragEnd = () => {
      document.removeEventListener("pointermove", this.onDragMove)
      document.removeEventListener("pointerup", this.onDragEnd)
      this.submitForm()
    }

    document.addEventListener("pointermove", this.onDragMove)
    document.addEventListener("pointerup", this.onDragEnd)
  }

  updateFromPointer(event) {
    const rect = this.zoomTrackTarget.getBoundingClientRect()
    const ratio = Math.min(Math.max((event.clientX - rect.left) / rect.width, 0), 1)
    const level = Math.round(ratio * (this.maxZoom - 1)) + 1
    this.setZoom(level)
  }

  setZoom(level) {
    const clamped = Math.min(Math.max(level, 1), this.maxZoom)
    if (clamped === this.currentZoom) return

    this.zoomTarget.value = clamped
    this.zoomTickTargets.forEach((tick) => {
      tick.classList.toggle("TimelineZoomTick--active", parseInt(tick.dataset.level, 10) === clamped)
    })
  }

  get currentZoom() {
    return parseInt(this.zoomTarget.value, 10)
  }

  get maxZoom() {
    return parseInt(this.zoomTrackTarget.dataset.maxZoom, 10)
  }
}
