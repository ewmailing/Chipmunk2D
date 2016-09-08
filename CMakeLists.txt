cmake_minimum_required(VERSION 2.6)
cmake_policy(SET CMP0001 NEW) # don't use MAKE_BACKWARDS_COMPATIBILITY but policies instead

project(chipmunk)
set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/CMakeModules/" ${CMAKE_MODULE_PATH})
include(CMakeDependentOption)

# to change the prefix, run cmake with the parameter:
#   -D CMAKE_INSTALL_PREFIX=/my/prefix

# to change the build type, run cmake with the parameter:
#   -D CMAKE_BUILD_TYPE=<build-type>
# run "cmake --help-variable CMAKE_BUILD_TYPE" for details
if(NOT CMAKE_BUILD_TYPE)
  SET(CMAKE_BUILD_TYPE Release CACHE STRING
      "Choose the type of build, options are: None Debug Release RelWithDebInfo MinSizeRel."
      FORCE)
endif()

# to manually select install locations of libraries and executables
#   -D LIB_INSTALL_DIR mylib
#   -D BIN_INSTALL_DIR newbin
set(LIB_INSTALL_DIR lib CACHE STRING "Install location of libraries")
set(BIN_INSTALL_DIR bin CACHE STRING "Install location of executables")

# other options for the build, you can i.e. activate the shared library by passing
#   -D BUILD_SHARED=ON
# to cmake. Other options analog
if(ANDROID)
  option(BUILD_DEMOS "Build the demo applications" OFF)
  option(INSTALL_DEMOS "Install the demo applications" OFF)
  option(BUILD_SHARED "Build and install the shared library" ON)
  option(BUILD_STATIC "Build as static library" ON)
  option(INSTALL_STATIC "Install the static library" OFF)
elseif(APPLE)
  # TODO: When iOS 7 is gone, consider switching to framework
  if(IOS)
    option(BUILD_SHARED "Build dynamic library" OFF)
    option(BUILD_STATIC "Build as static library" ON)
    option(BUILD_DEMOS "Build the demo applications" OFF)
    option(INSTALL_DEMOS "Install the demo applications" OFF)
	option(INSTALL_STATIC "Install the static library" OFF)
  else()
    OPTION(BUILD_SHARED "Build dynamic library" ON)
    CMAKE_DEPENDENT_OPTION(BUILD_FRAMEWORK "Set to ON to build framework instead of dylib. Only valid if BUILD_SHARED is ON an is OS X." ON "BUILD_SHARED" ON)
	option(BUILD_STATIC "Build as static library" ON)
    option(BUILD_DEMOS "Build the demo applications" ON)
	option(INSTALL_DEMOS "Install the demo applications" OFF)
	option(INSTALL_STATIC "Install the static library" OFF)
  endif()
else()
  option(BUILD_DEMOS "Build the demo applications" ON)
  option(INSTALL_DEMOS "Install the demo applications" OFF)
  option(BUILD_SHARED "Build and install the shared library" ON)
  option(BUILD_STATIC "Build as static library" ON)
  option(INSTALL_STATIC "Install the static library" ON)
endif()

# Visual Studio's C compiler sucks, but VS2013 Update 4 makes it tolerable.
# Compiling C as C++ can cause problems particularly with libraries and linkage.
# It generally should be avoided when possible.
if(MSVC)
	option(BUILD_AS_CPP "Compile source code as C++ instead of C" OFF)
endif(MSVC)


if(CMAKE_C_COMPILER_ID STREQUAL "Clang")
  option(FORCE_CLANG_BLOCKS "Force enable Clang blocks" YES)
endif()

# sanity checks...
if(INSTALL_DEMOS)
  set(BUILD_DEMOS ON FORCE)
endif()

# these need the static lib too
if(BUILD_DEMOS OR INSTALL_STATIC)
  set(BUILD_STATIC ON FORCE)
endif()

if(NOT MSVC)
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=gnu99") # always use gnu99
  if(FORCE_CLANG_BLOCKS)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fblocks")
  endif()
  set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -ffast-math") # extend release-profile with fast-math
  set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -Wall") # extend debug-profile with -Wall
endif()


# A bug report from Arch Linux + gcc 6 is getting unresolved symbol problems on libpthread.
if(UNIX AND NOT APPLE AND NOT ANDROID)
	set(CMAKE_THREAD_PREFER_PTHREAD TRUE)
	set(THREADS_PREFER_PTHREAD_FLAG TRUE)
	find_package(Threads REQUIRED)
	if(CMAKE_USE_PTHREADS_INIT)
		set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -pthread")
	endif()
	set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} ${CMAKE_THREAD_LIBS_INIT}")
endif()

add_subdirectory(src)

if(BUILD_DEMOS)
  add_subdirectory(demo)
endif()
