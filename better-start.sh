#!/bin/bash

source /apps/tvb-hip/setup-env.sh
export HOME=/home/$(whoami)
echo "HOME is $HOME"
cp /apps/tvb/hip-tvb-app*/*.ipynb $HOME/
cp -r /apps/tvb/hip-tvb-app*/tvb-pipeline $HOME/

# electron doesn't propagate environment to jlab, so
# we need to workaround it with .bashrc and .pythonrc
echo 'export HOME=/home/$(whoami)' > /home/$(whoami)/.bashrc
echo 'source /apps/tvb-hip/setup-env.sh' >> /home/$(whoami)/.bashrc

# create kernel with custom env vars 
# TODO python script to handle this
python3 -m ipykernel install --user --name TVB
echo '{
 "argv": [
  "/apps/tvb-hip/jlab_server/bin/python3",
  "-m",
  "ipykernel_launcher",
  "-f",
  "{connection_file}"
 ],
 "display_name": "TVB",
 "language": "python",
 "metadata": {
  "debugger": true
 },' > ~/.local/share/jupyter/kernels/tvb/kernel.json
echo "
  \"env\": { \"HOME\": \"$HOME\" }
}" >> ~/.local/share/jupyter/kernels/tvb/kernel.json

jlab=/apps/tvb-hip/jupyterlab_app
$jlab/node_modules/electron/dist/electron --no-sandbox $jlab