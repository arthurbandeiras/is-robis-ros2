FROM ros:humble

RUN apt-get update && apt-get install -y --no-install-recommends \
    usbutils \
    net-tools \
    software-properties-common \
    wget \
    libjpeg-dev \
    libjpeg8-dev \
    libfreetype6-dev \
    vim \
    python3-pip \
    ros-humble-diagnostic-updater \
    ros-humble-tf-transformations \
    ros-humble-slam-toolbox \
    cmake \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

#RUN wget https://bootstrap.pypa.io/get-pip.py && python3 get-pip.py
RUN python3 -m pip install --upgrade odrive

#RUN apt-get install -y ros-humble-diagnostic-updater
#RUN apt-get install -y ros-humble-tf-transformations
#RUN apt install -y ros-humble-slam-toolbox

WORKDIR /workspace/ros2_ws
RUN mkdir src/
RUN git clone -b devel https://github.com/arthurbandeiras/is-robis-ros2.git \
    && mv is-robis-ros2/odrive_ros2_pkg src/

WORKDIR /workspace/ros2_ws
RUN colcon build --packages-select odrive_ros2_pkg

SHELL [ "/bin/bash" , "-c" ]
RUN source install/setup.bash
WORKDIR /workspace/ros2_ws/src/odrive_ros2_pkg
RUN python3 -m pip install . --force-reinstall

# Lidar
#RUN apt install cmake pkg-config

WORKDIR /workspace

RUN git clone https://github.com/matheusdutra0207/YDLidar-SDK.git
WORKDIR /workspace/YDLidar-SDK/build
RUN cmake ..
RUN make
RUN sudo make install
RUN cpack

WORKDIR /workspace/ros2_ws

RUN cd src/ \
    && git clone -b humble https://github.com/matheusdutra0207/ydlidar_ros2_driver.git \
    && cd .. \
    && source /opt/ros/humble/setup.bash \
    && colcon build --packages-select ydlidar_ros2_driver \
    && source install/setup.bash 
#RUN apt-get update
#RUN apt install -y ros-humble-slam-toolbox  
