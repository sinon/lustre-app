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
                dir: './dist',
                entryFileNames: 'assets/gleam_vite_example.js',
            }
        }
    }
};