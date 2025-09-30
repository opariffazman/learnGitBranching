FROM node:14.20.0-alpine3.16 as build

RUN apk add git --no-cache
WORKDIR "/src"

COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile --ignore-scripts && \
	yarn cache clean

COPY . /src
RUN	yarn gulp dockerBuild

FROM scratch AS export
WORKDIR /
COPY --from=build /src/index.html .
COPY --from=build /src/build ./build



FROM nginx:stable-alpine
WORKDIR /usr/share/nginx/html/
COPY . .
# Override the local source with the built artifacts
COPY --from=export . . 
