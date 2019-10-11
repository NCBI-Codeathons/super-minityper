FROM erictdawson/base

RUN git clone --recursive https://github.com/lh3/minigraph.git && \
	cd minigraph && \
	make && \
	cp minigraph /usr/local/bin/
