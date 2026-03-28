FROM node:18-alpine

WORKDIR /app

# Install dependencies for sharp
RUN apk add --no-cache vips-dev build-base python3

# Copy package files
COPY backend/package*.json ./
RUN npm ci --only=production

# Copy backend code
COPY backend/src ./src
COPY backend/.env* ./

# Create data directory
RUN mkdir -p data/db data/uploads data/backups

# Expose port
EXPOSE 3000

# Start server
CMD ["node", "src/server.js"]
