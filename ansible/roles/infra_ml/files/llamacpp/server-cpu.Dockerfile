ARG UBUNTU_VERSION=22.04

# Target the CUDA build image
ARG BASE_DEV_CONTAINER=ubuntu:${UBUNTU_VERSION}
# Target the CUDA runtime image
ARG BASE_RUN_CONTAINER=ubuntu:${UBUNTU_VERSION}

FROM ${BASE_DEV_CONTAINER} as build

RUN apt-get update && \
    apt-get install -y build-essential git

WORKDIR /app

RUN git clone https://github.com/ggerganov/llama.cpp.git

RUN cd llama.cpp && make server && cp server ..

FROM ${BASE_RUN_CONTAINER} as runtime

COPY --from=build /app/server /server

ENTRYPOINT [ "/server" ]
