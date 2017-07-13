FROM centos:latest

# install dependencies 
RUN  yum update -y && \
     yum groupinstall -y "Development Tools" && \	
     yum install -y which && \
     yum install -y epel-release && \
     yum install -y python-pip python-devel openssl-devel Lmod && \
     pip install --upgrade pip && \
     pip install setuptools && \
     pip install easybuild && \ 
     pip install GitPython python-graph-dot graphviz keyring keyrings.alt

RUN  mkdir -p /app && \
     mkdir -p /scratch/tmp && \
     useradd easybuild && \
     chown easybuild:easybuild /app && \
     chown easybuild:easybuild -R /scratch && \
     su - easybuild && \
     echo "export EASYBUILD_PREFIX=/scratch" >> ~/.bashrc && \
     echo "export EASYBUILD_INSTALL_PATH=/app" >> ~/.bashrc && \
     echo "export EASYBUILD_MODULE_NAMING_SCHEME=HierarchicalMNS" >> ~/.bashrc && \
     echo "export EASYBUILD_TMPDIR=/scratch/tmp" >> ~/.bashrc 

 
