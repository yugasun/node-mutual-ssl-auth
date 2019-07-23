const fs = require('fs');
const https = require('https');
const Koa = require('koa');
const KoaRouter = require('koa-router');
const enforceHttps = require('koa-sslify').default;

const port = 8000;
const hostname = 'localhost';
const app = new Koa();
const router = new KoaRouter();

app.use(
    enforceHttps({
        port,
        hostname,
    }),
);

router.get('/', (ctx) => {
    ctx.body = 'hello';
});

app.use(router.routes()).use(router.allowedMethods());

const sslOptions = {
    ca: [fs.readFileSync('./ssl/ca.cert')],
    key: fs.readFileSync('./ssl/localhost.server.key'),
    cert: fs.readFileSync('./ssl/localhost.server.cert'),
    requestCert: true,
    rejectUnauthorized: true,
};

const server = https.createServer(sslOptions, app.callback());

server.listen(port, hostname, () => {
    console.log(`Server start on https://${hostname}:${port}`);
});
