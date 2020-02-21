# build stage
FROM        tzlibre/tzlibre:build AS builder

ADD         . /tzlibre
WORKDIR     /tzlibre
ENV         OPAMYES=true
RUN         eval $(opam env) && make build-deps
RUN         eval $(opam env) && make
RUN         strip tzlibre-accuser-001-Havana \
                    tzlibre-admin-client \
                    tzlibre-baker-001-Havana \
                    tzlibre-client \
                    tzlibre-endorser-001-Havana \
                    tzlibre-node \
                    tzlibre-protocol-compiler \
                    tzlibre-signer

# final stage
FROM          alpine:latest

RUN 	      apk add gmp-dev libev-dev
RUN	     	  echo "http://dl-3.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories
RUN           apk update
RUN           apk add hidapi-dev

COPY          --from=builder /tzlibre/tzlibre-accuser-001-Havana /usr/local/bin
COPY          --from=builder /tzlibre/tzlibre-admin-client /usr/local/bin
COPY          --from=builder /tzlibre/tzlibre-baker-001-Havana /usr/local/bin
COPY          --from=builder /tzlibre/tzlibre-client /usr/local/bin
COPY          --from=builder /tzlibre/tzlibre-endorser-001-Havana /usr/local/bin
COPY          --from=builder /tzlibre/tzlibre-node /usr/local/bin
COPY          --from=builder /tzlibre/tzlibre-protocol-compiler /usr/local/bin
COPY          --from=builder /tzlibre/tzlibre-signer /usr/local/bin

ADD           ./composes/scripts /scripts

CMD ["./scripts/node.sh"]
