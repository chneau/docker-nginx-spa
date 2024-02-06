# docker-nginx-spa

Docker image used to serve a Single Page App with environment substitution.  
This image is built every day at 00:00 UTC.

## Test it!

```bash
docker run --rm -it -e SUBST=nginx -e nginx=HACKED -p 7777:80 ghcr.io/chneau/nginx-spa
# open your browser at http://localhost:7777 to see all the nginx replaced with HACKED
```

## Typical usage

```Dockerfile
FROM oven/bun:1 as build
ENV VITE_CLIENT_ID="VITE_CLIENT_ID"
ENV VITE_CLIENT_SECRET="VITE_CLIENT_SECRET"
ENV VITE_REDIRECT_URI="VITE_REDIRECT_URI"
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
docker run --rm -it test -e SUBST=VITE_CLIENT_ID,VITE_CLIENT_SECRET,VITE_REDIRECT_URI -e VITE_CLIENT_ID=123 -e VITE_CLIENT_SECRET=456 -e VITE_REDIRECT_URI=http://localhost:3000 -p 7777:80 test

# First on your Vite build, you set the env vars to be replaced by theyr actual name
# Then you add this nginx-spa image to at the end of your Dockerfile
# When you run the image, you pass the env vars you want to replace
# The nginx-spa will replace the env vars with the actual value
# At the start of the container, it will print the env vars it replaced in which file
```
