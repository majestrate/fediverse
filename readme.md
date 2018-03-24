# Fediverse

**this project does not do anything interesting come back later**

Fediverse entrypoint repository.

If you want to run [clicker-rick](https://github.com/majestrate/clicker-rick) this is the right place to start.


## dependencies

* git
* GNU Make
* go 1.10 or higher

## setup process

Build the server, assets and generate configs, and run the server in the forground on `0.0.0.0:3000`

    $ make sandwich EMAIL='your-admin@email-address' DOMAIN='your-domain-goes-here.tld'

See `production/initscripts` for production level init scripts

## workflow

To update the server source and rebuild run:

    $ make refresh
    
To rebuild to frontend js run:

    $ make bloat
    
To reset *literally* everything run:

    $ make distclean
