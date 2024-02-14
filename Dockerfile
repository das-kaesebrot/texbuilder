ARG FEATURE_SET=full

FROM debian:12 as base

ARG PROJECT_PATH=/var/opt/texproject
ARG CONTAINER_USER=texbuilder

RUN useradd -m ${CONTAINER_USER} -s /bin/bash

FROM base AS image-slim
RUN apt-get update && \
	apt-get install -y \
		perl wget libfontconfig1 \
		&& \
	apt-get clean

FROM base AS image-full
RUN apt-get update && \
	apt-get install -y \
		perl wget libfontconfig1 \
		python3 python-is-python3 \
		# required for minted package
		python3-pygments \
		# required for svg/eps rendering package
		inkscape \
		&& \
	apt-get clean

FROM image-${FEATURE_SET} AS final

RUN mkdir -pv "${PROJECT_PATH}"
USER ${CONTAINER_USER}
WORKDIR ${PROJECT_PATH}

RUN wget -qO- "https://yihui.org/tinytex/install-bin-unix.sh" | sh

ENV PATH="${PATH}:/home/${CONTAINER_USER}/.TinyTeX/bin/x86_64-linux"
RUN tlmgr install xetex
RUN fmtutil-sys --all

RUN tlmgr install xcolor fancyhdr parskip texliveonfly biber koma-script
