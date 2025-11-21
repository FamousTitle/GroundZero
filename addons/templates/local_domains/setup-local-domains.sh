#!/bin/bash

echo "🚀 Setting up local domain development with Traefik"

APP_HOST="APP_NAME_PLACEHOLDER.dev"
echo "📍 Using domain: $APP_HOST"

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    else
        echo "unknown"
    fi
}

OS=$(detect_os)

# Function to add entries to /etc/hosts
setup_hosts() {
    echo "📝 Setting up /etc/hosts entries..."
    
    # Check if entry already exists
    if grep -q "$APP_HOST" /etc/hosts; then
        echo "✅ Host entry for $APP_HOST already exists"
        return 0
    fi
    
    echo "Adding local domain entry to /etc/hosts (requires sudo):"
    echo "127.0.0.1 $APP_HOST"
    
    # Add entry to /etc/hosts
    echo "" | sudo tee -a /etc/hosts
    echo "# Local development domain" | sudo tee -a /etc/hosts
    echo "127.0.0.1 $APP_HOST" | sudo tee -a /etc/hosts
    
    echo "✅ Host entry added successfully"
}

# Setup Traefik with mkcert for local SSL
setup_traefik() {
    echo "🔧 Setting up Traefik reverse proxy with local SSL certificates..."
    
    # Install mkcert for local SSL certificates
    if ! command -v mkcert &> /dev/null; then
        echo "📦 Installing mkcert for local SSL certificates..."
        
        if [ "$OS" == "macos" ]; then
            brew install mkcert
        elif [ "$OS" == "linux" ]; then
            # Install mkcert on Ubuntu/Debian
            sudo apt update
            sudo apt install -y libnss3-tools wget
            
            # Download and install mkcert
            wget https://github.com/FiloSottile/mkcert/releases/download/v1.4.4/mkcert-v1.4.4-linux-amd64
            chmod +x mkcert-v1.4.4-linux-amd64
            sudo mv mkcert-v1.4.4-linux-amd64 /usr/local/bin/mkcert
        else
            echo "❌ Unsupported OS. Please install mkcert manually."
            exit 1
        fi
    fi
    
    # Initialize mkcert
    echo "🔐 Setting up local certificate authority..."
    mkcert -install
    
    # Create certs directory inside services/traefik folder
    mkdir -p ./services/traefik/certs
    
    # Generate certificates for local domains
    echo "📜 Generating SSL certificates for *.dev..."
    mkcert -cert-file ./services/traefik/certs/dev.crt -key-file ./services/traefik/certs/dev.key "*.dev" "$APP_HOST" localhost
    
    # Create Traefik TLS configuration
    echo "📝 Creating Traefik TLS configuration..."
    cat > ./services/traefik/tls.yml <<EOF
tls:
  certificates:
    - certFile: /etc/ssl/certs/dev.crt
      keyFile: /etc/ssl/certs/dev.key
EOF
    
    echo "✅ Traefik and SSL setup complete!"
}

# Install CA certificate in browser (Linux only)
setup_browser_ca() {
    if [ "$OS" == "linux" ]; then
        echo "🌐 Installing CA certificate for Chrome/Chromium..."
        
        # Create NSS database directory if it doesn't exist
        mkdir -p $HOME/.pki/nssdb
        
        # Initialize NSS database if it doesn't exist
        if [ ! -f "$HOME/.pki/nssdb/cert9.db" ]; then
            certutil -d sql:$HOME/.pki/nssdb -N --empty-password
        fi
        
        # Check if mkcert CA is already installed
        if certutil -d sql:$HOME/.pki/nssdb -L | grep -q "mkcert"; then
            echo "✅ mkcert CA already installed in browser"
        else
            certutil -d sql:$HOME/.pki/nssdb -A -t "C,," -n "mkcert" -i ~/.local/share/mkcert/rootCA.pem
            echo "✅ mkcert CA installed in Chrome/Chromium"
            echo "⚠️  Please restart your browser for changes to take effect"
        fi
    fi
}

# Run setup
setup_hosts
setup_traefik
setup_browser_ca

echo ""
echo "🎉 Setup complete! Your local domains are ready to use."
echo ""
echo "🚀 To start your development environment:"
echo "   docker-compose up -d"
echo ""
echo "🌐 Your services will be available at:"
echo "   • https://$APP_HOST (main web app)"
echo "   • http://localhost:4003 (Traefik dashboard)"
echo ""
echo "📋 To stop:"
echo "   docker-compose down"
