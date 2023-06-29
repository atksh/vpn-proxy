# vpn-proxy

A container environment to use a socks5 proxy connected to a VPN as a jump server when the ssh destination requires anyconnect VPN.

```bash
cp .env1.sample .env1
vim .env1  # replace placeholders w/ ur credentials
cp .env2.sample .env2
vim .env2  # replace placeholders w/ ur credentials
docker-compose up -d
```
