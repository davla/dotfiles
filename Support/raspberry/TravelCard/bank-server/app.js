const bodyParser = require('body-parser');
const express = require('express');
const logger = require('morgan');
const MongoClient = require('mongodb').MongoClient;
const path = require('path');

const DB_URI = 'mongodb://localhost:27017/bank';
const DB_COLLECTION = 'accounts';

const app = express();

const editBalance = (msgSucc, msgErr, req, res, next) => {
    req.db.findOneAndUpdate(
        {IBAN: req.body.IBAN},
        {$inc: {balance: req.body.amount}})
        .then((result) => {
            req.dbConnection.close();
            if (result.value) {
                res.send({ok: true, msg: msgSucc});
            }
            else {
                next(msgErr);
            }
        })
        .catch((error) => {
            req.dbConnection.close();
            next(error);
        });
};

app.use(logger('dev'));
app.use(bodyParser.json());

app.use((req, res, next) => {
    MongoClient.connect(DB_URI)
    .then((db) => {
        req.dbConnection = db;
        req.db = db.collection(DB_COLLECTION);
        next();
    })
    .catch((error) => {
        next(`Could not connect to the database because ${ error.toString() }`);
    });
});

app.get('/account', (req, res, next) => {
    req.db.find(
        {},
        {fields: {_id: 0}}
    ).toArray()
    .then((accounts) => {
        req.dbConnection.close();
        res.send({ok: true, accounts});
    })
    .catch((error) => {
        req.dbConnection.close();
        next(error);
    });
});

app.get('/account/:IBAN', (req, res, next) => {
    req.db.findOne(
        {IBAN: req.params.IBAN},
        {fields: {_id: 0}}
    ).then((account) => {
        req.dbConnection.close();
        res.send({ok: true, account});
    })
    .catch((error) => {
        req.dbConnection.close();
        next(error);
    });
});

app.delete('/account/:IBAN', (req, res, next) => {
    req.db.deleteOne(
        {IBAN: req.params.IBAN}
    ).then((result) => {
        req.dbConnection.close();
        if (result.result.ok
            && result.result.n > 0
            && result.deletedCount > 0) {
            res.send({ok: true, msg: 'Account deletion successful'});
        }
        else {
            next('Could not delete account');
        }

    })
    .catch((error) => {
        req.dbConnection.close();
        next(error);
    });
});

app.post('/account', (req, res, next) => {
    req.db.insertOne({
        IBAN: req.body.IBAN,
        balance: req.body.balance
    })
    .then((result) => {
        req.dbConnection.close();
        if (result.result.ok
                && result.result.n > 0
                && result.insertedCount > 0) {
            res.send({ok: true, msg: 'Account creation successful'});
        }
        else {
            next('Could not create account');
        }
    })
    .catch((error) => {
        req.dbConnection.close();
        next(error);
    });
});

app.put('/account/pay', (req, res, next) => {
    req.body.amount = -req.body.amount;
    editBalance(
        'Payment successful',
        'Could not pay',
        req,
        res,
        next
    );
});

app.put('/account/topup', editBalance.bind(
    null,
    'Top-up successful',
    'Could not top-up'
));

// catch 404 and forward to error handler
app.use((req, res, next) => {
  req.status = 404;
  next(new Error('Not Found'));
});

// error handler
app.use((err, req, res, next) => {
    res.status(err.status || 500);
    res.send({ok: false, msg: err.toString()});
});

app.listen(process.argv[2] || 3000);

module.exports = app;
