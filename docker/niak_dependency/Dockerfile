FROM simexp/octave:3.8.1
MAINTAINER Pierre-Olivier Quirion <poq@criugm.qc.ca>

# Install PSOM
RUN  mkdir -p /home/niak/extensions && cd /home/niak/extensions && wget -qO- https://github.com/SIMEXP/psom/archive/v1.2.0.tar.gz | tar -xvz

#To remove the psom version number
#RUN  kdir -p /home/niak/extensions && cd /home/niak/extensions && wget -qO- https://github.com/SIMEXP/psom/archive/v1.2.0.tar.gz | tar --transform 's/^psom-[0-9]\+.[0-9]\+.[0-9]\+/psom/' -xvz

# Install BCT
RUN cd /home/niak/extensions && wget https://sites.google.com/site/bctnet/Home/functions/BCT.zip && unzip BCT.zip && rm BCT.zip

# Build octave configure file
RUN echo addpath\(genpath\(\"/home/niak/\"\)\)\; >> /etc/octave.conf

# get rid of sh
RUN rm /bin/sh && ln -s /bin/bash /bin/sh 

RUN echo "source /opt/minc-itk4/minc-toolkit-config.sh" >> /etc/profile

# Command for build
# docker build -t="simexp/niak_dependency" .

# Command to run bash (don't start octave)
# docker run -i -t --rm --name niakbash -v $HOME:$HOME --user $UID:$GID simexp/niak:0.13.0 /bin/bash -c "export HOME=$HOME; export USER=$USER; cd $HOME; source /opt/minc-itk4/minc-toolkit-config.sh; exec bash"

# Command to run octave as command line
# docker run -i -t --rm --name niakcli -v $HOME:$HOME --user $UID:$GID simexp/niak:0.13.0 /bin/bash -c "export HOME=$HOME; export USER=$USER; cd $HOME; source /opt/minc-itk4/minc-toolkit-config.sh; octave"

# Command to run octave as GUI
# docker run -i -t --rm --name niakgui  -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=unix$DISPLAY -v $HOME:$HOME --user $UID:$GID simexp/niak:0.13.0 /bin/bash -c "export HOME=$HOME; export USER=$USER; cd $HOME; source /opt/minc-itk4/minc-toolkit-config.sh; octave --force-gui"
