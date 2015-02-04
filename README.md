# WebhookD

**Flexible, configurable universal webhook receiver**

This app is a flexible, configurable universal webhook receiver, built with
sinatra.
It can receive a webhook, parse its payload and take action according to the
configuration.

Example: A git push to Gitlab sends a webhook to the webhookd. The webhookd then
parses the payload which contains the name and the branch of the pushed commit.
After that it looks up in the configuration what to do: run a different script per
repo or even per branch.

## Installation

Just install the GEM:

    $ gem install webhookd

The GEM has some dependencies which maybe need to build native extensions. Therefore on Ubuntu
and Debian the packages `ruby-dev` and `build-essential` are needed.

Some very basic Debian packaging effort can be found under [tobru/webhookd-debian-packaging](https://github.com/tobru/webhookd-debian-packaging).

## Usage

### Starting and stopping

The webhookd uses thin as rack server by default. It has a small CLI utility
to start and stop the service, called `webhookd`:

```
Commands:
  webhookd help [COMMAND]  # Describe available commands or one specific command
  webhookd start           # Starts the webhookd server
  webhookd stop            # Stops the thin server
```

To see the options for `thin`, run `webhookd start -h`. They can simply be added to the `start` command.
F.e. `webhookd start -d --config-file=/path/to/config.yml`

**Starting the webhookd server**

`webhookd start --config-file=/path/to/config.yml`

Test it with `curl -XGET http://username:password@localhost:8088`

**Stopping the webhookd server**

`webhookd stop`

### Init script

There is an example init script which uses the Debian `/etc/default` mechanism to configured the
daemon options. Just place the file `scripts/webhookd.init` to `/etc/init.d/webhookd`, the
file `scripts/webhookd.default` to `/etc/default/webhookd` and update the parameters in the
defaults file to match your system.

It also has some configuration options to use SSL with the thin server. Set `SSL` to `yes` and update
the parameters `SSK_KEY` and `SSL_CERT`. The daemon starts now with ssl enabled.
On Debian and Ubuntu you maybe need to install `libssl-dev` and re-install the `eventmachine` gem.

You can test the SSL connection with `curl -XGET https://username:password@localhost:8088 -k` or
`openssl s_client -showcerts -connect localhost:8088`

### Configuration

The configuration is written in YAML. To see an example have a look at `etc/example.yml`.

**Global configuration**   
This section holds some global parameters:

```YAML
global:
  loglevel: 'debug'
  logfile: 'app.log'
  username: 'deployer'
  password: 'Deploy1T'
```

* *loglevel*: One of: debug, info, warn, error, fatal
* *logfile*: Path (including filename) to the application log
* *username*: Username for the basic authentication to the application
* *password*: Password for the basic authentication to the application

**Payload type specific configuration**   
Per payload type configuration. Available payload types: vcs. (More to come)

**Payload type 'vcs'**   
This is meant for payload types coming from a version control system like git.

```YAML
vcs:
  myrepo:
    _all:
      command: 'echo _all with branch <%= branch_name %>'
    production:
      command: '/usr/local/bin/deploy-my-app'
    otherbranch:
      command: '/bin/true'
  myotherrepo:
    master:
      command: 'cd /my/local/path; /usr/bin/git pull'
  _all:
    master:
      command: 'echo applies to all master branches of not specifically configured repos'
    _all:
      command: 'echo will be applied to ALL repos and branches if not more specifically configured'
```

There should be an entry per repository. If needed there can be a catch-all name which applies
to all repositories: `_all`. On the next level comes the name of the branch. Here could also be a
catch-all name specified, also called `_all`.

The `command` parameter is parsed with the ERB templating system. Available variables:
* *branch_name*
* *repo_name*

**Examples:**

```YAML
vcs:
  repo1:
    _all:
      command: 'echo this is the branch <%= branch_name %>'
  _all:
    master:
      command: 'echo this is the repo <%= repo_name.upcase %>'
```

### Webhook usage

The use a webhook, add the URL to your project.

**Available webhook payload types**

* *Bitbucket*: http(s)://USERNAME:PASSWORD@YOURIP:YOURPORT/payload/bitbucket
* *Gitlab*: http(s)://USERNAME:PASSWORD@YOURIP:YOURPORT/payload/gitlab
* *Debug*: http(s)://USERNAME:PASSWORD@YOURIP:YOURPORT/payload/debug

### Testing

There are some tests in place using `minitest`. Run `rake test` to run all available test.
It should output a lot of log messages and at the end a summary of all test without any errors.
For the testcases to succeed, the configuration file `etc/example.yml` is used.

## Contributing

1. Fork it ( https://github.com/tobru/webhookd/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

### Payload types

Payload types are part of the business logic in `lib/webhookd/app.rb`.
It is defined in the payload endpoint in `lib/webhookd/payloadtype/<payloadtype>.rb`.
For an example have a look at `lib/webhookd/payloadtype/bitbucket.rb`.

Adding a new type would involve the following steps:
1. Write a payload parser in `lib/webhookd/payloadtype/`
1. Add business logic for the payload type in `lib/webhookd/app.rb` under `case parsed_data[:type]`
1. Update README.md

### Payload parser

The payload parser parses the payload data received from the webhook sender into a standard hash
which will be consumed by the business logic to take action.

**vcs**

The `vcs` payload type has the following hash signature:

```ruby
data[:type]
data[:source]
data[:repo_name]
data[:branch_name]
data[:author_name]
```

**debug**

The `debug` payload type has the following hash signature:

```ruby
data[:type]
```

It can be used to develop a new payload type or payload parser.
When using this payload type, it just outputs the request body
in the logfile under the loglevel `debug`.

## Packaging

### Debian

Some very basic Debian packaging effort can be found under [tobru/webhookd-debian-packaging](https://github.com/tobru/webhookd-debian-packaging).
This is how the initial package creation was done:

```
export DEBFULLNAME="My Name"
export DEBEMAIL="email@address.com"
gem fetch webhookd
gem2deb -p webhookd webhookd*.gem
cd webhookd-<VERSION>
git init
git-import-orig ../webhookd_*.orig.tar.gz --pristine-tar
cd ..
mv webhookd-<VERSION> webhookd
cd webhookd

# EDIT .gitignore
vi .gitignore

# add following lines
/debian/webhookd.postinst.debhelper
/debian/webhookd.postrm.debhelper
/debian/webhookd.prerm.debhelper
/debian/webhookd.substvars
/debian/webhookd
/debian/files
/.pc
Gemfile.lock

:wq
# END EDIT

git add .
git commit -a
git-buildpackage -us -uc
```

After changes to the packaging process (`/debian` folder):
```
dch -v <upstreamver>-<incrementpkgrel>
git commit -a
rm Gemfile.lock
git-buildpackage -us -uc
```

If there is a new upstream version:
```
gem fetch webhookd && gem2deb webhookd*.gem ; git-import-orig
dch -v <upstreamver>-<incrementpkgrel>
```

