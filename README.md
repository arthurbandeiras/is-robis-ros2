# Robis ros2

## Odrive Ros2

### Run the project
```
sudo docker run --rm --privileged -it --network=host -v "$(pwd):/workspace/src" -v /dev/bus/usb:/dev/bus/usb --name=robis_ro2 arthurbandeira/robis_ros2:0.0.2 bash
```

### Initialize the odrive node
```
source install/setup.bash
ros2 launch odrive_ros2_pkg is_robis_ros2_launch.py publish_odom_tf:=true
```
All ROS2 topics, services and node names of this robot now live under the
`/robis` namespace (applied once in `is_robis_ros2_launch.py` via
`PushRosNamespace`), so they don't need a per-topic remap and multiple
robots can share the same `ROS_DOMAIN_ID` without colliding.

### Consume the robot odometry 

```
sudo docker exec -it robis_ro2 bash
```

```
source /opt/ros/humble/setup.bash
ros2 topic echo /robis/odrive/odom --field pose.pose.position
```
### Publish cmd_vel topic

```
sudo docker exec -it robis_ro2 bash
```

```
source /opt/ros/humble/setup.bash
ros2 topic pub -r 15 /robis/cmd_vel geometry_msgs/msg/Twist "{linear: {x: 0.1, y: 0.0, z: 0.0}, angular: {x: 0.0, y: 0.0, z: 0.1}}"
```

### Map an environment

```
sudo docker exec -it robis_ro2 bash
```
#### Edit the config file
```
vim opt/ros/humble/share/slam_toolbox/config/mapper_params_online_async.yaml
```
#### Run the Slam Toolbox
```
source /opt/ros/humble/setup.bash
ros2 launch slam_toolbox online_async_launch.py
```

#### Some useful commands
```
ros2 service call /reinitialize_global_localization std_srvs/Empty
```
```
ros2 service call /reset_odometry std_srvs/Trigger
```
```
ros2 run teleop_twist_keyboard teleop_twist_keyboard --ros-args -r cmd_vel:=/robis/cmd_vel
```
```
ros2 run tf2_ros static_transform_publisher 0 0 0 0 0 0 1 map odom
```
```
ros2 run nav2_map_server map_saver_cli -f my_map
```
```
ros2 run tf2_tools view_frames
```


