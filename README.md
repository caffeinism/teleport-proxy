# teleport-proxy
teleport app service automation using dockergen

# Usage

## Teleport Proxy
```
docker run -d --name=teleport-proxy -v /var/run/docker.sock:/var/run/docker.sock -e TELEPORT_PROXY=PROXY_ADDRESS -e TELEPORT_TOKEN=TOKEN caffeinism/teleport-proxy
```

## Teleport Web App as Container
```
docker run -d -e TELEPORT_NAME=APP_NAME -e TELEPORT_PORT=PORT CONTAINER_NAME
```

## Example

```
docker run -d --name=teleport-proxy -v /var/run/docker.sock:/var/run/docker.sock -e TELEPORT_PROXY=teleport.mydomain.com -e TELEPORT_TOKEN=95104ef8f4c615a4f7bf4b6789828d93 caffeinism/teleport-proxy
docker run -d -e TELEPORT_NAME=hello -e TELEPORT_PORT=80 tutum/hello-world
```
You can access web with teleport app service



# Reference
- https://goteleport.com/
- https://github.com/nginx-proxy/nginx-proxy
- https://github.com/nginx-proxy/docker-gen
