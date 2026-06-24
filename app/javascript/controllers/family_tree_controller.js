import { Controller } from '@hotwired/stimulus'

const MIN_ZOOM = 0.6
const MAX_ZOOM = 1.6
const STEP = 0.15
const LONG_PRESS_MS = 500
const TRANSITION_MS = 250

export default class extends Controller {
  static targets = ['canvas', 'svg', 'zoomTrack', 'zoomTick']

  connect() {
    this.zoom = 1
    this.updateZoomVar()
    this.updateTicks()

    this.resizeObserver = new ResizeObserver(() => this.draw())
    this.resizeObserver.observe(this.canvasTarget)

    this.onDocumentPointerDown = this.onDocumentPointerDown.bind(this)
    document.addEventListener('pointerdown', this.onDocumentPointerDown)

    requestAnimationFrame(() => this.draw())
  }

  disconnect() {
    this.resizeObserver?.disconnect()
    document.removeEventListener('pointerdown', this.onDocumentPointerDown)
    this.cancelLongPress()
    this.stopDrawLoop()
  }

  zoomIn() {
    this.setZoom(this.zoom + STEP)
  }

  zoomOut() {
    this.setZoom(this.zoom - STEP)
  }

  zoomReset() {
    this.setZoom(1)
  }

  startTrackDrag(event) {
    this.setZoomFromTrackEvent(event)

    this.onTrackDrag = (e) => this.setZoomFromTrackEvent(e)
    this.onTrackDragEnd = () => {
      document.removeEventListener('pointermove', this.onTrackDrag)
      document.removeEventListener('pointerup', this.onTrackDragEnd)
    }

    document.addEventListener('pointermove', this.onTrackDrag)
    document.addEventListener('pointerup', this.onTrackDragEnd)
  }

  setZoomFromTrackEvent(event) {
    const rect = this.zoomTrackTarget.getBoundingClientRect()
    // "+" сверху — значит верх трека должен соответствовать MAX_ZOOM.
    const ratio = Math.min(
      Math.max((event.clientY - rect.top) / rect.height, 0),
      1
    )
    this.setZoom(MAX_ZOOM - ratio * (MAX_ZOOM - MIN_ZOOM))
  }

  setZoom(value) {
    this.zoom = Math.min(Math.max(value, MIN_ZOOM), MAX_ZOOM)
    this.updateZoomVar()
    this.updateTicks()
    this.runDrawLoop()
  }

  updateZoomVar() {
    this.canvasTarget.style.setProperty('--tree-zoom', this.zoom)
  }

  // Подсвечивает деление трека, ближайшее к текущему зуму. Деления идут
  // сверху вниз, "+" сверху — значит первое деление соответствует MAX_ZOOM.
  updateTicks() {
    if (!this.hasZoomTickTarget) return

    const ratio = 1 - (this.zoom - MIN_ZOOM) / (MAX_ZOOM - MIN_ZOOM)
    const activeIndex = Math.round(ratio * (this.zoomTickTargets.length - 1))

    this.zoomTickTargets.forEach((tick, index) => {
      tick.classList.toggle('FamilyTreeZoomTick--active', index === activeIndex)
    })
  }

  // Перерисовывает линии каждый кадр на время CSS-перехода, чтобы они
  // плавно следовали за анимирующимися размерами/отступами узлов.
  runDrawLoop() {
    this.stopDrawLoop()
    const start = performance.now()

    const tick = () => {
      this.draw()
      if (performance.now() - start < TRANSITION_MS) {
        this.drawLoopId = requestAnimationFrame(tick)
      }
    }

    tick()
  }

  stopDrawLoop() {
    if (this.drawLoopId) {
      cancelAnimationFrame(this.drawLoopId)
      this.drawLoopId = null
    }
  }

  draw() {
    let edges = []
    try {
      edges = JSON.parse(this.canvasTarget.dataset.edges || '[]')
    } catch (e) {
      edges = []
    }

    const svg = this.svgTarget
    svg.innerHTML = ''

    const canvasRect = this.canvasTarget.getBoundingClientRect()
    const nodes = this.canvasTarget.querySelectorAll('[data-tree-id]')
    const centers = {}

    nodes.forEach((node) => {
      const id = node.dataset.treeId
      const rect = node.getBoundingClientRect()
      centers[id] = {
        x: rect.left + rect.width / 2 - canvasRect.left,
        y: rect.top + rect.height / 2 - canvasRect.top
      }
    })

    const canvasCenterX = canvasRect.width / 2

    edges.forEach(([fromId, toId]) => {
      const from = centers[String(fromId)]
      const to = centers[String(toId)]
      if (!from || !to) return

      // Изгиб считаем от полной длины связи (не только по горизонтали),
      // иначе почти вертикальные связи (бабушка -> папа) рисуются прямыми.
      // Сторона изгиба зависит от положения относительно центра дерева,
      // чтобы линии стабильно "расходились" дугами, а не дёргались.
      const dx = to.x - from.x
      const dist = Math.hypot(dx, to.y - from.y) || 1
      const avgX = (from.x + to.x) / 2
      const side =
        avgX !== canvasCenterX
          ? Math.sign(avgX - canvasCenterX)
          : Math.sign(dx) || 1
      const bend = dist * 0.15

      const midX = (from.x + to.x) / 2 + side * bend
      const midY = (from.y + to.y) / 2 - Math.abs(dx) * 0.08

      const path = document.createElementNS(
        'http://www.w3.org/2000/svg',
        'path'
      )
      path.setAttribute(
        'd',
        `M ${from.x} ${from.y} Q ${midX} ${midY} ${to.x} ${to.y}`
      )
      path.setAttribute('fill', 'none')
      path.setAttribute('stroke', '#A7A6A4')
      path.setAttribute('stroke-width', '1')
      path.setAttribute('stroke-dasharray', '2 6')
      svg.appendChild(path)
    })
  }

  // --- Долгое нажатие на узел: дрожь + крестик удаления ---

  startPress(event) {
    const wrap = event.currentTarget
    this.cancelLongPress()

    this.longPressTimer = setTimeout(() => {
      this.shakingWrap = wrap
      this.justShook = true
      wrap.classList.add('TreeNodeAvatarWrap--shaking')
    }, LONG_PRESS_MS)
  }

  cancelPress() {
    this.cancelLongPress()
  }

  // Долгое нажатие на аватар запускает дрожь, но тот же клик потом
  // долетает до <label>, открывающего карточку с именем — без этой
  // проверки она открывалась бы сразу вместе с крестиком удаления.
  suppressClickIfShaking(event) {
    if (this.justShook) {
      event.preventDefault()
      this.justShook = false
    }
  }

  cancelLongPress() {
    if (this.longPressTimer) {
      clearTimeout(this.longPressTimer)
      this.longPressTimer = null
    }
  }

  onDocumentPointerDown(event) {
    if (!this.shakingWrap) return
    if (this.shakingWrap.contains(event.target)) return

    this.shakingWrap.classList.remove('TreeNodeAvatarWrap--shaking')
    this.shakingWrap = null
  }
}
