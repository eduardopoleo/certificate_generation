require_relative './spec_helper'
require_relative '../certificate_generator'

describe CertificateGenerator do
  describe '#generate' do
    context 'when the some of the options provided are wrong' do
      subject do
        described_class.new(
          username: 'eduardo',
          user_public_key: './some-random-location',
          ca_private_key: './spec/fixtures/ca-key',
          certificate_id: 'user-cert-id',
          validity: '+5d'
        ).generate
      end

      it 'raises a generation error' do
        expect { subject }.to raise_error(CertificateGenerator::GenerationError)
      end
    end

    context 'when all the options are properly provided' do
      subject do
        described_class.new(
          username: 'eduardo',
          user_public_key: './spec/fixtures/user-key.pub',
          ca_private_key: './spec/fixtures/ca-key',
          certificate_id: 'user-cert-id',
          validity: '+5d'
        ).generate
      end

      it 'returns a string containing the certificate' do
        expect(subject).to be_a(String)
      end
    end
  end

  describe '#build_command' do
    context 'when options are not provided' do
      subject do
        described_class.new(
          username: 'eduardo',
          user_public_key: './spec/fixtures/user-key.pub',
          ca_private_key: './spec/fixtures/ca-key',
          certificate_id: 'user-cert-id',
          validity: '+5d'
        ).build_command
      end

      it 'builds a ssh-keygen command just with the required information' do
        expect(subject).to eq([
          'ssh-keygen',
          '-s',
          './spec/fixtures/ca-key',
          '-I',
          'user-cert-id',
          '-n',
          'eduardo',
          '-V',
          '+5d',
          './spec/fixtures/user-key.pub'
        ])
      end
    end

    context 'when the validity is NOT provided' do
      subject do
        described_class.new(
          username: 'eduardo',
          user_public_key: './spec/fixtures/user-key.pub',
          ca_private_key: './spec/fixtures/ca-key',
          certificate_id: 'user-cert-id'
        ).build_command
      end

      it 'sets it to expire 12hrs from the date' do
        expect(subject).to eq([
          'ssh-keygen',
          '-s',
          './spec/fixtures/ca-key',
          '-I',
          'user-cert-id',
          '-n',
          'eduardo',
          '-V',
          '+12h',
          './spec/fixtures/user-key.pub'
        ])
      end
    end

    context 'when the force-command option is provided' do
      subject do
        described_class.new(
          username: 'eduardo',
          user_public_key: './spec/fixtures/user-key.pub',
          ca_private_key: './spec/fixtures/ca-key',
          certificate_id: 'user-cert-id',
          force_command: 'ls'
        ).build_command
      end

      it 'appends it to the list of options' do
        expect(subject).to eq([
          'ssh-keygen',
          '-s',
          './spec/fixtures/ca-key',
          '-I',
          'user-cert-id',
          '-n',
          'eduardo',
          '-V',
          '+12h',
          '-O',
          "force-command='ls'",
          './spec/fixtures/user-key.pub'
        ])
      end      
    end

    context 'when the deny_pt option is provided' do
      subject do
        described_class.new(
          username: 'eduardo',
          user_public_key: './spec/fixtures/user-key.pub',
          ca_private_key: './spec/fixtures/ca-key',
          certificate_id: 'user-cert-id',
          validity: '+5d',
          force_command: 'ls'
        ).build_command
      end

      it 'appends it to the list of options' do
        expect(subject).to eq([
          'ssh-keygen',
          '-s',
          './spec/fixtures/ca-key',
          '-I',
          'user-cert-id',
          '-n',
          'eduardo',
          '-V',
          '+5d',
          '-O',
          "force-command='ls'",
          './spec/fixtures/user-key.pub'
        ])
      end      
    end

    context 'when the deny_port_fwd option is provided' do
      subject do
        described_class.new(
          username: 'eduardo',
          user_public_key: './spec/fixtures/user-key.pub',
          ca_private_key: './spec/fixtures/ca-key',
          certificate_id: 'user-cert-id',
          validity: '+5d',
          deny_pty: true
        ).build_command
      end

      it 'appends it to the list of options' do
        expect(subject).to eq([
          'ssh-keygen',
          '-s',
          './spec/fixtures/ca-key',
          '-I',
          'user-cert-id',
          '-n',
          'eduardo',
          '-V',
          '+5d',
          '-O',
          'no-pty',
          './spec/fixtures/user-key.pub'
        ])
      end      
    end

    context 'when the deny_port_fwd option is provided' do
      subject do
        described_class.new(
          username: 'eduardo',
          user_public_key: './spec/fixtures/user-key.pub',
          ca_private_key: './spec/fixtures/ca-key',
          certificate_id: 'user-cert-id',
          validity: '+5d',
          deny_port_fwd: true
        ).build_command
      end

      it 'appends it to the list of options' do
        expect(subject).to eq([
          'ssh-keygen',
          '-s',
          './spec/fixtures/ca-key',
          '-I',
          'user-cert-id',
          '-n',
          'eduardo',
          '-V',
          '+5d',
          '-O',
          'no-port-forwarding',
          './spec/fixtures/user-key.pub'
        ])
      end      
    end

    context 'when the deny_port_fwd option is provided' do
      subject do
        described_class.new(
          username: 'eduardo',
          user_public_key: './spec/fixtures/user-key.pub',
          ca_private_key: './spec/fixtures/ca-key',
          certificate_id: 'user-cert-id',
          validity: '+5d',
          force_command: 'ls',
          deny_pty: true,
          deny_port_fwd: true
        ).build_command
      end

      it 'appends all the options' do
        expect(subject).to eq([
          'ssh-keygen',
          '-s',
          './spec/fixtures/ca-key',
          '-I',
          'user-cert-id',
          '-n',
          'eduardo',
          '-V',
          '+5d',
          '-O',
          "force-command='ls'",
          '-O',
          'no-pty',
          '-O',
          'no-port-forwarding',
          './spec/fixtures/user-key.pub'
        ])
      end      
    end
  end
end