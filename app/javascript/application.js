// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails";
import "controllers";

import flatpickr from "flatpickr"

document.addEventListener("turbo:load", () => {

  flatpickr("#date_range", {
    mode: "range",
    dateFormat: "Y-m-d",

    onChange: function(selectedDates) {

      if (selectedDates.length === 2) {

        const start = selectedDates[0].toISOString().split("T")[0]
        const end = selectedDates[1].toISOString().split("T")[0]

        document.getElementById("start_date").value = start
        document.getElementById("end_date").value = end

      }

    }

  })

})
