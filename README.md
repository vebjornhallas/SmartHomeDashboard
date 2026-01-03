# Homey Dashboard

A touch-friendly web dashboard for controlling your [Homey](https://homey.app) smart home devices and flows. Perfect for wall-mounted tablets or any browser.

## Features

- **Touch-optimized interface** - Large buttons, swipe-friendly controls
- **Device controls** - Toggle switches, dimmers, thermostats
- **Flow triggers** - One-tap flow activation
- **Multiple dashboards** - Create different dashboards for each room
- **Drag-and-drop layout** - Customize your dashboard layout
- **Real-time updates** - Device states update every 5 seconds
- **Configurable cards** - Choose which sensors and controls to display
- **No authentication** - Designed for local network use on dedicated displays

## Quick Start with Docker

The easiest way to run Homey Dashboard:

```bash
# Clone the repository
git clone https://github.com/vebjornhallas/SmartHomeDashboard.git
cd SmartHomeDa

# Start the container
docker compose up -d

# Access at http://localhost:8080
```

### Custom Port

```bash
PORT=3000 docker compose up -d
```

### Persistent Data

The SQLite database is stored in `./data/` and persists across container restarts.

## Manual Installation

### Requirements

- PHP 8.2+
- Composer
- Node.js 18+
- SQLite

### Steps

```bash
# Clone the repository
git clone https://github.com/vebjornhallas/SmartHomeDashboard.git
cd SmartHomeDashboard

# Install dependencies
composer install
npm install

# Setup environment
cp .env.example .env
php artisan key:generate

# Create database
touch database/database.sqlite
php artisan migrate

# Build frontend assets
npm run build

# Start the server
php artisan serve
```

Access the dashboard at `http://localhost:8000`

## Configuration

### 1. Get Your Homey API Key

1. Open the Homey app on your phone
2. Go to **Settings** → **API Keys**
3. Tap **Create new key**
4. Give it a name and copy the token

### 2. Find Your Homey IP Address

1. Open the Homey app
2. Go to **Settings** → **General**
3. Note the IP address (e.g., `192.168.1.100`)

### 3. Configure the Dashboard

1. Open `http://localhost:8080/admin/settings`
2. Enter your Homey's IP address and API token
3. Click **Test Connection** to verify
4. Save the settings

### 4. Create a Dashboard

1. Go to `http://localhost:8080/admin/dashboards`
2. Click **Create Dashboard**
3. Add a name and optional description
4. Click the edit icon to add devices and flows

### 5. Access Your Dashboard

Each dashboard has a unique URL like:
```
http://localhost:8080/d/abc123-def456
```

Use this URL on your wall tablet or any device on your local network.

## Usage

### Dashboard View

- **Toggle devices** - Tap the switch to turn on/off
- **Adjust brightness** - Use the slider for dimmable lights
- **Control thermostat** - Tap +/- to adjust temperature
- **Trigger flows** - Tap a flow card to run it

### Edit Mode

1. Click **Edit Layout** to enter edit mode
2. **Drag** cards to rearrange
3. **Resize** from the corner handle
4. **Add** devices/flows from the right panel
5. **Configure** cards with the gear icon
6. **Remove** cards with the X button
7. Click **Save Layout** when done

## Architecture

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Browser       │────▶│  Dashboard      │────▶│  Homey          │
│   (Tablet)      │◀────│  (Laravel)      │◀────│  (Local API)    │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

- **Frontend**: Tailwind CSS, Vite, GridStack.js
- **Backend**: Laravel 12, SQLite
- **API**: Local Homey REST API

## Production Deployment

### Using Docker (Recommended)

```bash
# Build and run
docker compose up -d --build

# View logs
docker compose logs -f

# Stop
docker compose down
```

### Behind a Reverse Proxy (Nginx)

```nginx
server {
    listen 80;
    server_name dashboard.local;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | `8080` | Port to expose the dashboard |
| `APP_DEBUG` | `false` | Enable debug mode (disable in production) |
| `APP_URL` | `http://localhost` | Public URL of the dashboard |

## Security Notes

- This dashboard has **no authentication** by design
- Only expose it on your **local network**
- Do **not** expose it to the internet without adding authentication
- The Homey API token is stored encrypted in the database

## Troubleshooting

### Cannot connect to Homey

1. Verify the IP address is correct
2. Ensure your server can reach Homey on the local network
3. Check that the API token is valid
4. Try creating a new API token in the Homey app

### Devices not updating

- Device states poll every 5 seconds
- Check browser console for errors
- Verify the Homey connection in admin settings

### Docker container won't start

```bash
# Check logs
docker compose logs app

# Rebuild from scratch
docker compose down
docker compose build --no-cache
docker compose up -d
```

## Development

```bash
# Start development server with hot reload
composer dev

# Or run separately:
php artisan serve
npm run dev
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - see [LICENSE](LICENSE) for details.

## Credits

- Built with [Laravel](https://laravel.com)
- Grid system by [GridStack.js](https://gridstackjs.com)
- Styled with [Tailwind CSS](https://tailwindcss.com)
- Smart home integration via [Homey](https://homey.app)
