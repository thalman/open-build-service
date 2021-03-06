require 'rails_helper'

RSpec.describe Cloud::UploadJob, type: :model, vcr: true do
  let(:user) { create(:confirmed_user, login: 'tom', ec2_configuration: create(:ec2_configuration)) }
  let(:params) do
    {
      project:    'Cloud',
      package:    'aws',
      repository: 'standard',
      arch:       'x86_64',
      filename:   'appliance.raw.gz',
      region:     'us-east-1'
    }
  end
  let(:response) do
    <<-HEREDOC
    <clouduploadjob name="6">
      <state>created</state>
      <details>waiting to receive image</details>
      <created>1513604055</created>
      <user>#{user.login}</user>
      <target>ec2</target>
      <project>Base:System</project>
      <repository>openSUSE_Factory</repository>
      <package>rpm</package>
      <arch>x86_64</arch>
      <filename>rpm-4.14.0-504.2.x86_64.rpm</filename>
      <size>1690860</size>
    </clouduploadjob>
    HEREDOC
  end

  describe '.create' do
    context 'with a valid backend response' do
      before do
        allow(Backend::Api::Cloud).to receive(:upload).with(user, params).and_return(response)
      end

      subject { Cloud::UploadJob.create(user, params) }

      it { expect(subject.valid?).to be_truthy }
    end

    context 'with an invalid Backend::UploadJob' do
      subject { Cloud::UploadJob.create(user, params) }

      it { expect(subject.valid?).to be_falsy }
      it 'has the correct error message' do
        subject.valid?
        expect(subject.errors.full_messages.to_sentence).to eq('Backend upload job no cloud upload server configurated')
      end
    end

    context 'with an invalid User::UploadJob' do
      let!(:job) { create(:upload_job, job_id: 6) }
      before do
        allow(Backend::Api::Cloud).to receive(:upload).with(user, params).and_return(response)
      end

      subject { Cloud::UploadJob.create(user, params) }

      it { expect(subject.valid?).to be_falsy }
      it 'has the correct error message' do
        subject.valid?
        expect(subject.errors.full_messages.to_sentence).to eq('User upload job Job has already been taken')
      end
    end
  end
end
