FROM ubuntu:18.04
ENV DEBIAN_FRONTEND=noninteractive
RUN echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes
RUN apt-get update \
&& apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        jq \
        git \
        iputils-ping \
        libcurl3 \
        libicu55 \
        python2.7 \
        unzip \
        wget

RUN wget https://releases.hashicorp.com/terraform/0.13.4/terraform_0.13.4_linux_amd64.zip
RUN sudo sudo unzip ./terraform_0.13.4_linux_amd64.zip -d /usr/local/bin/
RUN curl -o /usr/local/bin/terragrunt https://github.com/gruntwork-io/terragrunt/releases/download/v0.25.1/terragrunt_linux_amd64
RUN chmod +x /usr/local/bin/terragrunt

RUN curl -O https://bootstrap.pypa.io/get-pip.py
RUN python2.7 get-pip.py
RUN pip install awscli
RUN echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
WORKDIR /azp
CMD ["terraform" , "--version"]
