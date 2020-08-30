require 'open3'

class CertificateGenerator
  class GenerationError < StandardError; end

  attr_reader :username,
    :user_public_key,
    :ca_private_key,
    :certificate_id,
    :validity,
    :force_command,
    :deny_pty,
    :deny_port_fwd

  DEFAULT_VALIDITY_PERIOD = '+12h'.freeze
  def initialize(username:,
      user_public_key:, 
      ca_private_key:, 
      certificate_id:,
      validity: nil,
      force_command: nil,
      deny_pty: nil,
      deny_port_fwd: nil)

    @username = username
    @user_public_key = user_public_key
    @ca_private_key = ca_private_key
    @certificate_id = certificate_id
    @validity = validity || DEFAULT_VALIDITY_PERIOD
    @force_command = force_command
    @deny_pty = deny_pty
    @deny_port_fwd = deny_port_fwd
  end

  def build_command
     cmd = [
      'ssh-keygen',
      '-s',
      "#{ca_private_key}",
      '-I',
      "#{certificate_id}",
      '-n',
      "#{username}",
      '-V',
      "#{validity}",
    ]

    cmd = add_options(cmd)

    cmd << "#{user_public_key}"
  end

  def generate
    msg, status = Open3.capture2e(*build_command)

    if status.exitstatus != 0
      fail GenerationError.new(msg)
    end

    File.read(cert_path).tap do
      File.delete(cert_path)
    end
  end

  private

  def cert_path
    # removes the .pub from the public key path
    public_key_path = user_public_key[0...-4]
    public_key_path += '-cert.pub'
  end

  def add_options(cmd)
    if force_command
      cmd << '-O'
      cmd << "force-command=\'#{force_command}\'"
    end

    if deny_pty
      cmd << '-O'
      cmd << 'no-pty'
    end

    if deny_port_fwd
      cmd << '-O'
      cmd << 'no-port-forwarding'
    end

    cmd
  end
end
