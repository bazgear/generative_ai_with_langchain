# Using a base image:
FROM ubuntu:20.04

ENV PATH="/root/miniconda3/bin:${PATH}"
ARG PATH="/root/miniconda3/bin:${PATH}"
ENV PIP_DEFAULT_TIMEOUT=1000

RUN apt-get update && apt-get install -y wget build-essential curl && rm -rf /var/lib/apt/lists/*

RUN wget \
    https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && mkdir /root/.conda \
    && bash Miniconda3-latest-Linux-x86_64.sh -b \
    && rm -f Miniconda3-latest-Linux-x86_64.sh 

# Download and extract the Google Cloud SDK
RUN curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-460.0.0-linux-x86_64.tar.gz && \
    tar -xf google-cloud-cli-460.0.0-linux-x86_64.tar.gz && \
    rm google-cloud-cli-460.0.0-linux-x86_64.tar.gz

# Set the PATH environment variable to include /google-cloud-sdk/bin/gcloud
ENV PATH="/google-cloud-sdk/bin:${PATH}"

RUN conda update -n base -c defaults conda -y && conda --version

# Update the environment:
COPY langchain_ai.yaml .
# COPY notebooks ./notebooks
RUN conda env update --name base --file langchain_ai.yaml -vv

WORKDIR /home

EXPOSE 8888
ENTRYPOINT ["conda", "run", "-n", "base", "jupyter", "notebook", "--notebook-dir=/notebooks", "--ip=0.0.0.0", "--allow-root", "--NotebookApp.token=''", "--NotebookApp.password=''"]
