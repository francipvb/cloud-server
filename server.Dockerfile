FROM francipvb/dgd

LABEL author.name="Francisco R. Del Roio"
LABEL author.email="francipvb@hotmail.com"

WORKDIR /app
RUN mkdir mud && mkdir state

COPY cloud.dgd ./
COPY dockerentrypoint.sh ./
RUN chmod +x dockerentrypoint.sh
COPY src/ mud/
volume mud/

EXPOSE 8023 8080 5001

CMD ["./dockerentrypoint.sh"]
