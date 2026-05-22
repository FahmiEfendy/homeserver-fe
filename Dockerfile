FROM node:22-alpine AS builder
WORKDIR /app
ARG BASE_DOMAIN
ENV BASE_DOMAIN=$BASE_DOMAIN
ARG PUBLIC_API_BASE_URL
ENV PUBLIC_API_BASE_URL=$PUBLIC_API_BASE_URL
COPY package*.json ./
RUN npm install
COPY . .
# We don't need to pass BASE_DOMAIN here if it's evaluated at runtime, 
# BUT Astro static generates HTML at build time. 
# So we need to ensure the env var is available during build if we use static export.
# In a GH action, we'll pass it as a build arg or env var. 
# For now, let it build.
RUN npm run build

FROM nginx:alpine
ARG GIT_BRANCH=unknown
LABEL org.opencontainers.image.ref.name=${GIT_BRANCH}
# Copy the static built files from Astro to NGINX html folder
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
