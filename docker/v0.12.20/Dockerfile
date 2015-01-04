FROM ubuntu:12.04
MAINTAINER Pierre Bellec <pierre.bellec@criugm.qc.ca>

# Install Octave
RUN apt-get update
RUN apt-get install python-software-properties -y
RUN apt-get update
RUN apt-add-repository ppa:octave/stable -y
RUN apt-get update
RUN apt-get install octave -y
RUN apt-get install build-essential g++ cmake cmake-curses-gui bison flex freeglut3 freeglut3-dev libxi6 libxi-dev libxmu6 libxmu-dev libxmu-headers imagemagick libjpeg62 -y
RUN apt-get install "liboctave-dev" -y
RUN octave --eval "more off; pkg install -auto -global -forge -verbose control general signal image io statistics"

#Install MINC-toolkit
RUN apt-get install wget -y
RUN mkdir /home/niak
RUN wget http://packages.bic.mni.mcgill.ca/minc-toolkit/Debian/minc-toolkit-1.9.2-20140730-Ubuntu_12.04-x86_64.deb -P /home/niak
RUN dpkg -i /home/niak/minc-toolkit-1.9.2-20140730-Ubuntu_12.04-x86_64.deb
RUN rm /home/niak/minc-toolkit-1.9.2-20140730-Ubuntu_12.04-x86_64.deb

# Install PSOM
RUN apt-get install unzip
RUN mkdir -p /home/niak/build/SIMEXP/
RUN cd /home/niak/build/SIMEXP && wget http://www.nitrc.org/frs/download.php/7065/psom-1.0.2.zip
RUN cd /home/niak/build/SIMEXP && unzip psom-1.0.2.zip
RUN rm /home/niak/build/SIMEXP/psom-1.0.2.zip

# Install NIAK
RUN mkdir -p /home/niak/build/SIMEXP
RUN cd /home/niak/build/SIMEXP && wget https://github.com/SIMEXP/niak/archive/v0.12.20.zip
RUN cd /home/niak/build/SIMEXP && unzip v0.12.20.zip
RUN rm /home/niak/build/SIMEXP/v0.12.20.zip

# Install BCT
RUN mkdir -p /home/niak/build/SIMEXP
RUN cd /home/niak/build/SIMEXP && wget https://sites.google.com/site/bctnet/Home/functions/BCT.zip
RUN cd /home/niak/build/SIMEXP && unzip BCT.zip
RUN rm /home/niak/build/SIMEXP/BCT.zip

# Build octave configure file
RUN echo more off >> /etc/octave.conf
RUN echo save_default_options\(\'-7\'\)\; >> /etc/octave.conf
RUN echo graphics_toolkit gnuplot >> /etc/octave.conf
RUN echo addpath\(genpath\(\"/home/niak/build/SIMEXP/\"\)\)\; >> /etc/octave.conf

# Add the minc toolkit to the bash config
# for ubuntu 14.04
RUN touch /.bashrc
RUN echo source /opt/minc-itk4/minc-toolkit-config.sh >> /.bashrc
# docker build -t="pbellec/niak:v0.12.20" .
# docker run -i -t --name niak -v /home/pbellec/database:/database --user $UID:$GID pbellec/niak:v0.12.20 /bin/bash -c "source /.bashrc && octave"