# FROM nvidia/cuda:12.4.1-base-ubuntu22.04
FROM 192.168.0.96:5000/cyberfantasy2024/cfbase:202406

ENV DEBIAN_FRONTEND noninteractive
ENV CMDARGS --listen

RUN apt-get update -y && \
	apt-get install -y curl libgl1 libglib2.0-0 python3-pip python-is-python3 git && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

COPY requirements_docker.txt requirements_versions.txt /tmp/
RUN pip install --no-cache-dir -r /tmp/requirements_docker.txt -r /tmp/requirements_versions.txt && \
	rm -f /tmp/requirements_docker.txt /tmp/requirements_versions.txt
RUN pip install --no-cache-dir xformers==0.0.23 --no-dependencies
ADD frpc_linux_amd64 /usr/local/lib/python3.10/dist-packages/gradio/frpc_linux_amd64_v0.2
RUN chmod +x /usr/local/lib/python3.10/dist-packages/gradio/frpc_linux_amd64_v0.2

RUN adduser --disabled-password --gecos '' user && \
	mkdir -p /content/app /content/data

COPY entrypoint.sh /content/
RUN chown -R user:user /content

WORKDIR /content
USER user

COPY --chown=user:user . /content/app
RUN mv /content/app/models /content/app/models.org

CMD [ "sh", "-c", "/content/entrypoint.sh ${CMDARGS}" ]
