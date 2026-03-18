class Event < ApplicationRecord
    has_one_attached :photo

    validate :photo_size_within_limit

    private

    def photo_size_within_limit
        return unless photo.attached?
        return if photo.blob.byte_size < 20.megabytes
        errors.add(:photo, "must be smaller than 20MB")
    end
end
