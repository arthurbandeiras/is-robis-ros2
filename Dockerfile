FROM ros:humble

# RMW definitivo do Robis: Fast DDS (decisão de 14/10, ver contexto_arquitetura.md
# "Reavaliação da RMW"). O Create 3 já roda Fast DDS por padrão; manter RMWs
# diferentes entre robôs no mesmo ROS_DOMAIN_ID quebra a interoperabilidade de
# descoberta/QoS entre vendors, então o Robis passa a usar o mesmo.
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
    ros-humble-diagnostic-updater \
    ros-humble-tf-transformations \
    ros-humble-slam-toolbox \
    ros-humble-rmw-fastrtps-cpp \
    cmake \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Fixa setuptools/packaging numa combinação compatível com colcon-core
# (que exige setuptools<80,>=30.3.0) e sem o bug de
# "canonicalize_version() got an unexpected keyword argument
# 'strip_trailing_zero'" (setuptools>=69.3 chamando uma API que só existe em
# packaging>=22). Feito antes de qualquer colcon build/pip install do pacote
# próprio para não depender da versão que o `ros:humble` trouxe por padrão.
RUN python3 -m pip install "setuptools<80,>=69.3" "packaging>=22"

#RUN wget https://bootstrap.pypa.io/get-pip.py && python3 get-pip.py
RUN python3 -m pip install --upgrade odrive

WORKDIR /workspace/ros2_ws
RUN mkdir src/
#RUN git clone -b devel https://github.com/arthurbandeiras/is-robis-ros2.git \
#    && mv is-robis-ros2/odrive_ros2_pkg src/

COPY ./odrive_ros2_pkg src/odrive_ros2_pkg

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