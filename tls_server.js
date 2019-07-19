const tls = require('tls');
const fs = require('fs');

const options = {
    ca: fs.readFileSync('./ssl/ca.cert'),
    key: fs.readFileSync('./ssl/localhost.server.key'),
    cert: fs.readFileSync('./ssl/localhost.server.cert'),
    requestCert: true,
    rejectUnauthorized: true,
};

const server = tls.createServer(options, (socket) => {
    console.log(
        'server connected',
        socket.authorized ? 'authorized' : 'unauthorized',
    );

    socket.on('error', (error) => {
        console.log(error);
    });

    socket.write('hello world!');
    socket.setEncoding('utf8');
    socket.pipe(process.stdout);
    socket.pipe(socket);
});

server.listen(8000, () => {
    console.log('server start on https://localhost:8000');
});
