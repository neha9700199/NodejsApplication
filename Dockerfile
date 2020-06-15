# Dockerfile
FROM node:12 AS base
WORKDIR /myapp
COPY package*.json ./
RUN npm ci 

FROM node:12-alpine
WORKDIR /myapp
COPY --from=base /myapp .
COPY . .

EXPOSE 9000

CMD npm start
