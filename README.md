# Network Impairments Simulator

### Introduction

A simple script for simulating network impairments such as delay, packet loss and jitter. 

### Prerequisites

My script is based on the iproute package which usually comes preinstalled with all modern Linux distributions. In case it is not installed on your machine you can install it easily using the package manager or compile it from [source](https://github.com/shemminger/iproute2):
```
git clone https://github.com/shemminger/iproute2.git
```
A good guide of the iproute functionality could be find [here](https://wiki.linuxfoundation.org/networking/netem "IPROUTE Usage Guide") 

### Usage examples

You can run the software by executing the script and filling and defining the Ethernet interface, the time delay and jitter in miliseconds and the packet loss in percentage. Afterwards it asks you for confirmation:

```
$ ./netem.sh
Welcome to the network simulator:

Here is a list of your network interfaces:

eno1  XXX.XXX.XXX.XXX
eno2  XXX.XXX.XXX.XXX
eno3  XXX.XXX.XXX.XXX

Please select the network interface you want to use:
eno3
Please define the time delay in [ms]:
100
Please define the jitter in [ms]:
50
Please define the packet loss in [%]:
10

These are the set parameters:

Network interface:      eno3
Delay:                  100ms
Jitter:                 50ms
Packet Loss:            10%

Please confirm that these values are correct [Y/n]:
y

These are the set parameters:

Network interface:      eno3
Delay:                  100ms
Jitter:                 50ms
Packet Loss:            10%

```
I have created couple of checks so that the script won't accept invalid network port or packet loss higher than 100%. 

The second script in the directory, `random_netsim.sh` is actually applying a random packet loss, jitter and time delay between 0 and user defined thresholds defined by the user. It is very similar to `netsim.sh` and the idea is to run for a longer period of time simulating different randomly generated network impairments. 

### Similar Software

This script is similar to [WANEM](http://wanem.sourceforge.net/) but more limited in functionality, since it is supporting only packet loss, jitter and time delay. On the other hand I found that WANEM is not working properly on newer hardware.

### Future development

I was thinking to create a simple web Interface and even a docker container which will streamline the deployment.

### Bugs and Missing Features

In Ubuntu 18.04 the generation of the jitter doesn't seem to work properly. For some reason it is creating delay in some packets for more than 4 seconds and also if you define delay 200ms and jitt
er 100ms the RTT is always greater than 200ms, instead of varying between 100ms and 300ms. I think in Ubuntu 16.04 the jitter is working properly, but you have to check for yourself.

For additional bugs, please use Github Issues in case you spot a bug or have an idea how to optimize the scripts.

### External Links

* [IPROUTE2](https://github.com/shemminger/iproute2 "IPROUTE Official Github Page") 
* [IPROUTE Usage Guide](https://wiki.linuxfoundation.org/networking/netem "IPROUTE Usage Guide")
* [WANEM](http://wanem.sourceforge.net/ "WANEM official website")
