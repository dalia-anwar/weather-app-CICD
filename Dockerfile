FROM node:21.5.0 as build 
WORKDIR /app
COPY package*.json ./
RUN npm cache clean --force \
    && npm install
RUN npm install -g typescript @angular/cli
COPY . .




# Stage 2: Production stage
FROM node:21.5.0-alpine
WORKDIR /app
# Copy only necessary files from the build stage
COPY --from=build ./dist ./dist
COPY --from=build ./node_modules ./node_modules
COPY --from=build ./package*.json ./

# Expose the necessary port
EXPOSE 4200

# Start the application
CMD ["ng", "serve --host 0.0.0.0 --port 4200"]

