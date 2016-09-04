FROM okdocker/nginx-base

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log; ln -sf /dev/stderr /var/log/nginx/error.log

VOLUME ["/var/cache/nginx"]

EXPOSE 80 443

#CMD ["/sbin/entrypoint"]
CMD ["nginx", "-g", "daemon off;"]

