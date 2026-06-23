import { Controller } from "@hotwired/stimulus"

// Toggles between the list and calendar (year-at-a-glance) views, and
// applies client-side Race/Camp category filtering on the calendar chips.
export default class extends Controller {
  static targets = ["list", "calendar", "calendarIcon", "listIcon", "pill", "chip"]
  static values = {
    activeCategories: Array,
    initialView: String
  }

  connect() {
    // Restore the last view used in this tab so returning from the detail page
    // (Back button) keeps you in the calendar view instead of resetting to list.
    const stored = this.readStoredView()
    const initial = stored || (this.initialViewValue === "calendar" ? "calendar" : "list")
    this.showView(initial)
    this.updatePills()
    this.applyFilter()

    // Re-apply filtering after the year-nav Turbo Frame swaps in new chips.
    this.frameLoad = () => this.applyFilter()
    this.element.addEventListener("turbo:frame-load", this.frameLoad)
  }

  readStoredView() {
    try {
      return window.sessionStorage.getItem("eventsView")
    } catch {
      return null
    }
  }

  storeView(view) {
    try {
      window.sessionStorage.setItem("eventsView", view)
    } catch {
      // sessionStorage unavailable (e.g. private mode) — ignore.
    }
  }

  disconnect() {
    this.element.removeEventListener("turbo:frame-load", this.frameLoad)
  }

  toggleView() {
    const next = this.calendarTarget.classList.contains("hidden") ? "calendar" : "list"
    this.showView(next)
    if (next === "calendar") this.applyFilter()
  }

  showView(view) {
    const showCalendar = view === "calendar"
    this.calendarTarget.classList.toggle("hidden", !showCalendar)
    this.listTarget.classList.toggle("hidden", showCalendar)
    // Toggle button icon: show the calendar icon while in list view, list icon while in calendar view.
    if (this.hasCalendarIconTarget) this.calendarIconTarget.classList.toggle("hidden", showCalendar)
    if (this.hasListIconTarget) this.listIconTarget.classList.toggle("hidden", !showCalendar)
    this.storeView(showCalendar ? "calendar" : "list")
  }

  toggleCategory(event) {
    const category = event.currentTarget.dataset.category
    const active = new Set(this.activeCategoriesValue)
    if (active.has(category)) {
      active.delete(category)
    } else {
      active.add(category)
    }
    this.activeCategoriesValue = Array.from(active)
    this.updatePills()
    this.applyFilter()
  }

  updatePills() {
    const active = new Set(this.activeCategoriesValue)
    this.pillTargets.forEach((pill) => {
      const isActive = active.has(pill.dataset.category)
      if (isActive) {
        pill.style.backgroundColor = pill.dataset.color
        pill.style.color = "#ffffff"
        pill.style.opacity = "1"
      } else {
        pill.style.backgroundColor = pill.dataset.tint
        pill.style.color = "#989A96"
        pill.style.opacity = "1"
      }
    })
  }

  applyFilter() {
    const active = new Set(this.activeCategoriesValue)
    this.chipTargets.forEach((chip) => {
      chip.classList.toggle("hidden", !active.has(chip.dataset.category))
    })
  }
}
