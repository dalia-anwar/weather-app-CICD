FROM node:21.5.0 as node 
WORKDIR /app
COPY package*.json ./
RUN npm cache clean --force \
    && npm install
RUN npm install -g typescript @angular/cli
COPY . .

# Build the application
RUN ng build

## Stage 2: Production stage
#FROM node:21.5.0-alpine
#WORKDIR /app

# Copy only necessary files from the build stage
#COPY --from=build /app/dist ./dist
#COPY --from=build /app/node_modules ./node_modules
#COPY --from=build /app/package*.json ./

# Expose the necessary port
EXPOSE 4200

# Start the application
CMD ["ng", "serve"]

