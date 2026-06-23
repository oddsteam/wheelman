module EventsHelper
  CATEGORY_META = {
    "race" => { label: "Race", letter: "R", color: "#95C24A", tint: "#EDF4DF" },
    "camp" => { label: "Camp", letter: "C", color: "#EC8735", tint: "#FBEBDD" }
  }.freeze

  ACTIVITY_ICONS = {
    "swimming" => "Swim.png",
    "running"  => "Run.png",
    "cycling"  => "Bike.png"
  }.freeze

  def category_meta(category)
    CATEGORY_META[category.to_s] || { label: category.to_s.capitalize, letter: category.to_s.first.to_s.upcase, color: "#9CA3AF", tint: "#F3F4F6" }
  end

  def category_letter(category)
    category_meta(category)[:letter]
  end

  def category_color(category)
    category_meta(category)[:color]
  end

  def category_tint(category)
    category_meta(category)[:tint]
  end

  def activity_icon(type)
    ACTIVITY_ICONS[type.to_s]
  end
end
