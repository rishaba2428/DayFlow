import http from 'node:http'
import fs from 'node:fs'
import path from 'node:path'
import { fileURLToPath } from 'node:url'

const __dirname = path.dirname(fileURLToPath(import.meta.url))
const dist = path.join(__dirname, 'dist')
const port = Number(process.env.PORT) || 8080

let backend = (process.env.BACKEND_HOST || '').trim()
backend = backend.replace(/^https?:\/\//, '')
if (!backend || /[/${]/.test(backend) || backend.endsWith(':')) {
  backend = ''
}

const mime = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.svg': 'image/svg+xml',
  '.png': 'image/png',
  '.ico': 'image/x-icon',
  '.json': 'application/json',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
}

function sendFile(res, filePath) {
  const ext = path.extname(filePath)
  res.writeHead(200, { 'Content-Type': mime[ext] || 'application/octet-stream' })
  fs.createReadStream(filePath).pipe(res)
}

function proxyApi(req, res) {
  const targetUrl = new URL(req.url, `http://${backend}`)
  const headers = { ...req.headers, host: backend.split(':')[0] }
  delete headers['content-length']

  const proxyReq = http.request(
    {
      protocol: 'http:',
      hostname: backend.split(':')[0],
      port: backend.includes(':') ? backend.split(':')[1] : 80,
      path: targetUrl.pathname + targetUrl.search,
      method: req.method,
      headers,
    },
    (proxyRes) => {
      res.writeHead(proxyRes.statusCode || 502, proxyRes.headers)
      proxyRes.pipe(res)
    },
  )

  proxyReq.on('error', (err) => {
    res.writeHead(502, { 'Content-Type': 'text/plain' })
    res.end(`Bad gateway: ${err.message}`)
  })

  req.pipe(proxyReq)
}

const server = http.createServer((req, res) => {
  if (backend && req.url && req.url.startsWith('/api')) {
    return proxyApi(req, res)
  }

  const urlPath = decodeURIComponent((req.url || '/').split('?')[0])
  const safePath = path.normalize(urlPath).replace(/^(\.\.[/\\])+/, '')
  let filePath = path.join(dist, safePath === '/' ? 'index.html' : safePath)

  if (fs.existsSync(filePath) && fs.statSync(filePath).isDirectory()) {
    filePath = path.join(filePath, 'index.html')
  }

  if (fs.existsSync(filePath) && fs.statSync(filePath).isFile()) {
    return sendFile(res, filePath)
  }

  // SPA fallback
  return sendFile(res, path.join(dist, 'index.html'))
})

server.listen(port, '0.0.0.0', () => {
  console.log(`DayFlow frontend listening on 0.0.0.0:${port}`)
  console.log(`API proxy: ${backend || 'disabled'}`)
})
