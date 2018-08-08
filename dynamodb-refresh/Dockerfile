FROM node:8

COPY ./db-refresh.js .
COPY package.json .
COPY package-lock.json .

RUN npm install

CMD ["node", "db-refresh.js"]