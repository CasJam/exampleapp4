class Post < ApplicationRecord
  include SlugGenerator

  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-zA-Z0-9\-_]+\z/, message: "only allows letters, numbers, hyphens, and underscores" }

  
  before_validation :generate_slug, on: :create

  def to_param
    slug
  end

  private

  def generate_slug
    generate_slug_by_name(:title)
  end
  
end
