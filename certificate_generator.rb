class Certificate
  attr_reader :username,
    :user_public_key,
    :ca_private_key,
    :certificate_id,
    :validity,
    :force_command,
    :deny_pty,
    :deny_port_fwd

  def initialize(username:, # REQUIRED!
      user_public_key:, # REQUIRED!
      ca_private_key:, # REQUIRED!
      certificate_id:, # REQUIRED
      validity: nil, # optional (default: 12 hours)
      force_command: nil, # optional
      deny_pty: nil, # optional
      deny_port_fwd: nil) # optional

    @username = username
    @user_public_key = user_public_key
    @ca_private_key = ca_private_key
    @certificate_id = certificate_id
    @validity = validity
    @force_command = force_command
    @deny_pty = deny_pty
    @deny_port_fwd = deny_port_fwd
  end

  # capture any failure and fail hard
  def generate
    cmd = [
      "ssh-keygen -s #{ca_private_key}",
      "-I #{certificate_id}",
      "-n #{username}",
      "-V #{cert_validity}",
    ]

    cmd = add_options(cmd)

    cmd << "#{user_public_key}"

    cmd = cmd.join(' ')
require 'pry'; binding.pry
    system(cmd)
  end

  private

  DEFAULT_VALIDITY_PERIOD = '+12h'.freeze
  def cert_validity
    validity || DEFAULT_VALIDITY_PERIOD
  end

  def add_options(cmd)
    cmd << "-O force-command=\'#{force_command}\'" if force_command
    cmd << "-O no-pty" if deny_pty
    cmd << "-O no-port-forwarding" if deny_port_fwd

    cmd
  end
end

# CREATE: ssh-keygen -> key key.pub
# SIGN: ssh-keygen -s ca_key -I user_certificate user_key.pub -> key-cert.pub
# View: ssh-keygen -L -f ./key-cert.pub -> views the cert content.

Certificate.new(
  username: 'eduardo', 
  user_public_key: './user_key.pub', 
  ca_private_key: './ca_key',
  certificate_id: 'eduardo-cert'
).generate

Certificate.new(
  username: 'eduardo', 
  user_public_key: './user_key.pub', 
  ca_private_key: './ca_key',
  certificate_id: 'eduardo-cert',
  force_command: 'ls',
  deny_pty: true,
  deny_port_fwd: true
).generate
