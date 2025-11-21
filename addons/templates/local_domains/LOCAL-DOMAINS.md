# Local Domain Development Setup

This setup allows you to access your development environment using custom domains with HTTPS:

- 🌐 **https://APP_NAME_PLACEHOLDER.dev** - Main web application
- 🔧 **http://localhost:4003** - Traefik dashboard

## Quick Setup

1. Run the setup script:
   ```bash
   ./setup-local-domains.sh
   ```

2. Start your development environment:
   ```bash
   docker-compose up -d
   ```

3. Access your applications at the HTTPS URLs above!

## What This Does

- Installs `mkcert` for local SSL certificate generation
- Adds entries to `/etc/hosts` for local domain resolution
- Generates trusted SSL certificates for `*.dev` in `./services/traefik/certs/`
- Configures Traefik as a reverse proxy with automatic HTTPS

## File Structure

```
services/
└── traefik/
    ├── tls.yml              # Traefik TLS configuration
    └── certs/
        ├── dev.crt
        └── dev.key
```

## Stopping the Environment

```bash
docker-compose down
```

## Troubleshooting

- If you see certificate warnings, make sure `mkcert -install` was run successfully
- Check the Traefik dashboard at http://localhost:4003 to see if services are registered
- Ensure your `/etc/hosts` file contains the domain entries
- Verify certificates exist in `./services/traefik/certs/`
