# node-mutual-ssl-auth

Node mutual ssl authentication demo. This guide shows how to set up a mutual SSL authentication for TLS sockets and https server.

## Prepare certificates

All commands for generate client/server side certificates are wrote in file [gencert.sh](./gencert.sh).

```shell
bash gencert.sh
```

## Server code

```js
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
```

## Client code

```js
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

```

## Notice

When setting up mutual SSL authentication `requestCert` and `rejectUnauthorized` must be `true`. Refer to [tls.TLSSocket](https://nodejs.org/dist/latest-v10.x/docs/api/tls.html#tls_class_tls_tlssocket).

## License

[@yugasun](./LICENSE)