# clexec - swift developers & vibe

Modern web application built with TanStack Start and React.

## 🚀 Deploy to Cloudflare Pages

This project is optimized for Cloudflare Pages deployment.

### Quick Deploy

1. **Connect your GitHub repository** to Cloudflare Pages
2. **Configure build settings:**
   - Build command: `bun run build`
   - Build output directory: `.output/public`
   - Root directory: (leave as default)

3. **Environment variables:** (if needed)
   - Add any required environment variables in Cloudflare Pages settings

### Manual Deploy

```bash
# Install dependencies
bun install

# Build for production
bun run build

# Deploy with Wrangler
npx wrangler pages deploy .output/public
```

## 🛠 Development

```bash
# Install dependencies
bun install

# Start dev server
bun run dev

# Build for production
bun run build

# Preview production build
bun run preview

# Lint code
bun run lint

# Format code
bun run format
```

## 📦 Tech Stack

- **Framework:** TanStack Start (React SSR)
- **Runtime:** Nitro (Cloudflare Workers compatible)
- **Styling:** Tailwind CSS v4
- **UI Components:** Radix UI
- **Build Tool:** Vite
- **Package Manager:** Bun

## 🌐 Features

- Server-Side Rendering (SSR)
- Cloudflare Workers compatible
- Modern React 19
- Type-safe with TypeScript
- Responsive design
- Optimized for performance

## 📝 License

Private project

---

Built with ❤️ by clexec
