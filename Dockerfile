FROM node:14

# Create app directory
WORKDIR /usr/src/app

# Install app dependencies
COPY app/package*.json ./
RUN npm install
RUN npm install express

# Bundle app source
COPY . .

EXPOSE 3000
CMD [ "npm", "start" ]