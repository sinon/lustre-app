import gleam from "vite-gleam";
import tailwindcss from '@tailwindcss/vite'

export default {
    plugins: [
        gleam(),
        tailwindcss(),
    ],
    build: {
        rollupOptions: {
            input: 'main.js',
            output: {
                dir: './priv',
                entryFileNames: 'static/app.mjs',
            }
        }
    }
};