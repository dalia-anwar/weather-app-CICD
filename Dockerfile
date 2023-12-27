FROM node:21.5.0 as build 
WORKDIR /app
COPY package*.json ./
RUN npm cache clean --force \
    && npm install
RUN npm install -g typescript @angular/cli
COPY . .


FROM node:21.5.0-alpine as main
# adds workdir
WORKDIR /app
COPY --from=build . .    
# Expose the necessary port
EXPOSE 4200
# Start the application
# CMD ["ng", "serve", "--host", "0.0.0.0", "--port", "4200"]
CMD ["entrypoint.sh"]
