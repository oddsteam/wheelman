class User < ApplicationRecord
  has_secure_password validations: false

  normalizes :email, with: ->(email) { email.strip.downcase }

  # ทุก account ต้องมี identity อย่างน้อย 1 อย่าง (LINE หรือ email)
  validate :must_have_an_identity

  validates :line_user_id, uniqueness: true, allow_nil: true
  validates :email,
            uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP },
            allow_nil: true

  # password จำเป็นเฉพาะ account ที่ไม่มี LINE (เช่น admin ที่ login ด้วย email/password)
  validates :password, presence: true, on: :create, if: -> { line_user_id.blank? }
  validates :password, length: { minimum: 8 }, allow_nil: true

  private

  def must_have_an_identity
    if line_user_id.blank? && email.blank?
      errors.add(:base, "must have a LINE account or an email")
    end
  end
end
