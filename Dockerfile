FROM land007/tensorflow:latest

MAINTAINER Yiqiu Jia <yiqiujia@hotmail.com>

ARG S3FS_VERSION=1.85

RUN apt-get update && apt-get install -y build-essential cmake automake libfuse-dev libcurl4-openssl-dev libxml2-dev pkg-config libssl-dev && apt-get clean && \
	curl -L https://github.com/s3fs-fuse/s3fs-fuse/archive/v${S3FS_VERSION}.tar.gz | tar zxv -C /usr/src && \
	cd /usr/src/s3fs-fuse-${S3FS_VERSION} && ./autogen.sh && ./configure --prefix=/usr && make && make install && \
	mkdir /mnt/s3fs && chmod 777 /mnt/s3fs && ln -s /mnt/s3fs/ ~

ENV AccessKeyId= \
	SecretAccessKey= \
	Region=

RUN echo $(date "+%Y-%m-%d_%H:%M:%S") >> /.image_times && \
	echo $(date "+%Y-%m-%d_%H:%M:%S") > /.image_time && \
	echo "land007/s3fs" >> /.image_names && \
	echo "land007/s3fs" > /.image_name

#CMD echo ${AccessKeyId}:${SecretAccessKey} > /opt/s3fs_passwd && chmod 600 /opt/s3fs_passwd && s3fs ${Region} /mnt/s3fs -o passwd_file=/opt/s3fs_passwd  -d -d -f -o f2 -o curldbg ; bash
RUN echo 'echo ${AccessKeyId}:${SecretAccessKey} > /opt/s3fs_passwd' >> /start.sh && \
	echo 'chmod 600 /opt/s3fs_passwd' >> /start.sh && \
	echo 'nohup s3fs ${Region} /mnt/s3fs -o passwd_file=/opt/s3fs_passwd  -d -d -f -o f2 -o curldbg -o umask=0000 -o mp_umask=0000 -o allow_other > /dev/null 2>&1 &' >> /start.sh

CMD /start.sh && source /etc/bash.bashrc && jupyter notebook --notebook-dir=/tf --ip 0.0.0.0 --no-browser --allow-root
#-o default_acl=public-read
#docker build -t land007land007/tensorflow-s3fs:latest .
#docker rm -f tensorflow-s3fs ; docker run -it --privileged --name tensorflow-s3fs land007/tensorflow-s3fs:latest
