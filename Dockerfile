# Dockerfile
FROM node:12 AS base
WORKDIR /myapp
COPY package*.json ./
RUN npm ci --only=dev

FROM node:12-alpine
WORKDIR /myapp
COPY --from=base /myapp .
COPY . .

EXPOSE 8080

CMD npm start
