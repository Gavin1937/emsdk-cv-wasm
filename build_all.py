from os import system
import json


if __name__ == '__main__':
    config = None
    with open('docker-image-config.json', 'r') as file:
        config = json.load(file)
    
    images = [{'version':v,'platform':p} for p in config['platforms'] for v in config['opencv-versions']]
    print(images)
    
    for img in images:
        ver = img['version']
        plat = img['platform']
        cmd = None
        if plat.lower() == 'linux64':
            cmd = f' docker build -t gavin1937/emsdk-cv-wasm:{ver} --build-arg="VERSION={ver}" . '
        else:
            cmd = f' docker build -t gavin1937/emsdk-cv-wasm:{ver}-{plat} --build-arg="VERSION={ver}" . '
        print('\n\n'+cmd)
        system(cmd)
