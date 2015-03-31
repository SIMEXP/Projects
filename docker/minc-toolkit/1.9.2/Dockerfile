FROM ubuntu:12.04
MAINTAINER Pierre Bellec <pierre.bellec@criugm.qc.ca>

# Update repository list
RUN apt-get update
RUN apt-get dist-upgrade -y

# Install dependencies available through apt-get
RUN apt-get install -y \
  freeglut3 \
  imagemagick \
  libc6 \
  libexpat1 \
  libgl1 \
  libjpeg62 \
  libstdc++6 \
  libtiff4 \
  libuuid1 \
  libxau6 \
  libxcb1 \
  libxdmcp6 \
  libxext6 \
  libx11-6 \
  perl \
  wget 

#Install MINC-toolkit
RUN wget http://packages.bic.mni.mcgill.ca/minc-toolkit/Debian/minc-toolkit-1.9.2-20140730-Ubuntu_12.04-x86_64.deb -P /tmp
RUN dpkg -i /tmp/minc-toolkit-1.9.2-20140730-Ubuntu_12.04-x86_64.deb
RUN rm /tmp/minc-toolkit-1.9.2-20140730-Ubuntu_12.04-x86_64.deb

# Command for build 
# docker build -t="simexp/minc-toolkit:1.9.2" .
# Command for running
# docker run -i -t --rm --name minc-toolkit -v $HOME:$HOME --user $UID:$GID simexp/minc-toolkit:1.9.2 /bin/bash -c "export HOME=$HOME; cd $HOME; source /opt/minc-itk4/minc-toolkit-config.sh; exec bash"