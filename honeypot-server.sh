# Honeypot ubuntu server setup, check for ssh attacks
# Cowrie honeypot setup, which is a popular SSH honeypot written in Python. It simulates a real SSH server and allows you to monitor and analyze the attacker's behavior.

# Cowrie Documentation: https://docs.cowrie.org/en/latest/INSTALL.html

# 1. Install System Dependencies
sudo apt-get install git python3-pip python3-venv libssl-dev libffi-dev build-essential libpython3-dev python3-minimal authbind

# 2. Create a User for Cowrie
sudo adduser --disabled-password cowrie
# Adding user 'cowrie' ...
# Adding new group 'cowrie' (1002) ...
# Adding new user 'cowrie' (1002) with group 'cowrie' ...
# Changing the user information for cowrie
# Enter the new value, or press ENTER for the default
# Full Name []:
# Room Number []:
# Work Phone []:
# Home Phone []:
# Other []:
# Is the information correct? [Y/n]

sudo su - cowrie

# 3. Clone Cowrie Repository
git clone http://github.com/cowrie/cowrie
# Cloning into 'cowrie'...
# remote: Counting objects: 2965, done.
# remote: Compressing objects: 100% (1025/1025), done.
# remote: Total 2965 (delta 1908), reused 2962 (delta 1905), pack-reused 0
# Receiving objects: 100% (2965/2965), 3.41 MiB | 2.57 MiB/s, done.
# Resolving deltas: 100% (1908/1908), done.
# Checking connectivity... done.
cd cowrie

# 4. Set Up Virtual Environment
pwd
# /home/cowrie/cowrie
python3 -m venv cowrie-env
# New python executable in ./cowrie/cowrie-env/bin/python
# Installing setuptools, pip, wheel...done.

# The configuration for Cowrie is stored in cowrie.cfg.dist and cowrie.cfg (located in cowrie/etc).
# Both files are read on startup, where entries from cowrie.cfg take precedence.
# To run with a standard configuration, there is no need to change anything. 

# 5. Starting Cowrie
source cowrie-env/bin/activate
# (cowrie-env) $ cowrie start
# Starting cowrie with extra arguments [] ...

# The SSH daemon runs on port 22 by default. Cowrie runs on port 2222 by default. To receive most traffic, Cowrie will need to listen on port 22.
# This requires two changes: First, If you have an existing SSHD on port 22 it will need to be moved to another port. Second, Cowrie will need to listen to requests on port 22.
# There are three methods to make Cowrie accessible on the default SSH port (22): iptables, authbind and setcap.

# Iptables method:
sudo iptables -t nat -A PREROUTING -p tcp --dport 22 -j REDIRECT --to-port 2222

# Authbind method:
sudo apt-get install authbind
sudo touch /etc/authbind/byport/22
sudo chown cowrie:cowrie /etc/authbind/byport/22
sudo chmod 770 /etc/authbind/byport/22
# Change the listening port to 22 in cowrie.cfg:
# [ssh]
# listen_endpoints = tcp:22:interface=0.0.0.0

# Setcap method:
setcap cap_net_bind_service=+ep /usr/bin/python3
# Change the listening port to 22 in cowrie.cfg:
# [ssh]
# listen_endpoints = tcp:22:interface=0.0.0.0

# Logs are written to: /var/log/cowrie/cowrie.log