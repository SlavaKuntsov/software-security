const http = require('http');
const fs = require('fs');

const hostname = '127.0.0.1';
const port = 3001;

const server = http.createServer(function(request, response) {
    if (request.url === "/") {
        fs.readFile('index.html', function(err, html) {
            if (err) {
                throw err;
            }
            response.writeHeader(200, { "Content-Type": "text/html" });
            response.write(html);
            response.end();
        });
    } else if (request.url.match(/.*\.(js|css|wasm)/)) {
        fs.readFile('./' + lastPathSegment(request.url), function(err, file) {
            if (err) {
                throw err;
            }
            if (request.url.endsWith(".wasm")) {
                response.setHeader("Content-Type", "application/wasm");
            }
            response.write(file);
            response.end();
        });
    }
});

server.listen(port, hostname, () => {
    console.log(`Server running at http://${hostname}:${port}/`);
});

function lastPathSegment(path) {
    return path.substring(path.lastIndexOf('/') + 1)
}
