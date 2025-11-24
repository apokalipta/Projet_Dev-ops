import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { readFileSync } from 'fs'
import { resolve } from 'path'

export default defineConfig({
  plugins: [
    vue(),
    // Plugin pour servir lame.all.js depuis node_modules
    {
      name: 'serve-lamejs',
      configureServer(server) {
        server.middlewares.use('/node_modules/lamejs/lame.all.js', (req, res, next) => {
          try {
            const filePath = resolve(__dirname, 'node_modules/lamejs/lame.all.js')
            const content = readFileSync(filePath, 'utf-8')
            res.setHeader('Content-Type', 'application/javascript')
            res.end(content)
          } catch (e) {
            next()
          }
        })
      }
    }
  ],
  server: {
    port: 3000,
    open: true,
    hmr: {
      // Configuration du HMR pour éviter les erreurs de connexion
      clientPort: 3000,
      protocol: 'ws',
      host: 'localhost'
    }
  },
  // Servir les fichiers depuis node_modules
  publicDir: 'public',
  build: {
    // Configuration du build pour la production
    sourcemap: false,
    // Désactiver le HMR dans le build de production
    minify: 'terser',
    commonjsOptions: {
      // Options pour mieux gérer les modules CommonJS comme lamejs
      include: [/lamejs/, /node_modules/],
      transformMixedEsModules: true
    }
  },
  optimizeDeps: {
    // Inclure lamejs dans les dépendances optimisées
    include: ['lamejs']
  }
})
