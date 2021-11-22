# vpn-proxy

A container environment to use a socks5 proxy connected to a vpn as a jump server when the ssh destination requires anyconnect VPN.

```bash
cp .env.sample .env
vim .env  # replace placeholders w/ ur credentials
docker-compose up -d
```
