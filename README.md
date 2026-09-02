# docker-nginx-spa

[![Publish Docker image](https://github.com/chneau/docker-nginx-spa/actions/workflows/publish.yml/badge.svg)](https://github.com/chneau/docker-nginx-spa/actions/workflows/publish.yml)
[![Docker Image](https://img.shields.io/badge/docker_image-ghcr.io%2Fchneau%2Fnginx--spa-blue?logo=docker)](https://ghcr.io/chneau/nginx-spa)


Lightweight Alpine-based Nginx Docker image designed to serve Single Page Applications (React, Vue, Vite, Svelte, Angular, etc.) with **runtime environment variable substitution**.

Built and published daily for `linux/amd64` and `linux/arm64`.

---

## ✨ Features

- ⚡ **Runtime Substitution**: Inject environment variables at container startup without rebuilding your frontend image.
- 🔀 **SPA Routing**: HTML5 pushState routing out-of-the-box (`try_files $uri $uri/ $uri.html /index.html`).
- 🛡️ **Non-Root & Secure**: Runs as unprivileged user `1000:1000` with hidden Nginx server tokens.
- 🪶 **Minimal Footprint**: Built on `nginx:alpine` (~25MB image size).
- 📦 **Multi-Architecture**: Supports both `linux/amd64` and `linux/arm64` (Apple Silicon, Raspberry Pi, AWS Graviton).
- 🩺 **Built-in Healthcheck**: Ready for Docker Compose, Kubernetes, and container orchestrators.
- 🗜️ **Optimized Static Delivery**: Pre-configured `gzip` compression (including `.wasm` and `.svg`) and `sendfile` enabled.

---

## 🚀 Quick Demo

Test it right away without writing any configuration:

```bash
docker run --rm -it -p 7777:8080 -e _nginx=HACKED ghcr.io/chneau/nginx-spa
```

Open [http://localhost:7777](http://localhost:7777) in your browser — every instance of `nginx` in the default welcome page is dynamically replaced by `HACKED`.

---

## 📖 How It Works

1. During frontend build time, use placeholder tokens for your environment variables (e.g., `_VITE_API_URL` or `__API_KEY__`).
2. When the container boots, `start.sh` scans your web files (`.html`, `.js`, `.css`, `.json`, etc.) and replaces any token matching an environment variable prefixed with `PREFIX` (default: `_`).
3. Special characters (`/`, `&`, `?`, `=`, `\`, quotes) in variable values are safely escaped without corrupting your code.
4. Binary files (images, fonts, media) are untouched.
5. Nginx starts and serves your SPA.

---

## 🛠️ Usage Example

### 1. `Dockerfile` (Vite / React / Vue example)

```dockerfile
# Stage 1: Build your SPA
FROM oven/bun:1 AS build
WORKDIR /app

# Build-time placeholders matching the substitution prefix
ENV VITE_API_URL="_VITE_API_URL"
ENV VITE_APP_TITLE="_VITE_APP_TITLE"

COPY package.json bun.lockb ./
RUN bun install --frozen-lockfile

COPY . .
RUN bun x vite build

# Stage 2: Serve with docker-nginx-spa
FROM ghcr.io/chneau/nginx-spa
COPY --from=build /app/dist /usr/share/nginx/html
```

### 2. Build & Run

```bash
# Build the image
docker build -t my-spa-app .

# Run with your runtime values
docker run --rm -it \
  -p 8080:8080 \
  -e __VITE_API_URL="https://api.example.com/v1" \
  -e __VITE_APP_TITLE="Production Dashboard" \
  my-spa-app
```

> **Note on Prefixing:**  
> If your placeholder in the code is `_VITE_API_URL`, pass `__VITE_API_URL` as the environment variable (`PREFIX=_` + `_VITE_API_URL`).

---

## ⚙️ Configuration & Environment Variables

| Variable | Default | Description                                             |
| :------- | :------ | :------------------------------------------------------ |
| `PREFIX` | `_`     | The prefix pattern identifying variables to substitute. |
| `PORT`   | `8080`  | Internal listening port (exposed as unprivileged).      |

### Custom Prefix Example

If your SPA uses `%ENV_VAR%` or `APP_` naming conventions:

```bash
docker run --rm -it \
  -e PREFIX="SPA_" \
  -e SPA_API_URL="https://custom.domain.com" \
  -p 8080:8080 my-spa-app
```

---

## 🐳 Docker Compose Example

```yaml
services:
  frontend:
    image: my-spa-app
    ports:
      - "3000:8080"
    environment:
      - PREFIX=_
      - __VITE_API_URL=https://api.production.com
      - __VITE_ENV=production
    restart: unless-stopped
```

---

## 🧪 Testing Locally

Run the automated verification script:

```bash
./test.sh
```

---

## 📄 License

MIT © [chneau](https://github.com/chneau)
