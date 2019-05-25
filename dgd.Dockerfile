FROM alpine:3.9 AS base

LABEL author.name="Francisco R. Del Roio"
LABEL author.email="francipvb@hotmail.com"

RUN apk add libstdc++

FROM base AS build

RUN apk add make g++ bison
WORKDIR /build
COPY dgd/src/ ./

ENV DEFINES="-DLINUX -DSLASHSLASH"
ENV DEBUG=""

RUN make -e

FROM base AS final

COPY --from=build /build/a.out /bin/dgd
