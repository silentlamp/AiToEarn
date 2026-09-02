# Deploy

From workspace root:

```powershell
cd AIToEarn
docker compose up -d
docker compose ps
```

Open: http://localhost:8080

Stop:

```powershell
docker compose down
```

Rebuild after config changes (if needed):

```powershell
docker compose restart aitoearn-server aitoearn-ai aitoearn-web
```

First startup creates an admin user and auto-login token at `/data/init/token.txt` inside `aitoearn-web`.
