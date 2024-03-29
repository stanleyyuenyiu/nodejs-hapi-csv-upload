ARG WORK_DIR=/opt

### Base ###
FROM node:12.18.0-alpine AS base

ARG WORK_DIR

COPY . ${WORK_DIR}/

### Build ###
FROM node:12.13.0-alpine AS build

ARG WORK_DIR

RUN set -x \
	&& apk update \
    && apk --no-cache add git openssh-client --virtual builds-deps build-base python3 \
    && rm -rf /var/cache/apk/*

COPY --from=base ${WORK_DIR}/ ${WORK_DIR}/

WORKDIR ${WORK_DIR}

# install node module
RUN yarn install --production --ignore-engines --ignore-optional

RUN npm run build

### Release ###
FROM node:12.13.0-alpine AS release

ARG WORK_DIR
ENV WORK_DIR=${WORK_DIR}

WORKDIR ${WORK_DIR}

COPY --from=build --chown=node:node ${WORK_DIR} ${WORK_DIR}

USER node

EXPOSE 3000

CMD ["node", "dist/server.js"]
