# Picirus

Picirus connects to your accounts in the cloud and makes daily snapshot backups of your important stuff.

## Features

* connect to various cloud services via web interface, e.g. using oauth
* create snapshot backups of your stuff on a daily basis
* view/download files via web interface
* view/download files via samba/afp share

## Development

First, install Node.js 0.8.0 or higher. Then:

```bash
git clone git@github.com:seven1m/picirus.git
cd picirus
npm install
```

Watch for errors here, particularly when sqlite3 is installed. You may need to install sqlite header files on your OS.

Then start the app with:

```bash
node app.coffee
```

To make development easier, install and use supervisor instead:

```bash
sudo npm install -g supervisor
supervisor app.coffee
```

## Testing

To run the tests/specs:

```bash
npm test
```

## Copyright & License

Copyright 2012, TJRM, Inc. All rights reserved.
