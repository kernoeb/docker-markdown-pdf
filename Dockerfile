FROM ubuntu:21.10
LABEL desc="Docker way to convert Markdown to PDF with Pandoc"
LABEL author="kernoeb"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install xz-utils ghostscript wget texlive-luatex texlive-lang-cjk lmodern texlive-xetex \
    texlive-latex-extra texlive-fonts-recommended texlive-fonts-extra latexmk git latexdiff -y && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ARG PANDOC_VERSION=2.17.1.1
ARG PANDOC_CROSSREF_VERSION=0.3.12.2

RUN wget https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/pandoc-${PANDOC_VERSION}-1-amd64.deb && \
    dpkg -i pandoc-${PANDOC_VERSION}-1-amd64.deb && \
    wget https://github.com/lierdakil/pandoc-crossref/releases/download/v${PANDOC_CROSSREF_VERSION}/pandoc-crossref-Linux.tar.xz && \
    tar -xvf ./pandoc-crossref-Linux.tar.xz && mv pandoc-crossref /usr/local/bin && \
    rm ./pandoc-${PANDOC_VERSION}-1-amd64.deb ./pandoc-crossref*

ADD make.sh /usr/bin/make.sh
RUN chmod +x /usr/bin/make.sh

WORKDIR /app

ENTRYPOINT ["/usr/bin/make.sh"]
