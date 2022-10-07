# Docker-Web-Redirect #

This docker container listens on port 80 (default) and redirects all web traffic to the given target domain/URL.
- forked from [MorbZ/docker-web-redirect](https://github.com/MorbZ/docker-web-redirect)
  - Differences
    - Use HTTP redirect instead of nginx rewrite
    - Drop URL path

## Usage ##
### Environment ###
- (Required) The target domain/URL is set by the `REDIRECT_TARGET` environment variable.
  - Ex. `https://kftc.or.kr`
- (Optional) The redirection type is set by the `REDIRECT_CODE` environment variable.
  - Available codes
    - `301` : Permanent redirects. Using GET method to redirected location.
    - `308` : Permanent redirects. Using same method to redirected location. (Not supported by IE)
    - `303` : Temporary redirects. Using GET method to redirected location.
    - `307` : Temporary redirects. Using same method to redirected location. (Not supported by IE)
    - `302` : Temporary redirects. Originally same as `307`, but most browsers do like `303`.
  - Default code is `302`.

### Example ###
```sh
$ docker run --rm -d -e REDIRECT_TARGET=https://kftc.or.kr -p 80:80 yoobato/docker-web-redirect
```

## Docker Compose ##
This image can be combined with the [nginxproxy/nginx-proxy](https://hub.docker.com/r/nginxproxy/nginx-proxy/).
A sample docker-compose file that redirects `kftcold.net` to `kftcnew.net` could look like this:

```yaml
version: '3.8'

services:
  redirect:
    image: yoobato/docker-web-redirect
    restart: always
    environment:
      - VIRTUAL_HOST=kftcold.net
      - REDIRECT_TARGET=https://kftcnew.net
      - REDIRECT_CODE=301
```
