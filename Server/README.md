# adapt-server
Node.js, Express, and MySQL API

## To Install
- Install [node.js](https://nodejs.org) optionally using [nvm](https://github.com/creationix/nvm)
- Install [MySQL](https://www.mysql.com/downloads/) optionally using [brew](https://brew.sh/) `brew install mysql`

```bash
npm i
```

## To Run
**Replace <user> with your localhost MySQL username, and <password> with your password.**
```bash
export MYSQL_USER=<user>
export MYSQL_PASSWORD=<password>
npm start
```

## To run in the background
```
npm i -g forever

# START
forever start index.js

# STOP
forever stop index.js
```