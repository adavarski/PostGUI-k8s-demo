FROM node:16
RUN apt update   
WORKDIR /app
COPY package.json .
RUN npm install
COPY . .
USER node
EXPOSE 8771
#ENTRYPOINT ["tail", "-f", "/dev/null"] 
CMD [ "npm", "start"]
