from os import system

if __name__ == '__main__':
    lines = None
    with open('opencv-version-idx.txt', 'r') as file:
        lines = file.readlines()
    
    for l in lines:
        l = l.strip()
        cmd = f' docker build -t gavin1937/emsdk-cv-wasm:{l} --build-arg="VERSION={l}" . '
        print('\n\n'+cmd)
        system(cmd)
