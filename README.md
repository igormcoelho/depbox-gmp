# manydeps-gmp

[![CMake VCPKG on windows and linux](https://github.com/manydeps/manydeps-gmp/actions/workflows/cmake-multi-platform.yml/badge.svg)](https://github.com/manydeps/manydeps-gmp/actions/workflows/cmake-multi-platform.yml)

[![Bazel VCPKG on windows and linux](https://github.com/manydeps/manydeps-gmp/actions/workflows/bazel-vcpkg-win-linux.yml/badge.svg)](https://github.com/manydeps/manydeps-gmp/actions/workflows/bazel-vcpkg-win-linux.yml)

[![Bazel GMP Native on Windows, Linux and OSX-MACOS](https://github.com/manydeps/manydeps-gmp/actions/workflows/bazel-native-multi-platform.yml/badge.svg)](https://github.com/manydeps/manydeps-gmp/actions/workflows/bazel-native-multi-platform.yml)

[![Bazel GMP Conan on Windows, Linux and OSX-MACOS](https://github.com/manydeps/manydeps-gmp/actions/workflows/bazel-conan-multi-platform.yml/badge.svg)](https://github.com/manydeps/manydeps-gmp/actions/workflows/bazel-conan-multi-platform.yml)


This is a demonstration project from the [ManyDeps](https://github.com/manydeps),
for the C/C++ GMP library using package managers (vcpkg and conan) on windows/linux.

***If you want to learn more about this repo, please read the Medium text [Building Cross-platform C++ GMP library with VCPKG, CMake and Bazel: Lessons Learned](https://igormcoelho.medium.com/building-cross-platform-c-gmp-library-with-vcpkg-cmake-and-bazel-lessons-learned-ea2cba4b697d).***

This works fine on Windows Visual Studio 2022 and also Linux (including Windows WSL).
For Linux, the classic `gmp` library is used, but for Windows, the alternative `mpir`
is used (since `gmp` currently fails to build on Windows in this repo).

Basic setup in both platforms include: CMake and Ninja.
Also it is necessary to have vcpkg and conan, for the following scripts to work.

## Running the example on vcpkg

Please follow the next steps carefully.

### First step: get submodule dependencies

vcpkg is installed as shown in [vcpkg.io](vcpkg.io website), as a git submodule.

To get submodules, please run the following commands:

```
git submodule update --init --recursive
git pull --recurse-submodules
```

Check the folder [tools/vcpkg](tools/vcpkg) to see if vcpkg is present.

### Second step: get vcpkg dependencies

#### On Windows

On Windows Visual Studio, open the **Developer Command Prompt** and execute:

```
.\tools\vcpkg\bootstrap-vcpkg.bat
.\script-deps.bat
```

#### On Linux (or WSL)

On Linux (or WSL), just run:

```
./tools/vcpkg/bootstrap-vcpkg.sh 
./script-deps.sh
```

## Common errors

On Linux, sometimes dependencies are not fully available, so please double check:

### Latest CMake on Linux

```
python3 -m pip install --upgrade
```

### Ninja on Linux

```
apt-get install ninja-build
```

### General build dependencies on Linux

vcpkg requires some packages, such as pkg-config and autoconf:

```
apt-get install autoconf automake libtool pkg-config
```

## Using CMakePresets for IDE

Update your CMakePresets.json to include the desired toolchain.

### vcpkg toolchain

```{.json}
"toolchainFile": "${sourceDir}/deps/vcpkg/scripts/buildsystems/vcpkg.cmake",
```

Read more on vcpkg integration: https://learn.microsoft.com/pt-br/vcpkg/users/buildsystems/cmake-integration

### conan toolchain

Install conan with:

```
python3 -m pip install conan
```

Setup toolchain with cmake and conan:

```{.json}
"cacheVariables": {
    "CMAKE_BUILD_TYPE": "Release",
    "CMAKE_TOOLCHAIN_FILE": "build-conan/conan_toolchain.cmake"
},
```

## Discussion and common errors

The vcpkg tries to create some CMake toolchain with PkgConfig, 
in order to get dependencies.
We try to build them as **STATIC** libraries: 
`libgmp.a` (on linux) and `gmp.lib` (on windows).

This is the expected configuration after `vcpkg install`:

```
[cmake]     #  gmp
[cmake]     find_package(PkgConfig REQUIRED)
[cmake]     pkg_check_modules(gmp REQUIRED IMPORTED_TARGET gmp)
[cmake]     target_link_libraries(main PkgConfig::gmp)
[cmake] 
[cmake]     # gmpxx
[cmake]     find_package(PkgConfig REQUIRED)
[cmake]     pkg_check_modules(gmpxx REQUIRED IMPORTED_TARGET gmpxx)
[cmake]     target_link_libraries(main PkgConfig::gmpxx)
```

However, this failed in both Linux and Windows (in our experiments here),
 so we need to make some adjustments (**A LOT OF ADJUSTMENTS FOR WINDOWS**).

### Trying to understand the errors

The idea is to load packages locally on `build/vcpkg_installed/` folder 
(generated by vcpkg on our `script-deps`).

We still could not fully understand why it fails so bad in Windows,
but it seems that some files such as `gmp.pc` are missing!
For Linux they exist on `build/vcpkg_installed/x64-linux/lib/pkgconfig/` folder.

If you find a better solution, please Let Us Know!

## Testing with Bazel

```
vcpkg install
# will generate local folder vcpkg_installed

bazel run @hedron_compile_commands//:refresh_all
# will generate local compile_commands.json

bazel build ... --config linux

bazel test ... --config windows
```

Note some important flags on .bazelrc file.
On windows, there are two types of `.lib` library, so we assume here that GMP/MPIR is built with `/MT` flag, 
meaning that we need to add `static_link_msvcrt` configuration on .bazelrc:

- `build:windows     --cxxopt=/std:c++17 --cxxopt=/MT --linkopt=/NODEFAULTLIB:MSVCRT --features=static_link_msvcrt`

## Testing with GitHub Actions

Ongoing work...

## License

## License

[GPLv3+ License](https://www.gnu.org/licenses/gpl-3.0.html)

(... or at your choice)

[LGPLv3+ License](https://www.gnu.org/licenses/lgpl-3.0.html)

License is a combination of:

- GMP (GPL-2.0-or-later OR LGPL-3.0-or-later)
