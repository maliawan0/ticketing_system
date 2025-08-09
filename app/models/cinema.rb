class Cinema < ApplicationRecord
  # Soft delete: hides deleted records by default
  default_scope { where(deleted_at: nil) }

  scope :with_deleted, -> { unscope(where: :deleted_at) }
  scope :only_deleted, -> { with_deleted.where.not(deleted_at: nil) }

  def soft_delete
    update(deleted_at: Time.current)
  end

  def restore
    update(deleted_at: nil)
  end

  def destroy
    soft_delete
  end

  belongs_to :area
  has_many :screens, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :area_id, case_sensitive: false }
end
