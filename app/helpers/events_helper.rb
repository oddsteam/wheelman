module EventsHelper
  def format_date_range(start_date, end_date)
    return "" if start_date.blank? || end_date.blank?

    if start_date == end_date
      start_date.strftime('%d %b %Y')
    elsif start_date.month == end_date.month && start_date.year == end_date.year
      "#{start_date.strftime('%d')} - #{end_date.strftime('%d %b %Y')}"
    else
      "#{start_date.strftime('%d %b %Y')} - #{end_date.strftime('%d %b %Y')}"
    end
  end
end
