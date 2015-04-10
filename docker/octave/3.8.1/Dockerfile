FROM simexp/minc-toolkit:1.9.2
MAINTAINER Pierre Bellec <pierre.bellec@criugm.qc.ca>

# Update repository list
RUN apt-get update
RUN apt-get install python-software-properties -y
RUN apt-add-repository ppa:octave/stable -y
RUN apt-get update

# Install octave
RUN apt-get install -y \
  bison \
  build-essential \
  cmake \
  cmake-curses-gui \
  flex \  
  g++ \
  imagemagick \
  liboctave-dev=3.8.1-1ubuntu1~octave1~precise1 \
  libxi-dev \
  libxi6 \
  libxmu-dev \
  libxmu-headers \
  libxmu6 \
  octave=3.8.1-1ubuntu1~octave1~precise1 
  
# Fetch Octave forge packages
RUN mkdir /home/niak
RUN wget http://sourceforge.net/projects/octave/files/Octave%20Forge%20Packages/Individual%20Package%20Releases/control-2.8.0.tar.gz -P /home/octave
RUN wget http://sourceforge.net/projects/octave/files/Octave%20Forge%20Packages/Individual%20Package%20Releases/general-1.3.4.tar.gz -P /home/octave
RUN wget http://sourceforge.net/projects/octave/files/Octave%20Forge%20Packages/Individual%20Package%20Releases/signal-1.3.0.tar.gz -P /home/octave
RUN wget http://sourceforge.net/projects/octave/files/Octave%20Forge%20Packages/Individual%20Package%20Releases/image-2.2.2.tar.gz -P /home/octave
RUN wget http://sourceforge.net/projects/octave/files/Octave%20Forge%20Packages/Individual%20Package%20Releases/io-2.0.2.tar.gz -P /home/octave
RUN wget http://sourceforge.net/projects/octave/files/Octave%20Forge%20Packages/Individual%20Package%20Releases/statistics-1.2.4.tar.gz -P /home/octave

# Install Octave forge packages
RUN octave --eval "cd /home/octave; \
                   more off; \
                   pkg install -auto -global -verbose \
                   control-2.8.0.tar.gz \
                   general-1.3.4.tar.gz \
                   signal-1.3.0.tar.gz \
                   image-2.2.2.tar.gz \
                   io-2.0.2.tar.gz \
                   statistics-1.2.4.tar.gz"

# Build octave configure file
RUN echo more off >> /etc/octave.conf
RUN echo save_default_options\(\'-7\'\)\; >> /etc/octave.conf
RUN echo graphics_toolkit gnuplot >> /etc/octave.conf

# Command for build
# docker build -t="simexp/octave:3.8.1" .

# Command to run bash (don't start octave)
# docker run -i -t --rm --name octavebash -v $HOME:$HOME --user $UID:$GID simexp/octave:3.8.1 /bin/bash -c "export HOME=$HOME; cd $HOME; source /opt/minc-itk4/minc-toolkit-config.sh; exec bash"

# Command to run octave as command line
# docker run -i -t --rm --name octavecli -v $HOME:$HOME --user $UID:$GID simexp/octave:3.8.1 /bin/bash -c "export HOME=$HOME; cd $HOME; source /opt/minc-itk4/minc-toolkit-config.sh; octave"

# Command to run octave as GUI
# docker run -i -t --rm --name octavegui  -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=unix$DISPLAY -v $HOME:$HOME --user $UID:$GID simexp/octave:3.8.1 /bin/bash -c "export HOME=$HOME; cd $HOME; source /opt/minc-itk4/minc-toolkit-config.sh; octave --force-gui"
