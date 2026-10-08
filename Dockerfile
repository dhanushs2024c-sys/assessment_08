# Use a lightweight Nginx image to serve static HTML content
FROM nginx:alpine

# Copy the local index.html file into the default Nginx web root directory
COPY index.html /usr/share/nginx/html/index.html

# Expose port 80 to access the web server
EXPOSE 80
