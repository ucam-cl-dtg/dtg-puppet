#!/bin/bash

echo "** Cleaning out old venv **"
rm -rf venv

echo "** Setting up default sensible python2.7 venv **"
virtualenv venv

echo "** Setting up links to external deps **"
ln -s /usr/lib/python2.7/dist-packages/numpy venv/lib/python2.7/site-packages/numpy
ln -s /usr/lib/python2.7/dist-packages/numpy-*.egg-info venv/lib/python2.7/site-packages/
ln -s /usr/lib/python2.7/dist-packages/scipy venv/lib/python2.7/site-packages/scipy 
ln -s /usr/lib/python2.7/dist-packages/scipy-*.egg-info venv/lib/python2.7/site-packages/
ln -s /usr/lib/python2.7/dist-packages/zmq venv/lib/python2.7/site-packages/zmq

echo "** Activating venv **"
source venv/bin/activate

echo "** Installing requirements.txt **"
pip install -r requirements.txt

