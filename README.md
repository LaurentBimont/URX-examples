# Urx examples
Urx is an open source library to control a UR robot via python. This repo shows some codes to use it and some additional features like getting the length between the two fingers of a gripper. The original python-urx library can be found at [Python-urx package](https://github.com/SintefManufacturing/python-urx).  
An ATI Ethernet Axia F/T Sensor is added to our UR robot, an additional library to connect to it via python is also used. The original library can be found at [NetFT package](https://github.com/CameronDevine/NetFT)

## Install URX
* Open a terminal in python-urx-0.11.0/ and key in ``` python setup.py install  ```
* Open a terminal in NetFT-master/ and key in ``` python setup.py install  ```

## Modifications
To discover, add or modify some skills, go into  
  * python-urx-0.11.0/urx/robot.py
  * python-urx-0.11.0/urx/urrobot.py
  * NetFT-master/NetFT/__init__.py

After any changes, go into the terminal of the corresponding folder and key in ``` python setup.py install  ```

## Examples
Examples are in urx-examples.py.
