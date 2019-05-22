FROM frolvlad/alpine-miniconda3
RUN apk update
RUN apk add git
RUN apk add g++
RUN git clone -b develop https://github.com/ESRIN-RSS/L8_reflectance.git
RUN pip install --upgrade pip
RUN conda install gdal
RUN pip install numpy
RUN pip install -e L8_reflectance
ENTRYPOINT ["L8_reflectance"]
CMD []