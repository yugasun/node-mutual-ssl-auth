const https = require('https');
const fs = require('fs');

const options = {
    ca: fs.readFileSync('./ssl/ca.cert'),
    key: fs.readFileSync('./ssl/localhost.client.key'),
    cert: fs.readFileSync('./ssl/localhost.client.cert'),
    hostname: 'localhost',
    port: 8000,
    rejectUnauthorized: true,
    requestCert: true,
};

const req = https.request(options, (res) => {
    console.log(
        'client connected',
        res.socket.authorized ? 'authorized' : 'unauthorized',
    );
    res.on('data', (d) => {
        process.stdout.write(d);
    });
    process.stdin.pipe(res);
    process.stdin.resume();
});

req.end();

req.on('error', (e) => {
    console.log(e);
});
