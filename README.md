# AnyConnect + Dante in docker container

Provides SOCKS proxy on port 1081 that tunnels connections
via AnyConnect VPN. Start with `--priviledged` to allow 
docker container to setup tunneling network instance inside.


## Example run

    docker run -p 1081:1081 -p 3389:3389 \
        -e ANYCONNECT_SERVER=<server_ip> \
        -e CERT='sha256:<server_cert_fingerprint>' \
        -e ANYCONNECT_USER=<username> \
        -e ANYCONNECT_PASSWORD=<password> \
        --privileged -ti `docker build -q`

# vpn-proxy
