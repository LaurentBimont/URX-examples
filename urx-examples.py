# -*- coding: utf-8 -*-
import urx
from urx.robotiq_two_finger_gripper import Robotiq_Two_Finger_Gripper
import numpy as np

## Réglage de connection TCP/IP ###
TCP_Robot = "192.168.1.22"          # Adresse IP du robot
TCP_Mon_Ordi = "192.168.1.100"      # Adresse IP de mon ordi (Il faut paramétrer une liaison manuellement
                                    # et écrire une adresse IP dans le même sous réseau
                                    # que le robot 192.168.1.XX)
TCP_PORT_GRIPPER = 40001            # Ne pas changer
TCP_PORT = 30002                    # Ne pas changer

# Connection au robot
robot = urx.Robot(TCP_Robot)
robot.set_tcp((0, 0, 0.3, 0, 0, -0.43)) # Position du Tool Center Point par rapport au bout du robot (x,y,z,Rx,Ry,Rz)
                                    # (en mm et radians)
robot.set_payload(1, (0, 0, 0.1))       # Poids de l'outil et position de son centre de gravité (en kg et mm)

# Connection à la pince
gripper = Robotiq_Two_Finger_Gripper(robot)

# Caractéristique de mouvement
acc = 0.4                           # Accélération maximale des joints
vel = 0.4                           # Vitesse maximale des joints
deg2rad = np.pi/180
angular_pos = [-250*deg2rad, -55*deg2rad, 50*deg2rad, -90*deg2rad, 250*deg2rad, -50*deg2rad]

# Commandes robot
'''
Les différentes commandes sont disponibles dans les fichiers python-urx-0.11.0/urx/robot.py 
                                                          et python-urx-0.11.0/urx/urrobot.py
'''
robot.movel([0.192, -0.616, 0.3, 3, 0, 0], acc=acc, vel=vel)        # Bouge le robot aux coordonnées cartésiennes

robot.movej(angular_pos, acc=acc, vel=vel)	                    # Bouge le robot en articulaire (radian)
print(robot.get_pose())                                          # Renvoie le (x, y, z) du TCP
robot.up()
robot.down()
robot.translate([0.1, 0.1, 0.1])

# Commandes pince
'''
Les différentes commandes sont disponibles dans le fichier python-urx-0.11.0/urx/robotiq_two_fingers_gripper.py
dans la classe Robotiq_Two_Finger_Gripper                                             
'''
gripper.open_gripper()                                  # Ferme entièrement le gripper
gripper.close_gripper()                                 # Ouvre entièrement le gripper
gripper.gripper_action(150)                             # Ouvre le gripper à une certaine taille (0:ouvert, 255: fermé)
print(gripper.send_opening(TCP_Mon_Ordi, TCP_PORT_GRIPPER))  # Retourne l'ouverture de la pince
robot.close()                                           # Fermeture de la connection


# Commandes capteur de force ouvrir une connection avec le capteur de force
robot = urx.Robot(TCP_Robot, useForce=True)
robot.set_tcp((0, 0, 0.3, 0, 0, -0.43)) # Position du Tool Center Point par rapport au bout du robot (x,y,z,Rx,Ry,Rz)
                                    # (en mm et radians)
robot.set_payload(1, (0, 0, 0.1))
print(robot.force_sensor.getZForce())
robot.force_sensor.tare()           # Tare le capteur de force
robot.force_sensor.getNormForce()   # Retourne la norme de la force en Newton
print('Force en Z positif')
for i in range(5):
    robot.movel([0.192, -0.616, 0.3, 3, 0, 0], acc=acc, vel=vel, zforce=-1)
    robot.movel([0.0, -0.616, 0.3, 3, 0, 0], acc=acc, vel=vel, zforce=-1)

print('Force Normale')
for i in range(5):
    robot.movel([0.192, -0.616, 0.3, 3, 0, 0], acc=acc, vel=vel, force=5)
    robot.movel([0.0, -0.616, 0.3, 3, 0, 0], acc=acc, vel=vel, force=5)
# Fermeture propre de la connection
robot.close()
