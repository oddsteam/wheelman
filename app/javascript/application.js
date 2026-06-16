// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails";
import "controllers";

import flatpickr from "flatpickr"

document.addEventListener("turbo:load", () => {

  flatpickr("#date_range", {
    mode: "range",
    dateFormat: "Y-m-d",
    minDate: "today",

    onChange: function(selectedDates) {

      if (selectedDates.length === 2) {

        const fmt = (d) => {
          const y = d.getFullYear()
          const m = String(d.getMonth() + 1).padStart(2, "0")
          const day = String(d.getDate()).padStart(2, "0")
          return `${y}-${m}-${day}`
        }

        document.getElementById("start_date").value = fmt(selectedDates[0])
        document.getElementById("end_date").value = fmt(selectedDates[1])

      }

    }

  })

})
