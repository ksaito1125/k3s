FROM alpine:3.10 as base

ENV http_proxy=http://proxy-us.toshiba.co.jp:8080
ENV https_proxy=http://proxy-us.toshiba.co.jp:8080
ENV  no_proxy=toshiba.co.jp,*.toshiba.co.jp,133.,10.,localhost,169.254.169.254,s3.ap-northeast-1.amazonaws.com,dynamodb.ap-northeast-1.amazonaws.com,dkr.ecr.ap-northeast-1.amazonaws.com,logs.ap-northeast-1.amazonaws.com

RUN apk add -U ca-certificates
ADD build/out/data.tar.gz /image
RUN mkdir -p /image/etc/ssl/certs /image/run /image/var/run /image/tmp /image/lib/modules /image/lib/firmware && \
    cp /etc/ssl/certs/ca-certificates.crt /image/etc/ssl/certs/ca-certificates.crt
RUN cd image/bin && \
    rm -f k3s && \
    ln -s k3s-server k3s

FROM alpine:3.10

ENV http_proxy=http://proxy-us.toshiba.co.jp:8080
ENV https_proxy=http://proxy-us.toshiba.co.jp:8080
ENV  no_proxy=toshiba.co.jp,*.toshiba.co.jp,133.,10.,localhost,169.254.169.254,s3.ap-northeast-1.amazonaws.com,dynamodb.ap-northeast-1.amazonaws.com,dkr.ecr.ap-northeast-1.amazonaws.com,logs.ap-northeast-1.amazonaws.com

COPY --from=base /image /
RUN mkdir -p /etc && \
    echo 'hosts: files dns' > /etc/nsswitch.conf
RUN chmod 1777 /tmp
VOLUME /var/lib/kubelet
VOLUME /var/lib/rancher/k3s
VOLUME /var/lib/cni
VOLUME /var/log
ENV PATH="$PATH:/bin/aux"
ENTRYPOINT ["/bin/k3s"]
CMD ["agent"]
