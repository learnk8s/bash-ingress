FROM nginx

COPY run.sh .

ARG BUILDARCH

RUN curl -LO "https://dl.k8s.io/release/v1.25.0/bin/linux/$BUILDARCH/kubectl"
RUN install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

CMD ["/bin/bash", "-c", "nginx;./run.sh"]