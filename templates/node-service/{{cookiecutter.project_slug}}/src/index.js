const http = require("http");

const port = process.env.PORT || "3000";

const server = http.createServer((req, res) => {
  res.writeHead(200, { "Content-Type": "application/json" });
  res.end(
    JSON.stringify({
      service: "{{ cookiecutter.project_slug }}",
      status: "ok",
    })
  );
});

server.listen(port);
