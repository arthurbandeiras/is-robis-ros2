import os

from ament_index_python.packages import get_package_share_directory
from launch import LaunchDescription
from launch.actions import GroupAction, IncludeLaunchDescription
from launch.launch_description_sources import PythonLaunchDescriptionSource
from launch_ros.actions import PushRosNamespace, SetRemap

ROBOT_NAMESPACE = "robis"


def generate_launch_description():
    pkg_lidar = get_package_share_directory("ydlidar_ros2_driver")
    pkg_odrive = get_package_share_directory("odrive_ros2_pkg")

    cmd_lidar = IncludeLaunchDescription(
        PythonLaunchDescriptionSource(
            os.path.join(pkg_lidar, "launch", "ydlidar_launch.py"),
        ),
        launch_arguments={
            "params_file": os.path.join(pkg_odrive, "params", "ydlidar.yaml")
        }.items(),
    )

    cmd_odrive = IncludeLaunchDescription(
        PythonLaunchDescriptionSource(
            os.path.join(pkg_odrive, "launch", "odrive_launch.py")
        ),
    )

    # PushRosNamespace empurra o namespace para todos os nós criados dentro
    # do grupo, inclusive os que vêm de launch files inclusos (cmd_lidar),
    # desde que esses nós usem nomes relativos.
    robot_group = GroupAction(
        actions=[
            PushRosNamespace(ROBOT_NAMESPACE),
            SetRemap("/scan", f"/{ROBOT_NAMESPACE}/scan"),
            SetRemap("/point_cloud", f"/{ROBOT_NAMESPACE}/point_cloud"),
            cmd_lidar,
            cmd_odrive,
        ]
    )

    return LaunchDescription(
        [
            robot_group,
        ]
    )
