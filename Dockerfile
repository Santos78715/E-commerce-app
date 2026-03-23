# Stage 1: Build the application
FROM node:22-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Stage 2: Install production dependencies only
FROM node:22-alpine AS packager
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev

# Stage 3: Final runtime image
FROM node:22-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production

# Copy only the necessary files from previous stages
COPY --from=packager /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY package*.json ./

EXPOSE 3000
CMD ["node", "dist/main.js"]