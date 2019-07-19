const fs = require('fs');
const https = require('https');

const options = {
    ca: fs.readFileSync('./ssl/ca.cert'),
    key: fs.readFileSync('./ssl/localhost.server.key'),
    cert: fs.readFileSync('./ssl/localhost.server.cert'),
    requestCert: true,
    rejectUnauthorized: true,
};

const server = https.createServer(options, (req, res) => {
    console.log(
        'server connected',
        req.socket.authorized ? 'authorized' : 'unauthorized',
    );
    res.writeHead(200);
    res.end('hello world!');
});

server.listen(8000, () => {
    console.log('server start on https://localhost:8000');
});
