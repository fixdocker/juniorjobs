require 'rails_helper'

RSpec.describe Job, type: :model do
  let(:user) { create(:user, :company) }

  it { should validate_presence_of :title }
  it { should validate_presence_of :description }
  it { should validate_presence_of :employment_type }
  it { should validate_presence_of :city }
  it { should validate_presence_of :tasks }
  it { should validate_presence_of :requirements }
  it { should validate_presence_of :condition }
  it { should validate_numericality_of :salary_from }
  it { should validate_numericality_of :salary_to }

  context 'should be valid' do
    subject { build(:job, user: user) }
    it { is_expected.to be_valid }
  end
  context 'should be not valid' do
    subject { build(:job, :invalid, user: user) }
    it { is_expected.not_to be_valid }
  end
end