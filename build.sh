#!/bin/bash

cd libusb-1.0.19
./configure --prefix=/usr/local
make
sudo make install
cd ..

cd libusb-compat-0.1.5
./configure --prefix=/usr/local
make
sudo make install
cd ..

cd libhid-0.2.16
./configure --prefix=/usr/local
make
sudo make install
cd ..

cd ultrastikcmd-0.2
./configure --prefix=/usr/local
make
sudo make install
cd ..

sudo ldconfig
