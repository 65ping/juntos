import vue from "@vitejs/plugin-vue";
import liveVuePlugin from "live_vue/vitePlugin";
import tailwindcss from "@tailwindcss/vite";
import { resolve } from "path";

export default {
  plugins: [vue(), liveVuePlugin({ entrypoint: "./assets/js/server.js" }), tailwindcss()],
  resolve: {
    alias: {
      "@": resolve(__dirname, "js"),
      vue: resolve(__dirname, "../node_modules/vue"),
    },
  },
  server: {
    host: "127.0.0.1",
    port: 5173,
    strictPort: true,
    origin: "http://127.0.0.1:5173",
  },
  build: {
    target: "es2020",
    outDir: resolve(__dirname, "../priv/static/assets"),
    emptyOutDir: false,
    manifest: false,
    ssrManifest: false,
    rollupOptions: {
      input: {
        app: resolve(__dirname, "js/app.js"),
      },
      output: {
        entryFileNames: "js/[name].js",
        chunkFileNames: "js/[name]-[hash].js",
        assetFileNames: (assetInfo) => {
          if (assetInfo.name?.endsWith(".css")) {
            return "css/[name][extname]";
          }
          return "assets/[name]-[hash][extname]";
        },
      },
    },
  },
  ssr: {
    noExternal: process.env.NODE_ENV === "production" ? true : undefined,
  },
  optimizeDeps: {
    include: ["live_vue", "phoenix", "phoenix_html", "phoenix_live_view"],
  },
};
