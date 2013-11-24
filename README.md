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

Now, set up the config:

```bash
cp config.example.json config.json
vi config.json
```

Input your API keys in the `config.json` file and save. (You'll need to create an app for each one online and copy-paste the keys and secrets.)

Then start the app with:

```bash
coffee app.coffee
```

To make development easier, install and use supervisor instead:

```bash
sudo npm install -g supervisor
supervisor -i backup,node_modules app.coffee
```

## Testing

To run the tests/specs:

```bash
npm test
```

## Contributors

This project was born at [Startup Weekend Tulsa](http://tulsa.startupweekend.org) 2012.

* [Tim Morgan](http://timmorgan.org)
* [Brandon Westcott](https://github.com/brandonwestcott)
* [Nathan Phelps](https://github.com/nwp)
* [Saif Khan](http://www.lifeasadesigner.com) - logo design

## Copyright & License

Copyright 2013, Tim Morgan and contributors.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
