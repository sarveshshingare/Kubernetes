# Step 1: Build the React app
FROM node:18-alpine AS build

# Set working directory
WORKDIR /app

# Install dependencies
COPY package.json package-lock.json ./
RUN npm install

# Copy app source code
COPY . .

# Build the React app
RUN npm run build

# Step 2: Serve the app with Nginx
FROM nginx:alpine

# Copy built assets from the 'dist' directory
COPY --from=build /app/dist /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx server
CMD ["nginx", "-g", "daemon off;"]
