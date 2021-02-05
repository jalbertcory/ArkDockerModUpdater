FROM ubuntu:20.04

RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    python3.8 \
    python-is-python3 \
    python3-pip

RUN git clone https://github.com/Tiiffi/mcrcon.git

WORKDIR /mcrcon
RUN make
RUN make install

WORKDIR /

ADD requirements.txt /requirements.txt
RUN pip3 install -r /requirements.txt

# Add script and grant execution rights
ADD script.py /script.py
RUN chmod +x /script.py

# Run the command on container startup
CMD ["python","-u","script.py"]