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
RUN ls -lha
# Copy only necessary files from the build stage
COPY --from=build ./app/dist ./app/dist
COPY --from=build ./app/node_modules ./app/node_modules
COPY --from=build ./app/package*.json ./app

# Expose the necessary port
EXPOSE 4200

# Start the application
CMD ["ng", "serve --host 0.0.0.0 --port 4200"]

