FROM node:21.5.0-alpine as build 
WORKDIR /app
COPY package*.json ./
RUN npm cache clean --force \
    && npm install
RUN npm install -g typescript @angular/cli
COPY . .
EXPOSE 4200
CMD ["entrypoint.sh"]
