# vpn-proxy

A container environment to use a socks5 proxy connected to a VPN as a jump server when the ssh destination requires anyconnect VPN.

```bash
cp .env1.sample .env1
vim .env1  # replace placeholders w/ ur credentials
cp .env2.sample .env2
vim .env2  # replace placeholders w/ ur credentials
docker-compose up -d
```


Note that the .env1 is for localhost:1080 and .env2 is for localhost:1081 of the socks5 proxy running on your machine.
