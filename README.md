# docker-nginx-spa

Docker image used to serve a Single Page App with environment substitution.  
This image is built every day at 00:00 UTC.

## Test it!

```bash
docker run --rm -it -e _nginx=HACKED -p 7777:80 ghcr.io/chneau/nginx-spa
# open your browser at http://localhost:7777 to see all the nginx replaced with HACKED
```

## Typical usage

```Dockerfile
FROM oven/bun:1 as build
ENV VITE_CLIENT_ID="_VITE_CLIENT_ID"
ENV VITE_CLIENT_SECRET="_VITE_CLIENT_SECRET"
ENV VITE_REDIRECT_URI="_VITE_REDIRECT_URI"
WORKDIR /app
COPY package.json bun.lockb .
RUN bun install --frozen-lockfile
COPY . .
RUN bun x vite build

FROM ghcr.io/chneau/nginx-spa
COPY --from=build /app/dist /usr/share/nginx/html
```

```bash
# build it
docker build -t test .

# run it with with your own env var
docker run --rm -it test -e __VITE_CLIENT_ID=123 -e __VITE_CLIENT_SECRET=456 -e __VITE_REDIRECT_URI=http://localhost:3000 -p 7777:80 test

# By default the prefix is _, you can change it with the PREFIX env var
# Just add a _ to the value you want to replace in your SPA files
```
