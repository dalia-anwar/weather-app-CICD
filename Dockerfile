FROM node:latest as node 
WORKDIR /app
COPY . .
RUN npm cache clean --force
RUN npm install
RUN npm install -g typescript
RUN npm install -g @angular/cli
EXPOSE 4200
