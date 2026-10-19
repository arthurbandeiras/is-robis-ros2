from launch import LaunchDescription
from launch_ros.actions import Node
from launch.substitutions import LaunchConfiguration
from launch_ros.parameter_descriptions import ParameterValue


def generate_launch_description():
    publish_odom_tf = LaunchConfiguration("publish_odom_tf")
    publish_odom_tf_bool = ParameterValue(publish_odom_tf, value_type=bool)

    return LaunchDescription(
        [
            Node(
                package="odrive_ros2_pkg",
                executable="odrive_node",
                name="odrive_node",
                output="screen",
                emulate_tty=True,
                parameters=[
                    {
                        "simulation_mode": False,
                        "wheel_track": 0.278,
                        "tyre_circumference": 0.5,
                        "publish_odom_tf": publish_odom_tf_bool,
                    }
                ],
            ),
            Node(
                package="tf2_ros",
                executable="static_transform_publisher",
                name="base_link_broadcaster",
                arguments=[
                    "0",
                    "0",
                    "0",
                    "0",
                    "0",
                    "0",
                    "1",
                    "base_link",
                    "base_footprint",
                ],
            ),
        ]
    )
