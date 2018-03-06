const express = require('express');
const json = require('express-json');
//const bodyParser = require('body-parser');
const mysql = require('mysql');
const fs = require('fs');
const path = require('path');
var loggingEnabled = true;
var connection = mysql.createConnection({
    host     : 'localhost',
    user     : process.env.MYSQL_USER,
    password : process.env.MYSQL_PASSWORD,
    database : 'Adapt'
});
  
function checkDatabase() {
    initializeDatabaseQuery = fs.readFileSync(path.join(__dirname,'Adapt.sql')).toString();
    initQueries = initializeDatabaseQuery.split(";");
    currentIndex = 0;
    runNextQuery();
}

var initializeDatabaseQuery;
var initQueries;
var currentIndex;

connection.connect();
function query(queryString, callback) {
    //connection.connect();
    connection.query(queryString, (err, res, fields) => {
        callback(err, res, fields);
    });
    //connection.end();
}

function runNextQuery() {
    if (currentIndex >= initQueries.length) return;
    let next = initQueries[currentIndex];
    console.log('running query', next);
    query(next, (error, results, fields) => {
        if (error) {
            console.log('Error running query', error);
        }
        currentIndex++;
        if (currentIndex < initQueries.length) {
            runNextQuery();
        } else {
            console.log('database setup');
            currentIndex = 0;
        }
    });
}

function createPlayer(name, height, weight, number, position, callback) {
    query(`INSERT INTO Player (name, height, weight, number, position) VALUES ("${name}", ${height}, ${weight}, ${number}, "${position}");`, ((name)=> {return (err, res, fields) => {
        if (err) {
            console.log('Error in createPlayer', err);
            callback(err);
            return;
        }
        console.log(`Player ${name} created`);
        callback(null, res.insertId);
    }})(name));
}

function sendError(res, code, message) {
    res.status(code);
    res.send(message);
}

const app = express();
//app.use(bodyParser());
app.use(json());

app.get('/', (req, res) => res.send('Hello World!'));

app.get('/players', (req,res) => {
    console.log('fetch /players');
    query('SELECT * FROM Player ORDER BY name ASC', ((res)=> { return (err, results, fields) => {
        if (err) {
            console.log('error fetching players', err);
            sendError(res, 500, `Error fetching players ${err}`);
            return;
        }
        console.log('players', results);
        res.json(results);
    }})(res));
});

app.get('/players/delete', (req,res) => {
    console.log('fetch /players/delete', req.query);
    if (!req.query) {
        sendError(res, 400, 'No query provided');
        return;
    }
    let player = req.query;
    let { id } = player;
    if (!id) {
        sendError(res, 400, 'Player id is required');
        return;
    }
    query(`DELETE FROM Player WHERE id=${id}`, ((res, id) => { return (err, results, fields) => {
        if (err) {
            console.log('error deleting player', err);
            sendError(res, 500, `Error deleting player ${err}`);
            return;
        }
        res.json({id, message: 'Player successfully deleted'});
    }})(res, id));
})

app.get('/players/edit', (req, res) => {
    console.log('fetch /players/edit', req.query);
    if (!req.query) {
        sendError(res, 400, 'No query provided');
        return;
    }
    let player = req.query;
    let { id, name, height, number, position, weight } = player;
    if (!id) {
        sendError(res, 400, 'Player id is required');
        return;
    }
    var queryString = `UPDATE player SET `;
    var modified = false;
    if (name) {
        queryString += `name="${name}"`;
        modified = true;
    }
    if (height) {
        if (modified) queryString += ", "
        queryString += `height=${height}`;
        modified = true;
    }
    if (number) {
        if (modified) queryString += ", "
        queryString += `number=${number}`;
        modified = true;
    }
    if (position) {
        if (modified) queryString += ", "
        queryString += `position="${position}"`;
        modified = true;
    }
    if (weight) {
        if (modified) queryString += ", "
        queryString += `weight=${weight}`;
        modified = true;
    }
    if (!modified) {
        sendError(res, 400, 'You have not provided any changes to the player');
        return;
    }
    queryString += ` WHERE id=${id}`;
    console.log('edit query', queryString);
    query(queryString, (err, results, fields) => {
        if (err) {
            sendError(res, 500, `Error editing player ${err}`);
            return;
        }
        res.json({
            id,
            message: 'Player successfully edited'
        });
    });
});

app.get('/players/create', (req, res) => {
    console.log('fetch /players/create', req.query);
    if (!req.query) {
        sendError(res, 400, 'No query provided');
        return;
    }
    let player = req.query;
    let { name, height, number, position, weight } = player;
    if (!name) {
        sendError(res, 400, 'Player name is required');
        return;
    }
    if (!height) {
        sendError(res, 400, 'Player height is required');
        return;
    }
    if (!number) {
        sendError(res, 400, 'Player number is required');
        return;
    }
    if (!position) {
        sendError(res, 400, 'Player position is required');
        return;
    }
    if (!weight) {
        sendError(res, 400, 'Player weight is required');
        return;
    }
    createPlayer(name, height, weight, number, position,((res)=> { return (err, playerId)=> {
        if (err) {
            sendError(res, 400, `Error creating player: ${err}`);
            return;
        }
        res.json({
            id: playerId,
            message: 'Player successfully created'
        });
    }})(res));
});

app.listen(3000, () => {
    console.log('Player Training API listening on port 3000!')
    console.log('Quit by pressing Ctrl+C');
})

checkDatabase();