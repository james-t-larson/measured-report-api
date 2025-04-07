require 'rails_helper'

RSpec.describe Category, type: :model do
  describe "associations" do
    it { should have_many(:articles).dependent(:destroy) }
  end

  describe "validations" do
    it { should validate_uniqueness_of(:slug) }
    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_most(255) }
    it { should validate_numericality_of(:position).only_integer.is_greater_than_or_equal_to(0) }
    it { should validate_uniqueness_of(:position) }
  end

  describe 'callbacks' do
    context 'before_validation' do
      it 'generates a slug if slug is blank' do
        category = Category.new(name: 'Test Category', slug: nil)
        category.valid?
        expect(category.slug).to eq('test-category')
      end

      it 'does not overwrite an existing slug' do
        category = Category.new(name: 'Test Category', slug: 'custom-slug')
        category.valid?
        expect(category.slug).to eq('custom-slug')
      end
    end
  end
end
