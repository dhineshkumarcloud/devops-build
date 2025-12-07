# Use lightweight NGINX base image
FROM nginx:alpine

# Copy all build output (HTML, CSS, JS, etc.) into NGINX default web root
COPY . /usr/share/nginx/html

# Expose port 80 to serve the website
EXPOSE 80

# Start NGINX in foreground
CMD ["nginx", "-g", "daemon off;"]