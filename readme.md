# fediverse


## dependencies

* git
* GNU Make
* go 1.10 or higher

## setup process

Build the server, assets and generate configs, only run this once:

    $ make configure EMAIL='your-admin@email-address' DOMAIN='your-domain-goes-here.tld'

To run the server in forground:

    $ make run

See `production/initscripts` for production level init scripts
