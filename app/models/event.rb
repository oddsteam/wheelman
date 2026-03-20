class Event < ApplicationRecord
    has_one_attached :photo

    # event_name (1-200)
    validates :name, presence: true, length: { maximum: 200 }

    # activity_type (array/json ต้องมีอย่างน้อย 1)
    validate :activity_type_must_not_be_empty

    # event_category
    validates :category,
    presence: true,
    inclusion: { in: %w[race camp] }

    # description (max 500)
    validates :description, presence: true, length: { maximum: 500 }

    # location_description (max 200)
    validates :location_description, presence: true, length: { maximum: 200 }

    # link_location (optional + ต้องเป็น URL)
    validates :location_link,
            format: {
              with: URI::DEFAULT_PARSER.make_regexp(%w[http https]),
            },
            allow_blank: true

    # date
    validates :start_date, presence: true
    validates :end_date, presence: true
    validate :end_date_after_start_date

    validate :photo_size_within_limit

    private

    def photo_size_within_limit
        return unless photo.attached?
        return if photo.blob.byte_size <= 20.megabytes
        errors.add(:photo, "must be smaller than 20MB")
    end

    def activity_type_must_not_be_empty
        if activity_type.blank? || activity_type.reject(&:blank?).empty?
        errors.add(:activity_type, "must select at least one")
        end
    end

    def end_date_after_start_date
        return if start_date.blank? || end_date.blank?

        if end_date < start_date
            errors.add(:end_date, "must be after start date")
        end
    end
end
