# -*- coding: utf-8 -*-
import urx
from urx.robotiq_two_finger_gripper import Robotiq_Two_Finger_Gripper

## Réglage de connection TCP/IP ###
TCP_Robot = "192.168.1.22"          # Adresse IP du robot
TCP_Mon_Ordi = "192.168.1.20"       # Adresse IP de mon ordi (Il faut paramétrer une liaison manuellement
                                    # et écrire une adresse IP)
TCP_PORT_GRIPPER = 40001            # Ne pas changer
TCP_PORT = 30002                    # Ne pas changer

# Connection au robot
robot = urx.Robot(TCP_Robot)
robot.set_tcp((0, 0, 0.212, 0, 0, 0)) # Position du Tool Center Point par rapport au bout du robot (x,y,z,Rx,Ry,Rz)
                                    # (en mm et radians)
robot.set_payload(1, (0, 0, 0.1))     # Poids de l'outil et position de son centre de gravité (en kg et mm)

# Connection à la pince
gripper = Robotiq_Two_Finger_Gripper(robot)

# Caractéristique de mouvement
acc = 0.2                           # Accélération maximale des joints
vel = 0.2                           # Vitesse maximale des joints

# Commandes robot
'''
Les différentes commandes sont disponibles dans les fichiers python-urx-0.11.0/urx/robot.py 
                                                          et python-urx-0.11.0/urx/urrobot.py
'''
robot.movel([0.192, -0.616, 0.3, 3, 0, 0], acc=acc, vel=vel)      # Bouge le robot aux coordonnées cartésiennes
robot.get_pos()                                                   # Renvoie le (x, y, z) du TCP
robot.up()
robot.down()
robot.translate([0.1, 0.1, -0.05])

# Commandes pince
'''
Les différentes commandes sont disponibles dans le fichier python-urx-0.11.0/urx/robotiq_two_fingers_gripper.py
dans la classe Robotiq_Two_Finger_Gripper                                             
'''
gripper.open_gripper()                                  # Ferme entièrement le gripper
gripper.close_gripper()                                 # Ouvre entièrement le gripper
gripper.gripper_action(150)                             # Ouvre le gripper à une certaine taille (0:ouvert, 255: fermé)
gripper.send_opening(TCP_Mon_Ordi, TCP_PORT_GRIPPER)    # Retourne l'ouverture de la pince

# Fermeture propre de la connection
robot.close()
