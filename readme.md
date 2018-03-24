# Fediverse

**this project does not do anything interesting come back later**

Fediverse entrypoint repository.

If you want to run [clicker-rick](https://github.com/majestrate/clicker-rick) this is the right place to start.


## dependencies

* git
* GNU Make
* go 1.10 or higher

## setup process

Build the server, assets and generate configs, only run this once:

    $ make build configure EMAIL='your-admin@email-address' DOMAIN='your-domain-goes-here.tld'

To run the server in forground:

    $ make run

## workflow

To update the server source and rebuild run:

    $ make refresh

See `production/initscripts` for production level init scripts
