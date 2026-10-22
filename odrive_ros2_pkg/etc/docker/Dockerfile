FROM ros:jazzy-ros-base

ENV DEBIAN_FRONTEND=noninteractive

ENV RMW_IMPLEMENTATION=rmw_fastrtps_cpp

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
    ros-jazzy-diagnostic-updater \
    ros-jazzy-tf-transformations \
    ros-jazzy-slam-toolbox \
    ros-jazzy-rmw-fastrtps-cpp \
    cmake \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install --break-system-packages \
    "setuptools<80,>=69.3" "packaging>=22"

RUN python3 -m pip install --break-system-packages --ignore-installed --upgrade odrive

WORKDIR /workspace/ros2_ws
RUN mkdir src/

COPY ./odrive_ros2_pkg src/odrive_ros2_pkg

WORKDIR /workspace/ros2_ws
RUN . /opt/ros/jazzy/setup.sh \
    && colcon build --packages-select odrive_ros2_pkg

SHELL [ "/bin/bash" , "-c" ]
RUN source install/setup.bash
WORKDIR /workspace/ros2_ws/src/odrive_ros2_pkg

RUN python3 -m pip install --break-system-packages --ignore-installed . --force-reinstall

WORKDIR /workspace

RUN git clone https://github.com/matheusdutra0207/YDLidar-SDK.git
WORKDIR /workspace/YDLidar-SDK/build
RUN cmake ..
RUN make
RUN make install
RUN cpack

WORKDIR /workspace/ros2_ws

RUN cd src/ \
    && git clone -b humble https://github.com/matheusdutra0207/ydlidar_ros2_driver.git \
    && cd .. \
    && . /opt/ros/jazzy/setup.sh \
    && colcon build --packages-select ydlidar_ros2_driver \
    && source install/setup.bash