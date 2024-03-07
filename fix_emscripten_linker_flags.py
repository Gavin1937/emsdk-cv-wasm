# ############################################################# #
#                                                               #
# When compiling OpenCV.js with script                          #
# `platforms/js/build_js.py`, its argument `--build_flags` for  #
# changing emscripten linker flags will be override by          #
# CMakeLists file. Thus, in order to make linker flags to work  #
# for emscripten, we need to modify `modules/js/CMakeLists.txt` #
# file. This script allows you to insert a new line or          #
# replace a line in the CMakeLists.txt                          #
#                                                               #
# ############################################################# #
import sys, os, re


def insert_on_top(pattern, data, linker_flag) -> str:
    output = None
    match = re.search(pattern, data)
    if match:
        idx = match.span()[0]
        output = data[:idx] + linker_flag + data[idx:]
    else:
        raise ValueError('Cannot find `set_target_properties` function')
    return output

def replace_pattern_with(pattern, data, linker_flag) -> str:
    return re.sub(pattern, linker_flag, data)

if __name__ == '__main__':
    try:
        if len(sys.argv) != 2:
            print('Usage: python3 fix_emscripten_linker_flags.py "/path/to/opencv/modules/js/CMakeLists.txt"')
            exit(0)
        
        cmake_file = sys.argv[1]
        if not os.path.exists(cmake_file):
            raise ValueError('Input CMakeLists.txt file does not exists.')
        cmake_file = os.path.abspath(cmake_file)
        linker_flag = 'set(EMSCRIPTEN_LINK_FLAGS "${EMSCRIPTEN_LINK_FLAGS} -s TOTAL_MEMORY=128MB -s WASM_MEM_MAX=2GB -s ALLOW_MEMORY_GROWTH=1")\n'
        output = None
        
        print('Found CMakeLists file: %s' % cmake_file)
        print('Injecting emscripten linker flags:\n%s' % linker_flag)
        
        with open(cmake_file, 'r', encoding='utf-8') as file:
            data = file.read()
            
            # pattern = r'set_target_properties\(.*EMSCRIPTEN_LINK_FLAGS.*\)'
            # insert_on_top(pattern, data, linker_flag)
            
            pattern = r'set\(EMSCRIPTEN_LINK_FLAGS.*--memory-init-file.*\)'
            output = replace_pattern_with(pattern, data, linker_flag)
        
        if output:
            print('Writing to CMakeLists file: %s' % cmake_file)
            with open(cmake_file, 'w', encoding='utf-8') as file:
                file.write(output)
        else:
            raise ValueError('Output string is empty')
        
        print('Done')
    except KeyboardInterrupt:
        print()
        exit(-1)
    except Exception as err:
        raise err
    
