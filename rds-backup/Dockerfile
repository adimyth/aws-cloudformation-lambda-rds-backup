ARG FUNCTION_DIR="/lambda-rds-backup"

FROM python

LABEL maintainer="Aditya Mishra <mishraaditya6991@gmail.com>"

ARG FUNCTION_DIR
RUN mkdir -p ${FUNCTION_DIR}

# Install python & aws essentials
RUN apt -y update \
    && apt install -y \
    g++ \
    make \
    cmake \
    unzip \
    libcurl4-openssl-dev

# Install awslambdaric and awscli
RUN python3 -m pip install awslambdaric

RUN pip3 install awscli

# Install postgres client
RUN apt -y update && apt install -y postgresql-client-13 && \
    apt clean autoclean && \
    apt autoremove -y && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/

WORKDIR ${FUNCTION_DIR}

COPY app.py requirements.txt ./

# Install python deps
RUN pip3 install -r requirements.txt -t .

ENTRYPOINT [ "/usr/local/bin/python3", "-m", "awslambdaric" ]

CMD ["app.handler"]
