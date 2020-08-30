# Exercise 2: SSH Certificate Generation

## Assumptions
The code assumes that the user's public key and the CA's private key have been written to local files and that our module have access to them. The inputs `user_public_key` and `ca_private_key` are the corresponding relative paths (e.g as opposed to strings containing the keys) that can be provided directly to the `ssh-keygen` command. This simplifies the code and it's similar to what's done in the provided [aptible-api](https://github.com/aptible/aptible-api-ruby/blob/daeeebf449ca283e948c2e8770480aef06c151ba/lib/aptible/api/operation.rb#L47) code snippet.

## Defaults
Since we're delegating authentication and permissions handling to the Core api some of the defaults I chose are somewhat lenient:
- pty is enabled by default
- port forwarding is enabled by default
- we are not enforcing any particular command

That way the scope of the module is limited exclusively to generate the certificate. With that said a "smart" default of half a day (12hrs) is set if no validity is provided, this way developers would only have to authenticate once a day and we prevent having certs that live forever, which seems like a good compromise.

We could also use a smart default in case that the certificate_id is not provided (not implemented). For instance, could add a timestamp to it which could come in handy when auditing/debugging issues.

## Error Handling
The module captures the status of the `ssh-keygen` command and fails hard if the command fails. I find this a better approach than having the command fail silently making things harder to debug down the line.

## Tests & class structure
The 2 main methods exposed were `#build_command` & `#generate`. Normally, I would have have just exposed `#generate`, but doing exact or even partial assertions against a cert is cumbersome and maybe not necessary. Exposing `#build_command` allow us to assert that the `ssh-keygen` command we're sending is correct which ultimately is what we care about since we do not own the `ssh-keygen` implementation.
