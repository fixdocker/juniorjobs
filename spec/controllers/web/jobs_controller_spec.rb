# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Web::JobsController, type: :controller do
  describe 'POST #create' do
    context 'with valid attributes and registered user' do
      let(:user) { create(:user, :company) }
      before { login_user(user) }
      subject { post 'create', params: { job: attributes_for(:job) } }

      it 'saves the new job to database' do
        expect { subject }.to change(Job.all, :count).by(1)
      end

      it 'redirects to show view' do
        expect(subject).to redirect_to(assigns(:job))
      end
    end

    context 'with valid attributes and without user' do
      let(:tag) { create(:tag_ruby) }
      subject { post 'create', params: { job: attributes_for(:job), tag_list: %w[ruby javascript remote] } }

      it 'saves the new job to database' do
        expect { subject }.to change(Job.all, :count).by(1)
      end

      it 'redirects to show view' do
        expect(subject).to redirect_to(assigns(:job))
      end
    end

    context 'with invalid attributes' do
      subject { post 'create', params: { job: attributes_for(:job, :invalid) } }

      it 'does not save the job' do
        expect { subject }.to_not change(Job, :count)
      end

      it { is_expected.to render_template(:new) }
    end
  end

  describe '#show' do
    let(:job) { create(:job) }
    subject { get :show, params: { id: job.id } }

    it { is_expected.to render_template(:show) }
  end

  describe 'PUT #update' do
    let(:user) { create(:user, :company) }
    context 'update job with correct token' do
      let(:job) { create(:job, :approved) }

      before do
        login_user(user)
        put 'update', params: { id: job.id, job: attributes_for(:job, requirements: 'Работать') }
        job.tag_list = 'java'
        job.save
      end
      it 'updates job requirements' do
        # (job.reload.requirements).to eq ''
      end
      it 'should return correct tags' do
        expect(job.tag_list).to eq ['java']
      end
      # it { expect(job.reload.status).to eq 'not_approved' }
      # it { is_expected.to redirect_to(job_path(job)) }
    end

    context 'update job with incorrect token' do
      let(:job) { create(:job, :approved) }

      before do
        put 'update', params: { id: job.id, job: attributes_for(:job, requirements: 'Работать', token: 'wrong') }
      end

      it 'not updates job requirements' do
        expect(job.reload.requirements).to eq 'Работать много и пить кофе'
      end
      it { is_expected.to redirect_to(job_path(job)) }
    end

    context 'update job by owner without token' do
      let(:user) { create(:user, :company) }
      let(:job) { create(:job, :approved, user: user) }

      before do
        login_user(user)
        put 'update', params: { id: job.id, job: attributes_for(:job, requirements: 'Работать', token: '') }
      end

      it 'updates job requirements' do
        expect(job.reload.requirements).to eq 'Работать'
      end

      it { expect(job.reload.status).to eq 'not_approved' }
      it { is_expected.to redirect_to(job_path(job)) }
    end

    context 'not update job by other user' do
      let(:user) { create(:user, :company) }
      let(:other_user) { create(:user, :junior) }
      let(:job) { create(:job, :approved, user: user) }

      before do
        login_user(other_user)
        put 'update', params: { id: job.id, job: attributes_for(:job, requirements: 'Работать') }
      end

      it 'not updates job requirements' do
        expect(job.reload.requirements).to eq 'Работать много и пить кофе'
      end
    end

    context 'update job with invalid attributes' do
      let(:user) { create(:user, :company) }
      let(:job) { create(:job, :approved, user: user) }

      before do
        login_user(user)
        put 'update', params: { id: job.id, job: attributes_for(:job, :invalid, requirements: 'Работать') }
      end

      it 'not updates job' do
        expect(job.reload.requirements).to eq 'Работать много и пить кофе'
      end

      it { is_expected.to redirect_to(edit_job_path(job)) }
    end
  end
end
